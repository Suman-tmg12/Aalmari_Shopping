package com.example.aalmari.dto;

import java.util.ArrayList;
import java.util.List;

/** Everything cart.jsp needs, calculated on the server. */
public class CartView {

    public static class Line {
        private Long id;            // cart_items.id (used by /cart/update and /cart/remove)
        private Long productId;
        private String name;
        private String imageUrl;    // full URL
        private long unitPrice;     // price after discount
        private long originalPrice;
        private int quantity;
        private long lineTotal;

        public Long getId() { return id; }
        public void setId(Long id) { this.id = id; }
        public Long getProductId() { return productId; }
        public void setProductId(Long productId) { this.productId = productId; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getImageUrl() { return imageUrl; }
        public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
        public long getUnitPrice() { return unitPrice; }
        public void setUnitPrice(long unitPrice) { this.unitPrice = unitPrice; }
        public long getOriginalPrice() { return originalPrice; }
        public void setOriginalPrice(long originalPrice) { this.originalPrice = originalPrice; }
        public int getQuantity() { return quantity; }
        public void setQuantity(int quantity) { this.quantity = quantity; }
        public long getLineTotal() { return lineTotal; }
        public void setLineTotal(long lineTotal) { this.lineTotal = lineTotal; }
    }

    private List<Line> items = new ArrayList<>();
    private long subtotal;        // sum of original prices
    private long discountAmount;
    private long discountPercent;
    private long deliveryFee;
    private long total;

    public List<Line> getItems() { return items; }
    public void setItems(List<Line> items) { this.items = items; }
    public long getSubtotal() { return subtotal; }
    public void setSubtotal(long subtotal) { this.subtotal = subtotal; }
    public long getDiscountAmount() { return discountAmount; }
    public void setDiscountAmount(long discountAmount) { this.discountAmount = discountAmount; }
    public long getDiscountPercent() { return discountPercent; }
    public void setDiscountPercent(long discountPercent) { this.discountPercent = discountPercent; }
    public long getDeliveryFee() { return deliveryFee; }
    public void setDeliveryFee(long deliveryFee) { this.deliveryFee = deliveryFee; }
    public long getTotal() { return total; }
    public void setTotal(long total) { this.total = total; }
}