package com.example.aalmari.model;

import jakarta.persistence.*;

@Entity
@Table(name = "flash_sale_items", indexes = @Index(name = "idx_fsi_product", columnList = "product_id"))
public class FlashSaleItem {
    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "flash_sale_id", nullable = false)
    private FlashSale sale;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "product_id", nullable = false)
    private SellerProduct product;

    @Column(name = "regular_price", nullable = false) private int regularPrice;   // snapshot at creation
    @Column(nullable = false) private int discount;                               // 10-90
    @Column(name = "flash_price", nullable = false) private int flashPrice;       // computed on the server
    @Column(nullable = false) private int qty;
    @Column(name = "limit_per_customer", nullable = false) private int limitPerCustomer;
    @Column(nullable = false) private int sold;

    public Long getId() { return id; }
    public FlashSale getSale() { return sale; }            public void setSale(FlashSale s) { this.sale = s; }
    public SellerProduct getProduct() { return product; } public void setProduct(SellerProduct p) { this.product = p; }
    public int getRegularPrice() { return regularPrice; }  public void setRegularPrice(int v) { this.regularPrice = v; }
    public int getDiscount() { return discount; }          public void setDiscount(int v) { this.discount = v; }
    public int getFlashPrice() { return flashPrice; }      public void setFlashPrice(int v) { this.flashPrice = v; }
    public int getQty() { return qty; }                    public void setQty(int v) { this.qty = v; }
    public int getLimitPerCustomer() { return limitPerCustomer; } public void setLimitPerCustomer(int v) { this.limitPerCustomer = v; }
    public int getSold() { return sold; }                  public void setSold(int v) { this.sold = v; }
}