package com.example.aalmari.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/** One saved delivery address in a customer's address book. */
@Entity
@Table(name = "user_addresses",
        indexes = @Index(name = "idx_addr_user", columnList = "user_id"))
public class Address {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    /** Home, Office or Other */
    @Column(nullable = false, length = 20)
    private String label;

    @Column(name = "receiver_name", nullable = false, length = 150)
    private String receiverName;

    @Column(nullable = false, length = 20)
    private String phone;

    @Column(nullable = false, length = 50)
    private String province;

    @Column(nullable = false, length = 100)
    private String city;

    @Column(nullable = false, length = 255)
    private String street;

    @Column(length = 255)
    private String landmark;

    @Column(name = "is_default", nullable = false)
    private boolean defaultAddress;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public Address() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getUser() { return user; }
    public void setUser(User user) { this.user = user; }
    public String getLabel() { return label; }
    public void setLabel(String label) { this.label = label; }
    public String getReceiverName() { return receiverName; }
    public void setReceiverName(String receiverName) { this.receiverName = receiverName; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }
    public String getStreet() { return street; }
    public void setStreet(String street) { this.street = street; }
    public String getLandmark() { return landmark; }
    public void setLandmark(String landmark) { this.landmark = landmark; }
    public boolean isDefaultAddress() { return defaultAddress; }
    public void setDefaultAddress(boolean defaultAddress) { this.defaultAddress = defaultAddress; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}