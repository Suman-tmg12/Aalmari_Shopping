package com.example.aalmari.dto;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class FlashDeal {
    private Long itemId, productId;
    private String title, category, subCategory, mainImage, descriptionHtml;
    private List<String> galleryImages = new ArrayList<>();
    private Map<String, String> specs = new LinkedHashMap<>();
    private int regularPrice, flashPrice, discountPercent, qty, sold, stockLeft, limitPerCustomer;
    private long endTime;

    public Long getItemId() { return itemId; }                 public void setItemId(Long v) { itemId = v; }
    public Long getProductId() { return productId; }          public void setProductId(Long v) { productId = v; }
    public String getTitle() { return title; }                public void setTitle(String v) { title = v; }
    public String getCategory() { return category; }          public void setCategory(String v) { category = v; }
    public String getSubCategory() { return subCategory; }    public void setSubCategory(String v) { subCategory = v; }
    public String getMainImage() { return mainImage; }        public void setMainImage(String v) { mainImage = v; }
    public String getDescriptionHtml() { return descriptionHtml; } public void setDescriptionHtml(String v) { descriptionHtml = v; }
    public List<String> getGalleryImages() { return galleryImages; } public void setGalleryImages(List<String> v) { galleryImages = v; }
    public Map<String, String> getSpecs() { return specs; }   public void setSpecs(Map<String, String> v) { specs = v; }
    public int getRegularPrice() { return regularPrice; }     public void setRegularPrice(int v) { regularPrice = v; }
    public int getFlashPrice() { return flashPrice; }         public void setFlashPrice(int v) { flashPrice = v; }
    public int getDiscountPercent() { return discountPercent; } public void setDiscountPercent(int v) { discountPercent = v; }
    public int getQty() { return qty; }                       public void setQty(int v) { qty = v; }
    public int getSold() { return sold; }                     public void setSold(int v) { sold = v; }
    public int getStockLeft() { return stockLeft; }           public void setStockLeft(int v) { stockLeft = v; }
    public int getLimitPerCustomer() { return limitPerCustomer; } public void setLimitPerCustomer(int v) { limitPerCustomer = v; }
    public long getEndTime() { return endTime; }              public void setEndTime(long v) { endTime = v; }

    // ---- derived values used by the JSPs ----
    public String getCurrentPrice()  { return "Rs." + flashPrice; }
    public String getOriginalPrice() { return "Rs." + regularPrice; }
    public String getDiscount()      { return "-" + discountPercent + "%"; }
    public String getSoldText()      { return sold >= 1000 ? String.format("%.1fk sold", sold / 1000.0) : sold + " sold"; }
    public int getPercentLeft()      { return qty <= 0 ? 0 : Math.max(0, Math.min(100, (int) Math.round(stockLeft * 100.0 / qty))); }
    public int getMaxQty()           { return Math.max(1, Math.min(10, Math.min(stockLeft, limitPerCustomer))); }
}