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
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${product.name} — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/product.css?v=10">
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

                        <!-- Go to Store: opens this product's seller store -->
                        <a href="${pageContext.request.contextPath}/store/${product.sellerId}" class="go-to-store-btn">
                            <span class="material-symbols-outlined">storefront</span>
                            Go to Store
                        </a>
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
                if (val < 10) qtyInput.value = val + 1;
            });
        }

        // Button Placeholders
        const wishlistBtn = document.querySelector('.wishlist-btn');
        if (wishlistBtn) {
            wishlistBtn.addEventListener('click', function() { alert('Wishlist feature coming soon!'); });
        }
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
            buyNowBtn.addEventListener('click', function() { alert('Buy now feature coming soon!'); });
        }

        // "You May Also Like": wishlist heart toggle (same as product.jsp)
        document.querySelectorAll('#similarGrid .ar-wish').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                btn.classList.toggle('ar-wished');
            });
        });

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
    </script>
</body>
</html>
