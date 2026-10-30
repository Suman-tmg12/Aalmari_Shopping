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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/mystore.css?v=6">
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
                <span class="value">${empty store ? 6 : sellerProducts.size()}</span>
                <span class="label">Products</span>
            </div>
            <div class="stat-item">
                <span class="value">214</span>
                <span class="label">Reviews</span>
            </div>
            <div class="stat-item">
                <span class="value">4.8 ★</span>
                <span class="label">Rating</span>
            </div>
            <div class="stat-item">
                <span class="value">1.2k</span>
                <span class="label">Followers</span>
            </div>
        </div>

        <button class="follow-btn">Follow store</button>
    </div>

    <!-- Tabs Navigation -->
    <div class="store-tabs">
        <span class="tab active">Products</span>
        <span class="tab">Reviews</span>
    </div>

    <!-- Main Content / Product Grid Container -->
    <div class="ar-page">
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
                                <span class="ar-view">Add to cart</span>
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
            <%
                } else {
            %>
                <!-- Fallback demo items (only on plain /mystore) -->
                <article class="ar-card">
                    <button type="button" class="ar-wish"><span class="material-symbols-outlined ar-ic-sm">favorite</span></button>
                    <a href="#" class="ar-card-link">
                        <div class="ar-card-img">
                            <span class="ar-badge">-8%</span>
                            <img src="https://images.unsplash.com/photo-1523381210434-271e8be1f52b?auto=format&fit=crop&w=500&q=80" alt="Falcon" loading="lazy">
                        </div>
                        <div class="ar-card-body">
                            <div>
                                <div class="ar-card-top">
                                    <span class="ar-brand">GROCERIES</span>
                                    <span class="ar-sold">0 sold</span>
                                </div>
                                <h3 class="ar-p-title">Falcon</h3>
                            </div>
                            <div class="ar-price-row">
                                <div>
                                    <div class="ar-price">Rs.233000</div>
                                    <div class="ar-old">Rs.253261</div>
                                    <div class="ar-sub-muted">Household Essentials</div>
                                </div>
                                <span class="ar-view">Add to cart</span>
                            </div>
                        </div>
                    </a>
                </article>

                <article class="ar-card">
                    <button type="button" class="ar-wish"><span class="material-symbols-outlined ar-ic-sm">favorite</span></button>
                    <a href="#" class="ar-card-link">
                        <div class="ar-card-img">
                            <span class="ar-badge">-12%</span>
                            <img src="https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=500&q=80" alt="iPhone" loading="lazy">
                        </div>
                        <div class="ar-card-body">
                            <div>
                                <div class="ar-card-top">
                                    <span class="ar-brand">MOBILES</span>
                                    <span class="ar-sold">14 sold</span>
                                </div>
                                <h3 class="ar-p-title">iPhone 15 Pro</h3>
                            </div>
                            <div class="ar-price-row">
                                <div>
                                    <div class="ar-price">Rs.145000</div>
                                    <div class="ar-old">Rs.165000</div>
                                    <div class="ar-sub-muted">Smartphones</div>
                                </div>
                                <span class="ar-view">Add to cart</span>
                            </div>
                        </div>
                    </a>
                </article>

                <article class="ar-card">
                    <button type="button" class="ar-wish"><span class="material-symbols-outlined ar-ic-sm">favorite</span></button>
                    <a href="#" class="ar-card-link">
                        <div class="ar-card-img">
                            <span class="ar-badge">-25%</span>
                            <img src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=500&q=80" alt="Sneakers" loading="lazy">
                        </div>
                        <div class="ar-card-body">
                            <div>
                                <div class="ar-card-top">
                                    <span class="ar-brand">FASHION</span>
                                    <span class="ar-sold">48 sold</span>
                                </div>
                                <h3 class="ar-p-title">Nike Air Runner</h3>
                            </div>
                            <div class="ar-price-row">
                                <div>
                                    <div class="ar-price">Rs.12500</div>
                                    <div class="ar-old">Rs.16999</div>
                                    <div class="ar-sub-muted">Footwear</div>
                                </div>
                                <span class="ar-view">Add to cart</span>
                            </div>
                        </div>
                    </a>
                </article>

                <article class="ar-card">
                    <button type="button" class="ar-wish"><span class="material-symbols-outlined ar-ic-sm">favorite</span></button>
                    <a href="#" class="ar-card-link">
                        <div class="ar-card-img">
                            <span class="ar-badge">-15%</span>
                            <img src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=500&q=80" alt="Headphones" loading="lazy">
                        </div>
                        <div class="ar-card-body">
                            <div>
                                <div class="ar-card-top">
                                    <span class="ar-brand">ELECTRONICS</span>
                                    <span class="ar-sold">9 sold</span>
                                </div>
                                <h3 class="ar-p-title">AudioStudio Pro</h3>
                            </div>
                            <div class="ar-price-row">
                                <div>
                                    <div class="ar-price">Rs.8500</div>
                                    <div class="ar-old">Rs.9999</div>
                                    <div class="ar-sub-muted">Audio &amp; Sound</div>
                                </div>
                                <span class="ar-view">Add to cart</span>
                            </div>
                        </div>
                    </a>
                </article>

                <article class="ar-card">
                    <button type="button" class="ar-wish"><span class="material-symbols-outlined ar-ic-sm">favorite</span></button>
                    <a href="#" class="ar-card-link">
                        <div class="ar-card-img">
                            <span class="ar-badge">-5%</span>
                            <img src="https://images.unsplash.com/photo-1587049352847-4a222e784d38?auto=format&fit=crop&w=500&q=80" alt="Honey" loading="lazy">
                        </div>
                        <div class="ar-card-body">
                            <div>
                                <div class="ar-card-top">
                                    <span class="ar-brand">GROCERIES</span>
                                    <span class="ar-sold">32 sold</span>
                                </div>
                                <h3 class="ar-p-title">Wild Forest Honey</h3>
                            </div>
                            <div class="ar-price-row">
                                <div>
                                    <div class="ar-price">Rs.1150</div>
                                    <div class="ar-old">Rs.1210</div>
                                    <div class="ar-sub-muted">Natural Foods</div>
                                </div>
                                <span class="ar-view">Add to cart</span>
                            </div>
                        </div>
                    </a>
                </article>

                <article class="ar-card">
                    <button type="button" class="ar-wish"><span class="material-symbols-outlined ar-ic-sm">favorite</span></button>
                    <a href="#" class="ar-card-link">
                        <div class="ar-card-img">
                            <span class="ar-badge">-20%</span>
                            <img src="https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=500&q=80" alt="Watch" loading="lazy">
                        </div>
                        <div class="ar-card-body">
                            <div>
                                <div class="ar-card-top">
                                    <span class="ar-brand">FASHION</span>
                                    <span class="ar-sold">11 sold</span>
                                </div>
                                <h3 class="ar-p-title">Chronos Classic</h3>
                            </div>
                            <div class="ar-price-row">
                                <div>
                                    <div class="ar-price">Rs.4200</div>
                                    <div class="ar-old">Rs.5250</div>
                                    <div class="ar-sub-muted">Accessories</div>
                                </div>
                                <span class="ar-view">Add to cart</span>
                            </div>
                        </div>
                    </a>
                </article>
            <% } %>

        </div>

        <!-- Pagination -->
        <div class="pagination" id="pagination"></div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        // Wishlist heart toggle
        document.querySelectorAll('#productGrid .ar-wish').forEach(function (btn) {
            btn.addEventListener('click', function (e) {
                e.preventDefault();
                e.stopPropagation();
                btn.classList.toggle('ar-wished');
            });
        });

        // Pagination script (8 products per page)
        (function () {
            var PER_PAGE = 8;
            var HEADER_OFFSET = 100;
            var grid  = document.getElementById('productGrid');
            var nav   = document.getElementById('pagination');
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
                    var top = grid.getBoundingClientRect().top;
                    if (top < HEADER_OFFSET) {
                        window.scrollTo({
                            top: top + window.pageYOffset - HEADER_OFFSET,
                            behavior: 'smooth'
                        });
                    }
                }
            }

            window.addEventListener('popstate', function () { showPage(getPageFromUrl()); });
            showPage(getPageFromUrl());
        })();
    </script>
</body>
</html>
