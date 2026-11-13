package com.example.aalmari.model;

import jakarta.persistence.*;

@Entity
@Table(name = "flash_purchases", indexes = @Index(name = "idx_fp_user_item", columnList = "user_id,item_id"))
public class FlashPurchase {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "item_id", nullable = false)
    private FlashSaleItem item;

    @Column(name = "user_id", nullable = false) private Long userId;
    @Column(nullable = false) private int qty;
    @Column(name = "created_at", nullable = false) private long createdAt = System.currentTimeMillis();

    public Long getId() { return id; }
    public FlashSaleItem getItem() { return item; } public void setItem(FlashSaleItem i) { this.item = i; }
    public Long getUserId() { return userId; }      public void setUserId(Long u) { this.userId = u; }
    public int getQty() { return qty; }             public void setQty(int q) { this.qty = q; }
}