package com.example.aalmari.model;

import java.util.List;
import java.util.Map;

public class Product {
    private String id;
    private String title;
    private String category;
    private String subCategory;
    private String mainImage;
    private List<String> galleryImages;
    private String currentPrice;
    private String originalPrice;
    private String discount;
    private double rating;
    private int reviewCount;
    private String description;
    private List<String> colors;
    private List<String> sizes;
    private Map<String, String> specs;

    public Product() {}

    public Product(String id, String title, String category, String subCategory, String mainImage,
                   List<String> galleryImages, String currentPrice, String originalPrice,
                   String discount, double rating, int reviewCount, String description,
                   List<String> colors, List<String> sizes, Map<String, String> specs) {
        this.id = id;
        this.title = title;
        this.category = category;
        this.subCategory = subCategory;
        this.mainImage = mainImage;
        this.galleryImages = galleryImages;
        this.currentPrice = currentPrice;
        this.originalPrice = originalPrice;
        this.discount = discount;
        this.rating = rating;
        this.reviewCount = reviewCount;
        this.description = description;
        this.colors = colors;
        this.sizes = sizes;
        this.specs = specs;
    }

    public String getId() { return id; }
    public String getTitle() { return title; }
    public String getCategory() { return category; }
    public String getSubCategory() { return subCategory; }
    public String getMainImage() { return mainImage; }
    public List<String> getGalleryImages() { return galleryImages; }
    public String getCurrentPrice() { return currentPrice; }
    public String getOriginalPrice() { return originalPrice; }
    public String getDiscount() { return discount; }
    public double getRating() { return rating; }
    public int getReviewCount() { return reviewCount; }
    public String getDescription() { return description; }
    public List<String> getColors() { return colors; }
    public List<String> getSizes() { return sizes; }
    public Map<String, String> getSpecs() { return specs; }
}