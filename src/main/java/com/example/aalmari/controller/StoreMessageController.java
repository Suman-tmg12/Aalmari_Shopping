package com.example.aalmari.controller;

import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.StoreMessage;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.StoreMessageRepository;
import com.example.aalmari.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.format.DateTimeFormatter;
import java.util.*;

@RestController
public class StoreMessageController {

    private final StoreMessageRepository messageRepository;
    private final SellerProductRepository productRepository;
    private final UserRepository userRepository;

    public StoreMessageController(StoreMessageRepository messageRepository,
                                  SellerProductRepository productRepository,
                                  UserRepository userRepository) {
        this.messageRepository = messageRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

    public record MessageRequest(String subject, String body) {}

    @PostMapping("/api/products/{id}/messages")
    public ResponseEntity<?> sendMessage(@PathVariable Long id,
                                         @RequestBody MessageRequest request,
                                         HttpSession session) {
        Object userIdValue = session.getAttribute("userId");
        if (!(userIdValue instanceof Number number)) {
            return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));
        }

        Optional<SellerProduct> productOpt = productRepository.findById(id);
        if (productOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Product not found."));
        }

        SellerProduct product = productOpt.get();
        if (product.getSeller() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "This product has no seller."));
        }

        Long customerId = number.longValue();
        if (customerId.equals(product.getSeller().getId())) {
            return ResponseEntity.badRequest().body(Map.of("error", "Sellers cannot message a product from their own store."));
        }

        Optional<User> customerOpt = userRepository.findById(customerId);
        if (customerOpt.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "Session user is invalid."));
        }

        String subject = request == null || request.subject() == null ? "" : request.subject().trim();
        String body = request == null || request.body() == null ? "" : request.body().trim();
        if (subject.isEmpty()) subject = "Question about " + product.getName();
        if (body.isEmpty()) return ResponseEntity.badRequest().body(Map.of("error", "Message cannot be empty."));
        if (subject.length() > 120) return ResponseEntity.badRequest().body(Map.of("error", "Subject is too long."));
        if (body.length() > 2000) return ResponseEntity.badRequest().body(Map.of("error", "Message is too long."));

        StoreMessage message = new StoreMessage();
        message.setCustomer(customerOpt.get());
        message.setSeller(product.getSeller());
        message.setProduct(product);
        message.setSender(customerOpt.get());
        message.setSubject(subject);
        message.setBody(body);
        message.setUnreadForSeller(true);
        message.setUnreadForCustomer(false);
        messageRepository.save(message);

        return ResponseEntity.ok(Map.of("success", true, "message", "Your message was sent to the seller."));
    }

    @GetMapping("/api/seller/messages/conversations")
    public ResponseEntity<?> conversations(HttpSession session) {
        Long sellerId = sessionUserId(session);
        if (sellerId == null) return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));

        List<StoreMessage> newest = messageRepository.findForSellerNewest(sellerId);
        Map<String, StoreMessage> latestByThread = new LinkedHashMap<>();
        for (StoreMessage message : newest) {
            String key = message.getCustomer().getId() + ":" + message.getProduct().getId();
            latestByThread.putIfAbsent(key, message);
        }

        List<Map<String, Object>> conversations = new ArrayList<>();
        for (StoreMessage latest : latestByThread.values()) {
            List<StoreMessage> thread = messageRepository.findThread(sellerId,
                    latest.getCustomer().getId(), latest.getProduct().getId());
            boolean unread = thread.stream().anyMatch(StoreMessage::isUnreadForSeller);
            String customerName = safeName(latest.getCustomer());
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("customerId", latest.getCustomer().getId());
            item.put("productId", latest.getProduct().getId());
            item.put("productName", latest.getProduct().getName());
            item.put("name", customerName);
            item.put("subject", latest.getSubject());
            item.put("time", formatTime(latest.getCreatedAt()));
            item.put("unread", unread);
            item.put("preview", latest.getBody());
            conversations.add(item);
        }
        return ResponseEntity.ok(conversations);
    }

    public record ReplyRequest(Long customerId, Long productId, String body) {}

    @GetMapping("/api/seller/messages/thread")
    public ResponseEntity<?> thread(@RequestParam Long customerId,
                                    @RequestParam Long productId,
                                    HttpSession session) {
        Long sellerId = sessionUserId(session);
        if (sellerId == null) return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));

        List<StoreMessage> messages = messageRepository.findThread(sellerId, customerId, productId);
        for (StoreMessage message : messages) {
            if (message.isUnreadForSeller()) {
                message.setUnreadForSeller(false);
                messageRepository.save(message);
            }
        }

        List<Map<String, Object>> thread = new ArrayList<>();
        for (StoreMessage message : messages) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("me", message.getSender().getId().equals(sellerId));
            item.put("text", message.getBody());
            item.put("time", formatTime(message.getCreatedAt()));
            item.put("senderName", safeName(message.getSender()));
            thread.add(item);
        }
        return ResponseEntity.ok(thread);
    }

    @GetMapping("/api/products/{id}/messages/thread")
    public ResponseEntity<?> customerThread(@PathVariable Long id, HttpSession session) {
        Long customerId = sessionUserId(session);
        if (customerId == null) return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));

        Optional<SellerProduct> productOpt = productRepository.findById(id);
        if (productOpt.isEmpty()) return ResponseEntity.badRequest().body(Map.of("error", "Product not found."));

        List<StoreMessage> messages = messageRepository.findCustomerThread(customerId, id);
        for (StoreMessage message : messages) {
            if (message.isUnreadForCustomer()) {
                message.setUnreadForCustomer(false);
                messageRepository.save(message);
            }
        }

        List<Map<String, Object>> thread = new ArrayList<>();
        for (StoreMessage message : messages) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("me", message.getSender().getId().equals(customerId));
            item.put("seller", message.getSender().getId().equals(productOpt.get().getSeller().getId()));
            item.put("text", message.getBody());
            item.put("time", formatTime(message.getCreatedAt()));
            item.put("senderName", safeName(message.getSender()));
            thread.add(item);
        }
        return ResponseEntity.ok(thread);
    }

    @GetMapping("/api/messages/unread-count")
    public ResponseEntity<?> customerUnreadCount(HttpSession session) {
        Long customerId = sessionUserId(session);
        if (customerId == null) return ResponseEntity.status(401).body(Map.of("count", 0));
        return ResponseEntity.ok(Map.of("count", messageRepository.countByCustomer_IdAndUnreadForCustomerTrue(customerId)));
    }

    @PostMapping("/api/seller/messages/reply")
    public ResponseEntity<?> reply(@RequestBody ReplyRequest request, HttpSession session) {
        Long sellerId = sessionUserId(session);
        if (sellerId == null) return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));
        if (request == null || request.customerId() == null || request.productId() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "Conversation details are required."));
        }

        String body = request.body() == null ? "" : request.body().trim();
        if (body.isEmpty()) return ResponseEntity.badRequest().body(Map.of("error", "Reply cannot be empty."));
        if (body.length() > 2000) return ResponseEntity.badRequest().body(Map.of("error", "Reply is too long."));

        Optional<User> sellerOpt = userRepository.findById(sellerId);
        Optional<User> customerOpt = userRepository.findById(request.customerId());
        Optional<SellerProduct> productOpt = productRepository.findById(request.productId());
        if (sellerOpt.isEmpty() || customerOpt.isEmpty() || productOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Conversation not found."));
        }
        SellerProduct product = productOpt.get();
        if (product.getSeller() == null || !sellerId.equals(product.getSeller().getId())) {
            return ResponseEntity.status(403).body(Map.of("error", "You cannot reply to another seller's conversation."));
        }

        List<StoreMessage> existing = messageRepository.findThread(sellerId, request.customerId(), request.productId());
        if (existing.isEmpty()) return ResponseEntity.badRequest().body(Map.of("error", "Conversation not found."));

        StoreMessage reply = new StoreMessage();
        reply.setCustomer(customerOpt.get());
        reply.setSeller(sellerOpt.get());
        reply.setProduct(product);
        reply.setSender(sellerOpt.get());
        reply.setSubject(existing.getLast().getSubject());
        reply.setBody(body);
        reply.setUnreadForSeller(false);
        reply.setUnreadForCustomer(true);
        messageRepository.save(reply);
        return ResponseEntity.ok(Map.of("success", true, "time", formatTime(reply.getCreatedAt())));
    }

    private Long sessionUserId(HttpSession session) {
        Object value = session.getAttribute("userId");
        return value instanceof Number number ? number.longValue() : null;
    }

    private String safeName(User user) {
        String first = user.getFirstName() == null ? "" : user.getFirstName().trim();
        String last = user.getLastName() == null ? "" : user.getLastName().trim();
        String name = (first + " " + last).trim();
        return name.isEmpty() ? "Customer" : name;
    }

    private String formatTime(java.time.LocalDateTime time) {
        if (time == null) return "";
        return time.format(DateTimeFormatter.ofPattern("MMM d, h:mm a", Locale.ENGLISH));
    }
}

