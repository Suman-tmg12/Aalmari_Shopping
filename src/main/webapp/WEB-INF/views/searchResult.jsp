<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%!
    // Utility method to safely escape HTML attributes and prevent XSS
    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#39;");
    }

    // "12.4k sold" -> 12400, "800 sold" -> 800
    private double parseSold(String sold) {
        try {
            String s = sold.toLowerCase().replace("sold", "").trim();
            double mult = 1;
            if (s.endsWith("k")) { mult = 1000; s = s.substring(0, s.length() - 1); }
            return Double.parseDouble(s) * mult;
        } catch (Exception e) {
            return 0;
        }
    }
%>
<%
    String rawQuery = request.getParameter("q");
    String searchQuery = (rawQuery != null) ? rawQuery.trim() : "";
    String filterCategory = request.getParameter("cat");
    boolean hasCategoryFilter = filterCategory != null && !filterCategory.trim().isEmpty();

    // Master Product Catalog (Aggregated across store sections)
    String[][] allProductsData = {
        // Name, Image, Folder, Price, OldPrice, Sold, SubCategory, MainCategory
        {"iPhone 15 Pro", "iphone15pro.jpg", "Products", "1500", "2300", "12.4k sold", "Mobiles", "Electronics"},
        {"Samsung Galaxy S24", "iphone15pro.jpg", "Products", "1400", "2100", "9.8k sold", "Mobiles", "Electronics"},
        {"MacBook Pro M3", "MacBookProm3.jpg", "Products", "2200", "3200", "9.7k sold", "Laptops", "Electronics"},
        {"Dell XPS 15", "MacBookProm3.jpg", "Products", "1900", "2800", "6.3k sold", "Laptops", "Electronics"},
        {"AirPods Pro", "Airpods.jpg", "Products", "250", "400", "15.2k sold", "Headphones", "Electronics"},
        {"Wireless Headphone", "Wireless_headPhone.jpg", "FlashSaleImages", "70", "120", "4.5k sold", "Headphones", "Electronics"},
        {"Smart Fitness Band", "SmartFitnessBand.jpg", "FlashSaleImages", "120", "200", "2.3k sold", "Smart Watches", "Electronics"},
        {"Bluetooth Speaker", "hairSpray.jpg", "Products", "180", "300", "1.1k sold", "Accessories", "Electronics"},

        {"Nike Shoes", "nikeShoe.jpg", "Products", "200", "320", "8.1k sold", "Shoes", "Fashion"},
        {"Classic Black Shoes", "ClassicBlackShoes.jpg", "FlashSaleImages", "90", "180", "2.3k sold", "Shoes", "Fashion"},
        {"Black Glasses", "BlackGlass.jpg", "Products", "90", "150", "2.3k sold", "Men", "Fashion"},
        {"White T-Shirt", "WhiteSpray.jpg", "Products", "25", "50", "5.2k sold", "Men", "Fashion"},
        {"Summer Dress", "skincare.jpg", "Products", "45", "80", "3.1k sold", "Women", "Fashion"},
        {"Leather Handbag", "hairSpray.jpg", "Products", "120", "200", "1.8k sold", "Bags", "Fashion"},

        {"Himalaya Face Scrub", "HimalayaFaceScrub.jpg", "FlashSaleImages", "70", "150", "4.5k sold", "Skincare", "Beauty & Personal Care"},
        {"Skin Care Set", "skincare.jpg", "FlashSaleImages", "150", "300", "1.8k sold", "Skincare", "Beauty & Personal Care"},
        {"White Spray", "WhiteSpray.jpg", "Products", "80", "140", "1.8k sold", "Fragrances", "Beauty & Personal Care"},
        {"Falcon Spray", "FalconSpray.jpg", "Products", "110", "200", "5.6k sold", "Fragrances", "Beauty & Personal Care"},
        {"Hair Spray", "hairSpray.jpg", "Products", "70", "150", "4.5k sold", "Hair Care", "Beauty & Personal Care"},
        {"Lipstick Set", "olipop.jpg", "Products", "35", "60", "8.2k sold", "Makeup", "Beauty & Personal Care"},

        {"Wooden Table", "home&living.jpg", "Products", "250", "400", "2.1k sold", "Furniture", "Home & Living"},
        {"LED Lamp", "SmartFitnessBand.jpg", "Products", "45", "80", "5.6k sold", "Lighting", "Home & Living"},
        {"Storage Box", "hairSpray.jpg", "Products", "15", "30", "9.3k sold", "Storage", "Home & Living"},
        {"Kitchen Knife Set", "HimalayaFaceScrub.jpg", "Products", "35", "60", "4.2k sold", "Kitchen", "Home & Living"},

        {"Organic Rice", "Healthy.jpg", "FlashSaleImages", "25", "40", "12.4k sold", "Rice & Grains", "Groceries"},
        {"Fresh Apples", "Healthy.jpg", "FlashSaleImages", "15", "25", "8.7k sold", "Fruits & Vegetables", "Groceries"},
        {"Snack Pack", "unhealthy-foods.jpg", "FlashSaleImages", "10", "20", "15.2k sold", "Snacks", "Groceries"},
        {"Milk Carton", "olipop.jpg", "Products", "8", "12", "6.3k sold", "Dairy", "Groceries"},

        {"Yoga Mat", "SmartFitnessBand.jpg", "Products", "30", "50", "7.4k sold", "Fitness Accessories", "Sports & Fitness"},
        {"Dumbbell Set", "hairSpray.jpg", "Products", "85", "140", "3.2k sold", "Gym Equipment", "Sports & Fitness"},
        {"Running Shoes", "nikeShoe.jpg", "Products", "120", "200", "5.8k sold", "Sportswear", "Sports & Fitness"},

        {"Novel Collection", "hairSpray.jpg", "Products", "20", "35", "4.1k sold", "Books", "Books & Stationery"},
        {"Pen Set", "WhiteSpray.jpg", "Products", "8", "15", "9.5k sold", "Pens & Pencils", "Books & Stationery"},
        {"Notebook Pack", "skincare.jpg", "Products", "12", "20", "6.7k sold", "Notebooks", "Books & Stationery"},

        {"Car Phone Holder", "hairSpray.jpg", "Products", "25", "45", "5.3k sold", "Car Accessories", "Automotive"},
        {"Bike Helmet", "SmartFitnessBand.jpg", "Products", "60", "100", "3.8k sold", "Helmets", "Automotive"},
        {"Car Wash Kit", "HimalayaFaceScrub.jpg", "Products", "35", "60", "2.9k sold", "Car Care", "Automotive"},

        {"Building Blocks", "hairSpray.jpg", "Products", "40", "70", "8.4k sold", "Toys", "Toys & Games"},
        {"Board Game", "skincare.jpg", "Products", "25", "45", "4.6k sold", "Board Games", "Toys & Games"},
        {"RC Car", "SmartFitnessBand.jpg", "Products", "55", "90", "3.1k sold", "Remote-Control Toys", "Toys & Games"},

        {"Vitamin C Tablets", "Healthy.jpg", "FlashSaleImages", "20", "35", "7.2k sold", "Vitamins & Supplements", "Health & Wellness"},
        {"First Aid Kit", "hairSpray.jpg", "Products", "30", "55", "4.8k sold", "Healthcare Products", "Health & Wellness"},
        {"Massage Roller", "SmartFitnessBand.jpg", "Products", "25", "40", "5.5k sold", "Fitness", "Health & Wellness"}
    };

    String[] categoriesList = {"Electronics", "Fashion", "Beauty & Personal Care", "Home & Living", "Groceries", "Sports & Fitness", "Books & Stationery", "Automotive", "Toys & Games", "Health & Wellness"};

    // Filter results matching the search query
    List<String[]> matchingProducts = new ArrayList<>();
    Map<String, Integer> catCounts = new HashMap<>();   // counts for the sidebar (search only, ignoring category filter)
    int totalSearchCount = 0;
    String lowerQuery = searchQuery.toLowerCase();

    for (String[] p : allProductsData) {
        String pName = p[0].toLowerCase();
        String pSub = p[6].toLowerCase();
        String pMainCat = p[7].toLowerCase();

        boolean matchesSearch = lowerQuery.isEmpty()
            || pName.contains(lowerQuery)
            || pSub.contains(lowerQuery)
            || pMainCat.contains(lowerQuery);

        boolean matchesCategoryFilter = !hasCategoryFilter
            || p[7].equalsIgnoreCase(filterCategory);

        if (matchesSearch) {
            totalSearchCount++;
            catCounts.put(p[7], catCounts.containsKey(p[7]) ? catCounts.get(p[7]) + 1 : 1);
        }
        if (matchesSearch && matchesCategoryFilter) {
            matchingProducts.add(p);
        }
    }

    // Sub-category counts + price ceiling for the filter panel
    Map<String, Integer> subCounts = new TreeMap<>();
    long highestPrice = 0;
    for (String[] p : matchingProducts) {
        subCounts.put(p[6], subCounts.containsKey(p[6]) ? subCounts.get(p[6]) + 1 : 1);
        highestPrice = Math.max(highestPrice, Long.parseLong(p[3]));
    }
    long priceCeiling = Math.max(100, ((highestPrice + 99) / 100) * 100);

    String qEnc = java.net.URLEncoder.encode(searchQuery, "UTF-8");
    String catEnc = hasCategoryFilter ? java.net.URLEncoder.encode(filterCategory, "UTF-8") : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= searchQuery.isEmpty() ? "Search Results" : escapeHtml(searchQuery) %> — Aalmari Store</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/searchResult.css?v=2">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="ar-page"
         data-ctx="${pageContext.request.contextPath}"
         data-query="<%= escapeHtml(searchQuery) %>">



        <!-- ===== Main ===== -->
        <main class="ar-container ar-main">
             <!-- ===== Summary bar ===== -->
                <section class="ar-summary">
                    <div class="ar-container">
                        <nav class="ar-crumbs" aria-label="Breadcrumb">
                            <a href="${pageContext.request.contextPath}/">Home</a>
                            <span class="material-symbols-outlined ar-ic-xs" aria-hidden="true">chevron_right</span>
                            <% if (hasCategoryFilter) { %>
                                <a href="${pageContext.request.contextPath}/search?q=<%= qEnc %>"><%= escapeHtml(filterCategory) %></a>
                                <span class="material-symbols-outlined ar-ic-xs" aria-hidden="true">chevron_right</span>
                            <% } %>
                            <span class="ar-cur">Search Results</span>
                        </nav>

                        <div class="ar-title-row">
                            <div>
                                <h1 class="ar-h1">
                                    <% if (searchQuery.isEmpty()) { %>All Products<% } else { %>Results for <span>"<%= escapeHtml(searchQuery) %>"</span><% } %>
                                </h1>
                                <p class="ar-sub">Showing <b id="arMatchCount"><%= matchingProducts.size() %></b> item<%= matchingProducts.size() == 1 ? "" : "s" %> matching your search</p>
                            </div>

                            <div class="ar-controls">
                                <button type="button" id="arOpenFilters" class="ar-filter-btn" aria-controls="arFilterPanel">
                                    <span class="material-symbols-outlined ar-ic-sm" aria-hidden="true">tune</span>
                                    <span>Filters</span>
                                    <span id="arFilterBadge" class="ar-filter-badge ar-hidden">0</span>
                                </button>

                                <div class="ar-controls-right">
                                    <div class="ar-sort">
                                        <label for="sortBy">Sort by:</label>
                                        <select id="sortBy" aria-label="Sort search results">
                                            <option value="best">Relevance / Best Match</option>
                                            <option value="low-high">Price: Low to High</option>
                                            <option value="high-low">Price: High to Low</option>
                                            <option value="popular">Most Popular</option>
                                        </select>
                                    </div>
                                    <div class="ar-view-switch">
                                        <button type="button" id="arGridView" class="ar-active" aria-label="Grid view">
                                            <span class="material-symbols-outlined ar-ic-sm">grid_view</span>
                                        </button>
                                        <button type="button" id="arListView" aria-label="List view">
                                            <span class="material-symbols-outlined ar-ic-sm">view_list</span>
                                        </button>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Active filters (server-side category + client-side filters) -->
                        <div id="arActiveFilters" class="ar-active-filters<%= hasCategoryFilter ? "" : " ar-hidden" %>" data-has-cat="<%= hasCategoryFilter %>">
                            <span class="ar-af-label">Active Filters:</span>
                            <div class="ar-chips">
                                <% if (hasCategoryFilter) { %>
                                <span class="ar-chip">
                                    <%= escapeHtml(filterCategory) %>
                                    <a href="${pageContext.request.contextPath}/search?q=<%= qEnc %>" aria-label="Remove category filter">
                                        <span class="material-symbols-outlined ar-ic-xs">close</span>
                                    </a>
                                </span>
                                <% } %>
                                <span id="arClientChips" class="ar-chips"></span>
                            </div>
                            <% if (hasCategoryFilter) { %>
                                <a class="ar-clear-all" href="${pageContext.request.contextPath}/search?q=<%= qEnc %>">Clear All</a>
                            <% } else { %>
                                <button type="button" class="ar-clear-all" id="arClearAll">Clear All</button>
                            <% } %>
                        </div>
                    </div>
                </section>
            <div class="ar-layout">

                <!-- Filter panel (sidebar on desktop, slide-in drawer on mobile) -->
                <aside id="arFilterPanel" class="ar-sidebar" aria-label="Refine search">
                    <div class="ar-panel">
                        <div class="ar-panel-head">
                            <h2><span class="material-symbols-outlined ar-ic-sm" aria-hidden="true">filter_alt</span> Filters</h2>
                            <div class="ar-panel-actions">
                                <button type="button" class="ar-reset" id="arResetFilters">Reset</button>
                                <button type="button" class="ar-close-panel" id="arCloseFilters" aria-label="Close filters">
                                    <span class="material-symbols-outlined ar-ic">close</span>
                                </button>
                            </div>
                        </div>

                        <!-- Categories (server-side links) -->
                        <div class="ar-section">
                            <h3 class="ar-section-title">Categories</h3>
                            <ul class="ar-cat-list">
                                <li>
                                    <a href="${pageContext.request.contextPath}/search?q=<%= qEnc %>"
                                       class="ar-cat-btn<%= hasCategoryFilter ? "" : " ar-active" %>">
                                        <span>All Categories</span>
                                        <small><%= totalSearchCount %></small>
                                    </a>
                                </li>
                                <% for (String cat : categoriesList) {
                                       boolean isActive = cat.equalsIgnoreCase(filterCategory);
                                       int c = catCounts.containsKey(cat) ? catCounts.get(cat) : 0;
                                %>
                                <li>
                                    <a href="${pageContext.request.contextPath}/search?q=<%= qEnc %>&cat=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"
                                       class="ar-cat-btn<%= isActive ? " ar-active" : "" %>">
                                        <span><%= escapeHtml(cat) %></span>
                                        <small><%= c %></small>
                                    </a>
                                </li>
                                <% } %>
                            </ul>
                        </div>

                        <!-- Price range (client-side) -->
                        <div class="ar-section">
                            <h3 class="ar-section-title">Price Range</h3>
                            <div class="ar-price-box">
                                <input type="range" id="arPriceRange" min="0" max="<%= priceCeiling %>" step="10" value="<%= priceCeiling %>" aria-label="Maximum price">
                                <div class="ar-price-inputs">
                                    <div class="ar-money"><span>Rs</span><input type="number" id="arMinPrice" value="0" min="0" aria-label="Minimum price"></div>
                                    <span>to</span>
                                    <div class="ar-money"><span>Rs</span><input type="number" id="arMaxPrice" value="<%= priceCeiling %>" max="<%= priceCeiling %>" aria-label="Maximum price"></div>
                                </div>
                            </div>
                        </div>

                        <!-- Product types (sub-categories, client-side) -->
                        <% if (!subCounts.isEmpty()) { %>
                        <div class="ar-section">
                            <h3 class="ar-section-title">Product Type</h3>
                            <input type="text" id="arTypeSearch" class="ar-type-search" placeholder="Filter types..." aria-label="Filter product types">
                            <div class="ar-check-list" id="arTypeList">
                                <% for (Map.Entry<String, Integer> e : subCounts.entrySet()) { %>
                                <label class="ar-check" data-label="<%= escapeHtml(e.getKey().toLowerCase()) %>">
                                    <input type="checkbox" class="ar-type-cb" value="<%= escapeHtml(e.getKey()) %>">
                                    <span><%= escapeHtml(e.getKey()) %></span>
                                    <small><%= e.getValue() %></small>
                                </label>
                                <% } %>
                            </div>
                        </div>
                        <% } %>

                        <!-- Discount (client-side) -->
                        <div class="ar-section">
                            <h3 class="ar-section-title">Minimum Discount</h3>
                            <div class="ar-radio-list">
                                <label class="ar-check"><input type="radio" name="arDiscount" value="10"><span>10% off or more</span></label>
                                <label class="ar-check"><input type="radio" name="arDiscount" value="25"><span>25% off or more</span></label>
                                <label class="ar-check"><input type="radio" name="arDiscount" value="40"><span>40% off or more</span></label>
                            </div>
                        </div>

                        <!-- Mobile-only buttons -->
                        <div class="ar-apply-wrap">
                            <button type="button" class="ar-btn-outline" id="arMobileReset">Reset</button>
                            <button type="button" class="ar-btn-dark" id="arMobileApply">Apply</button>
                        </div>
                    </div>
                </aside>
                <div class="ar-backdrop" id="arBackdrop"></div>

                <!-- Results -->
                <section class="ar-results">
                    <% if (matchingProducts.isEmpty()) { %>
                    <div class="ar-empty">
                        <div class="ar-empty-icon"><span class="material-symbols-outlined ar-ic-lg">search_off</span></div>
                        <h3>No results found for "<%= escapeHtml(searchQuery) %>"</h3>
                        <p>Try checking your spelling, using more general terms, or exploring our categories.</p>
                        <a href="${pageContext.request.contextPath}/" class="ar-btn-dark">Back to Homepage</a>
                    </div>
                    <% } else { %>

                    <div class="ar-grid" id="productGrid">
                        <%
                            int idx = 0;
                            for (String[] p : matchingProducts) {
                                String pName = p[0], pImage = p[1], pFolder = p[2];
                                long pPrice = Long.parseLong(p[3]);
                                long pOldPrice = Long.parseLong(p[4]);
                                String pSold = p[5], pSub = p[6], pMain = p[7];

                                int discount = pOldPrice > 0 ? (int) Math.round(((double)(pOldPrice - pPrice) / pOldPrice) * 100) : 0;
                                double numericSold = parseSold(pSold);
                        %>
                        <article class="ar-card"
                                 data-index="<%= idx++ %>"
                                 data-price="<%= pPrice %>"
                                 data-sold="<%= (long) numericSold %>"
                                 data-discount="<%= discount %>"
                                 data-sub="<%= escapeHtml(pSub) %>"
                                 data-name="<%= escapeHtml(pName) %>">
                            <button type="button" class="ar-wish" aria-label="Save to wishlist">
                                <span class="material-symbols-outlined ar-ic-sm">favorite</span>
                            </button>
                            <a href="#" class="ar-card-link">
                                <div class="ar-card-img">
                                    <img src="${pageContext.request.contextPath}/HomePageImages/<%= pFolder %>/<%= pImage %>"
                                         alt="<%= escapeHtml(pName) %>"
                                         loading="lazy">
                                    <% if (discount > 0) { %><span class="ar-badge">-<%= discount %>%</span><% } %>
                                </div>
                                <div class="ar-card-body">
                                    <div>
                                        <div class="ar-card-top">
                                            <span class="ar-brand"><%= escapeHtml(pMain) %></span>
                                            <span class="ar-sold"><%= escapeHtml(pSold) %></span>
                                        </div>
                                        <h3 class="ar-p-title"><%= escapeHtml(pName) %></h3>
                                    </div>
                                    <div class="ar-price-row">
                                        <div>
                                            <div class="ar-price">Rs.<%= pPrice %></div>
                                            <div class="ar-old">Rs.<%= pOldPrice %></div>
                                            <div class="ar-sub-muted"><%= escapeHtml(pSub) %></div>
                                        </div>
                                        <span class="ar-view">View</span>
                                    </div>
                                </div>
                            </a>
                        </article>
                        <% } %>
                    </div>

                    <!-- Shown when client-side filters hide every product -->
                    <div id="arEmptyClient" class="ar-empty ar-hidden">
                        <div class="ar-empty-icon"><span class="material-symbols-outlined ar-ic-lg">search_off</span></div>
                        <h3>No matching products found</h3>
                        <p>Try adjusting your filters or search for something else.</p>
                        <button type="button" class="ar-btn-dark" id="arClearEmpty">Clear Filters</button>
                    </div>

                    <p class="ar-footer-count" id="arFooterCount">
                        Showing <b id="arShownCount"><%= matchingProducts.size() %></b> of <b><%= matchingProducts.size() %></b> items
                    </p>
                    <% } %>
                </section>
            </div>
        </main>

        <!-- Toast -->
        <div id="arToast" class="ar-toast" role="status" aria-live="polite">
            <span class="material-symbols-outlined ar-ic">check_circle</span>
            <span id="arToastMsg">Saved</span>
        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        (function () {
            'use strict';

            document.addEventListener('DOMContentLoaded', function () {
                var page = document.querySelector('.ar-page');
                var grid = document.getElementById('productGrid');
                if (!page) return;

                var $ = function (id) { return document.getElementById(id); };

                /* ---------- Mobile filter drawer (works even with no products) ---------- */
                var panel = $('arFilterPanel'), backdrop = $('arBackdrop');
                function setDrawer(open) {
                    panel.classList.toggle('ar-open', open);
                    backdrop.classList.toggle('ar-open', open);
                }
                $('arOpenFilters').addEventListener('click', function () { setDrawer(true); });
                $('arCloseFilters').addEventListener('click', function () { setDrawer(false); });
                backdrop.addEventListener('click', function () { setDrawer(false); });
                $('arMobileApply').addEventListener('click', function () { setDrawer(false); });
                document.addEventListener('keydown', function (e) { if (e.key === 'Escape') setDrawer(false); });

                if (!grid) return; // server-side "no results" page: nothing else to wire up

                /* ---------- Toast ---------- */
                var toastTimer;
                function showToast(msg) {
                    $('arToastMsg').textContent = msg;
                    var t = $('arToast');
                    t.classList.add('ar-show');
                    clearTimeout(toastTimer);
                    toastTimer = setTimeout(function () { t.classList.remove('ar-show'); }, 2500);
                }

                /* ---------- State ---------- */
                var cards = Array.prototype.slice.call(grid.querySelectorAll('.ar-card'));
                var CEILING = parseFloat($('arPriceRange').max) || 0;
                var state = { min: 0, max: CEILING, types: [], discount: 0, sort: 'best' };

                var priceRange = $('arPriceRange'), minInput = $('arMinPrice'), maxInput = $('arMaxPrice');
                var hasServerCat = $('arActiveFilters').getAttribute('data-has-cat') === 'true';

                function clampPrices() {
                    if (isNaN(state.min) || state.min < 0) state.min = 0;
                    if (isNaN(state.max) || state.max > CEILING) state.max = CEILING;
                    if (state.min > state.max) state.min = state.max;
                }

                /* ---------- Render ---------- */
                function render() {
                    clampPrices();

                    // sort
                    var sorted = cards.slice().sort(function (a, b) {
                        var pa = parseFloat(a.dataset.price) || 0, pb = parseFloat(b.dataset.price) || 0;
                        var sa = parseFloat(a.dataset.sold) || 0, sb = parseFloat(b.dataset.sold) || 0;
                        if (state.sort === 'low-high') return pa - pb;
                        if (state.sort === 'high-low') return pb - pa;
                        if (state.sort === 'popular') return sb - sa;
                        return (parseInt(a.dataset.index, 10) || 0) - (parseInt(b.dataset.index, 10) || 0);
                    });

                    // filter + reorder
                    var visible = 0;
                    sorted.forEach(function (card) {
                        var price = parseFloat(card.dataset.price) || 0;
                        var disc = parseFloat(card.dataset.discount) || 0;
                        var ok = price >= state.min && price <= state.max
                              && (state.types.length === 0 || state.types.indexOf(card.dataset.sub) !== -1)
                              && disc >= state.discount;
                        card.hidden = !ok;
                        if (ok) visible++;
                        grid.appendChild(card);
                    });

                    $('arMatchCount').textContent = visible;
                    $('arShownCount').textContent = visible;
                    $('arEmptyClient').classList.toggle('ar-hidden', visible !== 0);
                    $('arFooterCount').classList.toggle('ar-hidden', visible === 0);
                    grid.classList.toggle('ar-hidden', visible === 0);

                    renderChips();
                }

                function chip(label, onRemove) {
                    var span = document.createElement('span');
                    span.className = 'ar-chip';
                    span.appendChild(document.createTextNode(label));
                    var btn = document.createElement('button');
                    btn.type = 'button';
                    btn.setAttribute('aria-label', 'Remove filter ' + label);
                    btn.innerHTML = '<span class="material-symbols-outlined ar-ic-xs">close</span>';
                    btn.addEventListener('click', onRemove);
                    span.appendChild(btn);
                    return span;
                }

                function renderChips() {
                    var box = $('arClientChips');
                    box.innerHTML = '';
                    var count = 0;

                    if (state.min > 0 || state.max < CEILING) {
                        count++;
                        box.appendChild(chip('Rs ' + state.min + ' – Rs ' + state.max, function () {
                            state.min = 0; state.max = CEILING; syncPriceInputs(); render();
                        }));
                    }
                    state.types.forEach(function (t) {
                        count++;
                        box.appendChild(chip(t, function () {
                            state.types = state.types.filter(function (x) { return x !== t; });
                            syncTypeBoxes(); render();
                        }));
                    });
                    if (state.discount > 0) {
                        count++;
                        box.appendChild(chip(state.discount + '%+ off', function () {
                            state.discount = 0; syncDiscountRadios(); render();
                        }));
                    }

                    var total = count + (hasServerCat ? 1 : 0);
                    $('arActiveFilters').classList.toggle('ar-hidden', total === 0);
                    var badge = $('arFilterBadge');
                    badge.textContent = total;
                    badge.classList.toggle('ar-hidden', total === 0);
                }

                /* ---------- Sync helpers ---------- */
                function syncPriceInputs() {
                    priceRange.value = state.max;
                    minInput.value = state.min;
                    maxInput.value = state.max;
                }
                function syncTypeBoxes() {
                    document.querySelectorAll('.ar-type-cb').forEach(function (cb) {
                        cb.checked = state.types.indexOf(cb.value) !== -1;
                    });
                }
                function syncDiscountRadios() {
                    document.querySelectorAll('input[name="arDiscount"]').forEach(function (r) {
                        r.checked = parseInt(r.value, 10) === state.discount;
                    });
                }

                function resetAll() {
                    state.min = 0; state.max = CEILING; state.types = []; state.discount = 0;
                    var ts = $('arTypeSearch');
                    if (ts) { ts.value = ''; filterTypeList(''); }
                    syncPriceInputs(); syncTypeBoxes(); syncDiscountRadios();
                    render();
                }

                /* ---------- Events ---------- */
                priceRange.addEventListener('input', function () {
                    state.max = parseFloat(this.value) || 0;
                    clampPrices(); syncPriceInputs(); render();
                });
                minInput.addEventListener('change', function () {
                    state.min = parseFloat(this.value) || 0;
                    clampPrices(); syncPriceInputs(); render();
                });
                maxInput.addEventListener('change', function () {
                    state.max = parseFloat(this.value);
                    if (isNaN(state.max)) state.max = CEILING;
                    clampPrices(); syncPriceInputs(); render();
                });

                document.querySelectorAll('.ar-type-cb').forEach(function (cb) {
                    cb.addEventListener('change', function () {
                        if (cb.checked) { if (state.types.indexOf(cb.value) === -1) state.types.push(cb.value); }
                        else state.types = state.types.filter(function (x) { return x !== cb.value; });
                        render();
                    });
                });

                function filterTypeList(text) {
                    var q = text.toLowerCase().trim();
                    document.querySelectorAll('#arTypeList .ar-check').forEach(function (row) {
                        row.hidden = q !== '' && row.getAttribute('data-label').indexOf(q) === -1;
                    });
                }
                var typeSearch = $('arTypeSearch');
                if (typeSearch) typeSearch.addEventListener('input', function () { filterTypeList(this.value); });

                document.querySelectorAll('input[name="arDiscount"]').forEach(function (r) {
                    r.addEventListener('change', function () { state.discount = parseInt(r.value, 10) || 0; render(); });
                });

                $('sortBy').addEventListener('change', function () { state.sort = this.value; render(); });

                var gridBtn = $('arGridView'), listBtn = $('arListView');
                gridBtn.addEventListener('click', function () {
                    grid.classList.remove('ar-list');
                    gridBtn.classList.add('ar-active'); listBtn.classList.remove('ar-active');
                });
                listBtn.addEventListener('click', function () {
                    grid.classList.add('ar-list');
                    listBtn.classList.add('ar-active'); gridBtn.classList.remove('ar-active');
                });

                $('arResetFilters').addEventListener('click', resetAll);
                $('arMobileReset').addEventListener('click', function () { resetAll(); setDrawer(false); });
                $('arClearEmpty').addEventListener('click', resetAll);
                var clearAll = $('arClearAll');
                if (clearAll) clearAll.addEventListener('click', resetAll);

                // Wishlist heart (visual only)
                grid.addEventListener('click', function (e) {
                    var btn = e.target.closest('.ar-wish');
                    if (!btn) return;
                    e.preventDefault();
                    var on = btn.classList.toggle('ar-wished');
                    showToast(on ? 'Saved to wishlist' : 'Removed from wishlist');
                });

                render();
            });
        })();
    </script>
</body>
</html>
