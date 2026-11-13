package com.example.aalmari.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "flash_sales")
public class FlashSale {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @Column(nullable = false, length = 60)
    private String name;

    @Column(name = "start_time", nullable = false) private long startTime;   // epoch millis
    @Column(name = "end_time", nullable = false)   private long endTime;     // epoch millis
    @Column(name = "ended_early", nullable = false) private boolean endedEarly;
    @Column(name = "created_at", nullable = false)  private long createdAt = System.currentTimeMillis();

    @OneToMany(mappedBy = "sale", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("id ASC")
    private List<FlashSaleItem> items = new ArrayList<>();

    public Long getId() { return id; }
    public User getSeller() { return seller; }          public void setSeller(User s) { this.seller = s; }
    public String getName() { return name; }           public void setName(String n) { this.name = n; }
    public long getStartTime() { return startTime; }   public void setStartTime(long v) { this.startTime = v; }
    public long getEndTime() { return endTime; }       public void setEndTime(long v) { this.endTime = v; }
    public boolean isEndedEarly() { return endedEarly; } public void setEndedEarly(boolean v) { this.endedEarly = v; }
    public long getCreatedAt() { return createdAt; }
    public List<FlashSaleItem> getItems() { return items; }
}