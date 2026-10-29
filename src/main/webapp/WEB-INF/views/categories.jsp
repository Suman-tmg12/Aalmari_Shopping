<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%!
    private static final String S3_BASE = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";
    private static final com.fasterxml.jackson.databind.ObjectMapper MAPPER =
            new com.fasterxml.jackson.databind.ObjectMapper();

    // Escapes HTML to prevent XSS
    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
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
<%
    String category = request.getParameter("name");
    if (category == null || category.trim().isEmpty()) category = "Electronics";
    String sub = request.getParameter("sub");
    if (sub != null && sub.trim().isEmpty()) sub = null;

    // Passed by CategoriesController
    @SuppressWarnings("unchecked")
    List<com.example.aalmari.model.SellerProduct> products =
            (List<com.example.aalmari.model.SellerProduct>) request.getAttribute("sellerProducts");

    String pageTitle = escapeHtml(category);
    String pageSubtitle = "Showing results for " + pageTitle + (sub != null ? " › " + escapeHtml(sub) : "");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= pageTitle %> — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/category.css?v=6">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="flash-page"
         data-ctx="${pageContext.request.contextPath}"
         data-category="<%= escapeHtml(category) %>"
         data-sub="<%= escapeHtml(sub) %>">

        <!-- Mobile Category Chips -->
        <nav class="category-chip-bar" aria-label="Categories">
            <%
                String[] allCategories = {"Electronics", "Fashion", "Beauty & Personal Care", "Home & Living", "Groceries", "Sports & Fitness", "Books & Stationery", "Automotive", "Toys & Games", "Health & Wellness"};
                for (String cat : allCategories) {
                    boolean isActive = cat.equals(category);
            %>
            <a href="${pageContext.request.contextPath}/category?name=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"
               class="chip<%= isActive ? " active" : "" %>"><%= escapeHtml(cat) %></a>
            <% } %>
        </nav>

        <div class="flash-layout">
            <!-- Desktop Sidebar -->
            <aside class="category-sidebar">
                <h2 class="sidebar-title">Categories</h2>
                <div id="sidebarAccordion"></div>
            </aside>

            <!-- Results Main Section -->
            <section class="results-section">
                <div class="results-header">
                    <div>
                        <h1 class="results-title" id="pageTitle"><%= pageTitle %></h1>
                        <p class="results-subtitle" id="pageSubtitle"><%= pageSubtitle %></p>
                    </div>
                    <div class="sort-row">
                        <label class="sort-label" for="sortBy">Sort By:</label>
                        <select id="sortBy" class="sort-select" aria-label="Sort products">
                            <option value="best">Best Match</option>
                            <option value="low-high">Price: Low to High</option>
                            <option value="high-low">Price: High to Low</option>
                            <option value="popular">Most Popular</option>
                        </select>
                    </div>
                </div>

                <!-- Product Grid -->
                <div class="ar-page">
                    <div class="ar-grid" id="productGrid">
                    <%
                        int idx = 0;
                        if (products != null && !products.isEmpty()) {
                            for (com.example.aalmari.model.SellerProduct p : products) {
                                if (!p.getActive()) continue;

                                int price = p.getPrice();
                                int discount = p.getDiscount();
                                long oldPrice = 0;
                                if (discount > 0 && discount < 100) {
                                    oldPrice = Math.round(price / ((100.0 - discount) / 100.0));
                                }

                                String cardImg = firstGalleryImage(p.getImageUrlsJson());
                                if (cardImg == null) cardImg = request.getContextPath() + "/placeholder.jpg";
                    %>
                        <article class="ar-card"
                                 data-index="<%= idx %>"
                                 data-price="<%= price %>"
                                 data-sold="<%= p.getSold() %>"
                                 data-name="<%= escapeHtml(p.getName()) %>"<%= idx >= 8 ? " style=\"display:none\"" : "" %>>
                            <button type="button" class="ar-wish" aria-label="Save to wishlist">
                                <span class="material-symbols-outlined ar-ic-sm">favorite</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/product/<%= p.getId() %>" class="ar-card-link">
                                <div class="ar-card-img">
                                    <img src="<%= escapeHtml(cardImg) %>"
                                         alt="<%= escapeHtml(p.getName()) %>"
                                         loading="lazy"
                                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/placeholder.jpg'">
                                    <% if (discount > 0) { %><span class="ar-badge">-<%= discount %>%</span><% } %>
                                </div>
                                <div class="ar-card-body">
                                    <div>
                                        <div class="ar-card-top">
                                            <span class="ar-brand"><%= escapeHtml(p.getCategory()) %></span>
                                            <span class="ar-sold"><%= p.getSold() %> sold</span>
                                        </div>
                                        <h3 class="ar-p-title"><%= escapeHtml(p.getName()) %></h3>
                                    </div>
                                    <div class="ar-price-row">
                                        <div>
                                            <div class="ar-price">Rs.<%= price %></div>
                                            <% if (oldPrice > 0) { %><div class="ar-old">Rs.<%= oldPrice %></div><% } %>
                                            <div class="ar-sub-muted"><%= escapeHtml(p.getSubCategory()) %></div>
                                        </div>
                                        <span class="ar-view">Add to cart</span>
                                    </div>
                                </div>
                            </a>
                        </article>
                    <%
                                idx++;
                            }
                        }
                        if (idx == 0) {
                    %>
                        <p class="no-products-msg">No products found<%= sub != null ? " in this sub-category" : "" %> yet.</p>
                    <% } %>
                    </div>
                </div>

                <!-- Pagination (built by JavaScript) -->
                <div class="pagination" id="pagination"></div>
            </section>
        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        (function () {
            'use strict';

            const pageCategories = {
                "Electronics": ["Mobiles", "Laptops", "Tablets", "Headphones", "Cameras", "Smart Watches", "Accessories"],
                "Fashion": ["Men", "Women", "Kids", "Shoes", "Bags", "Watches", "Clothing"],
                "Beauty & Personal Care": ["Skincare", "Makeup", "Hair Care", "Fragrances", "Personal Care"],
                "Home & Living": ["Furniture", "Kitchen", "Home Decor", "Bedding", "Lighting", "Storage"],
                "Groceries": ["Fruits & Vegetables", "Snacks", "Beverages", "Dairy", "Rice & Grains", "Household Essentials"],
                "Sports & Fitness": ["Sports Equipment", "Gym Equipment", "Fitness Accessories", "Outdoor Gear", "Sportswear"],
                "Books & Stationery": ["Books", "Notebooks", "Pens & Pencils", "School Supplies", "Office Supplies"],
                "Automotive": ["Car Accessories", "Bike Accessories", "Car Care", "Spare Parts", "Helmets"],
                "Toys & Games": ["Toys", "Board Games", "Video Games", "Educational Toys", "Remote-Control Toys"],
                "Health & Wellness": ["Vitamins & Supplements", "Fitness", "Healthcare Products", "Personal Wellness"]
            };

            document.addEventListener('DOMContentLoaded', function () {
                const pageRoot = document.querySelector('.flash-page');
                if (!pageRoot) return;

                const pageCTX = pageRoot.dataset.ctx || '';
                const currentCategory = pageRoot.dataset.category || 'Electronics';
                const currentSub = pageRoot.dataset.sub || null;

                // Wishlist heart toggle
                document.querySelectorAll('#productGrid .ar-wish').forEach(function (btn) {
                    btn.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        btn.classList.toggle('ar-wished');
                    });
                });

                // Auto-scroll active mobile chip into view on load
                const activeChip = document.querySelector('.category-chip-bar .chip.active');
                if (activeChip) {
                    activeChip.scrollIntoView({ behavior: 'smooth', inline: 'center', block: 'nearest' });
                }

                // Build Sidebar Accordion
                const accordion = document.getElementById('sidebarAccordion');
                if (accordion) {
                    const fragment = document.createDocumentFragment();

                    Object.keys(pageCategories).forEach(cat => {
                        const isCurrentCat = cat === currentCategory;

                        const wrap = document.createElement('div');
                        wrap.className = 'cat-group' + (isCurrentCat ? ' open' : '');

                        const header = document.createElement('div');
                        header.className = 'cat-header' + (isCurrentCat ? ' active-cat' : '');

                        const catLink = document.createElement('a');
                        catLink.href = pageCTX + '/category?name=' + encodeURIComponent(cat);
                        catLink.textContent = cat;
                        catLink.className = 'cat-header-text';

                        const chevron = document.createElement('span');
                        chevron.className = 'material-symbols-outlined chevron';
                        chevron.textContent = 'expand_more';
                        chevron.setAttribute('aria-hidden', 'true');

                        header.appendChild(catLink);
                        header.appendChild(chevron);

                        header.addEventListener('click', function (e) {
                            if (e.target.classList.contains('cat-header-text')) return;
                            e.preventDefault();
                            const isOpen = wrap.classList.contains('open');

                            document.querySelectorAll('.cat-group').forEach(g => {
                                g.classList.remove('open');
                                g.querySelector('.cat-header').classList.remove('active-cat');
                            });

                            if (!isOpen) {
                                wrap.classList.add('open');
                                header.classList.add('active-cat');
                            }
                        });

                        const subList = document.createElement('div');
                        subList.className = 'cat-sub-list';

                        pageCategories[cat].forEach(subName => {
                            const a = document.createElement('a');
                            a.href = pageCTX + '/category?name=' + encodeURIComponent(cat) + '&sub=' + encodeURIComponent(subName);
                            a.className = 'cat-sub-link' + ((isCurrentCat && subName === currentSub) ? ' active-sub' : '');
                            a.textContent = subName;
                            subList.appendChild(a);
                        });

                        wrap.appendChild(header);
                        wrap.appendChild(subList);
                        fragment.appendChild(wrap);
                    });

                    accordion.appendChild(fragment);
                }

                // ---------- Pagination (8 per page) ----------
                const PER_PAGE = 6;
                const HEADER_OFFSET = 100; // change to your sticky header height in px
                const grid = document.getElementById('productGrid');
                const nav = document.getElementById('pagination');
                const totalCards = grid ? grid.querySelectorAll('.ar-card').length : 0;
                const total = Math.ceil(totalCards / PER_PAGE);
                let current = 1;

                // Always read the cards in their current DOM order (it changes after sorting)
                function getCards() {
                    return Array.from(grid.querySelectorAll('.ar-card'));
                }

                function getPageFromUrl() {
                    const p = parseInt(new URLSearchParams(window.location.search).get('page'), 10);
                    return (p >= 1 && p <= total) ? p : 1;
                }

                // Builds [1, '...', 4, 5, 6, '...', 20]
                function pageItems() {
                    if (total <= 7) {
                        return Array.from({ length: total }, (_, i) => i + 1);
                    }
                    const items = [1];
                    const start = Math.max(2, current - 1);
                    const end = Math.min(total - 1, current + 1);
                    if (start > 2) items.push('...');
                    for (let i = start; i <= end; i++) items.push(i);
                    if (end < total - 1) items.push('...');
                    items.push(total);
                    return items;
                }

                function makeItem(label, page, opts) {
                    opts = opts || {};
                    const s = document.createElement('span');
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
                        s.addEventListener('click', () => goTo(page, true));
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
                            const dots = document.createElement('span');
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
                    const start = (page - 1) * PER_PAGE;
                    const end = start + PER_PAGE;
                    getCards().forEach(function (card, i) {
                        card.style.display = (i >= start && i < end) ? '' : 'none';
                    });
                    renderNav();
                }

                function goTo(page, userClicked) {
                    if (page < 1 || page > total) return;
                    showPage(page);
                    if (userClicked) {
                        const url = new URL(window.location);
                        url.searchParams.set('page', page);
                        history.pushState({ page: page }, '', url);

                        // Scroll only if the top of the grid is out of view
                        const top = grid.getBoundingClientRect().top;
                        if (top < HEADER_OFFSET) {
                            window.scrollTo({ top: top + window.pageYOffset - HEADER_OFFSET, behavior: 'smooth' });
                        }
                    }
                }

                const paginationOn = nav && total > 1;
                if (nav && !paginationOn) nav.style.display = 'none';

                if (paginationOn) {
                    window.addEventListener('popstate', () => showPage(getPageFromUrl()));
                    showPage(getPageFromUrl());
                }

                // ---------- Client-side Product Sorting ----------
                const sortSelect = document.getElementById('sortBy');

                if (sortSelect && grid) {
                    sortSelect.addEventListener('change', function () {
                        const cards = getCards();
                        if (cards.length === 0) return;

                        const val = this.value;

                        cards.sort((a, b) => {
                            const priceA = parseFloat(a.dataset.price) || 0;
                            const priceB = parseFloat(b.dataset.price) || 0;
                            const soldA = parseFloat(a.dataset.sold) || 0;
                            const soldB = parseFloat(b.dataset.sold) || 0;

                            if (val === 'low-high') return priceA - priceB;
                            if (val === 'high-low') return priceB - priceA;
                            if (val === 'popular') return soldB - soldA;
                            return (parseInt(a.dataset.index) || 0) - (parseInt(b.dataset.index) || 0);
                        });

                        cards.forEach(card => grid.appendChild(card));

                        // Sorting changes the order, so go back to page 1
                        if (paginationOn) {
                            const url = new URL(window.location);
                            url.searchParams.delete('page');
                            history.replaceState(null, '', url);
                            showPage(1);
                        }
                    });
                }
            });
        })();
    </script>
</body>
</html>