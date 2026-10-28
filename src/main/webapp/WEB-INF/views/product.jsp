<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.title} — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=2">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="product-page">

        <!-- Breadcrumb -->
        <nav class="breadcrumb">
            <a href="${pageContext.request.contextPath}/">Home</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/category?name=${product.category}">${product.category}</a>
            <c:if test="${not empty product.subCategory}">
                <span>/</span>
                <a href="${pageContext.request.contextPath}/category?name=${product.category}&sub=${product.subCategory}">${product.subCategory}</a>
            </c:if>
            <span>/</span>
            <span class="current">${product.title}</span>
        </nav>

        <!-- Main Product Section -->
        <div class="product-main">

            <!-- Left: Image Gallery -->
            <div class="product-gallery">
                <div class="gallery-thumbs">
                    <c:forEach var="img" items="${product.galleryImages}" varStatus="status">
                        <div class="thumb ${status.first ? 'active' : ''}">
                            <img src="${pageContext.request.contextPath}/HomePageImages/Products/${img}" alt="${product.title}" class="thumb-img">
                        </div>
                    </c:forEach>
                </div>
                <div class="gallery-main">
                    <img src="${pageContext.request.contextPath}/HomePageImages/Products/${product.mainImage}" alt="${product.title}" id="mainImage">
                    <button class="wishlist-btn" aria-label="Add to wishlist">
                        <span class="material-symbols-outlined">favorite</span>
                    </button>
                </div>
            </div>

            <!-- Right: Product Info -->
            <div class="product-info">
                <h1 class="product-title">${product.title}</h1>

                <div class="product-rating">
                    <div class="stars">
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined filled">star</span>
                        <span class="material-symbols-outlined half">star_half</span>
                    </div>
                    <span class="rating-text">${product.rating}</span>
                    <span class="review-count">(${product.reviewCount} reviews)</span>
                </div>

                <div class="product-price">
                    <span class="current-price">${product.currentPrice}</span>
                    <c:if test="${not empty product.originalPrice}">
                        <span class="original-price">${product.originalPrice}</span>
                    </c:if>
                    <c:if test="${not empty product.discount}">
                        <span class="discount-badge">${product.discount}</span>
                    </c:if>
                </div>

                <!-- Color Options -->
                <c:if test="${not empty product.colors}">
                    <div class="product-option">
                        <label>Color: <span class="selected-value" id="selectedColor">${product.colors[0]}</span></label>
                        <div class="color-options">
                            <c:forEach var="color" items="${product.colors}" varStatus="status">
                                <button type="button" class="color-btn ${status.first ? 'active' : ''}" data-color="${color}">${color}</button>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- RAM Options -->
                <c:if test="${not empty product.rams}">
                    <div class="product-option">
                        <label>RAM: <span class="selected-value" id="selectedRam">${product.rams[0]}</span></label>
                        <div class="size-options">
                            <c:forEach var="ram" items="${product.rams}" varStatus="status">
                                <button type="button" class="size-btn ${status.first ? 'active' : ''}" data-ram="${ram}">${ram}</button>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- Size Options -->
                <c:if test="${not empty product.sizes}">
                    <div class="product-option">
                        <label>Size: <span class="selected-value" id="selectedSize">${product.sizes[0]}</span></label>
                        <div class="size-options">
                            <c:forEach var="size" items="${product.sizes}" varStatus="status">
                                <button type="button" class="size-btn ${status.first ? 'active' : ''}" data-size="${size}">${size}</button>
                            </c:forEach>
                        </div>
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
                    <c:if test="${not empty product.specs}">
                        <h4>Specifications</h4>
                        <ul class="specs-list">
                            <c:forEach var="spec" items="${product.specs}">
                                <li><strong>${spec.key}:</strong> ${spec.value}</li>
                            </c:forEach>
                        </ul>
                    </c:if>
                </div>
            </div>
        </div>

    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        // Gallery Thumbnail Switcher
        const mainImage = document.getElementById('mainImage');
        const thumbs = document.querySelectorAll('.thumb');

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
    </script>
</body>
</html>