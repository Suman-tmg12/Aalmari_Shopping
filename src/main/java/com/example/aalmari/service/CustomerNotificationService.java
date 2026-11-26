package com.example.aalmari.service;

import com.example.aalmari.model.CustomerNotification;
import com.example.aalmari.model.Order;
import com.example.aalmari.model.OrderItem;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.CustomerNotificationRepository;
import com.example.aalmari.repository.OrderItemRepository;
import com.example.aalmari.repository.OrderRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
public class CustomerNotificationService {
    private static final DateTimeFormatter DATE_FORMAT =
            DateTimeFormatter.ofPattern("MMM d, yyyy 'at' h:mm a");

    private final CustomerNotificationRepository notificationRepository;
    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;

    public CustomerNotificationService(CustomerNotificationRepository notificationRepository,
                                       OrderRepository orderRepository,
                                       OrderItemRepository orderItemRepository) {
        this.notificationRepository = notificationRepository;
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
    }

    @Transactional
    public void createForOrder(Order order, String title, String message) {
        createForUser(order.getUser(), order, "CUSTOMER", title, message);
    }

    @Transactional
    public void createSellerOrderNotifications(Order order) {
        if (order.getItems() == null) return;
        order.getItems().stream()
                .map(OrderItem::getSeller)
                .filter(Objects::nonNull)
                .filter(seller -> seller.getId() != null)
                .collect(Collectors.toMap(User::getId, seller -> seller, (first, ignored) -> first))
                .values()
                .forEach(seller -> createSellerOrderNotification(seller, order));
    }

    private void createSellerOrderNotification(User seller, Order order) {
        String orderNumber = order.getOrderNumber() != null
                ? order.getOrderNumber() : "AAL-" + order.getId();
        createForUser(seller, order, "SELLER", "New order received",
                "Order " + orderNumber + " includes product(s) from your store.");
    }

    private void createForUser(User user, Order order, String audience, String title, String message) {
        CustomerNotification notification = new CustomerNotification();
        notification.setUser(user);
        notification.setAudience(audience);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setOrderId(order.getId());
        notificationRepository.save(notification);
    }

    @Transactional
    public Feed feed(Long userId, String audience) {
        backfillActiveOrders(userId, audience);
        List<Item> items = notificationRepository.findTop20ByUser_IdAndAudienceOrderByCreatedAtDesc(userId, audience)
                .stream()
                .map(CustomerNotificationService::toItem)
                .toList();
        return new Feed(notificationRepository.countByUser_IdAndAudienceAndReadAtIsNull(userId, audience), items);
    }

    private void backfillActiveOrders(Long userId, String audience) {
        if ("CUSTOMER".equals(audience)) {
            for (Order order : orderRepository.findTop20ByUser_IdOrderByIdDesc(userId)) {
                if (!notificationRepository.existsByUser_IdAndOrderIdAndAudience(userId, order.getId(), audience)) {
                    String orderNumber = order.getOrderNumber() != null
                            ? order.getOrderNumber() : "AAL-" + order.getId();
                    String status = order.getStatus() == null ? "updated" : order.getStatus().toLowerCase();
                    createForOrder(order, "Order update",
                            "Order " + orderNumber + " is currently " + status.replace('_', ' ') + ".");
                }
            }
            return;
        }

        orderItemRepository.findForSeller(userId).stream()
                .filter(item -> "PENDING".equalsIgnoreCase(item.getStatus()))
                .filter(item -> item.getSeller() != null)
                .collect(Collectors.toMap(item -> item.getOrder().getId(), OrderItem::getOrder,
                        (first, ignored) -> first))
                .values().forEach(order -> {
                    if (!notificationRepository.existsByUser_IdAndOrderIdAndAudience(userId, order.getId(), audience)) {
                        order.getItems().stream()
                                .filter(item -> item.getSeller() != null && userId.equals(item.getSeller().getId()))
                                .map(OrderItem::getSeller)
                                .findFirst()
                                .ifPresent(seller -> createSellerOrderNotification(seller, order));
                    }
                });
    }

    @Transactional
    public boolean markRead(Long userId, String audience, Long notificationId) {
        return notificationRepository.findByIdAndUser_IdAndAudience(notificationId, userId, audience)
                .map(notification -> {
                    if (notification.getReadAt() == null) {
                        notification.setReadAt(LocalDateTime.now());
                        notificationRepository.save(notification);
                    }
                    return true;
                })
                .orElse(false);
    }

    @Transactional
    public void markAllRead(Long userId, String audience) {
        notificationRepository.markAllRead(userId, audience, LocalDateTime.now());
    }

    private static Item toItem(CustomerNotification notification) {
        return new Item(
                notification.getId(),
                notification.getTitle(),
                notification.getMessage(),
                notification.getCreatedAt().format(DATE_FORMAT),
                notification.getReadAt() != null,
                notification.getOrderId());
    }

    public record Item(Long id, String title, String message, String createdAt, boolean read, Long orderId) {}
    public record Feed(long unreadCount, List<Item> items) {}
}
