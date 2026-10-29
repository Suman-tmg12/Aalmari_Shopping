<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%!
    private static final String S3_BASE = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";
    private static final com.fasterxml.jackson.databind.ObjectMapper MAPPER =
            new com.fasterxml.jackson.databind.ObjectMapper();

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    // Returns the full URL of the first gallery image, or null if none
    private static String firstGalleryImage(String json) {
        if (json == null || json.isEmpty() || json.equals("[]")) return null;
        try {
            List<String> paths = MAPPER.readValue(json,
                    new com.fasterxml.jackson.core.type.TypeReference<List<String>>() {});
            for (String path : paths) {
                if (path != null && !path.isEmpty()) {
                    return path.startsWith("http") ? path : S3_BASE + path;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
%>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/produc.css?v=11">

<div class="section-header">
    <span class="section-title">Products</span>
</div>

<div class="ar-page">
    <div class="ar-grid" id="productGrid">
    <%
        // Get the list from Model (passed by HomeController)
        List<com.example.aalmari.model.SellerProduct> products =
                (List<com.example.aalmari.model.SellerProduct>) request.getAttribute("sellerProducts");

        if (products != null && !products.isEmpty()) {
            for (com.example.aalmari.model.SellerProduct p : products) {
                // Skip if not active (safety check)
                if (!p.getActive()) continue;

                int price = p.getPrice();
                int discount = p.getDiscount();

                // Calculate old price for display (strikethrough)
                long oldPrice = 0;
                if (discount > 0 && discount < 100) {
                    oldPrice = Math.round(price / ((100.0 - discount) / 100.0));
                }

                // Card image = first gallery image
                String cardImg = firstGalleryImage(p.getImageUrlsJson());
                if (cardImg == null) {
                    cardImg = request.getContextPath() + "/placeholder.jpg";
                }

                String soldText = p.getSold() + " sold";
    %>
        <article class="ar-card" data-price="<%= price %>" data-name="<%= esc(p.getName()) %>">
            <button type="button" class="ar-wish" aria-label="Save to wishlist">
                <span class="material-symbols-outlined ar-ic-sm">favorite</span>
            </button>
            <!-- Link to the dynamic product detail page -->
            <a href="${pageContext.request.contextPath}/product/<%= p.getId() %>" class="ar-card-link">
                <div class="ar-card-img">
                    <img src="<%= esc(cardImg) %>" alt="<%= esc(p.getName()) %>" loading="lazy">
                    <% if (discount > 0) { %><span class="ar-badge">-<%= discount %>%</span><% } %>
                </div>
                <div class="ar-card-body">
                    <div>
                        <div class="ar-card-top">
                            <span class="ar-brand"><%= esc(p.getCategory()) %></span>
                            <span class="ar-sold"><%= soldText %></span>
                        </div>
                        <h3 class="ar-p-title"><%= esc(p.getName()) %></h3>
                    </div>
                    <div class="ar-price-row">
                        <div>
                            <div class="ar-price">Rs.<%= price %></div>
                            <% if (oldPrice > 0) { %><div class="ar-old">Rs.<%= oldPrice %></div><% } %>
                            <div class="ar-sub-muted"><%= esc(p.getSubCategory()) %></div>
                        </div>
                        <span class="ar-view">Add to cart</span>
                    </div>
                </div>
            </a>
        </article>
    <%
            }
        } else {
    %>
        <div style="grid-column: 1 / -1; text-align: center; padding: 50px; color: #666;">
            <h2>No products available at this time.</h2>
        </div>
    <% } %>
    </div>
</div>

<script>
    // Wishlist heart toggle
    document.querySelectorAll('#productGrid .ar-wish').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();
            btn.classList.toggle('ar-wished');
        });
    });
</script>
