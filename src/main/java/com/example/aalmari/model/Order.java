package com.example.aalmari.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

/** One customer order. Table "orders" ("order" is a reserved word in SQL). */
@Entity(name = "ShopOrder")
@Table(name = "orders")
public class Order {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "order_number", unique = true, length = 30)
    private String orderNumber;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** PLACED, PENDING_PAYMENT, CANCELLED (more later: SHIPPED, DELIVERED) */
    @Column(nullable = false, length = 30)
    private String status;

    /** COD, ESEWA, KHALTI, CARD */
    @Column(name = "payment_method", nullable = false, length = 20)
    private String paymentMethod;

    /** UNPAID, PAID */
    @Column(name = "payment_status", nullable = false, length = 20)
    private String paymentStatus;

    @Column(nullable = false) private long subtotal;
    @Column(name = "discount_amount", nullable = false) private long discountAmount;
    @Column(name = "delivery_fee", nullable = false) private long deliveryFee;
    @Column(nullable = false) private long total;

    @Column(name = "receiver_name", nullable = false, length = 150) private String receiverName;
    @Column(name = "receiver_phone", nullable = false, length = 20) private String receiverPhone;
    @Column(nullable = false, length = 50) private String province;
    @Column(nullable = false, length = 100) private String city;
    @Column(nullable = false, length = 255) private String address;
    @Column(length = 255) private String landmark;
    @Column(length = 500) private String note;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    public Order() {}

    public void addItem(OrderItem item) {
        item.setOrder(this);
        items.add(item);
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getOrderNumber() { return orderNumber; }
    public void setOrderNumber(String orderNumber) { this.orderNumber = orderNumber; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    public long getSubtotal() { return subtotal; }
    public void setSubtotal(long subtotal) { this.subtotal = subtotal; }
    public long getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(long discountAmount) { this.discountAmount = discountAmount; }
    public long getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(long deliveryFee) { this.deliveryFee = deliveryFee; }
    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }
    public String getReceiverPhone() { return receiverPhone; }
    public void setReceiverPhone(String receiverPhone) { this.receiverPhone = receiverPhone; }
    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getLandmark() { return landmark; }
    public void setLandmark(String landmark) { this.landmark = landmark; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public List<OrderItem> getItems() { return items; }
    public void setItems(List<OrderItem> items) { this.items = items; }
}