package com.example.aalmari.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "store_follows",
        uniqueConstraints = @UniqueConstraint(name = "uk_store_follow", columnNames = {"follower_id", "seller_id"}),
        indexes = @Index(name = "idx_store_follow_seller", columnList = "seller_id"))
public class StoreFollow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "follower_id", nullable = false)
    private User follower;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public StoreFollow() {}
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public User getFollower() { return follower; }
    public void setFollower(User follower) { this.follower = follower; }
    public User getSeller() { return seller; }
    public void setSeller(User seller) { this.seller = seller; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}

