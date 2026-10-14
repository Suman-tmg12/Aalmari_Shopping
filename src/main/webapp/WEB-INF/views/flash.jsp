<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flash Deals — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/flash.css?v=5">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
   <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="flash-page">

        <div class="flash-layout">

            <!-- Sidebar: Flash dropdown accordion -->
            <aside class="flash-sidebar">
                <h3 class="sidebar-title">Flash Deals</h3>
                <div id="sidebarAccordion"></div>
            </aside>

            <!-- Results -->
            <section class="results-section">

                <div class="results-header">
                    <div>
                        <h1 class="results-title" id="pageTitle">Electronics</h1>
                        <p class="results-subtitle" id="pageSubtitle">Showing results for Electronics</p>
                    </div>
                    <div class="sort-row">
                        <label class="sort-label" for="sortBy">Sort By:</label>
                        <select id="sortBy" class="sort-select">
                            <option>Best Match</option>
                            <option>Price: Low to High</option>
                            <option>Price: High to Low</option>
                            <option>Newest</option>
                            <option>Most Popular</option>
                        </select>
                    </div>
                </div>

                <!-- Product Grid (3 per row) -->
                <div class="ar-page">
                    <div class="ar-grid" id="productGrid">
                    <%
                        String[] prodIds     = {"iphone-15-pro", "macbook-pro-m3", "airpods-pro", "wireless-headphone", "smart-fitness-band", "bluetooth-speaker"}; // adjust
                        String[] prods       = {"iPhone 15 Pro", "MacBook Pro M3", "AirPods Pro", "Wireless Headphone", "Smart Fitness Band", "Bluetooth Speaker"};
                        String[] prodImages  = {"iphone15pro.jpg", "MacBookProm3.jpg", "Airpods.jpg", "Wireless_headPhone.jpg", "SmartFitnessBand.jpg", "hairSpray.jpg"};
                        String[] prodFolders = {"Products", "Products", "Products", "FlashSaleImages", "FlashSaleImages", "Products"};
                        long[]   prodPrices    = {1500, 2200, 250, 70, 120, 180};
                        long[]   prodOldPrices = {2300, 3200, 400, 120, 200, 300};
                        String[] prodSold    = {"12.4k sold", "9.7k sold", "15.2k sold", "4.5k sold", "2.3k sold", "1.1k sold"};
                        String[] prodBrands  = {"Electronics", "Electronics", "Electronics", "Electronics", "Electronics", "Electronics"}; // adjust
                        String[] prodSubs    = {"Mobiles", "Laptops", "Headphones", "Headphones", "Smart Watches", "Accessories"};        // adjust

                        for (int i = 0; i < prods.length; i++) {
                            long price = prodPrices[i];
                            long oldPrice = prodOldPrices[i];
                            int discount = oldPrice > 0 ? (int) Math.round(((double) (oldPrice - price) / oldPrice) * 100) : 0;
                    %>
                        <article class="ar-card" data-index="<%= i %>" data-price="<%= price %>" data-name="<%= esc(prods[i]) %>">
                            <button type="button" class="ar-wish" aria-label="Save to wishlist">
                                <span class="material-symbols-outlined ar-ic-sm">favorite</span>
                            </button>
                            <a href="${pageContext.request.contextPath}/flashsaleproduct?id=<%= prodIds[i] %>" class="ar-card-link">
                                <div class="ar-card-img">
                                    <img src="${pageContext.request.contextPath}/HomePageImages/<%= prodFolders[i] %>/<%= prodImages[i] %>"
                                         alt="<%= esc(prods[i]) %>" loading="lazy">
                                    <% if (discount > 0) { %><span class="ar-badge">-<%= discount %>%</span><% } %>
                                </div>
                                <div class="ar-card-body">
                                    <div>
                                        <div class="ar-card-top">
                                            <span class="ar-brand"><%= esc(prodBrands[i]) %></span>
                                            <span class="ar-sold"><%= esc(prodSold[i]) %></span>
                                        </div>
                                        <h3 class="ar-p-title"><%= esc(prods[i]) %></h3>
                                    </div>
                                    <div class="ar-price-row">
                                        <div>
                                            <div class="ar-price">Rs.<%= price %></div>
                                            <% if (oldPrice > price) { %><div class="ar-old">Rs.<%= oldPrice %></div><% } %>
                                            <div class="ar-sub-muted"><%= esc(prodSubs[i]) %></div>
                                        </div>
                                        <span class="ar-view">Add to cart</span>
                                    </div>
                                </div>
                            </a>
                        </article>
                    <% } %>
                    </div>
                </div>

            </section>
        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        (function () {
            // ===== Category Data (scoped locally to avoid clashing with header2.jsp) =====
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

            const pageCTX = '${pageContext.request.contextPath}';
            const CURRENT_CATEGORY = 'Electronics'; // TODO: set from request attribute server-side

            document.addEventListener('DOMContentLoaded', function () {
                // Wishlist heart toggle
                document.querySelectorAll('#productGrid .ar-wish').forEach(function (btn) {
                    btn.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        btn.classList.toggle('ar-wished');
                    });
                });

                const accordion = document.getElementById('sidebarAccordion');
                if (!accordion) return;

                Object.keys(pageCategories).forEach(cat => {
                    const wrap = document.createElement('div');
                    wrap.className = 'flash-group' + (cat === CURRENT_CATEGORY ? ' open' : '');

                    const header = document.createElement('div');
                    header.className = 'flash-header' + (cat === CURRENT_CATEGORY ? ' active-cat' : '');
                    header.innerHTML = '<span>' + cat + '</span><span class="material-symbols-outlined chevron">expand_more</span>';

                    const subList = document.createElement('div');
                    subList.className = 'flash-sub-list';
                    pageCategories[cat].forEach(sub => {
                        const a = document.createElement('a');
                        a.href = pageCTX + '/category?name=' + encodeURIComponent(cat) + '&sub=' + encodeURIComponent(sub);
                        a.className = 'flash-sub-link';
                        a.textContent = sub;
                        subList.appendChild(a);
                    });

                    header.addEventListener('click', () => {
                        const isOpen = wrap.classList.contains('open');
                        document.querySelectorAll('.flash-group.open').forEach(g => {
                            g.classList.remove('open');
                            g.querySelector('.flash-header').classList.remove('active-cat');
                        });
                        if (!isOpen) {
                            wrap.classList.add('open');
                            header.classList.add('active-cat');
                            document.getElementById('pageTitle').textContent = cat;
                            document.getElementById('pageSubtitle').textContent = 'Showing results for ' + cat;
                        }
                    });

                    wrap.appendChild(header);
                    wrap.appendChild(subList);
                    accordion.appendChild(wrap);
                });
            });
        })();
    </script>

</body>
</html>