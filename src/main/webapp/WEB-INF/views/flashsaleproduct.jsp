<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>⚡ Flash Sale: <c:out value="${product.title}"/> — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/flashsaleproduct.css?v=2">
    <!-- Card styles (.ar-card ...) shared with productDetails.jsp -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/produc.css?v=11">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <c:if test="${product == null}">
        <div style="padding:50px;text-align:center;background:#fff;margin:90px 20px;">
            <h1>Flash deal not found</h1>
            <p>This deal may have ended.</p>
            <p><a href="${pageContext.request.contextPath}/">Return to Home</a></p>
        </div>
    </c:if>

    <c:if test="${product != null}">
    <div class="product-page">

        <!-- Breadcrumb -->
        <nav class="breadcrumb">
            <a href="${pageContext.request.contextPath}/">Home</a>
            <span>/</span>
            <a href="${pageContext.request.contextPath}/flash"><span class="flash-tag">⚡ Flash Sale</span></a>
            <span>/</span>
            <span class="current"><c:out value="${product.title}"/></span>
        </nav>

        <!-- Main Product Section -->
        <div class="product-main">

            <!-- Gallery -->
            <div class="product-gallery">
                <c:if test="${not empty product.galleryImages}">
                    <div class="gallery-thumbs">
                        <c:forEach var="img" items="${product.galleryImages}" varStatus="status">
                            <div class="thumb ${status.first ? 'active' : ''}">
                                <img src="${img}" alt="<c:out value='${product.title}'/>" class="thumb-img">
                            </div>
                        </c:forEach>
                    </div>
                </c:if>
                <div class="gallery-main">
                    <c:if test="${not empty product.mainImage}">
                        <img src="${product.mainImage}" alt="<c:out value='${product.title}'/>" id="mainImage">
                    </c:if>
                    <button type="button" class="wishlist-btn" aria-label="Add to wishlist" data-product-id="${product.productId}">
                        <span class="material-symbols-outlined">favorite</span>
                    </button>
                </div>
            </div>

            <!-- Info -->
            <div class="product-info">
                <div class="flash-banner-alert">
                    <span class="flash-banner-text">
                        <span class="material-symbols-outlined">bolt</span> FLASH SALE LIMITED OFFER
                    </span>
                    <span class="timer-badge">Ends in: <span id="fsTimer" data-end="${product.endTime}">--:--:--</span></span>
                </div>

                <h1 class="product-title"><c:out value="${product.title}"/></h1>

                <div class="product-price">
                    <span class="current-price">${product.currentPrice}</span>
                    <span class="original-price">${product.originalPrice}</span>
                    <span class="discount-badge">${product.discount}</span>
                </div>

                <!-- Stock bar -->
                <div class="stock-container">
                    <div class="stock-label">
                        Only <strong>${product.stockLeft}</strong> left at this price - order soon!
                        <span class="stock-meta">(limit ${product.limitPerCustomer} per customer · ${product.soldText})</span>
                    </div>
                    <div class="stock-bar">
                        <div class="stock-fill" style="width: ${product.percentLeft}%;"></div>
                    </div>
                </div>

                <div class="product-actions">
                    <div class="quantity-wrapper">
                        <label for="qtyInput" class="quantity">Quantity</label>
                        <div class="quantity-selector">
                            <button type="button" class="qty-btn minus" id="qtyMinus" aria-label="Decrease quantity">-</button>
                            <input type="number" value="1" min="1" max="${product.maxQty}" class="qty-input" id="qtyInput">
                            <button type="button" class="qty-btn plus" id="qtyPlus" aria-label="Increase quantity">+</button>
                        </div>
                        <span class="qty-note">Max ${product.maxQty} per order</span>
                    </div>

                    <div class="action-buttons">
                        <button type="button" class="buy-now-btn" data-product-id="${product.productId}">Claim Flash Deal</button>
                        <button type="button" class="add-to-cart-btn" data-product-id="${product.productId}">
                            <span class="material-symbols-outlined">shopping_bag</span>
                            Add to Cart
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Details -->
        <div class="product-tabs">
            <div class="tab-headers">
                <button type="button" class="tab-btn active">Flash Item Details</button>
            </div>
            <div class="tab-content">
                <div class="tab-panel active">
                    <div class="content-restriction-wrapper">
                        <div class="restricted-content-body" id="restrictedContentBody">
                            <%-- already sanitized on the server (Jsoup), so it is printed as HTML --%>
                            <div class="product-desc">${product.descriptionHtml}</div>

                            <c:if test="${not empty product.specs}">
                                <h4>Specifications</h4>
                                <ul class="specs-list">
                                    <c:forEach var="spec" items="${product.specs}">
                                        <li><strong><c:out value="${spec.key}"/></strong><span><c:out value="${spec.value}"/></span></li>
                                    </c:forEach>
                                </ul>
                            </c:if>

                            <c:if test="${not empty product.mainImage}">
                                <img src="${product.mainImage}" alt="<c:out value='${product.title}'/>" id="detailsMainImage">
                            </c:if>
                        </div>

                        <div class="restriction-overlay-ui" id="restrictionOverlayUi">
                            <button type="button" id="viewMoreBtn" class="view-more-action-btn">View More</button>
                        </div>

                        <div class="view-less-container" id="viewLessContainer">
                            <button type="button" id="viewLessBtn" class="view-less-action-btn">View Less</button>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- More live flash deals (only live ones, the current deal is skipped) -->
        <c:if test="${not empty relatedFlashDeals}">
            <div class="related-header">
                <span class="related-title">⚡ More Live Flash Deals</span>
                <a href="${pageContext.request.contextPath}/flash" class="related-more">see all</a>
            </div>

            <div class="ar-page">
                <div class="ar-grid" id="flashRelatedGrid">
                    <c:forEach var="d" items="${relatedFlashDeals}">
                        <c:if test="${d.itemId ne param.id}">
                        <article class="ar-card">
                            <button type="button" class="ar-wish" aria-label="Save to wishlist">
                                <span class="material-symbols-outlined ar-ic-sm">favorite</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/flashsaleproduct?id=${d.itemId}" class="ar-card-link">
                                <div class="ar-card-img">
                                    <c:if test="${not empty d.mainImage}">
                                        <img src="${d.mainImage}" alt="<c:out value='${d.title}'/>" loading="lazy">
                                    </c:if>
                                    <span class="ar-badge">${d.discount}</span>
                                </div>
                                <div class="ar-card-body">
                                    <div>
                                        <div class="ar-card-top">
                                            <span class="ar-brand">⚡ Flash</span>
                                        </div>
                                        <h3 class="ar-p-title"><c:out value="${d.title}"/></h3>
                                    </div>
                                    <div class="ar-price-row">
                                        <div>
                                            <div class="ar-price">${d.currentPrice}</div>
                                            <div class="ar-old">${d.originalPrice}</div>
                                        </div>
                                        <%-- Same hook as productDetails.jsp: .js-add-to-cart. Click is handled in the script below (it stops the parent <a> from navigating). --%>
                                        <span class="ar-view js-add-to-cart" role="button" tabindex="0"
                                              data-product-id="${d.productId}">Add to cart</span>
                                    </div>
                                </div>
                            </a>
                        </article>
                        </c:if>
                    </c:forEach>
                </div>
            </div>
            <div class="pagination" id="flashRelatedPagination"></div>
        </c:if>

    </div>
    </c:if>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        // ===== Gallery =====
        const mainImage = document.getElementById('mainImage');
        const detailsMainImage = document.getElementById('detailsMainImage');
        const thumbs = document.querySelectorAll('.thumb');
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

        // ===== Quantity (max comes from the server: flash stock left and per-customer limit) =====
        const qtyInput = document.getElementById('qtyInput');
        const qtyMinus = document.getElementById('qtyMinus');
        const qtyPlus  = document.getElementById('qtyPlus');
        if (qtyMinus && qtyPlus && qtyInput) {
            const max = parseInt(qtyInput.max) || 1;
            function clampQty() {
                let v = parseInt(qtyInput.value) || 1;
                qtyInput.value = Math.max(1, Math.min(max, v));
            }
            qtyMinus.addEventListener('click', () => {
                let v = parseInt(qtyInput.value) || 1;
                if (v > 1) qtyInput.value = v - 1;
            });
            qtyPlus.addEventListener('click', () => {
                let v = parseInt(qtyInput.value) || 1;
                if (v < max) qtyInput.value = v + 1;
            });
            qtyInput.addEventListener('change', clampQty);
        }


        // Add to Cart: same flow as productDetails.jsp (addToCart is defined in Cart.js, loaded by header.jsp)
        const PRODUCT_ID = '${product.productId}';

        // Shared helper for both main buttons. Returns a Promise that resolves after addToCart finishes.
        function addFlashItemToCart(btn) {
            const max = parseInt(qtyInput ? qtyInput.max : 1) || 1;
            const qty = Math.max(1, Math.min(max, parseInt(qtyInput ? qtyInput.value : 1) || 1));
            console.log('[flash cart] click', { PRODUCT_ID: PRODUCT_ID, qty: qty });

            if (!PRODUCT_ID || PRODUCT_ID === 'null') {
                console.error('[flash cart] PRODUCT_ID is empty: check product.productId in the controller/DTO');
                alert('This deal has no product id, so it cannot be added to the cart.');
                return Promise.reject(new Error('missing product id'));
            }
            if (typeof addToCart !== 'function') {
                console.error('[flash cart] addToCart is not defined: Cart.js is not loaded on this page (check the path/casing in header.jsp)');
                alert('Cart is not available on this page.');
                return Promise.reject(new Error('addToCart missing'));
            }
            try {
                return Promise.resolve(addToCart(PRODUCT_ID, qty, btn));
            } catch (e) {
                console.error('[flash cart] addToCart threw:', e);
                return Promise.reject(e);
            }
        }

        // Add to Cart
        const addToCartBtn = document.querySelector('.add-to-cart-btn');
        if (addToCartBtn) {
            addToCartBtn.addEventListener('click', function () {
                addFlashItemToCart(addToCartBtn)
                    .then(function (r) { console.log('[flash cart] done', r); })
                    .catch(function (e) { console.error('[flash cart] failed', e); });
            });
        }

        // Claim Flash Deal: add to cart, then go to the cart page (change /cart if your route differs)
        const claimBtn = document.querySelector('.buy-now-btn');
        if (claimBtn) {
            claimBtn.addEventListener('click', function () {
                addFlashItemToCart(claimBtn)
                    .then(function () { window.location.href = '${pageContext.request.contextPath}/cart'; })
                    .catch(function (e) { console.error('[flash cart] claim failed', e); });
            });
        }

        // ===== Countdown; when it hits zero the deal is over, so go back to the list =====
        (function () {
            const el = document.getElementById('fsTimer');
            if (!el) return;
            const end = Number(el.dataset.end);
            const pad = n => String(n).padStart(2, '0');
            function tick() {
                let s = Math.floor((end - Date.now()) / 1000);
                if (s <= 0) {
                    el.textContent = 'Ended';
                    setTimeout(() => { location.href = '${pageContext.request.contextPath}/flash'; }, 1500);
                    return false;
                }
                const d = Math.floor(s / 86400); s %= 86400;
                const h = Math.floor(s / 3600);  s %= 3600;
                const m = Math.floor(s / 60);    s %= 60;
                el.textContent = (d ? d + 'd ' : '') + pad(h) + ':' + pad(m) + ':' + pad(s);
                return true;
            }
            if (tick()) {
                const t = setInterval(() => { if (!tick()) clearInterval(t); }, 1000);
            }
        })();



       // ===== Related deals: Add to cart (stops the parent <a> from navigating) =====
       (function () {
           var grid = document.getElementById('flashRelatedGrid');
           if (!grid) return;

           function handle(e) {
               var el = e.target.closest('.js-add-to-cart');
               if (!el || !grid.contains(el)) return;
               e.preventDefault();
               e.stopPropagation();

               var id = el.getAttribute('data-product-id');
               if (!id || id === 'null' || id === '0') {
                   console.error('[flash cart] related card has no product id');
                   alert('This deal cannot be added to the cart right now.');
                   return;
               }
               if (typeof addToCart !== 'function') {
                   console.error('[flash cart] addToCart is not defined: Cart.js is not loaded on this page');
                   alert('Cart is not available on this page.');
                   return;
               }

               // Do NOT set el.dataset.busy here: addToCart() already uses it to block double clicks.
               addToCart(id, 1, el);
           }

           // capture phase: runs before the <a> navigates and before any other handler
           grid.addEventListener('click', handle, true);
           grid.addEventListener('keydown', function (e) {
               if (e.key === 'Enter' || e.key === ' ') handle(e);
           }, true);
       })();

        // ===== Related deals: pagination, 8 per page =====
        (function () {
            var PER_PAGE = 8;
            var HEADER_OFFSET = 100;
            var grid = document.getElementById('flashRelatedGrid');
            var nav  = document.getElementById('flashRelatedPagination');
            if (!grid || !nav) return;

            var cards = Array.prototype.slice.call(grid.querySelectorAll('.ar-card'));
            var total = Math.ceil(cards.length / PER_PAGE);
            var current = 1;
            if (total <= 1) { nav.style.display = 'none'; return; }

            function getPageFromUrl() {
                var p = parseInt(new URLSearchParams(window.location.search).get('page'), 10);
                return (p >= 1 && p <= total) ? p : 1;
            }
            function pageItems() {
                if (total <= 7) return Array.from({ length: total }, function (_, i) { return i + 1; });
                var items = [1];
                var start = Math.max(2, current - 1), end = Math.min(total - 1, current + 1);
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
                if (opts.active) { s.className = 'active'; s.setAttribute('aria-current', 'page'); }
                else if (opts.disabled) { s.className = 'disabled'; s.setAttribute('aria-disabled', 'true'); }
                else {
                    s.setAttribute('role', 'button');
                    s.tabIndex = 0;
                    s.addEventListener('click', function () { goTo(page, true); });
                    s.addEventListener('keydown', function (e) {
                        if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); goTo(page, true); }
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
                var start = (page - 1) * PER_PAGE, end = start + PER_PAGE;
                cards.forEach(function (card, i) { card.style.display = (i >= start && i < end) ? '' : 'none'; });
                renderNav();
            }
            function goTo(page, userClicked) {
                if (page < 1 || page > total) return;
                showPage(page);
                if (userClicked) {
                    var url = new URL(window.location);
                    url.searchParams.set('page', page);
                    history.pushState({ page: page }, '', url);
                    var top = grid.getBoundingClientRect().top;
                    if (top < HEADER_OFFSET) {
                        window.scrollTo({ top: top + window.pageYOffset - HEADER_OFFSET, behavior: 'smooth' });
                    }
                }
            }
            window.addEventListener('popstate', function () { showPage(getPageFromUrl()); });
            showPage(getPageFromUrl());
        })();

        // ===== VIEW MORE / VIEW LESS =====
        const viewMoreBtn = document.getElementById('viewMoreBtn');
        const viewLessBtn = document.getElementById('viewLessBtn');
        const restrictionOverlay = document.getElementById('restrictionOverlayUi');
        const restrictedBody = document.getElementById('restrictedContentBody');
        const viewLessContainer = document.getElementById('viewLessContainer');

        if (viewMoreBtn && viewLessBtn && restrictionOverlay && restrictedBody && viewLessContainer) {
            const VISIBLE_IMAGE_PX = 260;
            const MIN_COLLAPSED_PX = 300;
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
