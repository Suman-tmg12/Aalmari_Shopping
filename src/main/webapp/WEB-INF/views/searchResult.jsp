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
%>
<%
    String rawQuery = request.getParameter("q");
    String searchQuery = (rawQuery != null) ? rawQuery.trim() : "";
    String filterCategory = request.getParameter("cat");

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

    // Filter results matching the search query
    List<String[]> matchingProducts = new ArrayList<>();
    String lowerQuery = searchQuery.toLowerCase();

    for (String[] p : allProductsData) {
        String pName = p[0].toLowerCase();
        String pSub = p[6].toLowerCase();
        String pMainCat = p[7].toLowerCase();

        boolean matchesSearch = lowerQuery.isEmpty()
            || pName.contains(lowerQuery)
            || pSub.contains(lowerQuery)
            || pMainCat.contains(lowerQuery);

        boolean matchesCategoryFilter = (filterCategory == null || filterCategory.trim().isEmpty())
            || p[7].equalsIgnoreCase(filterCategory);

        if (matchesSearch && matchesCategoryFilter) {
            matchingProducts.add(p);
        }
    }

    String pageTitle = searchQuery.isEmpty() ? "All Products" : "Search results for \"" + escapeHtml(searchQuery) + "\"";
    String pageSubtitle = matchingProducts.size() + " product" + (matchingProducts.size() == 1 ? "" : "s") + " found";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= searchQuery.isEmpty() ? "Search Results" : escapeHtml(searchQuery) %> — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/searchResult.css?v=1">
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="search-page"
         data-ctx="${pageContext.request.contextPath}"
         data-query="<%= escapeHtml(searchQuery) %>">

        <!-- Mobile Quick Category Filters -->
        <nav class="category-chip-bar" aria-label="Filter categories">
            <a href="${pageContext.request.contextPath}/search?q=<%= java.net.URLEncoder.encode(searchQuery, "UTF-8") %>"
               class="chip<%= (filterCategory == null || filterCategory.isEmpty()) ? " active" : "" %>">All Results</a>
            <%
                String[] categoriesList = {"Electronics", "Fashion", "Beauty & Personal Care", "Home & Living", "Groceries", "Sports & Fitness", "Books & Stationery", "Automotive", "Toys & Games", "Health & Wellness"};
                for (String cat : categoriesList) {
                    boolean isActive = cat.equalsIgnoreCase(filterCategory);
            %>
            <a href="${pageContext.request.contextPath}/search?q=<%= java.net.URLEncoder.encode(searchQuery, "UTF-8") %>&cat=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"
               class="chip<%= isActive ? " active" : "" %>"><%= escapeHtml(cat) %></a>
            <% } %>
        </nav>

        <div class="search-layout">
            <!-- Sidebar Category Refinement -->
            <aside class="category-sidebar">
                <h2 class="sidebar-title">Refine Search</h2>
                <ul class="search-filter-list">
                    <li>
                        <a href="${pageContext.request.contextPath}/search?q=<%= java.net.URLEncoder.encode(searchQuery, "UTF-8") %>"
                           class="filter-link <%= (filterCategory == null || filterCategory.isEmpty()) ? "active" : "" %>">
                            <span>All Categories</span>
                        </a>
                    </li>
                    <% for (String cat : categoriesList) {
                        boolean isActive = cat.equalsIgnoreCase(filterCategory);
                    %>
                    <li>
                        <a href="${pageContext.request.contextPath}/search?q=<%= java.net.URLEncoder.encode(searchQuery, "UTF-8") %>&cat=<%= java.net.URLEncoder.encode(cat, "UTF-8") %>"
                           class="filter-link <%= isActive ? "active" : "" %>">
                            <span><%= escapeHtml(cat) %></span>
                        </a>
                    </li>
                    <% } %>
                </ul>
            </aside>

            <!-- Results Section -->
            <section class="results-section">
                <div class="results-header">
                    <div>
                        <h1 class="results-title"><%= pageTitle %></h1>
                        <p class="results-subtitle"><%= pageSubtitle %></p>
                    </div>
                    <div class="sort-row">
                        <label class="sort-label" for="sortBy">Sort By:</label>
                        <select id="sortBy" class="sort-select" aria-label="Sort search results">
                            <option value="best">Relevance / Best Match</option>
                            <option value="low-high">Price: Low to High</option>
                            <option value="high-low">Price: High to Low</option>
                            <option value="popular">Most Popular</option>
                        </select>
                    </div>
                </div>

                <div class="product-grid" id="productGrid">
                    <%
                        if (matchingProducts.isEmpty()) {
                    %>
                    <div class="no-results-card">
                        <span class="material-symbols-outlined no-results-icon">search_off</span>
                        <h3>No results found for "<%= escapeHtml(searchQuery) %>"</h3>
                        <p>Try checking your spelling, using more general terms, or exploring our categories above.</p>
                        <a href="${pageContext.request.contextPath}/" class="btn-home">Back to Homepage</a>
                    </div>
                    <%
                        } else {
                            for (String[] p : matchingProducts) {
                                String pName = p[0], pImage = p[1], pFolder = p[2];
                                long pPrice = Long.parseLong(p[3]);
                                long pOldPrice = Long.parseLong(p[4]);
                                String pSold = p[5], pSub = p[6];

                                int discount = (int) Math.round(((double)(pOldPrice - pPrice) / pOldPrice) * 100);

                                double numericSold = 0;
                                try {
                                    String cleanSold = pSold.toLowerCase().replace("sold", "").replace("k", "000").trim();
                                    numericSold = Double.parseDouble(cleanSold);
                                } catch (Exception ignored) {}
                    %>
                    <a href="#" class="product-card" data-price="<%= pPrice %>" data-sold="<%= numericSold %>" data-name="<%= escapeHtml(pName) %>">
                        <div class="product-image-wrap">
                            <img src="${pageContext.request.contextPath}/HomePageImages/<%= pFolder %>/<%= pImage %>"
                                 alt="<%= escapeHtml(pName) %>"
                                 class="product-image"
                                 loading="lazy">
                            <span class="discount-badge">-<%= discount %>%</span>
                        </div>
                        <div class="product-meta">
                            <div class="product-name"><%= escapeHtml(pName) %></div>
                            <div class="product-price-row">
                                <span class="product-price">Rs.<%= pPrice %></span>
                                <span class="product-old-price">Rs.<%= pOldPrice %></span>
                            </div>
                            <div class="product-tag"><%= escapeHtml(pSold) %> • <%= escapeHtml(pSub) %></div>
                        </div>
                    </a>
                    <%
                            }
                        }
                    %>
                </div>
            </section>
        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        (function () {
            'use strict';

            document.addEventListener('DOMContentLoaded', function () {
                const activeChip = document.querySelector('.category-chip-bar .chip.active');
                if (activeChip) {
                    activeChip.scrollIntoView({
                        behavior: 'smooth',
                        inline: 'center',
                        block: 'nearest'
                    });
                }

                // Sorting behavior for Search Results
                const sortSelect = document.getElementById('sortBy');
                const productGrid = document.getElementById('productGrid');

                if (sortSelect && productGrid) {
                    sortSelect.addEventListener('change', function () {
                        const cards = Array.from(productGrid.querySelectorAll('.product-card'));
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
                            return 0; // Default relevance order
                        });

                        cards.forEach(card => productGrid.appendChild(card));
                    });
                }
            });
        })();
    </script>
</body>
</html>