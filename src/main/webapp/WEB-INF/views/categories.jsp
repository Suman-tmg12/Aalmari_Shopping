<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
    String category = request.getParameter("name");
    if (category == null || category.trim().isEmpty()) {
        category = "Electronics";
    }
    String sub = request.getParameter("sub");
    if (sub != null && sub.trim().isEmpty()) {
        sub = null;
    }

    // Mock Data Sets
    String[][] electronicsData = {
        {"iPhone 15 Pro", "iphone15pro.jpg", "Products", "1500", "2300", "12.4k sold", "Mobiles"},
        {"Samsung Galaxy S24", "iphone15pro.jpg", "Products", "1400", "2100", "9.8k sold", "Mobiles"},
        {"MacBook Pro M3", "MacBookProm3.jpg", "Products", "2200", "3200", "9.7k sold", "Laptops"},
        {"Dell XPS 15", "MacBookProm3.jpg", "Products", "1900", "2800", "6.3k sold", "Laptops"},
        {"AirPods Pro", "Airpods.jpg", "Products", "250", "400", "15.2k sold", "Headphones"},
        {"Wireless Headphone", "Wireless_headPhone.jpg", "FlashSaleImages", "70", "120", "4.5k sold", "Headphones"},
        {"Smart Fitness Band", "SmartFitnessBand.jpg", "FlashSaleImages", "120", "200", "2.3k sold", "Smart Watches"},
        {"Bluetooth Speaker", "hairSpray.jpg", "Products", "180", "300", "1.1k sold", "Accessories"}
    };
    String[][] fashionData = {
        {"Nike Shoes", "nikeShoe.jpg", "Products", "200", "320", "8.1k sold", "Shoes"},
        {"Classic Black Shoes", "ClassicBlackShoes.jpg", "FlashSaleImages", "90", "180", "2.3k sold", "Shoes"},
        {"Black Glasses", "BlackGlass.jpg", "Products", "90", "150", "2.3k sold", "Men"},
        {"White T-Shirt", "WhiteSpray.jpg", "Products", "25", "50", "5.2k sold", "Men"},
        {"Summer Dress", "skincare.jpg", "Products", "45", "80", "3.1k sold", "Women"},
        {"Leather Handbag", "hairSpray.jpg", "Products", "120", "200", "1.8k sold", "Bags"}
    };
    String[][] beautyData = {
        {"Himalaya Face Scrub", "HimalayaFaceScrub.jpg", "FlashSaleImages", "70", "150", "4.5k sold", "Skincare"},
        {"Skin Care Set", "skincare.jpg", "FlashSaleImages", "150", "300", "1.8k sold", "Skincare"},
        {"White Spray", "WhiteSpray.jpg", "Products", "80", "140", "1.8k sold", "Fragrances"},
        {"Falcon Spray", "FalconSpray.jpg", "Products", "110", "200", "5.6k sold", "Fragrances"},
        {"Hair Spray", "hairSpray.jpg", "Products", "70", "150", "4.5k sold", "Hair Care"},
        {"Lipstick Set", "olipop.jpg", "Products", "35", "60", "8.2k sold", "Makeup"}
    };
    String[][] homeData = {
        {"Wooden Table", "home&living.jpg", "Products", "250", "400", "2.1k sold", "Furniture"},
        {"LED Lamp", "SmartFitnessBand.jpg", "Products", "45", "80", "5.6k sold", "Lighting"},
        {"Storage Box", "hairSpray.jpg", "Products", "15", "30", "9.3k sold", "Storage"},
        {"Kitchen Knife Set", "HimalayaFaceScrub.jpg", "Products", "35", "60", "4.2k sold", "Kitchen"}
    };
    String[][] groceriesData = {
        {"Organic Rice", "Healthy.jpg", "FlashSaleImages", "25", "40", "12.4k sold", "Rice & Grains"},
        {"Fresh Apples", "Healthy.jpg", "FlashSaleImages", "15", "25", "8.7k sold", "Fruits & Vegetables"},
        {"Snack Pack", "unhealthy-foods.jpg", "FlashSaleImages", "10", "20", "15.2k sold", "Snacks"},
        {"Milk Carton", "olipop.jpg", "Products", "8", "12", "6.3k sold", "Dairy"}
    };
    String[][] sportsData = {
        {"Yoga Mat", "SmartFitnessBand.jpg", "Products", "30", "50", "7.4k sold", "Fitness Accessories"},
        {"Dumbbell Set", "hairSpray.jpg", "Products", "85", "140", "3.2k sold", "Gym Equipment"},
        {"Running Shoes", "nikeShoe.jpg", "Products", "120", "200", "5.8k sold", "Sportswear"}
    };
    String[][] booksData = {
        {"Novel Collection", "hairSpray.jpg", "Products", "20", "35", "4.1k sold", "Books"},
        {"Pen Set", "WhiteSpray.jpg", "Products", "8", "15", "9.5k sold", "Pens & Pencils"},
        {"Notebook Pack", "skincare.jpg", "Products", "12", "20", "6.7k sold", "Notebooks"}
    };
    String[][] automotiveData = {
        {"Car Phone Holder", "hairSpray.jpg", "Products", "25", "45", "5.3k sold", "Car Accessories"},
        {"Bike Helmet", "SmartFitnessBand.jpg", "Products", "60", "100", "3.8k sold", "Helmets"},
        {"Car Wash Kit", "HimalayaFaceScrub.jpg", "Products", "35", "60", "2.9k sold", "Car Care"}
    };
    String[][] toysData = {
        {"Building Blocks", "hairSpray.jpg", "Products", "40", "70", "8.4k sold", "Toys"},
        {"Board Game", "skincare.jpg", "Products", "25", "45", "4.6k sold", "Board Games"},
        {"RC Car", "SmartFitnessBand.jpg", "Products", "55", "90", "3.1k sold", "Remote-Control Toys"}
    };
    String[][] healthData = {
        {"Vitamin C Tablets", "Healthy.jpg", "FlashSaleImages", "20", "35", "7.2k sold", "Vitamins & Supplements"},
        {"First Aid Kit", "hairSpray.jpg", "Products", "30", "55", "4.8k sold", "Healthcare Products"},
        {"Massage Roller", "SmartFitnessBand.jpg", "Products", "25", "40", "5.5k sold", "Fitness"}
    };

    String[][] categoryData;
    switch (category) {
        case "Fashion": categoryData = fashionData; break;
        case "Beauty & Personal Care": categoryData = beautyData; break;
        case "Home & Living": categoryData = homeData; break;
        case "Groceries": categoryData = groceriesData; break;
        case "Sports & Fitness": categoryData = sportsData; break;
        case "Books & Stationery": categoryData = booksData; break;
        case "Automotive": categoryData = automotiveData; break;
        case "Toys & Games": categoryData = toysData; break;
        case "Health & Wellness": categoryData = healthData; break;
        default: categoryData = electronicsData; category = "Electronics"; break;
    }

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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/category.css?v=4">
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

                <div class="product-grid" id="productGrid">
                    <%
                        boolean anyRendered = false;
                        for (String[] p : categoryData) {
                            String pName = p[0], pImage = p[1], pFolder = p[2];
                            long pPrice = Long.parseLong(p[3]);
                            long pOldPrice = Long.parseLong(p[4]);
                            String pSold = p[5], pSub = p[6];

                            if (sub != null && !sub.equalsIgnoreCase(pSub)) continue;
                            anyRendered = true;

                            int discount = (int) Math.round(((double)(pOldPrice - pPrice) / pOldPrice) * 100);

                            // Extract raw sold count for sorting (e.g. "12.4k sold" -> 12400)
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
                            <div class="product-tag"><%= escapeHtml(pSold) %></div>
                        </div>
                    </a>
                    <% }
                       if (!anyRendered) {
                    %>
                    <p class="no-products-msg">No products found in this sub-category yet.</p>
                    <% } %>
                </div>
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

                // Auto-scroll active mobile chip into view on load
                const activeChip = document.querySelector('.category-chip-bar .chip.active');
                if (activeChip) {
                    activeChip.scrollIntoView({
                        behavior: 'smooth',
                        inline: 'center',
                        block: 'nearest'
                    });
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

                        // Toggle accordion expand state on header click (except direct text link)
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

                // Client-side Product Sorting
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
                            return 0; // Default/Best match original order
                        });

                        cards.forEach(card => productGrid.appendChild(card));
                    });
                }
            });
        })();
    </script>
</body>
</html>