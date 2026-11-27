<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<%!
    private static final String S3_BASE = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";
    private static final com.fasterxml.jackson.databind.ObjectMapper MAPPER =
            new com.fasterxml.jackson.databind.ObjectMapper();

    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

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
    <title><c:out value="${empty store ? 'My Store' : store.storeName}"/> - Aalmari Store</title>
    <!-- Google Material Symbols for Icons -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mystore.css?v=7">
</head>
<body>
   <jsp:include page="/WEB-INF/components/header.jsp" />

   <!-- Store Banner -->
   <div class="store-banner">
       <img src="${not empty bannerUrl ? bannerUrl : 'https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=1200&q=80'}" alt="Store Banner">
   </div>

    <!-- Store Info Bar -->
    <div class="store-info-bar">
        <div class="store-profile">
            <img src="${not empty logoUrl ? logoUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'}" alt="Store Logo" class="store-avatar">
            <div class="store-details">
                <h2><c:out value="${empty store ? 'The Corner Market' : store.storeName}"/></h2>
                <p><c:out value="${empty store ? 'This is my new Store please buy our product' : store.storeTagline}"/></p>
            </div>
        </div>

        <div class="store-stats">
            <div class="stat-item">
                <span class="value">${empty store ? 0 : sellerProducts.size()}</span>
                <span class="label">Products</span>
            </div>
            <div class="stat-item">
                <span class="value">${storeReviewCount}</span>
                <span class="label">Reviews</span>
            </div>
            <div class="stat-item">
                <span class="value"><fmt:formatNumber value="${storeRating}" maxFractionDigits="1"/> ★</span>
                <span class="label">Rating</span>
            </div>
            <div class="stat-item">
                <span class="value" id="storeFollowerCount">${followerCount}</span>
                <span class="label">Followers</span>
            </div>
        </div>

        <c:choose>
            <c:when test="${not empty sellerId}">
                <button type="button" class="follow-btn ${isFollowing ? 'following' : ''}" id="followStoreBtn"
                        data-seller-id="${sellerId}" data-following="${isFollowing}">
                    ${isFollowing ? 'Following' : 'Follow store'}
                </button>
            </c:when>
            <c:otherwise>
                <button type="button" class="follow-btn" disabled style="opacity:.55">Follow store</button>
            </c:otherwise>
        </c:choose>
    </div>

    <!-- Tabs Navigation -->
    <div class="store-tabs">
        <button type="button" class="tab active" data-store-tab="products">Products</button>
        <button type="button" class="tab" data-store-tab="reviews">Reviews <span class="tab-count">${storeReviewCount}</span></button>
    </div>

    <section class="store-review-panel hidden" id="storeReviewsPanel">
        <c:choose>
            <c:when test="${not empty storeReviews}">
                <div class="store-review-summary">
                    <strong><fmt:formatNumber value="${storeRating}" maxFractionDigits="1"/></strong>
                    <span>★ average from ${storeReviewCount} reviews</span>
                </div>
                <div class="store-review-list">
                    <c:forEach var="review" items="${storeReviews}">
                        <article class="store-review-card">
                            <div class="store-review-head">
                                <div class="store-review-avatar">${not empty review.user.firstName ? fn:substring(review.user.firstName,0,1) : 'A'}</div>
                                <div>
                                    <b><c:out value="${review.user.firstName}"/> <c:out value="${review.user.lastName}"/></b>
                                    <small>✓ Verified purchase · <c:out value="${review.product.name}"/></small>
                                </div>
                                <strong class="store-review-rating">${review.rating}.0 ★</strong>
                            </div>
                            <p><c:out value="${empty review.comment ? 'Rated this product.' : review.comment}"/></p>
                        </article>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="store-review-empty">
                    <span class="material-symbols-outlined">reviews</span>
                    <h3>No store reviews yet</h3>
                    <p>Reviews appear after customers receive products from this store.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </section>

    <!-- Main Content / Product Grid Container -->
    <div class="ar-page" id="storeProductsPanel">
        <div class="ar-grid" id="productGrid">

            <%
                List<com.example.aalmari.model.SellerProduct> products =
                        (List<com.example.aalmari.model.SellerProduct>) request.getAttribute("sellerProducts");

                if (products != null && !products.isEmpty()) {
                    for (com.example.aalmari.model.SellerProduct p : products) {
                        if (p.getActive() != null && !p.getActive()) continue;

                        int price = p.getPrice();
                        int discount = p.getDiscount();
                        long oldPrice = 0;
                        if (discount > 0 && discount < 100) {
                            oldPrice = Math.round(price / ((100.0 - discount) / 100.0));
                        }

                        String cardImg = firstGalleryImage(p.getImageUrlsJson());
                        if (cardImg == null) {
                            cardImg = request.getContextPath() + "/placeholder.jpg";
                        }
                        String soldText = p.getSold() + " sold";
            %>
                <article class="ar-card">
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
                } else if (request.getAttribute("store") != null) {
            %>
                <p style="grid-column:1/-1; text-align:center; color:#777; padding:40px 0;">
                    This store has no products yet.
                </p>
            <% } else { %>
                <p style="grid-column:1/-1; text-align:center; color:#777; padding:40px 0;">
                    Browse an approved seller store to view their products.
                </p>
            <% } %>

        </div>

        <!-- Pagination -->
        <div class="pagination" id="pagination"></div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        // Store tabs and follow action
        document.querySelectorAll('[data-store-tab]').forEach(function (tab) {
            tab.addEventListener('click', function () {
                document.querySelectorAll('[data-store-tab]').forEach(function (item) { item.classList.remove('active'); });
                tab.classList.add('active');
                var isReviews = tab.dataset.storeTab === 'reviews';
                document.getElementById('storeProductsPanel').classList.toggle('hidden', isReviews);
                document.getElementById('storeReviewsPanel').classList.toggle('hidden', !isReviews);
            });
        });

        var followBtn = document.getElementById('followStoreBtn');
        if (followBtn) {
            followBtn.addEventListener('click', async function () {
                if (followBtn.disabled) return;
                followBtn.disabled = true;
                try {
                    var response = await fetch('${pageContext.request.contextPath}/api/store/' + followBtn.dataset.sellerId + '/follow', { method: 'POST' });
                    var data = await response.json().catch(function () { return {}; });
                    if (response.status === 401) {
                        window.location.href = '${pageContext.request.contextPath}/login';
                        return;
                    }
                    if (!response.ok) throw new Error(data.error || 'Could not update follow status.');
                    followBtn.classList.toggle('following', data.following);
                    followBtn.textContent = data.following ? 'Following' : 'Follow store';
                    followBtn.dataset.following = data.following;
                    var count = document.getElementById('storeFollowerCount');
                    if (count) count.textContent = data.followers;
                } catch (error) {
                    alert(error.message);
                } finally {
                    followBtn.disabled = false;
                }
            });
        }

        // Wishlist heart toggle
        document.querySelectorAll('#productGrid .ar-wish').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                btn.classList.toggle('ar-wished');
            });
        });

        // Server-side store pagination
        (function () {
            var nav = document.getElementById('pagination');
            var grid = document.getElementById('productGrid');
            if (!nav || !grid) return;

            var current = parseInt('<%= request.getAttribute("currentPage") %>', 10) || 1;
            var total = parseInt('<%= request.getAttribute("totalPages") %>', 10) || 0;
            var sellerId = '<%= request.getAttribute("sellerId") %>';
            var sort = '<%= request.getAttribute("sort") %>';
            if (total <= 1) { nav.style.display = 'none'; return; }

            var base = '${pageContext.request.contextPath}/store/' + encodeURIComponent(sellerId);
            function link(label, page, active, disabled) {
                var el = document.createElement(disabled ? 'span' : 'a');
                el.innerHTML = label;
                if (disabled) el.className = 'disabled';
                else if (active) { el.className = 'active'; el.setAttribute('aria-current', 'page'); }
                else {
                    var u = new URL(base, window.location.origin);
                    u.searchParams.set('page', page);
                    u.searchParams.set('size', '<%= request.getAttribute("pageSize") %>');
                    if (sort) u.searchParams.set('sort', sort);
                    el.href = u.pathname + u.search;
                }
                return el;
            }

            nav.appendChild(link('&lt; Previous', current - 1, false, current === 1));
            var start = Math.max(1, current - 2), end = Math.min(total, current + 2);
            if (start > 1) nav.appendChild(link('1', 1, current === 1, false));
            if (start > 2) { var dots = document.createElement('span'); dots.className = 'pg-dots'; dots.textContent = '...'; nav.appendChild(dots); }
            for (var p = start; p <= end; p++) nav.appendChild(link(String(p), p, p === current, false));
            if (end < total - 1) { var dots2 = document.createElement('span'); dots2.className = 'pg-dots'; dots2.textContent = '...'; nav.appendChild(dots2); }
            if (end < total) nav.appendChild(link(String(total), total, current === total, false));
            nav.appendChild(link('Next &gt;', current + 1, false, current === total));
        })();
    </script>
</body>
</html>