package com.example.aalmari.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "store_messages", indexes = {
        @Index(name = "idx_msg_seller", columnList = "seller_id"),
        @Index(name = "idx_msg_customer", columnList = "customer_id")
})
public class StoreMessage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "customer_id", nullable = false)
    private User customer;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private SellerProduct product;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "sender_id", nullable = false)
    private User sender;

    @Column(nullable = false, length = 120)
    private String subject;

    @Column(nullable = false, length = 2000)
    private String body;

    @Column(name = "unread_for_seller", nullable = false)
    private boolean unreadForSeller;

    @Column(name = "unread_for_customer", nullable = false)
    private boolean unreadForCustomer;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public StoreMessage() {}
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getCustomer() { return customer; }
    public void setCustomer(User customer) { this.customer = customer; }
    public User getSeller() { return seller; }
    public void setSeller(User seller) { this.seller = seller; }
    public SellerProduct getProduct() { return product; }
    public void setProduct(SellerProduct product) { this.product = product; }
    public User getSender() { return sender; }
    public void setSender(User sender) { this.sender = sender; }
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public String getBody() { return body; }
    public void setBody(String body) { this.body = body; }
    public boolean isUnreadForSeller() { return unreadForSeller; }
    public void setUnreadForSeller(boolean unreadForSeller) { this.unreadForSeller = unreadForSeller; }
    public boolean isUnreadForCustomer() { return unreadForCustomer; }
    public void setUnreadForCustomer(boolean unreadForCustomer) { this.unreadForCustomer = unreadForCustomer; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}

