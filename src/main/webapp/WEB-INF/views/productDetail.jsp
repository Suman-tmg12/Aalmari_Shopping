<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=12">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />

    <!-- Same card styles as product.jsp (used by the "You May Also Like" section) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/produc.css?v=11">
    <style>
        /* ===== PAGINATION (same as product.jsp). var() fallbacks are used only if the variable is not defined on this page ===== */
        .pagination {
            display: flex;
            flex-wrap: wrap;
            justify-content: center;
            align-items: center;
            gap: 8px;
            margin-bottom: clamp(32px, 5vw, 48px);
            font-size: 13px;
            color: var(--color-text-muted, #6b7280);
        }

        .pagination span {
            cursor: pointer;
            padding: 6px 10px;
            border-radius: var(--radius-sm, 8px);
            transition: background 0.15s var(--ease, ease), color 0.15s var(--ease, ease);
        }

        .pagination span:hover {
            background: rgba(255, 255, 255, 0.6);
        }

        .pagination span.active {
            font-weight: bold;
            color: #FFFFFF;
            background: var(--color-accent, #ff7a00);
        }

        .pagination span.disabled { opacity: .4; cursor: not-allowed; pointer-events: none; }
        .pagination span.pg-dots { cursor: default; }
        .pagination span.pg-dots:hover { background: none; }

        .review-section { max-width:80rem; margin:32px auto 8px; padding:28px 32px; background:#fff; border:1px solid #e5e7eb; border-radius:20px; }
        .review-heading { display:flex; align-items:center; justify-content:space-between; gap:16px; margin-bottom:20px; }
        .review-eyebrow { color:#ff7b00; font-size:12px; font-weight:800; text-transform:uppercase; letter-spacing:.08em; }
        .review-heading h2 { color:#111827; font-size:22px; margin-top:2px; }
        .review-write-btn,.review-login-link { display:inline-flex; align-items:center; gap:7px; border-radius:10px; border: none; cursor: pointer; padding:10px 14px; background:#ff7b00; color:#fff; font-size:13px; font-weight:800; }
        .review-login-link { background:#111827; }
        .review-eligible-note { color:#6b7280; font-size:12px; background:#fff7ed; border:1px solid #fed7aa; border-radius:999px; padding:8px 12px; }
        .review-list { display:grid; gap:12px; }
        .review-card { border:1px solid #e5e7eb; border-radius:14px; padding:16px; }
        .review-card-head { display:flex; align-items:center; gap:10px; }
        .review-avatar { width:40px; height:40px; border-radius:50%; display:grid; place-items:center; background:#fff7ed; color:#c95700; font-weight:800; }
        .review-user { font-size:14px; font-weight:800; color:#111827; }
        .review-meta { margin-top:2px; }
        .verified-badge { color:#059669; font-size:11px; font-weight:700; }
        .review-stars { margin-left:auto; color:#ff7b00; }
        .review-stars-value { color:#111827; }
        .review-comment { color:#4b5563; font-size:13px; line-height:1.7; margin:12px 0 0 50px; white-space:pre-wrap; }
        .review-empty { text-align:center; padding:28px; color:#6b7280; border:1px dashed #d1d5db; border-radius:14px; }
        .review-empty .material-symbols-outlined { color:#ff7b00; font-size:36px; }
        .review-modal { display:none; position:fixed; inset:0; z-index:4000; background:rgba(17,24,39,.55); backdrop-filter:blur(3px); align-items:center; justify-content:center; padding:16px; }
        .review-modal.open { display:flex; }
        .review-modal-card { position:relative; width:min(520px,100%); background:#fff; border-radius:18px; padding:24px; box-shadow:0 24px 60px rgba(0,0,0,.22); }
        .review-modal-close { position:absolute; top:12px; right:14px; font-size:24px; color:#6b7280; border: none; background: none; cursor: pointer; }
        .review-modal-card h2 { font-size:20px; color:#111827; }
        .review-modal-subtitle { color:#6b7280; font-size:13px; margin:4px 0 16px; }
        .review-star-picker { display:flex; gap:4px; margin-bottom:12px;}
        .review-star-picker button { color:#d1d5db; font-size:34px; line-height:1; transition:.15s; background: none; border: none; cursor: pointer; }
        .review-star-picker button.active { color:#ffb000; }
        .review-modal textarea { width:100%; min-height:130px; resize:vertical; border:1px solid #d1d5db; border-radius:12px; padding:12px; outline:none; }
        .review-modal textarea:focus { border-color:#ff7b00; box-shadow:0 0 0 3px rgba(255,123,0,.12); }
        .review-character-count { text-align:right; color:#9ca3af; font-size:11px; margin-top:4px; }
        .review-submit-btn { width:100%; margin-top:10px; border-radius:10px; background:#ff7b00; color:#fff; padding:11px; font-weight:800; border: none; cursor: pointer; }
        .review-error { min-height:18px; color:#e11d48; font-size:12px; margin-top:8px; }
        @media(max-width:640px){ .review-section{margin:24px 16px;padding:20px 16px}.review-heading{align-items:flex-start}.review-heading h2{font-size:19px}.review-comment{margin-left:0}.review-modal-card{padding:20px}.review-eligible-note{max-width:180px;text-align:center} }
    </style>
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
                        <button type="button" class="wishlist-btn" aria-label="Add to wishlist" data-product-id="${product.id}">
                            <span class="material-symbols-outlined">favorite</span>
                        </button>
                    </div>
                </div>

                <div class="product-info">
                    <h1 class="product-title">${product.name}</h1>
                    <div class="product-rating">
                        <div class="stars" aria-label="Product rating">
                            <span class="material-symbols-outlined filled">star</span>
                            <span class="material-symbols-outlined filled">star</span>
                            <span class="material-symbols-outlined filled">star</span>
                            <span class="material-symbols-outlined filled">star</span>
                            <span class="material-symbols-outlined filled">star</span>
                        </div>
                        <span class="rating-text"><%= String.format(java.util.Locale.US, "%.1f", request.getAttribute("averageRating") == null ? 0.0 : (Double) request.getAttribute("averageRating")) %></span>
                        <span class="review-count">(${reviewCount} reviews)</span>
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
                                <input type="number" value="1" min="1" max="${product.stock == null ? 1 : (product.stock < 10 ? product.stock : 10)}" class="qty-input" id="qtyInput">
                                <button type="button" class="qty-btn plus" id="qtyPlus">+</button>
                            </div>
                        </div>
                        <div class="action-buttons">
                            <button type="button" class="buy-now-btn" ${product.stock == null || product.stock <= 0 ? 'disabled style="opacity:.5;cursor:not-allowed"' : ''}>Buy Now</button>
                            <button type="button" class="add-to-cart-btn" ${product.stock == null || product.stock <= 0 ? 'disabled style="opacity:.5;cursor:not-allowed"' : ''}>
                                <span class="material-symbols-outlined">shopping_bag</span>
                                Add to Cart
                            </button>
                        </div>

                        <!-- Go to Store: opens this product's seller store -->
                        <a href="${pageContext.request.contextPath}/store/${product.sellerId}" class="go-to-store-btn">
                            <span class="material-symbols-outlined">storefront</span>
                            Go to Store
                        </a>
                        <button type="button" class="ask-seller-btn" id="openMessageModal">
                            <span class="material-symbols-outlined">chat</span>
                            Ask Seller
                        </button>
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

            <!-- ============ MESSAGE THE SELLER ============ -->
            <div class="message-modal" id="messageModal" aria-hidden="true">
                <div class="message-modal-card" role="dialog" aria-modal="true" aria-labelledby="messageModalTitle">
                    <button type="button" class="message-modal-close" id="closeMessageModal" aria-label="Close">×</button>
                    <span class="message-modal-icon material-symbols-outlined">chat</span>
                    <h2 id="messageModalTitle">Ask the Seller</h2>
                    <p>Send a message about <strong><c:out value="${product.name}"/></strong>.</p>
                    <div class="customer-message-thread" id="customerMessageThread"></div>
                    <label for="messageSubject">Subject</label>
                    <input type="text" id="messageSubject" maxlength="120" value="Question about <c:out value="${product.name}"/>">
                    <label for="messageBody">Message</label>
                    <textarea id="messageBody" maxlength="2000" placeholder="Ask about availability, delivery, size, or product details..."></textarea>
                    <div class="message-modal-footer">
                        <span id="messageCharacterCount">0/2000</span>
                        <button type="button" id="sendMessageBtn">Send Message</button>
                    </div>
                    <p class="message-error" id="messageError"></p>
                </div>
            </div>

            <!-- ============ CUSTOMER REVIEWS ============ -->
            <section class="review-section" id="customerReviews">
                <div class="review-heading">
                    <div>
                        <span class="review-eyebrow">Customer feedback</span>
                        <h2>Ratings &amp; Reviews</h2>
                    </div>
                    <c:choose>
                        <c:when test="${canReview}">
                            <button type="button" class="review-write-btn" id="openReviewModal">
                                <span class="material-symbols-outlined">rate_review</span>
                                <c:choose>
                                    <c:when test="${not empty existingReview}">Edit Your Review</c:when>
                                    <c:otherwise>Write a Review</c:otherwise>
                                </c:choose>
                            </button>
                        </c:when>
                        <c:when test="${empty sessionScope.userId}">
                            <a href="${pageContext.request.contextPath}/login" class="review-login-link">Log in to review</a>
                        </c:when>
                        <c:otherwise>
                            <span class="review-eligible-note">Available after a delivered purchase</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <c:choose>
                    <c:when test="${not empty reviews}">
                        <div class="review-list">
                            <c:forEach var="review" items="${reviews}">
                                <article class="review-card">
                                    <div class="review-card-head">
                                        <div class="review-avatar">${not empty review.user.firstName ? fn:substring(review.user.firstName,0,1) : 'A'}</div>
                                        <div>
                                            <div class="review-user"><c:out value="${review.user.firstName}"/> <c:out value="${review.user.lastName}"/></div>
                                            <div class="review-meta"><span class="verified-badge">✓ Verified purchase</span></div>
                                        </div>
                                        <strong class="review-stars"><span class="review-stars-value">${review.rating}.0</span> / 5</strong>
                                    </div>
                                    <p class="review-comment"><c:out value="${review.comment}"/></p>
                                </article>
                            </c:forEach>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="review-empty">
                            <span class="material-symbols-outlined">reviews</span>
                            <h3>No reviews yet</h3>
                            <p>Be the first to review this product after purchasing and receiving it.</p>
                        </div>
                    </c:otherwise>
                </c:choose>
            </section>

            <div class="review-modal" id="reviewModal" aria-hidden="true">
                <div class="review-modal-card" role="dialog" aria-modal="true" aria-labelledby="reviewModalTitle">
                    <button type="button" class="review-modal-close" id="closeReviewModal" aria-label="Close">×</button>
                    <h2 id="reviewModalTitle"><c:choose><c:when test="${not empty existingReview}">Edit Your Review</c:when><c:otherwise>Write a Review</c:otherwise></c:choose></h2>
                    <p class="review-modal-subtitle">Share your experience with other shoppers.</p>
                    <div class="review-star-picker" id="reviewStarPicker" aria-label="Choose rating">
                        <button type="button" data-rating="1" aria-label="1 star">★</button>
                        <button type="button" data-rating="2" aria-label="2 stars">★</button>
                        <button type="button" data-rating="3" aria-label="3 stars">★</button>
                        <button type="button" data-rating="4" aria-label="4 stars">★</button>
                        <button type="button" data-rating="5" aria-label="5 stars">★</button>
                    </div>
                    <textarea id="reviewComment" maxlength="1000" placeholder="Tell others what you liked or what could be better..."><c:out value="${existingReview.comment}"/></textarea>
                    <p class="review-character-count"><span id="reviewCharacterCount">0</span>/1000</p>
                    <button type="button" class="review-submit-btn" id="submitReviewBtn">Submit Review</button>
                    <p class="review-error" id="reviewError"></p>
                </div>
            </div>

            <!-- ============ YOU MAY ALSO LIKE ============ -->
            <%
                @SuppressWarnings("unchecked")
                List<com.example.aalmari.model.SellerProduct> similarProducts =
                        (List<com.example.aalmari.model.SellerProduct>) request.getAttribute("similarProducts");

                if (similarProducts != null && !similarProducts.isEmpty()) {
            %>
            <div class="section-header">
                <span class="section-title">You May Also Like</span>
            </div>

            <div class="ar-page">
                <div class="ar-grid" id="similarGrid">
                <%
                    for (com.example.aalmari.model.SellerProduct p : similarProducts) {
                        if (!Boolean.TRUE.equals(p.getActive())) continue;

                        // Same price logic as ProductController (price = original, discount in %)
                        int origPrice = p.getPrice() == null ? 0 : p.getPrice();
                        int discount = p.getDiscount() == null ? 0 : p.getDiscount();
                        int price = Math.max(0, (int) (origPrice * (100 - discount) / 100.0));
                        long oldPrice = (discount > 0 && discount < 100) ? origPrice : 0;

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
                                    <span class="ar-view js-add-to-cart" role="button" tabindex="0"
                                          data-product-id="<%= p.getId() %>">Add to cart</span>
                                </div>
                            </div>
                        </a>
                    </article>
                <%
                    }
                %>
                </div>
            </div>

            <!-- Pagination (built by JavaScript) -->
            <div class="pagination" id="similarPagination"></div>
            <% } %>
            <!-- ============ /YOU MAY ALSO LIKE ============ -->

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
                let max = parseInt(qtyInput.max, 10) || 10;
                if (val < max) qtyInput.value = val + 1;
            });
        }

        // Button Placeholders

        const PRODUCT_ID = '${product.id}';
        const addToCartBtn = document.querySelector('.add-to-cart-btn');
        if (addToCartBtn) {
            addToCartBtn.addEventListener('click', function() {
                const qty = Math.max(1, Math.min(10, parseInt(qtyInput ? qtyInput.value : 1) || 1));
                addToCart(PRODUCT_ID, qty, addToCartBtn);   // defined in cart.js (loaded by header.jsp)
            });
        }
        const buyNowBtn = document.querySelector('.buy-now-btn');
        if (buyNowBtn) {
            buyNowBtn.addEventListener('click', async function() {
                if (buyNowBtn.disabled) return;
                const qty = Math.max(1, Math.min(
                    parseInt(qtyInput ? qtyInput.max : '10', 10) || 10,
                    parseInt(qtyInput ? qtyInput.value : '1', 10) || 1
                ));
                buyNowBtn.disabled = true;
                buyNowBtn.textContent = 'Preparing checkout...';
                try {
                    const form = new URLSearchParams();
                    form.append('productId', PRODUCT_ID);
                    form.append('quantity', String(qty));
                    const response = await fetch('${pageContext.request.contextPath}/checkout/buy-now', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                        body: form.toString()
                    });
                    const data = await response.json().catch(function() { return {}; });
                    if (response.status === 401) {
                        window.location.href = '${pageContext.request.contextPath}/login';
                        return;
                    }
                    if (!response.ok) throw new Error(data.error || 'Could not start checkout.');
                    window.location.href = '${pageContext.request.contextPath}' + data.redirect;
                } catch (error) {
                    alert(error.message);
                    buyNowBtn.disabled = false;
                    buyNowBtn.textContent = 'Buy Now';
                }
            });
        }



        // "You May Also Like": pagination, 8 products per page (same logic as product.jsp)
        (function () {
            var PER_PAGE = 8;
            var HEADER_OFFSET = 100; // change to your sticky header height in px
            var grid  = document.getElementById('similarGrid');
            var nav   = document.getElementById('similarPagination');
            if (!grid || !nav) return;

            var cards = Array.prototype.slice.call(grid.querySelectorAll('.ar-card'));
            var total = Math.ceil(cards.length / PER_PAGE);
            var current = 1;

            // Hide pagination when everything fits on one page
            if (total <= 1) { nav.style.display = 'none'; return; }

            function getPageFromUrl() {
                var p = parseInt(new URLSearchParams(window.location.search).get('page'), 10);
                return (p >= 1 && p <= total) ? p : 1;
            }

            // Builds [1, '...', 4, 5, 6, '...', 20]
            function pageItems() {
                if (total <= 7) {
                    return Array.from({ length: total }, function (_, i) { return i + 1; });
                }
                var items = [1];
                var start = Math.max(2, current - 1);
                var end   = Math.min(total - 1, current + 1);
                if (start > 2) items.push('...');
                for (var i = start; i <= end; i++) items.push(i);
                if (end < total - 1) items.push('...');
                items.push(total);
                return items;
            }

            function makeItem(label, page, opts) {
                opts = opts || {};
                var s = document.createElement('span');
                s.innerHTML = label;
                if (opts.active) {
                    s.className = 'active';
                    s.setAttribute('aria-current', 'page');
                } else if (opts.disabled) {
                    s.className = 'disabled';
                    s.setAttribute('aria-disabled', 'true');
                } else {
                    s.setAttribute('role', 'button');
                    s.tabIndex = 0;
                    s.addEventListener('click', function () { goTo(page, true); });
                    s.addEventListener('keydown', function (e) {
                        if (e.key === 'Enter' || e.key === ' ') {
                            e.preventDefault();
                            goTo(page, true);
                        }
                    });
                }
                return s;
            }

            function renderNav() {
                nav.innerHTML = '';
                nav.appendChild(makeItem('&lt; Previous', current - 1, { disabled: current === 1 }));
                pageItems().forEach(function (item) {
                    if (item === '...') {
                        var dots = document.createElement('span');
                        dots.className = 'pg-dots';
                        dots.textContent = '...';
                        nav.appendChild(dots);
                    } else {
                        nav.appendChild(makeItem(item, item, { active: item === current }));
                    }
                });
                nav.appendChild(makeItem('Next &gt;', current + 1, { disabled: current === total }));
            }

            function showPage(page) {
                current = page;
                var start = (page - 1) * PER_PAGE;
                var end   = start + PER_PAGE;
                cards.forEach(function (card, i) {
                    card.style.display = (i >= start && i < end) ? '' : 'none';
                });
                renderNav();
            }

            function goTo(page, userClicked) {
                if (page < 1 || page > total) return;
                showPage(page);
                if (userClicked) {
                    var url = new URL(window.location);
                    url.searchParams.set('page', page);
                    history.pushState({ page: page }, '', url);

                    // Scroll only if the top of the grid is out of view
                    var top = grid.getBoundingClientRect().top;
                    if (top < HEADER_OFFSET) {
                        window.scrollTo({
                            top: top + window.pageYOffset - HEADER_OFFSET,
                            behavior: 'smooth'
                        });
                    }
                }
            }

            // Browser back/forward buttons
            window.addEventListener('popstate', function () { showPage(getPageFromUrl()); });

            showPage(getPageFromUrl());
        })();

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
                return Math.max(MIN_COLLAPSED_PX, img.offsetTop + VISIBLE_IMAGE_PX);
            }

            function applyCollapsed() {
                const h = collapsedHeight();
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

            const detailImg = document.getElementById('detailsMainImage');
            if (detailImg && !detailImg.complete) {
                detailImg.addEventListener('load', () => { if (!expanded) applyCollapsed(); });
            }
            window.addEventListener('resize', () => { if (!expanded) applyCollapsed(); });
            applyCollapsed();
        }

        // ===== Message the seller =====
        var messageModal = document.getElementById('messageModal');
        var openMessageModal = document.getElementById('openMessageModal');
        var closeMessageModal = document.getElementById('closeMessageModal');
        var messageBody = document.getElementById('messageBody');
        var messageSubject = document.getElementById('messageSubject');
        var messageCharacterCount = document.getElementById('messageCharacterCount');
        var sendMessageBtn = document.getElementById('sendMessageBtn');
        var messageError = document.getElementById('messageError');
        var customerMessageThread = document.getElementById('customerMessageThread');

        function escapeMessageText(value) {
            return String(value == null ? '' : value).replace(/[&<>"']/g, function (c) {
                return ({ '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":"&#39;" })[c];
            });
        }

        function loadCustomerMessages() {
            if (!customerMessageThread) return;
            fetch('${pageContext.request.contextPath}/api/products/' + PRODUCT_ID + '/messages/thread')
                .then(function (response) { if (!response.ok) throw new Error('Unable to load replies'); return response.json(); })
                .then(function (items) {
                    if (!items || items.length === 0) {
                        customerMessageThread.innerHTML = '';
                        customerMessageThread.style.display = 'none';
                        return;
                    }
                    customerMessageThread.style.display = 'flex';
                    customerMessageThread.innerHTML = items.map(function (item) {
                        return '<div class="customer-message-bubble ' + (item.seller ? 'seller-reply' : 'customer-message') + '">' +
                            '<strong>' + escapeMessageText(item.seller ? 'Seller' : 'You') + '</strong>' +
                            '<p>' + escapeMessageText(item.text) + '</p>' +
                            '<span>' + escapeMessageText(item.time) + '</span></div>';
                    }).join('');
                    customerMessageThread.scrollTop = customerMessageThread.scrollHeight;
                })
                .catch(function () { customerMessageThread.innerHTML = ''; });
        }

        function refreshCustomerUnread() {
            fetch('${pageContext.request.contextPath}/api/messages/unread-count')
                .then(function (r) { return r.ok ? r.json() : { count: 0 }; })
                .then(function (data) {
                    if (openMessageModal) {
                        openMessageModal.classList.toggle('has-reply', Number(data.count || 0) > 0);
                        openMessageModal.title = Number(data.count || 0) > 0 ? 'Seller replied to your message' : 'Ask the seller';
                    }
                }).catch(function () {});
        }

        function closeSellerMessage() {
            if (messageModal) {
                messageModal.classList.remove('open');
                messageModal.setAttribute('aria-hidden', 'true');
            }
            if (messageError) messageError.textContent = '';
        }
        if (openMessageModal) openMessageModal.addEventListener('click', function () {
            <c:choose>
                <c:when test="${empty sessionScope.userId}">
                    window.location.href = '${pageContext.request.contextPath}/login';
                </c:when>
                <c:otherwise>
                    messageModal.classList.add('open');
                    messageModal.setAttribute('aria-hidden', 'false');
                    loadCustomerMessages();
                    refreshCustomerUnread();
                    if (messageBody) messageBody.focus();
                </c:otherwise>
            </c:choose>
        });
        if (closeMessageModal) closeMessageModal.addEventListener('click', closeSellerMessage);
        if (messageModal) messageModal.addEventListener('click', function (event) { if (event.target === messageModal) closeSellerMessage(); });
        if (messageBody) messageBody.addEventListener('input', function () {
            if (messageCharacterCount) messageCharacterCount.textContent = messageBody.value.length + '/2000';
        });
        refreshCustomerUnread();
        setInterval(refreshCustomerUnread, 15000);

        if (sendMessageBtn) sendMessageBtn.addEventListener('click', function () {
            var subject = messageSubject ? messageSubject.value.trim() : '';
            var body = messageBody ? messageBody.value.trim() : '';
            if (!body) { messageError.textContent = 'Write a message before sending.'; return; }
            sendMessageBtn.disabled = true;
            sendMessageBtn.textContent = 'Sending...';
            messageError.textContent = '';
            fetch('${pageContext.request.contextPath}/api/products/' + PRODUCT_ID + '/messages', {
                method: 'POST', headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ subject: subject, body: body })
            }).then(function (response) {
                return response.json().catch(function () { return {}; }).then(function (data) {
                    if (!response.ok) throw new Error(data.error || 'Unable to send message.');
                    return data;
                });
            }).then(function (data) {
                messageBody.value = '';
                if (messageCharacterCount) messageCharacterCount.textContent = '0/2000';
                loadCustomerMessages();
                messageError.textContent = data.message || 'Your message was sent to the seller.';
            }).catch(function (error) {
                messageError.textContent = error.message;
            }).finally(function () {
                sendMessageBtn.disabled = false;
                sendMessageBtn.textContent = 'Send Message';
            });
        });

        // ===== Customer product reviews =====
        var reviewModal = document.getElementById('reviewModal');
        var openReviewModal = document.getElementById('openReviewModal');
        var closeReviewModal = document.getElementById('closeReviewModal');
        var starButtons = document.querySelectorAll('#reviewStarPicker button');
        var reviewComment = document.getElementById('reviewComment');
        var reviewCharacterCount = document.getElementById('reviewCharacterCount');
        var submitReviewBtn = document.getElementById('submitReviewBtn');
        var reviewError = document.getElementById('reviewError');
        var selectedRating = <c:choose><c:when test="${not empty existingReview}">${existingReview.rating}</c:when><c:otherwise>0</c:otherwise></c:choose>;

        function paintStars(rating) {
            starButtons.forEach(function (button) {
                button.classList.toggle('active', parseInt(button.dataset.rating, 10) <= rating);
            });
        }

        function openReview() {
            paintStars(selectedRating);
            updateReviewCharacterCount();
            reviewModal.classList.add('open');
            reviewModal.setAttribute('aria-hidden', 'false');
        }

        function closeReview() {
            reviewModal.classList.remove('open');
            reviewModal.setAttribute('aria-hidden', 'true');
            reviewError.textContent = '';
        }

        function updateReviewCharacterCount() {
            if (reviewCharacterCount && reviewComment) {
                reviewCharacterCount.textContent = reviewComment.value.length;
            }
        }

        if (openReviewModal) openReviewModal.addEventListener('click', openReview);
        if (closeReviewModal) closeReviewModal.addEventListener('click', closeReview);
        if (reviewModal) reviewModal.addEventListener('click', function (event) { if (event.target === reviewModal) closeReview(); });
        starButtons.forEach(function (button) {
            button.addEventListener('click', function () {
                selectedRating = parseInt(button.dataset.rating, 10);
                paintStars(selectedRating);
                reviewError.textContent = '';
            });
        });
        if (reviewComment) reviewComment.addEventListener('input', updateReviewCharacterCount);

        if (submitReviewBtn) {
            submitReviewBtn.addEventListener('click', function () {
                if (selectedRating < 1) {
                    reviewError.textContent = 'Choose a star rating.';
                    return;
                }
                submitReviewBtn.disabled = true;
                submitReviewBtn.textContent = 'Submitting...';
                reviewError.textContent = '';

                fetch('${pageContext.request.contextPath}/api/products/' + PRODUCT_ID + '/reviews', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ rating: selectedRating, comment: reviewComment ? reviewComment.value.trim() : '' })
                }).then(function (response) {
                    return response.json().catch(function () { return {}; }).then(function (body) {
                        if (!response.ok) throw new Error(body.error || 'Unable to submit review.');
                        return body;
                    });
                }).then(function () {
                    window.location.reload();
                }).catch(function (error) {
                    reviewError.textContent = error.message;
                    submitReviewBtn.disabled = false;
                    submitReviewBtn.textContent = 'Submit Review';
                });
            });
        }

    </script>
</body>
</html>