<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
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
        // S3 Base URL
        String s3Base = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";

        // Get the list from Model (passed by HomeController)
        List<com.example.aalmari.model.SellerProduct> products = (List<com.example.aalmari.model.SellerProduct>) request.getAttribute("sellerProducts");

        if (products != null && !products.isEmpty()) {
            for (com.example.aalmari.model.SellerProduct p : products) {
                // Skip if not active (safety check)
                if (!p.getActive()) continue;

                int price = p.getPrice();
                int discount = p.getDiscount();

                // Calculate old price for display (strikethrough)
                long oldPrice = 0;
                if (discount > 0) {
                    oldPrice = Math.round(price / ((100.0 - discount) / 100.0));
                }

                // Get Main Image (Info Image or first gallery image)
                String mainImg = "";
                if (p.getInfoImageUrl() != null && !p.getInfoImageUrl().isEmpty()) {
                    mainImg = p.getInfoImageUrl();
                    if (!mainImg.startsWith("http")) {
                        mainImg = s3Base + mainImg;
                    }
                } else {
                    // Fallback: Try to get first image from gallery if info image is missing
                    // Note: Parsing JSON in JSP is messy, better to ensure InfoImage exists in DB
                    // For now, we skip if no main image
                    mainImg = "${pageContext.request.contextPath}/placeholder.jpg";
                }

                String soldText = p.getSold() + " sold";
    %>
        <article class="ar-card" data-price="<%= price %>" data-name="<%= esc(p.getName()) %>">
            <button type="button" class="ar-wish" aria-label="Save to wishlist">
                <span class="material-symbols-outlined ar-ic-sm">favorite</span>
            </button>
            <!-- Link to the new dynamic product detail page -->
            <a href="${pageContext.request.contextPath}/product/<%= p.getId() %>" class="ar-card-link">
                <div class="ar-card-img">
                    <img src="<%= mainImg %>" alt="<%= esc(p.getName()) %>" loading="lazy">
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