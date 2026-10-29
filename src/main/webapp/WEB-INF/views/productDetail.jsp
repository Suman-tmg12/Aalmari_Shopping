<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=9">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <c:if test="${product == null}">
        <div style="padding: 50px; text-align: center; color: red; background: #fff; margin: 20px;">
            <h1>ERROR: Product not found!</h1>
            <p>The requested product could not be loaded from the database.</p>
            <p><a href="${pageContext.request.contextPath}/">Return to Home</a></p>
        </div>
        <jsp:include page="/WEB-INF/components/footer.jsp" />
    </c:if>

    <c:if test="${product != null}">
        <div class="product-page">

            <nav class="breadcrumb">
                <a href="${pageContext.request.contextPath}/">Home</a>
                <c:if test="${not empty product.category}">
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/category?name=${product.category}">
                        ${product.category}
                    </a>
                </c:if>
                <c:if test="${not empty product.subCategory}">
                    <span>/</span>
                    <a href="${pageContext.request.contextPath}/category?name=${product.category}&amp;sub=${product.subCategory}">
                        ${product.subCategory}
                    </a>
                </c:if>
                <span>/</span>
                <span class="current">${product.name}</span>
            </nav>

            <div class="product-main">
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
                        <img src="${galleryImages[0]}" alt="${product.name}" id="mainImage">
                        <button class="wishlist-btn" aria-label="Add to wishlist">
                            <span class="material-symbols-outlined">favorite</span>
                        </button>
                    </div>
                </div>

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
                    <div class="product-actions">
                        <div class="quantity-wrapper">
                            <label for="qtyInput" class="quantity">Quantity</label>
                            <div class="quantity-selector">
                                <button type="button" class="qty-btn minus" id="qtyMinus">-</button>
                                <input type="number" value="1" min="1" max="10" class="qty-input" id="qtyInput">
                                <button type="button" class="qty-btn plus" id="qtyPlus">+</button>
                            </div>
                        </div>
                        <div class="action-buttons">
                            <button type="button" class="buy-now-btn">Buy Now</button>
                            <button type="button" class="add-to-cart-btn">
                                <span class="material-symbols-outlined">shopping_bag</span>
                                Add to Cart
                            </button>
                        </div>
                    </div>
                </div>
            </div>

            <div class="product-tabs">
                <div class="tab-headers">
                    <button class="tab-btn active" data-tab="details">Product Details</button>
                </div>
                <div class="tab-content">
                    <div class="tab-panel active" id="details">

                        <!-- RESTRICTED CONTENT CONTAINER -->
                        <div class="content-restriction-wrapper">
                           <div class="restricted-content-body" id="restrictedContentBody">
                               <p>${product.description}</p>
                               <c:if test="${not empty specs}">
                                   <h4>Specifications</h4>
                                   <ul class="specs-list">
                                       <c:forEach var="spec" items="${specs}">
                                           <li><strong>${spec.key}:</strong> ${spec.value}</li>
                                       </c:forEach>
                                   </ul>
                               </c:if>
                               <img src="${mainImage}" alt="${product.name}" id="detailsMainImage">
                           </div>

                            <!-- GRADIENT OVERLAY & VIEW MORE BUTTON -->
                            <div class="restriction-overlay-ui" id="restrictionOverlayUi">
                                <button id="viewMoreBtn" class="view-more-action-btn">
                                    View More
                                </button>
                            </div>

                            <!-- VIEW LESS BUTTON (Hidden by default, shown via JS) -->
                            <div class="view-less-container" id="viewLessContainer">
                                <button id="viewLessBtn" class="view-less-action-btn">
                                    View Less
                                </button>
                            </div>
                        </div>

                    </div>
                </div>
            </div>

        </div>
    </c:if>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        // Gallery Logic
        const mainImage = document.getElementById('mainImage');
        const detailsMainImage = document.getElementById('detailsMainImage');
        const thumbs = document.querySelectorAll('.thumb');
        if (thumbs.length > 0) {
            thumbs.forEach(thumb => {
                thumb.addEventListener('click', () => {
                    thumbs.forEach(t => t.classList.remove('active'));
                    thumb.classList.add('active');
                    const imgTag = thumb.querySelector('img');
                    if (imgTag) {
                        if (mainImage) mainImage.src = imgTag.src;
                        if (detailsMainImage) detailsMainImage.src = imgTag.src;
                    }
                });
            });
        }

        // Quantity Logic
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

        // Button Placeholders
        const wishlistBtn = document.querySelector('.wishlist-btn');
        if (wishlistBtn) {
            wishlistBtn.addEventListener('click', function() { alert('Wishlist feature coming soon!'); });
        }
        const addToCartBtn = document.querySelector('.add-to-cart-btn');
        if (addToCartBtn) {
            addToCartBtn.addEventListener('click', function() { alert('Add to cart feature coming soon!'); });
        }
        const buyNowBtn = document.querySelector('.buy-now-btn');
        if (buyNowBtn) {
            buyNowBtn.addEventListener('click', function() { alert('Buy now feature coming soon!'); });
        }

        // ==========================================
        // VIEW MORE / VIEW LESS LOGIC (FIXED)
        // ==========================================
     // VIEW MORE / VIEW LESS
     const viewMoreBtn = document.getElementById('viewMoreBtn');
     const viewLessBtn = document.getElementById('viewLessBtn');
     const restrictionOverlay = document.getElementById('restrictionOverlayUi');
     const restrictedBody = document.getElementById('restrictedContentBody');
     const viewLessContainer = document.getElementById('viewLessContainer');

     if (viewMoreBtn && viewLessBtn && restrictionOverlay && restrictedBody && viewLessContainer) {

         const VISIBLE_IMAGE_PX = 260;   // how much of the image shows when collapsed
         const MIN_COLLAPSED_PX = 300;   // never collapse smaller than this
         let expanded = false;

         function collapsedHeight() {
             const img = document.getElementById('detailsMainImage');
             if (!img) return 400;
             // offsetTop is relative to restrictedBody (it is position: relative)
             return Math.max(MIN_COLLAPSED_PX, img.offsetTop + VISIBLE_IMAGE_PX);
         }

         function applyCollapsed() {
             const h = collapsedHeight();
             // If everything already fits, no need for the button at all
             if (restrictedBody.scrollHeight <= h + 40) {
                 restrictedBody.style.maxHeight = 'none';
                 restrictionOverlay.style.display = 'none';
                 return;
             }
             restrictedBody.style.maxHeight = h + 'px';
             restrictedBody.style.overflow = 'hidden';
             restrictionOverlay.style.display = 'flex';
             viewLessContainer.style.display = 'none';
         }

         viewMoreBtn.addEventListener('click', function () {
             expanded = true;
             restrictionOverlay.style.display = 'none';
             restrictedBody.style.maxHeight = 'none';
             restrictedBody.style.overflow = 'visible';
             viewLessContainer.style.display = 'flex';
         });

         viewLessBtn.addEventListener('click', function () {
             expanded = false;
             applyCollapsed();
             restrictedBody.scrollIntoView({ behavior: 'smooth', block: 'start' });
         });

         // Recalculate once the image has loaded (its height shifts the layout), and on resize
         const detailImg = document.getElementById('detailsMainImage');
         if (detailImg && !detailImg.complete) {
             detailImg.addEventListener('load', () => { if (!expanded) applyCollapsed(); });
         }
         window.addEventListener('resize', () => { if (!expanded) applyCollapsed(); });
         applyCollapsed();
     }
    </script>
</body>
</html>