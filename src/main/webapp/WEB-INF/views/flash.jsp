<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%!
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
                .replace("\"", "&quot;").replace("'", "&#39;");
    }

    // Safe for use inside a JavaScript string
    private static String jsEsc(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("'", "\\'").replace("\"", "\\\"")
                .replace("<", "\\u003C").replace("\n", " ").replace("\r", " ");
    }
%>
<%
    // Selected category / sub-category from the URL (/flash?name=...&sub=...). Both optional.
    String curCat = request.getParameter("name");
    String curSub = request.getParameter("sub");
    if (curCat != null && curCat.trim().isEmpty()) curCat = null;
    if (curSub != null && curSub.trim().isEmpty()) curSub = null;
    String heading = curCat == null ? "All Flash Deals" : curCat;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flash Deals — Aalmari Store</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/flash.css?v=6">
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
                        <h1 class="results-title" id="pageTitle"><%= esc(heading) %></h1>
                        <p class="results-subtitle" id="pageSubtitle">
                            ${flashDeals.size()} live flash deal(s)<%= curCat != null ? " in " + esc(curCat) : "" %><%= curSub != null ? " &rsaquo; " + esc(curSub) : "" %>
                        </p>
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

                        <c:forEach var="d" items="${flashDeals}">
                        <article class="ar-card" data-price="${d.flashPrice}">
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
                                            <span class="ar-brand"><c:out value="${d.category}"/></span>
                                            <span class="ar-sold">${d.soldText}</span>
                                        </div>
                                        <h3 class="ar-p-title"><c:out value="${d.title}"/></h3>
                                    </div>
                                    <div class="ar-price-row">
                                        <div>
                                            <div class="ar-price">${d.currentPrice}</div>
                                            <div class="ar-old">${d.originalPrice}</div>
                                            <div class="ar-sub-muted"><c:out value="${d.subCategory}"/></div>
                                            <div class="ar-sub-muted fs-ends" data-end="${d.endTime}"></div>
                                        </div>
                                        <span class="ar-view">Add to cart</span>
                                    </div>
                                </div>
                            </a>
                        </article>
                        </c:forEach>

                        <c:if test="${empty flashDeals}">
                            <div style="grid-column: 1 / -1; text-align: center; padding: 50px; color: #666;">
                                <h2>No live flash deals in this category right now.</h2>
                            </div>
                        </c:if>
                    </div>
                </div>

            </section>
        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        (function () {
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
            const CURRENT_CATEGORY = '<%= jsEsc(curCat) %>';
            const CURRENT_SUB = '<%= jsEsc(curSub) %>';

            // "Ends in 02:14:09" under each card
            function pad(n) { return String(n).padStart(2, '0'); }
            function tickEnds() {
                document.querySelectorAll('.fs-ends').forEach(function (el) {
                    var s = Math.floor((Number(el.dataset.end) - Date.now()) / 1000);
                    if (s <= 0) { el.textContent = 'Ended'; return; }
                    var d = Math.floor(s / 86400); s %= 86400;
                    var h = Math.floor(s / 3600); s %= 3600;
                    var m = Math.floor(s / 60); s %= 60;
                    el.textContent = 'Ends in ' + (d ? d + 'd ' : '') + pad(h) + ':' + pad(m) + ':' + pad(s);
                });
            }

            document.addEventListener('DOMContentLoaded', function () {
                tickEnds();
                setInterval(tickEnds, 1000);

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
                        a.href = pageCTX + '/flash?name=' + encodeURIComponent(cat) + '&sub=' + encodeURIComponent(sub);
                        a.className = 'flash-sub-link' + (cat === CURRENT_CATEGORY && sub === CURRENT_SUB ? ' active' : '');
                        a.textContent = sub;
                        subList.appendChild(a);
                    });

                    header.addEventListener('click', () => {
                        if (wrap.classList.contains('open')) {
                            wrap.classList.remove('open');
                            header.classList.remove('active-cat');
                        } else {
                            window.location.href = pageCTX + '/flash?name=' + encodeURIComponent(cat);
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