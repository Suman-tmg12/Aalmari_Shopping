package com.example.aalmari.service;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.dto.CheckoutForm;
import com.example.aalmari.model.Address;
import com.example.aalmari.model.Order;
import com.example.aalmari.model.OrderItem;
import com.example.aalmari.model.Payment;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.AddressRepository;
import com.example.aalmari.repository.CartItemRepository;
import com.example.aalmari.repository.OrderRepository;
import com.example.aalmari.repository.PaymentRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.UserRepository;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.LinkedHashMap;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;

@Service
public class EsewaPaymentService {

    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;
    private final CartService cartService;
    private final CartItemRepository cartItemRepository;
    private final AddressRepository addressRepository;
    private final SellerProductRepository productRepository;
    private final UserRepository userRepository;
    private final FlashSaleService flashSaleService;
    private final ObjectMapper mapper = new ObjectMapper();
    private final RestTemplate restTemplate = new RestTemplate();

    @Value("${esewa.product-code}") private String productCode;
    @Value("${esewa.secret-key}") private String secretKey;
    @Value("${esewa.form-url}") private String formUrl;
    @Value("${esewa.status-url}") private String statusUrl;
    @Value("${esewa.success-url}") private String successUrl;
    @Value("${esewa.failure-url}") private String failureUrl;

    public EsewaPaymentService(OrderRepository orderRepository,
                               PaymentRepository paymentRepository,
                               CartService cartService,
                               CartItemRepository cartItemRepository,
                               AddressRepository addressRepository,
                               SellerProductRepository productRepository,
                               UserRepository userRepository,
                               FlashSaleService flashSaleService) {
        this.orderRepository = orderRepository;
        this.paymentRepository = paymentRepository;
        this.cartService = cartService;
        this.cartItemRepository = cartItemRepository;
        this.addressRepository = addressRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
        this.flashSaleService = flashSaleService;
    }

    public record EsewaForm(Map<String, String> fields, String formUrl) {}

    @Transactional
    public EsewaForm initiate(Long userId, CheckoutForm f, HttpSession session) {
        CartView cart;
        Object buyProduct = session.getAttribute("buyNowProductId");
        Object buyQuantity = session.getAttribute("buyNowQuantity");
        if (buyProduct instanceof Number productNumber && buyQuantity instanceof Number quantityNumber) {
            cart = cartService.buyNowView(userId, productNumber.longValue(), quantityNumber.intValue());
        } else {
            cart = cartService.view(userId);
        }

        if (cart.getItems().isEmpty()) throw new IllegalStateException("Your cart is empty.");
        if (f.getAddressId() == null) throw new IllegalStateException("Please choose a delivery address.");

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("Please log in again."));
        Address address = addressRepository.findByIdAndUser_Id(f.getAddressId(), userId)
                .orElseThrow(() -> new IllegalStateException("Please choose a delivery address."));

        String transactionUuid = UUID.randomUUID().toString();

        Order order = new Order();
        order.setUser(user);
        order.setStatus("PENDING_PAYMENT");
        order.setPaymentMethod("ESEWA");
        order.setPaymentStatus("PENDING");
        order.setTransactionUuid(transactionUuid);
        order.setSubtotal(cart.getSubtotal());
        order.setDiscountAmount(cart.getDiscountAmount());
        order.setDeliveryFee(cart.getDeliveryFee());
        order.setTotal(cart.getTotal());
        order.setReceiverName(address.getReceiverName());
        order.setReceiverPhone(address.getPhone());
        order.setProvince(address.getProvince());
        order.setCity(address.getCity());
        order.setAddress(address.getStreet());
        order.setLandmark(blank(address.getLandmark()));
        order.setNote(blank(f.getOrderNote()));

        for (CartView.Line line : cart.getItems()) {
            SellerProduct product = productRepository.findById(line.getProductId())
                    .filter(p -> Boolean.TRUE.equals(p.getActive()))
                    .orElseThrow(() -> new IllegalStateException(line.getName() + " is no longer available."));
            if (product.getSeller() != null && product.getSeller().getId() != null
                    && product.getSeller().getId().equals(userId)) {
                throw new IllegalStateException("You cannot purchase a product that you sell.");
            }
            int stock = product.getStock() == null ? 0 : product.getStock();
            if (stock < line.getQuantity()) {
                throw new IllegalStateException(stock == 0
                        ? line.getName() + " is out of stock."
                        : "Only " + stock + " of " + line.getName() + " left in stock.");
            }

            OrderItem item = new OrderItem();
            item.setProductId(line.getProductId());
            item.setSeller(product.getSeller());
            item.setStatus("PENDING");
            item.setName(line.getName());
            item.setImageUrl(line.getImageUrl());
            item.setUnitPrice(line.getUnitPrice());
            item.setOriginalPrice(line.getOriginalPrice());
            item.setQuantity(line.getQuantity());
            item.setLineTotal(line.getUnitPrice() * line.getQuantity());
            order.addItem(item);
        }

        orderRepository.save(order);
        order.setOrderNumber(String.format("AAL-%06d", order.getId()));
        orderRepository.save(order);
        session.setAttribute("pendingEsewaUuid", transactionUuid);

        long payable = cart.getTotal() - cart.getDeliveryFee();
        if (payable < 0) payable = 0;

        Map<String, String> fields = new LinkedHashMap<>();
        fields.put("amount", money(payable));
        fields.put("tax_amount", "0");
        fields.put("total_amount", money(cart.getTotal()));
        fields.put("transaction_uuid", transactionUuid);
        fields.put("product_code", productCode);
        fields.put("product_service_charge", "0");
        fields.put("product_delivery_charge", money(cart.getDeliveryFee()));
        fields.put("success_url", successUrl);
        fields.put("failure_url", failureUrl);
        fields.put("signed_field_names", "total_amount,transaction_uuid,product_code");
        fields.put("signature", sign("total_amount=" + money(cart.getTotal())
                + ",transaction_uuid=" + transactionUuid
                + ",product_code=" + productCode));

        return new EsewaForm(fields, formUrl);
    }

    @Transactional
    public Order verifySuccess(Long userId, String encodedData) {
        if (encodedData == null || encodedData.isBlank()) {
            throw new IllegalArgumentException("Payment response is missing.");
        }

        JsonNode response;
        try {
            byte[] decoded = Base64.getDecoder().decode(encodedData);
            response = mapper.readTree(new String(decoded, StandardCharsets.UTF_8));
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid eSewa payment response.");
        }

        String transactionUuid = text(response, "transaction_uuid");
        String transactionCode = text(response, "transaction_code");
        String status = text(response, "status");
        String totalAmount = text(response, "total_amount");
        if (transactionUuid.isEmpty()) throw new IllegalArgumentException("Invalid eSewa transaction.");

        Order order = orderRepository.findByTransactionUuid(transactionUuid)
                .orElseThrow(() -> new IllegalArgumentException("Payment transaction was not found."));
        if (!order.getUser().getId().equals(userId)) {
            throw new SecurityException("You cannot confirm another buyer's order.");
        }

        if ("PAID".equals(order.getPaymentStatus())) return order;

        verifyResponseSignature(response);

        Map<String, Object> statusResponse;
        try {
            String uri = UriComponentsBuilder.fromUriString(statusUrl)
                    .queryParam("product_code", productCode)
                    .queryParam("total_amount", money(order.getTotal()))
                    .queryParam("transaction_uuid", transactionUuid)
                    .build().encode().toUriString();
            statusResponse = restTemplate.getForObject(uri, Map.class);
        } catch (Exception e) {
            throw new IllegalStateException("Could not verify the eSewa payment. Please try again.");
        }

        if (statusResponse == null
                || !"COMPLETE".equalsIgnoreCase(String.valueOf(statusResponse.get("status")))) {
            throw new IllegalArgumentException("The eSewa payment is not complete.");
        }

        String checkedUuid = String.valueOf(statusResponse.getOrDefault("transaction_uuid", transactionUuid));
        if (!transactionUuid.equals(checkedUuid)) {
            throw new IllegalArgumentException("The eSewa transaction does not match this order.");
        }

        String checkedAmount = String.valueOf(statusResponse.getOrDefault("total_amount", totalAmount));
        if (!sameAmount(checkedAmount, order.getTotal()) || !sameAmount(totalAmount, order.getTotal())) {
            throw new IllegalArgumentException("The eSewa payment amount does not match this order.");
        }
        if (!"COMPLETE".equalsIgnoreCase(status)) {
            throw new IllegalArgumentException("The eSewa payment is not complete.");
        }

        return confirmPaid(order, transactionCode, response.toString());
    }

    @Transactional
    public Order confirmPaid(Order order, String transactionCode, String rawResponse) {
        if ("PAID".equals(order.getPaymentStatus())) return order;

        for (OrderItem item : order.getItems()) {
            SellerProduct product = productRepository.findById(item.getProductId())
                    .orElseThrow(() -> new IllegalStateException(item.getName() + " is no longer available."));
            int stock = product.getStock() == null ? 0 : product.getStock();
            if (stock < item.getQuantity()) {
                throw new IllegalStateException(item.getName() + " is out of stock.");
            }

            flashSaleService.claim(order.getUser().getId(), item.getProductId(), item.getQuantity());
            product.setStock(stock - item.getQuantity());
            product.setSold((product.getSold() == null ? 0 : product.getSold()) + item.getQuantity());
            productRepository.save(product);
            item.setStatus("PENDING");
        }

        order.setStatus("CONFIRMED");
        order.setPaymentStatus("PAID");
        order.setPaymentReference(transactionCode);
        orderRepository.save(order);

        cartItemRepository.deleteAll(cartItemRepository.findByUser_IdOrderByIdDesc(order.getUser().getId()));

        Payment payment = new Payment();
        payment.setOrder(order);
        payment.setProvider("ESEWA");
        payment.setTransactionUuid(order.getTransactionUuid());
        payment.setTransactionCode(transactionCode);
        payment.setStatus("PAID");
        payment.setAmount(order.getTotal());
        payment.setRawResponse(rawResponse);
        paymentRepository.save(payment);
        return order;
    }

    @Transactional
    public Order markFailure(Long userId, String encodedData, HttpSession session) {
        String transactionUuid = null;
        if (encodedData != null && !encodedData.isBlank()) {
            try {
                JsonNode response = mapper.readTree(new String(Base64.getDecoder().decode(encodedData), StandardCharsets.UTF_8));
                transactionUuid = text(response, "transaction_uuid");
            } catch (Exception ignored) {}
        }
        if (transactionUuid == null || transactionUuid.isBlank()) {
            Object stored = session.getAttribute("pendingEsewaUuid");
            if (stored != null) transactionUuid = stored.toString();
        }

        if (transactionUuid == null || transactionUuid.isBlank()) {
            throw new IllegalArgumentException("Payment transaction was not found.");
        }
        Order order = orderRepository.findByTransactionUuid(transactionUuid)
                .orElseThrow(() -> new IllegalArgumentException("Payment transaction was not found."));
        if (!order.getUser().getId().equals(userId)) {
            throw new SecurityException("You cannot cancel another buyer's order.");
        }

        if (!"PAID".equals(order.getPaymentStatus())) {
            order.setStatus("PAYMENT_FAILED");
            order.setPaymentStatus("FAILED");
            for (OrderItem item : order.getItems()) item.setStatus("CANCELLED");
            orderRepository.save(order);

            Payment payment = new Payment();
            payment.setOrder(order);
            payment.setProvider("ESEWA");
            payment.setTransactionUuid(transactionUuid);
            payment.setStatus("FAILED");
            payment.setAmount(order.getTotal());
            payment.setRawResponse(encodedData);
            paymentRepository.save(payment);
        }
        session.removeAttribute("pendingEsewaUuid");
        return order;
    }

    @Scheduled(fixedDelay = 300000)
    @Transactional
    public void reverifyPendingOrders() {
        for (Order order : orderRepository.findByStatusAndPaymentMethod("PENDING_PAYMENT", "ESEWA")) {
            if (order.getCreatedAt() != null
                    && order.getCreatedAt().isBefore(LocalDateTime.now().minusMinutes(30))) {
                try {
                    Map<String, Object> statusResponse = checkStatus(order);
                    if (statusResponse != null && "COMPLETE".equalsIgnoreCase(String.valueOf(statusResponse.get("status")))
                            && sameAmount(String.valueOf(statusResponse.getOrDefault("total_amount", "")), order.getTotal())) {
                        confirmPaid(order, String.valueOf(statusResponse.getOrDefault("transaction_code", "")), statusResponse.toString());
                        continue;
                    }
                } catch (Exception ignored) {}

                order.setStatus("PAYMENT_FAILED");
                order.setPaymentStatus("FAILED");
                for (OrderItem item : order.getItems()) item.setStatus("CANCELLED");
                orderRepository.save(order);
            }
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> checkStatus(Order order) {
        String uri = UriComponentsBuilder.fromUriString(statusUrl)
                .queryParam("product_code", productCode)
                .queryParam("total_amount", money(order.getTotal()))
                .queryParam("transaction_uuid", order.getTransactionUuid())
                .build().encode().toUriString();
        return restTemplate.getForObject(uri, Map.class);
    }

    private void verifyResponseSignature(JsonNode response) {
        String signedNames = text(response, "signed_field_names");
        String receivedSignature = text(response, "signature");
        if (signedNames.isEmpty() || receivedSignature.isEmpty()) {
            throw new IllegalArgumentException("The eSewa response signature is missing.");
        }

        StringBuilder message = new StringBuilder();
        String[] names = signedNames.split(",");
        for (int i = 0; i < names.length; i++) {
            String name = names[i].trim();
            if (i > 0) message.append(',');
            message.append(name).append('=').append(text(response, name));
        }

        String expected = sign(message.toString());
        if (!constantTimeEquals(expected, receivedSignature)) {
            throw new IllegalArgumentException("The eSewa response signature is invalid.");
        }
    }

    private String sign(String message) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secretKey.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return Base64.getEncoder().encodeToString(mac.doFinal(message.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("Could not sign eSewa payment.", e);
        }
    }

    private boolean constantTimeEquals(String a, String b) {
        if (a == null || b == null || a.length() != b.length()) return false;
        int result = 0;
        for (int i = 0; i < a.length(); i++) result |= a.charAt(i) ^ b.charAt(i);
        return result == 0;
    }

    private static boolean sameAmount(String value, long orderTotal) {
        try {
            return new BigDecimal(value).compareTo(BigDecimal.valueOf(orderTotal)) == 0;
        } catch (Exception e) {
            return false;
        }
    }

    private static String money(long amount) {
        return String.format(Locale.US, "%.2f", (double) amount);
    }

    private static String text(JsonNode node, String name) {
        JsonNode value = node == null ? null : node.get(name);
        return value == null || value.isNull() ? "" : value.asText();
    }

    private static String blank(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
    }
}

