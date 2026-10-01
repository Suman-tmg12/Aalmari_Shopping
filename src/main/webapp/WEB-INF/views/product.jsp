<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Details — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=1">
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="product-page">

        <!-- Breadcrumb -->
        <nav class="breadcrumb">
            <a href="${pageContext.request.contextPath}/">Home</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/category?name=Fashion">Fashion</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/category?name=Fashion&sub=Women">Women</a>
            <span>/</span>
            <span class="current">Casual Cropped Joggers</span>
        </nav>

        <!-- Main Product Section -->
        <div class="product-main">

            <!-- Left: Image Gallery -->
            <div class="product-gallery">
                <div class="gallery-thumbs">
                    <div class="thumb active">
                        <img src="${pageContext.request.contextPath}/HomePageImages/Products/jogger1.jpg" alt="Front view">
                    </div>
                    <div class="thumb">
                        <img src="${pageContext.request.contextPath}/HomePageImages/Products/jogger2.jpg" alt="Side view">
                    </div>
                    <div class="thumb">
                        <img src="${pageContext.request.contextPath}/HomePageImages/Products/jogger3.jpg" alt="Back view">
                    </div>
                </div>
                <div class="gallery-main">
                    <img src="${pageContext.request.contextPath}/HomePageImages/Products/jogger1.jpg" alt="Grey Acid Wash Wide Leg Jogger" id="mainImage">
                    <button class="wishlist-btn" aria-label="Add to wishlist">
                        <span class="material-symbols-outlined">favorite</span>
                    </button>
                </div>
            </div>

            <!-- Right: Product Info -->
            <div class="product-info">
                <h1 class="product-title">Grey Acid Wash Wide Leg Jogger</h1>

                <div class="product-rating">
                    <div class="stars">
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined half">star_half</span>
                    </div>
                    <span class="rating-text">4.5</span>
                    <span class="review-count">(532 reviews)</span>
                </div>

                <div class="product-price">
                    <span class="current-price">Rs.215</span>
                    <span class="original-price">Rs.350</span>
                    <span class="discount-badge">-39%</span>
                </div>

                <!-- Color Selection -->
                <div class="product-option">
                    <label>Color: <span class="selected-value">Black</span></label>
                    <div class="color-options">
                        <button class="color-btn active" data-color="Black" style="background: #1a1a1a;" aria-label="Black"></button>
                        <button class="color-btn" data-color="Grey" style="background: #888;" aria-label="Grey"></button>
                        <button class="color-btn" data-color="Navy" style="background: #223355;" aria-label="Navy"></button>
                    </div>
                </div>

                <!-- Size Selection -->
                <div class="product-option">
                    <label>Size: <span class="selected-value">M</span></label>
                    <div class="size-options">
                        <button class="size-btn">XXS</button>
                        <button class="size-btn">XS</button>
                        <button class="size-btn">S</button>
                        <button class="size-btn active">M</button>
                        <button class="size-btn">L</button>
                        <button class="size-btn">XL</button>
                        <button class="size-btn">XXL</button>
                    </div>
                    <a href="#" class="size-guide-link">View size guide</a>
                </div>

                <!-- Quantity & Actions -->
                <div class="product-actions">
                    <div class="quantity-selector">
                        <button class="qty-btn minus">-</button>
                        <input type="number" value="1" min="1" max="10" class="qty-input">
                        <button class="qty-btn plus">+</button>
                    </div>
                    <button class="add-to-cart-btn">
                        <span class="material-symbols-outlined">shopping_bag</span>
                        Add to Cart
                    </button>
                    <button class="find-in-store-btn">
                        <span class="material-symbols-outlined">location_on</span>
                        Find in store
                    </button>
                </div>

                <!-- Delivery Info -->
                <div class="delivery-info">
                    <p><span class="material-symbols-outlined">local_shipping</span> Enjoy <strong>FREE</strong> shipping & <strong>Free Returns</strong> on every order!</p>
                    <p class="payment-methods">
                        Payment methods:
                        <img src="${pageContext.request.contextPath}/HomePageImages/payment/visa.png" alt="Visa">
                        <img src="${pageContext.request.contextPath}/HomePageImages/payment/mastercard.png" alt="Mastercard">
                        <img src="${pageContext.request.contextPath}/HomePageImages/payment/paypal.png" alt="PayPal">
                        <img src="${pageContext.request.contextPath}/HomePageImages/payment/amex.png" alt="Amex">
                    </p>
                </div>
            </div>
        </div>

        <!-- Product Tabs -->
        <div class="product-tabs">
            <div class="tab-headers">
                <button class="tab-btn active" data-tab="details">Product Details</button>
                <button class="tab-btn" data-tab="care">Care Guide</button>
                <button class="tab-btn" data-tab="reviews">Reviews</button>
            </div>
            <div class="tab-content">
                <div class="tab-panel active" id="details">
                    <p>One of our all time favourites and all day style with these grey acid wash joggers that effortlessly marry fashion with comfort. Crafted for those committed to both ease and on-trend of denim, these joggers feature a flattering wide leg silhouette and elasticated waistband with a touch of stretch for unrestricted movement. The acid wash finish adds a lived-in, vintage appeal that pairs seamlessly with everything from cropped tees to oversized knits.</p>
                    <p>Whether you're running errands, working from home, or meeting friends for coffee, these joggers transition effortlessly from loungewear to streetwear. The premium cotton blend ensures breathability while maintaining shape wear after wear.</p>

                    <h4>Product Specifications</h4>
                    <ul class="specs-list">
                        <li><strong>Material:</strong> 85% Cotton, 15% Polyester</li>
                        <li><strong>Fit:</strong> Wide leg, relaxed fit</li>
                        <li><strong>Waist:</strong> Elasticated with drawstring</li>
                        <li><strong>Pockets:</strong> Side pockets, back patch pockets</li>
                        <li><strong>Care:</strong> Machine wash cold, tumble dry low</li>
                        <li><strong>Imported</strong></li>
                    </ul>
                </div>
                <div class="tab-panel" id="care">
                    <h4>Care Instructions</h4>
                    <ul class="care-list">
                        <li><span class="material-symbols-outlined">local_laundry_service</span> Machine wash cold with like colors</li>
                        <li><span class="material-symbols-outlined">dry</span> Tumble dry low or hang dry</li>
                        <li><span class="material-symbols-outlined">iron</span> Iron on low heat if needed</li>
                        <li><span class="material-symbols-outlined">block</span> Do not bleach</li>
                    </ul>
                </div>
                <div class="tab-panel" id="reviews">
                    <div class="reviews-summary">
                        <div class="overall-rating">
                            <span class="big-rating">4.5</span>
                            <div class="stars">
                                <span class="material-symbols-outlined filled">star</span>
                                <span class="material-symbols-outlined filled">star</span>
                                <span class="material-symbols-outlined filled">star</span>
                                <span class="material-symbols-outlined filled">star</span>
                                <span class="material-symbols-outlined half">star_half</span>
                            </div>
                            <span>Based on 532 reviews</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- More Favorites -->
        <section class="more-favorites">
            <h3>More Favorites This Way</h3>
            <div class="favorite-tags">
                <a href="#" class="fav-tag">Bulk Loungepants</a>
                <a href="#" class="fav-tag">Women's Nightwear</a>
                <a href="#" class="fav-tag">Hoodies & Sweatshirts</a>
                <a href="#" class="fav-tag">Black Joggers</a>
                <a href="#" class="fav-tag">Knitwear</a>
                <a href="#" class="fav-tag">Women's T-shirt</a>
                <a href="#" class="fav-tag">White Dress</a>
                <a href="#" class="fav-tag">Black Loungepants</a>
            </div>
        </section>

        <!-- Related Products -->
        <section class="related-products">
            <h3>Related Product</h3>
            <div class="related-grid">
                <%
                    String[][] relatedProducts = {
                        {"Urban Black Oversized", "oversized1.jpg", "$49.99", "Hoodie Sweatshirt"},
                        {"Crew Neck Textured Lounge", "lounge1.jpg", "$45.00", "Lounge Set"},
                        {"Grey Wide Leg Trouser", "trouser1.jpg", "$55.00", "Wide Leg Pants"},
                        {"Minimalist Monochrome", "mono1.jpg", "$52.00", "Striped Top"},
                        {"Casual Weekend Set", "weekend1.jpg", "$89.00", "Matching Set"}
                    };
                    for (String[] p : relatedProducts) {
                %>
                <div class="related-card">
                    <div class="related-image-wrap">
                        <img src="${pageContext.request.contextPath}/HomePageImages/Products/<%= p[1] %>" alt="<%= p[0] %>">
                    </div>
                    <div class="related-info">
                        <h4><%= p[0] %></h4>
                        <p class="related-desc"><%= p[3] %></p>
                        <span class="related-price"><%= p[2] %></span>
                    </div>
                </div>
                <% } %>
            </div>
        </section>

    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        // Image Gallery
        document.querySelectorAll('.thumb').forEach(thumb => {
            thumb.addEventListener('click', function() {
                document.querySelectorAll('.thumb').forEach(t => t.classList.remove('active'));
                this.classList.add('active');
                document.getElementById('mainImage').src = this.querySelector('img').src.replace('thumb', 'main');
            });
        });

        // Color Selection
        document.querySelectorAll('.color-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.color-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                document.querySelector('.product-option label .selected-value').textContent = this.dataset.color;
            });
        });

        // Size Selection
        document.querySelectorAll('.size-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.size-btn').forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                document.querySelectorAll('.product-option label .selected-value')[1].textContent = this.textContent;
            });
        });

        // Quantity
        const qtyInput = document.querySelector('.qty-input');
        document.querySelector('.qty-btn.minus').addEventListener('click', () => {
            if (qtyInput.value > 1) qtyInput.value--;
        });
        document.querySelector('.qty-btn.plus').addEventListener('click', () => {
            if (qtyInput.value < 10) qtyInput.value++;
        });

        // Tabs
        document.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', function() {
                document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                document.querySelectorAll('.tab-panel').forEach(p => p.classList.remove('active'));
                this.classList.add('active');
                document.getElementById(this.dataset.tab).classList.add('active');
            });
        });
    </script>
</body>
</html>