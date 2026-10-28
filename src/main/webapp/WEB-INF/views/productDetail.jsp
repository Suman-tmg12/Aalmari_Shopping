<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=2">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <!-- Debug: Check if product exists -->
    <c:if test="${product == null}">
        <div style="padding: 50px; text-align: center; color: red; background: #fff; margin: 20px;">
            <h1>ERROR: Product not found!</h1>
            <p>The requested product could not be loaded from the database.</p>
            <p><a href="${pageContext.request.contextPath}/">Return to Home</a></p>
        </div>
        <jsp:include page="/WEB-INF/components/footer.jsp" />
    </c:if>

    <!-- Main Content - Only show if product exists -->
    <c:if test="${product != null}">
        <div class="product-page">

            <!-- Breadcrumb -->
            <nav class="breadcrumb">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <c:if test="${not empty product.category}">
                    <span>/</span>
                    <span>${product.category}</span>
                </c:if>
                <c:if test="${not empty product.subCategory}">
                    <span>/</span>
                    <span>${product.subCategory}</span>
                </c:if>
                <span>/</span>
                <span class="current">${product.name}</span>
            </nav>

            <!-- Main Product Section -->
            <div class="product-main">

                <!-- Left: Image Gallery - Using S3 URLs from controller */ -->
                <div class="product-gallery">
                    <c:if test="${not empty galleryImages}">
                        <div class="gallery-thumbs">
                            <c:forEach var="img" items="${galleryImages}" varStatus="status">
                                <div class="thumb ${status.first ? 'active' : ''}">
                                    <img src="${img}" alt="${product.name}" class="thumb-img">
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>
                    <div class="gallery-main">
                        <img src="${mainImage}" alt="${product.name}" id="mainImage">
                        <button class="wishlist-btn" aria-label="Add to wishlist">
                            <span class="material-symbols-outlined">favorite</span>
                        </button>
                    </div>
                </div>

                <!-- Right: Product Info -->
                <div class="product-info">
                    <h1 class="product-title">${product.name}</h1>

                    <div class="product-rating">
                        <div class="stars">
                            <span class="material-symbols-outlined">star</span>
                            <span class="material-symbols-outlined">star</span>
                            <span class="material-symbols-outlined">star</span>
                            <span class="material-symbols-outlined">star</span>
                            <span class="material-symbols-outlined">star</span>
                        </div>
                        <span class="rating-text">0</span>
                        <span class="review-count">(0 reviews)</span>
                    </div>

                    <div class="product-price">
                        <span class="current-price">${currentPrice}</span>
                        <c:if test="${not empty originalPrice}">
                            <span class="original-price">${originalPrice}</span>
                        </c:if>
                        <c:if test="${not empty discount}">
                            <span class="discount-badge">${discount}</span>
                        </c:if>
                    </div>

                    <!-- Product Description -->
                    <div class="product-description">
                        <p>${product.description}</p>
                    </div>

                    <!-- Specifications -->
                    <c:if test="${not empty specs}">
                        <div class="product-specs">
                            <h4>Specifications</h4>
                            <ul class="specs-list">
                                <c:forEach var="spec" items="${specs}">
                                    <li><strong>${spec.key}:</strong> ${spec.value}</li>
            <c:choose>
                                    <c:when test="${spec.key == 'Weight' or spec.key == 'Dimensions' or spec.key == 'Size'}">
                                        <li><strong>${spec.key}:</strong> ${spec.value}</li>
                                    </c:when>
                                    <c:otherwise>
            <!-- Hide sensitive specs if needed -->
                                    </c:otherwise>
                                </c:choose>
                                </c:forEach>
                            </ul>
                        </div>
                    </c:if>

                    <!-- Quantity & Action Buttons -->
                    <div class="product-actions">
                        <div class="quantity-selector">
                            <button type="button" class="qty-btn minus" id="qtyMinus">-</button>
                            <input type="number" value="1" min="1" max="10" class="qty-input" id="qtyInput">
                            <button type="button" class="qty-btn plus" id="qtyPlus">+</button>
                        </div>

                        <div class="action-buttons">
                            <button type="button" class="buy-now-btn">
                                Buy Now
                            </button>
                            <button type="button" class="add-to-cart-btn">
            <span class="material-symbols-outlined">shopping_bag</span>
                                Add to Cart
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Details Tab -->
            <div class="product-tabs">
                <div class="tab-headers">
                    <button class="tab-btn active" data-tab="details">Product Details</button>
                </div>
                <div class="tab-content">
                    <div class="tab-panel active" id="details">
                        <p>${product.description}</p>
                        <c:if test="${not empty specs}">
                            <h4>Specifications</h4>
                            <ul class="specs-list">
                                <c:forEach var="spec" items="${specs}">
                                    <li><strong>${spec.key}:</strong> ${spec.value}</li>
                                </c:forEach>
                            </ul>
                        </c:if>
                    </div>
                </div>
            </div>

        </div>
    </c:if>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        // Gallery Thumbnail Switcher
        const mainImage = document.getElementById('mainImage');
        const thumbs = document.querySelectorAll('.thumb');

        if (thumbs.length > 0 && mainImage) {
            thumbs.forEach(thumb => {
                thumb.addEventListener('click', () => {
                    thumbs.forEach(t => t.classList.remove('active'));
                    thumb.classList.add('active');
                    const imgTag = thumb.querySelector('img');
                    if (imgTag && mainImage) {
                        mainImage.src = imgTag.src;
                    }
                });
            });
        }

        // Quantity Selector Controls
        const qtyInput = document.getElementById('qtyInput');
        const qtyMinus = document.getElementById('qtyMinus');
        const qtyPlus = document.getElementById('qtyPlus');

        if (qtyMinus && qtyPlus && qtyInput) {
            qtyMinus.addEventListener('click', () => {
                let val = parseInt(qtyInput.value) || 1;
                if (val > 1) qtyInput.value = val - 1;
            });
            qtyPlus.addEventListener('click', () => {
                let val = parseInt(qtyInput.value) || 1;
                if (val < 10) qtyInput.value = val + 1;
            });
        }

        // Wishlist button
        const wishlistBtn = document.querySelector('.wishlist-btn');
        if (wishlistBtn) {
            wishlistBtn.addEventListener('click', function() {
                alert('Wishlist feature coming soon!');
            });
        }

        // Add to cart button
        const addToCartBtn = document.querySelector('.add-to-cart-btn');
        if (addToCartBtn) {
            addToCartBtn.addEventListener('click', function() {
                alert('Add to cart feature coming soon!');
            });
        }

        // Buy now button
        const buyNowBtn = document.querySelector('.buy-now-btn');
        if (buyNowBtn) {
            buyNowBtn.addEventListener('click', function() {
                alert('Buy now feature coming soon!');
            });
        }
    </script>
</body>
</html>