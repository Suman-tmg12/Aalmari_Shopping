package com.example.aalmari.model;

import jakarta.persistence.*;
import java.util.ArrayList;
import java.util.List;
// ⚠️ Make sure this import points to your actual User entity
import com.example.aalmari.model.User;

@Entity
@Table(name = "seller_products")
public class SellerProduct {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 👇 THIS IS THE TRUE FOREIGN KEY RELATIONSHIP 👇
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", referencedColumnName = "id", nullable = false)
    private User seller;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String sku;

    @Column(nullable = false)
    private String category;

    private String subCategory;

    @Column(columnDefinition = "TEXT")
    private String attributesJson;

    @Column(nullable = false)
    private Integer price;

    @Column(nullable = false)
    private Integer discount;

    @Column(nullable = false)
    private Integer stock;

    @Column(nullable = false)
    private Integer sold;

    // 👇 Default set to true (1) 👇
    @Column(nullable = false)
    private Boolean active = true;

    @Column(columnDefinition = "TEXT")
    private String description;

    @Column(name = "info_image_url", length = 2048)
    private String infoImageUrl;

    @Column(columnDefinition = "TEXT")
    private String imageUrlsJson;

    // Constructor
    public SellerProduct() {
        this.sold = 0;
        this.active = true; // Default to active
        this.discount = 0;
        this.imageUrlsJson = "[]";
        this.attributesJson = "{}";
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    // 👇 Relationship Getters and Setters 👇
    public User getSeller() { return seller; }
    public void setSeller(User seller) { this.seller = seller; }

    // Helper method to easily get the ID if needed in JSP/Thymeleaf
    public Long getSellerId() {
        return seller != null ? seller.getId() : null;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public String getSubCategory() { return subCategory; }
    public void setSubCategory(String subCategory) { this.subCategory = subCategory; }

    public String getAttributesJson() { return attributesJson; }
    public void setAttributesJson(String attributesJson) { this.attributesJson = attributesJson; }

    public Integer getPrice() { return price; }
    public void setPrice(Integer price) { this.price = price; }

    public Integer getDiscount() { return discount; }
    public void setDiscount(Integer discount) { this.discount = discount; }

    public Integer getStock() { return stock; }
    public void setStock(Integer stock) { this.stock = stock; }

    public Integer getSold() { return sold; }
    public void setSold(Integer sold) { this.sold = sold; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getInfoImageUrl() { return infoImageUrl; }
    public void setInfoImageUrl(String infoImageUrl) { this.infoImageUrl = infoImageUrl; }

    public String getImageUrlsJson() { return imageUrlsJson; }
    public void setImageUrlsJson(String imageUrlsJson) { this.imageUrlsJson = imageUrlsJson; }
}