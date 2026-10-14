<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
        String[] prodIds       = {"hair-spray","olipop-cherry","nike-shoes","black-glasses","white-spray","falcon-spray","iphone-15-pro","macbook-pro-m3","airpods-pro"};
        String[] prods         = {"Hair Spray", "OLIPOP Cherry", "Nike Shoes", "Black Glasses", "White Spray", "Falcon Spray", "iPhone 15 Pro", "MacBook Pro M3", "AirPods Pro"};
        String[] prodImages    = {"hairSpray.jpg", "olipop.jpg", "nikeShoe.jpg", "BlackGlass.jpg", "WhiteSpray.jpg", "FalconSpray.jpg", "iphone15pro.jpg", "MacBookProm3.jpg", "Airpods.jpg"};
        long[]   prodPrices    = {70, 120, 200, 90, 80, 110, 1500, 2200, 250};
        long[]   prodOldPrices = {100, 150, 260, 120, 100, 140, 1800, 2600, 300};   // adjust to real values
        String[] prodSold      = {"4.5k sold", "3.2k sold", "8.1k sold", "2.3k sold", "1.8k sold", "5.6k sold", "12.4k sold", "9.7k sold", "15.2k sold"};
        String[] prodBrands    = {"Beauty", "Beverages", "Fashion", "Fashion", "Beauty", "Beauty", "Electronics", "Electronics", "Electronics"}; // adjust
        String[] prodSubs      = {"Hair Care", "Soft Drinks", "Footwear", "Eyewear", "Body Spray", "Body Spray", "Smartphones", "Laptops", "Audio"}; // adjust

        for (int i = 0; i < prods.length; i++) {
            long price = prodPrices[i];
            long oldPrice = prodOldPrices[i];
            int discount = oldPrice > 0 ? (int) Math.round(((double) (oldPrice - price) / oldPrice) * 100) : 0;
    %>
        <article class="ar-card" data-index="<%= i %>" data-price="<%= price %>" data-name="<%= esc(prods[i]) %>">
            <button type="button" class="ar-wish" aria-label="Save to wishlist">
                <span class="material-symbols-outlined ar-ic-sm">favorite</span>
            </button>
            <a href="${pageContext.request.contextPath}/product?id=<%= prodIds[i] %>" class="ar-card-link">
                <div class="ar-card-img">
                    <img src="${pageContext.request.contextPath}/HomePageImages/Products/<%= prodImages[i] %>"
                         alt="<%= esc(prods[i]) %>" loading="lazy">
                    <% if (discount > 0) { %><span class="ar-badge">-<%= discount %>%</span><% } %>
                </div>
                <div class="ar-card-body">
                    <div>
                        <div class="ar-card-top">
                            <span class="ar-brand"><%= esc(prodBrands[i]) %></span>
                            <span class="ar-sold"><%= esc(prodSold[i]) %></span>
                        </div>
                        <h3 class="ar-p-title"><%= esc(prods[i]) %></h3>
                    </div>
                    <div class="ar-price-row">
                        <div>
                            <div class="ar-price">Rs.<%= price %></div>
                            <% if (oldPrice > price) { %><div class="ar-old">Rs.<%= oldPrice %></div><% } %>
                            <div class="ar-sub-muted"><%= esc(prodSubs[i]) %></div>
                        </div>
                        <span class="ar-view">Add to cart</span>
                    </div>
                </div>
            </a>
        </article>
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