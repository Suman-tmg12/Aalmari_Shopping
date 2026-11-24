package com.example.aalmari.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "payout_settlements")
public class PayoutSettlement {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "seller_id", nullable = false)
    private Long sellerId;

    @Column(nullable = false, length = 20)
    private String period;

    @Column(nullable = false, length = 20)
    private String status;

    @Column(length = 100)
    private String reference;

    @Column(name = "settled_at")
    private LocalDateTime settledAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public Long getSellerId() { return sellerId; }
    public void setSellerId(Long sellerId) { this.sellerId = sellerId; }

    public String getPeriod() { return period; }
    public void setPeriod(String period) { this.period = period; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getReference() { return reference; }
    public void setReference(String reference) { this.reference = reference; }

    public LocalDateTime getSettledAt() { return settledAt; }
    public void setSettledAt(LocalDateTime settledAt) { this.settledAt = settledAt; }
}

