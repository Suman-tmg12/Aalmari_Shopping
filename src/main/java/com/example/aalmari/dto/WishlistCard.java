package com.example.aalmari.dto;

/** Everything one wishlist card on the My Profile page needs. Prices are always the live ones. */
public class WishlistCard {
    private Long productId;
    private String name, category, subCategory, imageUrl;
    /** Path inside the app, e.g. /product/12 or /flashsaleproduct?id=5 (flash price is live). */
    private String link;
    private int price, oldPrice, discount, sold;
    private boolean flash, active, available;

    public Long getProductId() { return productId; }          public void setProductId(Long v) { productId = v; }
    public String getName() { return name; }                  public void setName(String v) { name = v; }
    public String getCategory() { return category; }          public void setCategory(String v) { category = v; }
    public String getSubCategory() { return subCategory; }    public void setSubCategory(String v) { subCategory = v; }
    public String getImageUrl() { return imageUrl; }          public void setImageUrl(String v) { imageUrl = v; }
    public String getLink() { return link; }                  public void setLink(String v) { link = v; }
    public int getPrice() { return price; }                   public void setPrice(int v) { price = v; }
    public int getOldPrice() { return oldPrice; }             public void setOldPrice(int v) { oldPrice = v; }
    public int getDiscount() { return discount; }             public void setDiscount(int v) { discount = v; }
    public int getSold() { return sold; }                     public void setSold(int v) { sold = v; }
    public boolean isFlash() { return flash; }                public void setFlash(boolean v) { flash = v; }
    /** false when the seller deactivated the product (page no longer exists). */
    public boolean isActive() { return active; }              public void setActive(boolean v) { active = v; }
    /** true when it can be bought right now (active and in stock). */
    public boolean isAvailable() { return available; }        public void setAvailable(boolean v) { available = v; }

    public boolean isOnSale() { return oldPrice > 0; }
}