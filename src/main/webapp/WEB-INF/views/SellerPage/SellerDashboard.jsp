<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="com.fasterxml.jackson.databind.ObjectMapper" %>
<%@ page import="com.fasterxml.jackson.databind.JsonNode" %>
<%@ page import="com.example.aalmari.dto.SellerFinance" %>
<%!
    /** HTML-escape anything that came from a user before printing it. */
    static String h(String s) {
        if (s == null) return "";
        StringBuilder b = new StringBuilder(s.length() + 16);
        for (int k = 0; k < s.length(); k++) {
            char c = s.charAt(k);
            switch (c) {
                case '&':  b.append("&amp;");  break;
                case '<':  b.append("&lt;");   break;
                case '>':  b.append("&gt;");   break;
                case '"':  b.append("&quot;"); break;
                case '\'': b.append("&#39;");  break;
                default:   b.append(c);
            }
        }
        return b.toString();
    }

    /** First letter for placeholder thumbnails (always safe to put inside a JS string). */
    static String initial(String s) {
        if (s == null || s.isEmpty()) return "?";
        char c = Character.toUpperCase(s.charAt(0));
        return Character.isLetterOrDigit(c) ? String.valueOf(c) : "?";
    }

    static String nz(String s) { return s == null ? "" : s; }

    /** JSON used by the Edit form (read by SellerDashboard.js from data-json). */
    static String editJson(String[] p) {
        ObjectMapper om = new ObjectMapper();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("name", p[0]);
        m.put("cat", p[2]);
        m.put("sub", p[8]);
        m.put("price", Integer.parseInt(p[3]));
        m.put("disc", p[4].isEmpty() ? 0 : Integer.parseInt(p[4]));
        m.put("stock", Integer.parseInt(p[5]));
        m.put("active", "Active".equals(p[7]));
        m.put("description", p[12]);
        JsonNode attrs;
        try { attrs = om.readTree(p[13]); } catch (Exception e) { attrs = om.createObjectNode(); }
        if (attrs == null || !attrs.isObject()) attrs = om.createObjectNode();
        m.put("attrs", attrs);
        m.put("infoImage", p[9]);
        try { return om.writeValueAsString(m); } catch (Exception e) { return "{}"; }
    }
%>
<%
    // ---------------- Store status ----------------
    String rawStatus = (String) request.getAttribute("status");
    if (rawStatus == null) rawStatus = "pending";
    String storeName = (String) request.getAttribute("storeName");
    if (storeName == null) storeName = "";
    String rejectionReason = (String) request.getAttribute("rejectionReason");

    boolean isApproved    = "approved".equalsIgnoreCase(rawStatus);
    boolean isRejected    = "rejected".equalsIgnoreCase(rawStatus);
    boolean isUnderReview = "pending".equalsIgnoreCase(rawStatus);

    String status = isApproved ? "Approved" : isRejected ? "Rejected" : "Under Review";
    String activeMenu = "Dashboard";

    // ---------------- REAL finance data (OrderService.sellerFinance) ----------------
    SellerFinance fin = (SellerFinance) request.getAttribute("finance");
    if (fin == null) fin = SellerFinance.empty();

    String[] months         = fin.months;
    long[]   grossByMonth   = fin.gross;
    int[]    ordersByMonth  = fin.orders;
    double   commissionRate = fin.commissionRate;

    int last = months.length - 1;
    long grossTotal = 0;
    for (long gv : grossByMonth) grossTotal += gv;
    long commissionTotal = Math.round(grossTotal * commissionRate);
    long netTotal        = grossTotal - commissionTotal;
    long curGross        = grossByMonth[last];
    long curCommission   = Math.round(curGross * commissionRate);
    long pendingPayout   = curGross - curCommission;
    int  curOrders       = ordersByMonth[last];

    long prevGross  = last > 0 ? grossByMonth[last - 1] : 0;
    int  prevOrders = last > 0 ? ordersByMonth[last - 1] : 0;
    boolean revUp = curGross >= prevGross;
    boolean ordUp = curOrders >= prevOrders;
    String revChangeTxt = prevGross > 0
            ? String.format("%+d%% vs last month", Math.round((curGross - prevGross) * 100.0 / prevGross))
            : "No sales last month";
    String ordChangeTxt = prevOrders > 0
            ? String.format("%+d%% vs last month", Math.round((curOrders - prevOrders) * 100.0 / prevOrders))
            : "No orders last month";

    // Chart scales adapt to the real numbers
    long maxGross = 0; for (long gv : grossByMonth) maxGross = Math.max(maxGross, gv);
    int  maxOrd   = 0; for (int ov : ordersByMonth) maxOrd = Math.max(maxOrd, ov);
    long tickStep = 2500;
    if (maxGross > 0) {
        long rawStep = (long) Math.ceil(maxGross / 4.0);
        long pow10 = (long) Math.pow(10, Math.floor(Math.log10(rawStep)));
        double mant = rawStep / (double) pow10;
        tickStep = (mant <= 1 ? 1 : mant <= 2 ? 2 : mant <= 5 ? 5 : 10) * pow10;
    }
    long   axisMax = tickStep * 4;
    double yScale  = 200.0 / axisMax;
    double oScale  = 200.0 / Math.max(1, maxOrd);

    StringBuilder csvBuilder = new StringBuilder("Month,Gross,Net\n");
    for (int ci = 0; ci < months.length; ci++) {
        csvBuilder.append(months[ci]).append(",").append(grossByMonth[ci]).append(",")
                  .append(Math.round(grossByMonth[ci] * (1 - commissionRate))).append("\n");
    }
    String csvData = csvBuilder.toString().replace("\n", "&#10;");

    List<SellerFinance.Earn>   earnings = fin.earnings;
    List<SellerFinance.Payout> payouts  = fin.payouts;
    long maxEarn = 0;
    for (SellerFinance.Earn er : earnings) maxEarn = Math.max(maxEarn, er.amount);

    // ---------------- Demo data that has no backend yet ----------------
    String[][] reviews = {
        {"Priya Nair", "5", "Hand-Thrown Ceramic Mug", "Beautiful glaze and it feels perfect in the hand."},
        {"Søren Lindqvist", "5", "Full-Grain Leather Wallet", "Great quality leather, stitching is flawless."},
        {"James Okafor", "4", "Merino Wool Scarf", "Very soft and warm. Colour was slightly darker."},
        {"Marta Kowalczyk", "5", "Waxed Canvas Tote Bag", "Sturdy, roomy and looks even better after use."}
    };

    String[][] messages = {
        {"Priya Nair", "Question about ceramic mug sizes", "Hi, do you offer the mug in a larger 400ml version?", "2h ago", "1"},
        {"James Okafor", "Shipping to Nigeria", "Is express shipping available to Abuja?", "Yesterday", "1"},
        {"Marta Kowalczyk", "Custom monogram on tote?", "Can I request a monogram on the canvas tote?", "Aug 10", "0"}
    };
    int unreadMessages = 0;
    for (String[] mm : messages) if ("1".equals(mm[4])) unreadMessages++;

    // ---------------- Products from the database ----------------
    @SuppressWarnings("unchecked")
    List<com.example.aalmari.model.SellerProduct> realProducts =
        (List<com.example.aalmari.model.SellerProduct>) request.getAttribute("products");
    if (realProducts == null) realProducts = new ArrayList<>();

    // columns: 0 name, 1 sku, 2 category, 3 price, 4 discount, 5 stock, 6 sold, 7 status,
    //          8 subCategory, 9 infoImage, 10 imagesJson, 11 id, 12 description, 13 attrsJson, 14 thumbnail
    String[][] products = new String[realProducts.size()][15];
    int i = 0;
    for (com.example.aalmari.model.SellerProduct p : realProducts) {
        products[i][0]  = nz(p.getName());
        products[i][1]  = nz(p.getSku());
        products[i][2]  = nz(p.getCategory());
        products[i][3]  = String.valueOf(p.getPrice() == null ? 0 : p.getPrice());
        products[i][4]  = String.valueOf(p.getDiscount() == null ? 0 : p.getDiscount());
        products[i][5]  = String.valueOf(p.getStock() == null ? 0 : p.getStock());
        products[i][6]  = String.valueOf(p.getSold() == null ? 0 : p.getSold());
        products[i][7]  = Boolean.TRUE.equals(p.getActive()) ? "Active" : "Inactive";
        products[i][8]  = nz(p.getSubCategory());
        products[i][9]  = nz(p.getInfoImageUrl());
        products[i][10] = (p.getImageUrlsJson() != null && !p.getImageUrlsJson().isEmpty()) ? p.getImageUrlsJson() : "[]";
        products[i][11] = String.valueOf(p.getId());
        products[i][12] = nz(p.getDescription());
        products[i][13] = (p.getAttributesJson() != null && !p.getAttributesJson().isEmpty()) ? p.getAttributesJson() : "{}";

        // Thumbnail = first gallery image, fallback to info image
        String thumb = "";
        if (!products[i][10].trim().equals("[]")) {
            try {
                List<?> galleryList = new ObjectMapper().readValue(products[i][10], List.class);
                if (!galleryList.isEmpty() && galleryList.get(0) != null && !galleryList.get(0).toString().isEmpty()) {
                    thumb = galleryList.get(0).toString();
                }
            } catch (Exception ex) { }
        }
        if (thumb.isEmpty()) thumb = products[i][9];
        products[i][14] = thumb;
        i++;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Seller Hub - Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/seller/SellerDashboard.css?v=15">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon_names" />
</head>
<body>
    <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="container">
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <div class="icon-box"></div>
                <span class="nav-text">Aalmari Seller Hub</span>
                <span class="collapse" id="collapseBtn">
                    <span class="material-symbols-outlined">arrow_back_ios</span>
                </span>
            </div>

            <div class="store-status" id="sidebarStatus">
                <span class="dot"></span>
                <span class="status-text nav-text" id="statusText"><%= status %></span>
                <span class="store-name nav-text"><%= h(storeName) %></span>
            </div>

            <div class="nav" id="sidebarNav">
                <%
                    String[][] items = {
                        {"<span class=\"material-symbols-outlined\">dashboard</span>", "Dashboard"},
                        {"<span class=\"material-symbols-outlined\">package_2</span>", "Products"},
                        {"<span class=\"material-symbols-outlined\">bolt</span>", "Flash Sale"},
                        {"<span class=\"material-symbols-outlined\">shopping_bag</span>", "Orders"},
                        {"<span class=\"material-symbols-outlined\">currency_rupee</span>", "Finance"},
                        {"<span class=\"material-symbols-outlined\">storefront</span>", "My Store"},
                        {"<span class=\"material-symbols-outlined\">chat_bubble</span>", "Messages"}
                    };
                    for (String[] item : items) {
                        String icon = item[0];
                        String name = item[1];
                        boolean isActive = name.equals(activeMenu);
                        boolean isDisabled = isUnderReview && !name.equals("Dashboard");
                %>
                <div class="nav-item<%= isActive ? " active" : "" %><%= isDisabled ? " disabled" : "" %>"
                     data-view="<%= name.toLowerCase().replace(" ", "") %>"
                     <% if (isDisabled) { %>title="Access restricted until application approval"<% } else { %>title="<%= name %>"<% } %>>
                    <span class="nav-icon"><%= icon %></span>
                    <span class="nav-text"><%= name %></span>
                    <% if (name.equals("Messages") && unreadMessages > 0) { %>
                        <span class="badge"><%= unreadMessages %></span>
                    <% } %>
                </div>
                <% } %>
            </div>
        </div>

        <!-- Main Content Area -->
        <div class="main">

            <!-- ============ VIEW: DASHBOARD ============ -->
            <div class="view" id="view-dashboard">

                <!-- Under review -->
                <div class="review-card" id="reviewState" style="display:none;">
                    <div class="review-icon">⏱</div>
                    <h1>Application under review</h1>
                    <p>
                        Your seller application has been submitted. Our team reviews within 2 business days.
                        We'll notify you by email once a decision is made.
                    </p>
                    <div class="steps">
                        <div class="step done">
                            <div class="circle"><span class="material-symbols-outlined">description</span></div>
                            <span class="label">Application submitted</span>
                        </div>
                        <div class="step current">
                            <div class="circle"><span class="material-symbols-outlined">group</span></div>
                            <span class="label">Team review</span>
                        </div>
                        <div class="step pending">
                            <div class="circle"><span class="material-symbols-outlined">task_alt</span></div>
                            <span class="label">Approved &amp; live</span>
                        </div>
                    </div>
                </div>

                <!-- Rejected -->
                <div class="review-card" id="rejectedState" style="display:none;">
                    <div class="review-icon">✕</div>
                    <h1>Application rejected</h1>
                    <p>
                        <% if (rejectionReason != null && !rejectionReason.isEmpty()) { %>
                            Reason: <%= h(rejectionReason) %>
                        <% } else { %>
                            Your seller application was not approved this time.
                        <% } %>
                    </p>
                    <a href="${pageContext.request.contextPath}/seller" class="btn-primary" style="text-decoration:none;">
                        Re-apply
                    </a>
                </div>

                <!-- Approved dashboard -->
                <div id="approvedDashboard" style="display: none;">
                    <%
                        int inactiveCount = 0;
                        String lowName = null; int lowStock = 0;
                        for (String[] dp : products) {
                            if (!"Active".equals(dp[7])) inactiveCount++;
                            int ds = Integer.parseInt(dp[5]);
                            if ("Active".equals(dp[7]) && ds > 0 && ds <= 5 && lowName == null) { lowName = dp[0]; lowStock = ds; }
                        }

                        // ---- Smooth line + area chart geometry ----
                        int chartLeft = 50, chartStep = 180, chartBase = 220;
                        int[] rx = new int[months.length], ry = new int[months.length], oy = new int[months.length];
                        for (int ci2 = 0; ci2 < months.length; ci2++) {
                            rx[ci2] = chartLeft + ci2 * chartStep;
                            ry[ci2] = chartBase - (int) Math.round(grossByMonth[ci2] * yScale);
                            oy[ci2] = chartBase - (int) Math.round(ordersByMonth[ci2] * oScale);
                        }
                        StringBuilder revPath = new StringBuilder("M " + rx[0] + "," + ry[0]);
                        StringBuilder ordPath = new StringBuilder("M " + rx[0] + "," + oy[0]);
                        for (int ci2 = 1; ci2 < months.length; ci2++) {
                            int mid = (rx[ci2 - 1] + rx[ci2]) / 2;
                            revPath.append(" C ").append(mid).append(",").append(ry[ci2 - 1]).append(" ")
                                   .append(mid).append(",").append(ry[ci2]).append(" ")
                                   .append(rx[ci2]).append(",").append(ry[ci2]);
                            ordPath.append(" C ").append(mid).append(",").append(oy[ci2 - 1]).append(" ")
                                   .append(mid).append(",").append(oy[ci2]).append(" ")
                                   .append(rx[ci2]).append(",").append(oy[ci2]);
                        }
                        String areaPath = revPath + " L " + rx[months.length - 1] + "," + chartBase + " L " + rx[0] + "," + chartBase + " Z";

                        // ---- Top products: real best sellers ----
                        List<String[]> topProducts = new ArrayList<>(Arrays.asList(products));
                        topProducts.sort((ta, tb) -> Integer.parseInt(tb[6]) - Integer.parseInt(ta[6]));
                        if (topProducts.size() > 5) topProducts = new ArrayList<>(topProducts.subList(0, 5));
                        int topMaxSold = 0;
                        for (String[] tp : topProducts) topMaxSold = Math.max(topMaxSold, Integer.parseInt(tp[6]));
                        int topMax = Math.max(4, ((topMaxSold + 3) / 4) * 4);
                    %>

                    <!-- Page header -->
                    <div class="page-header center-v">
                        <div>
                            <h1 class="page-title">Seller Dashboard</h1>
                            <div class="page-subtitle"><%= fin.currentMonthLabel %> · <%= h(storeName) %></div>
                        </div>
                        <div class="header-actions">
                            <span class="approved-badge">
                                <span class="material-symbols-outlined">check_circle</span> Approved seller
                            </span>
                            <button type="button" class="icon-btn" aria-label="Notifications">
                                <span class="material-symbols-outlined">notifications</span>
                            </button>
                        </div>
                    </div>

                    <!-- Stat cards -->
                    <div class="stat-grid">
                        <div class="stat-card">
                            <div class="stat-top">
                                <span class="stat-label">Revenue (<%= months[last] %>)</span>
                                <span class="stat-icon ic-orange"><span class="material-symbols-outlined">currency_rupee</span></span>
                            </div>
                            <div class="stat-value">Rs <%= String.format("%,d", curGross) %></div>
                            <div class="stat-sub <%= revUp ? "up" : "down" %>"><span class="material-symbols-outlined"><%= revUp ? "north_east" : "south_east" %></span> <%= revChangeTxt %></div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-top">
                                <span class="stat-label">Orders</span>
                                <span class="stat-icon ic-blue"><span class="material-symbols-outlined">shopping_bag</span></span>
                            </div>
                            <div class="stat-value"><%= curOrders %></div>
                            <div class="stat-sub <%= ordUp ? "up" : "down" %>"><span class="material-symbols-outlined"><%= ordUp ? "north_east" : "south_east" %></span> <%= ordChangeTxt %></div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-top">
                                <span class="stat-label">Products</span>
                                <span class="stat-icon ic-purple"><span class="material-symbols-outlined">package_2</span></span>
                            </div>
                            <div class="stat-value"><%= products.length %></div>
                            <div class="stat-sub"><%= inactiveCount %> inactive</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-top">
                                <span class="stat-label">Store rating</span>
                                <span class="stat-icon ic-green"><span class="material-symbols-outlined">star</span></span>
                            </div>
                            <div class="stat-value">4.8★</div>
                            <div class="stat-sub">From 214 reviews</div>
                        </div>
                    </div>

                    <!-- Alerts (JS keeps these live) -->
                    <div class="alerts-grid">
                        <% if (lowName != null) { %>
                        <div class="alert-card warning">
                            <span class="material-symbols-outlined alert-icon">warning</span>
                            <div class="alert-content">
                                <div class="alert-title">Low stock alert</div>
                                <div class="alert-body"><%= h(lowName) %> — only <%= lowStock %> units left.</div>
                            </div>
                        </div>
                        <% } %>
                        <% if (unreadMessages > 0) { %>
                        <div class="alert-card info">
                            <span class="material-symbols-outlined alert-icon">inbox</span>
                            <div class="alert-content">
                                <div class="alert-title"><%= unreadMessages %> unread messages</div>
                                <div class="alert-body">Customer inquiries awaiting reply.</div>
                            </div>
                        </div>
                        <% } %>
                    </div>

                    <!-- Charts -->
                    <div class="charts-grid">
                        <div class="chart-card">
                            <div class="card-header">
                                <div>
                                    <div class="card-title">Revenue &amp; Orders</div>
                                    <div class="card-subtitle">Last 6 months · delivered orders</div>
                                </div>
                                <div class="chart-legend">
                                    <span><span class="legend-line revenue-line"></span> Revenue</span>
                                    <span><span class="legend-line orders-line"></span> Orders</span>
                                </div>
                            </div>

                            <svg viewBox="0 0 980 250" class="area-chart-svg" role="img" aria-label="Revenue and orders, last 6 months">
                                <defs>
                                    <linearGradient id="revFill" x1="0" y1="0" x2="0" y2="1">
                                        <stop offset="0%" stop-color="#d97213" stop-opacity="0.16" />
                                        <stop offset="100%" stop-color="#d97213" stop-opacity="0" />
                                    </linearGradient>
                                </defs>

                                <% for (int gt2 = 0; gt2 <= 4; gt2++) {
                                       long gv2 = gt2 * tickStep;
                                       int gy = chartBase - (int) Math.round(gv2 * yScale); %>
                                <line x1="50" y1="<%= gy %>" x2="950" y2="<%= gy %>" class="grid-line" />
                                <text x="40" y="<%= gy + 4 %>" class="axis-text" text-anchor="end"><%= String.format("%,d", gv2) %></text>
                                <% } %>

                                <% for (int vi = 0; vi < months.length; vi++) { %>
                                <line x1="<%= rx[vi] %>" y1="20" x2="<%= rx[vi] %>" y2="220" class="grid-line" />
                                <text x="<%= rx[vi] %>" y="242" class="axis-text" text-anchor="middle"><%= months[vi] %></text>
                                <% } %>

                                <path d="<%= areaPath %>" fill="url(#revFill)" />
                                <path d="<%= revPath %>" fill="none" stroke="#d97213" stroke-width="2.5" stroke-linecap="round" />
                                <path d="<%= ordPath %>" fill="none" stroke="#3b5bdb" stroke-width="2.5" stroke-linecap="round" />
                            </svg>
                        </div>

                        <div class="chart-card">
                            <div class="card-header">
                                <div>
                                    <div class="card-title">Top products</div>
                                    <div class="card-subtitle">Units sold all time</div>
                                </div>
                            </div>

                            <div class="hbar-chart">
                                <% for (String[] tp : topProducts) {
                                       int soldTop = Integer.parseInt(tp[6]);
                                       int tw = (int) Math.round(soldTop * 100.0 / topMax);
                                       String lbl = tp[0].length() > 16 ? tp[0].substring(0, 15) + "…" : tp[0]; %>
                                <div class="hbar-row">
                                    <span class="hbar-label" title="<%= h(tp[0]) %>"><%= h(lbl) %></span>
                                    <div class="hbar-track"><div class="hbar-fill" style="width: <%= tw %>%;"></div></div>
                                </div>
                                <% } %>
                                <% if (topProducts.isEmpty()) { %><div class="muted-sm">No products yet.</div><% } %>
                                <div class="hbar-axis">
                                    <span>0</span><span><%= topMax / 4 %></span><span><%= topMax / 2 %></span><span><%= topMax * 3 / 4 %></span><span><%= topMax %></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Recent orders (filled by JS from #orderData) -->
                    <div class="recent-orders-card">
                        <div class="orders-header">
                            <h3>Recent orders</h3>
                            <a href="#" class="view-all-link">View all</a>
                        </div>
                        <div class="orders-table-wrapper">
                            <table class="orders-table">
                                <tbody></tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <!-- ============ END VIEW: DASHBOARD ============ -->


            <!-- ============ VIEW: PRODUCTS ============ -->
            <div class="view" id="view-products" style="display: none;">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Products</h1>
                        <div class="page-subtitle"><%= products.length %> listings</div>
                    </div>
                    <button class="btn-primary" type="button">
                        <span class="material-symbols-outlined">add</span> Add product
                    </button>
                </div>

                <div class="toolbar">
                    <div class="search-box">
                        <span class="material-symbols-outlined">search</span>
                        <input type="text" id="productSearch" placeholder="Search products...">
                    </div>
                    <button class="btn-filter" type="button">
                        <span class="material-symbols-outlined">filter_alt</span> Filter
                    </button>
                </div>

                <div class="products-card">
                    <table class="products-table" id="productsTable">
                        <thead>
                            <tr>
                                <th>PRODUCT</th>
                                <th>CATEGORY</th>
                                <th class="num">PRICE</th>
                                <th class="num">STOCK</th>
                                <th class="num">SOLD</th>
                                <th>STATUS</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                        <% for (String[] p : products) {
                               int stock = Integer.parseInt(p[5]);
                               boolean active = "Active".equals(p[7]);
                               String sub = p[8];
                               String ini = initial(p[0]);
                        %>
                        <tr data-id="<%= h(p[11]) %>" data-json="<%= h(editJson(p)) %>" data-images="<%= h(p[10]) %>">
                            <td>
                                <div class="prod-cell">
                                    <div class="prod-thumb">
                                        <% if (!p[14].isEmpty()) { %>
                                            <img src="<%= h(p[14]) %>" alt="Product Image" onerror="this.onerror=null;this.parentNode.textContent='<%= ini %>'">
                                        <% } else { %><%= ini %><% } %>
                                    </div>
                                    <div>
                                        <div class="prod-name"><%= h(p[0]) %></div>
                                        <div class="prod-sku"><%= h(p[1]) %></div>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <span class="cat-tag"><span class="material-symbols-outlined">sell</span><%= h(p[2]) %></span>
                                <% if (!sub.isEmpty()) { %><div class="sub-tag"><%= h(sub) %></div><% } %>
                            </td>
                            <td class="num price">Rs <%= p[3] %><% if (!p[4].isEmpty() && !p[4].equals("0")) { %><span class="discount">-<%= p[4] %>%</span><% } %></td>
                            <td class="num stock <%= stock == 0 ? "out" : (stock <= 5 ? "low" : "") %>"><%= stock %><%= stock == 0 ? " <small>Out</small>" : "" %></td>
                            <td class="num sold"><%= p[6] %></td>
                            <td><span class="pill <%= active ? "pill-active" : "pill-inactive" %>"><%= p[7] %></span></td>
                            <td class="actions">
                                <span class="material-symbols-outlined" data-act="edit">edit</span>
                                <span class="material-symbols-outlined" data-act="del">delete</span>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>

                    <div class="pagination" id="productsPagination" style="display:none;"></div>
                </div>
            </div>
            <!-- ============ END VIEW: PRODUCTS ============ -->


            <!-- ============ VIEW: FLASH SALE ============ -->
            <div class="view" id="view-flashsale" style="display: none;">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Flash Sale</h1>
                        <div class="page-subtitle" id="flashSubtitle">Time-limited discounts on your listed products</div>
                    </div>
                    <button class="btn-primary" type="button" id="newFlashBtn">
                        <span class="material-symbols-outlined">add</span> Create flash sale
                    </button>
                </div>

                <div class="stat-grid" id="flashStats"></div>

                <div class="tabs" id="flashTabs">
                    <button type="button" class="tab active" data-filter="all">All <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="live">Live <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="scheduled">Scheduled <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="ended">Ended <span class="tab-count">0</span></button>
                </div>

                <div id="flashList"></div>
                <div class="empty-note" id="flashEmpty" style="display:none;">No flash sales here yet.</div>

                <%
                    String flashJson = (String) request.getAttribute("flashSalesJson");
                    if (flashJson == null || flashJson.trim().isEmpty()) flashJson = "[]";
                    flashJson = flashJson.replace("<", "\\u003c");
                %>
                <script type="application/json" id="flashData"><%= flashJson %></script>
            </div>
            <!-- ============ END VIEW: FLASH SALE ============ -->


            <!-- ============ VIEW: ORDERS ============ -->
            <div class="view" id="view-orders" style="display: none;">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Order Management</h1>
                        <div class="page-subtitle">0 total orders</div>
                    </div>
                </div>

                <div class="tabs" id="orderTabs">
                    <button type="button" class="tab active" data-filter="all">All <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="pending">Pending <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="confirmed">Confirmed <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="shipped">Shipped <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="delivered">Delivered <span class="tab-count">0</span></button>
                    <button type="button" class="tab" data-filter="return">Returns <span class="tab-count">0</span></button>
                </div>

                <div class="products-card">
                    <table class="products-table orders-list" id="ordersTable">
                        <thead>
                            <tr>
                                <th>ORDER</th>
                                <th>CUSTOMER</th>
                                <th class="center">STATUS</th>
                                <th class="num">TOTAL</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody></tbody>
                    </table>
                    <div class="empty-note" id="ordersEmpty" style="display:none;">No orders in this category.</div>
                </div>
                <%
                    String ordersJson = (String) request.getAttribute("sellerOrdersJson");
                    if (ordersJson == null || ordersJson.trim().isEmpty()) ordersJson = "[]";
                    ordersJson = ordersJson.replace("<", "\\u003c");
                %>
                <script type="application/json" id="orderData"><%= ordersJson %></script>
            </div>
            <!-- ============ END VIEW: ORDERS ============ -->


            <!-- ============ VIEW: FINANCE ============ -->
            <div class="view" id="view-finance" style="display: none;">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Sales &amp; Finance</h1>
                        <div class="page-subtitle">6-month summary · <%= fin.rangeLabel %></div>
                    </div>
                </div>

                <div class="stat-grid">
                    <div class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Gross revenue</span>
                            <span class="stat-icon ic-orange"><span class="material-symbols-outlined">trending_up</span></span>
                        </div>
                        <div class="stat-value">Rs <%= String.format("%,d", grossTotal) %></div>
                        <div class="stat-sub">Last 6 months</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Net earnings</span>
                            <span class="stat-icon ic-green"><span class="material-symbols-outlined">currency_rupee</span></span>
                        </div>
                        <div class="stat-value">Rs <%= String.format("%,d", netTotal) %></div>
                        <div class="stat-sub">After <%= (int) Math.round(commissionRate * 100) %>% commission</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Commission paid</span>
                            <span class="stat-icon ic-red"><span class="material-symbols-outlined">description</span></span>
                        </div>
                        <div class="stat-value">Rs <%= String.format("%,d", commissionTotal) %></div>
                        <div class="stat-sub">Platform fee</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Pending payout</span>
                            <span class="stat-icon ic-blue"><span class="material-symbols-outlined">schedule</span></span>
                        </div>
                        <div class="stat-value">Rs <%= String.format("%,d", pendingPayout) %></div>
                        <div class="stat-sub">Releases <%= fin.nextPayoutDate %></div>
                    </div>
                </div>

                <div class="fin-card">
                    <div class="fin-card-header">
                        <div>
                            <div class="fin-title">Monthly revenue</div>
                            <div class="fin-sub">Gross vs net (after commission)</div>
                        </div>
                        <button type="button" class="btn-outline" id="exportCsvBtn" data-csv="<%= csvData %>">
                            <span class="material-symbols-outlined">download</span> Export CSV
                        </button>
                    </div>

                    <svg viewBox="0 0 900 250" class="bar-chart-svg" role="img" aria-label="Monthly gross and net revenue">
                        <%
                            int plotBottom = 220, groupW = 138, barW = 36;
                            for (int gt = 0; gt <= 4; gt++) {
                                long v = gt * tickStep;
                                int y = plotBottom - (int) Math.round(v * yScale);
                        %>
                        <line x1="50" y1="<%= y %>" x2="878" y2="<%= y %>" class="<%= v == 0 ? "axis-line" : "grid-line" %>" />
                        <text x="40" y="<%= y + 4 %>" class="axis-text" text-anchor="end"><%= String.format("%,d", v) %></text>
                        <% } %>
                        <% for (int gi = 0; gi <= months.length; gi++) { %>
                        <line x1="<%= 50 + gi * groupW %>" y1="20" x2="<%= 50 + gi * groupW %>" y2="220" class="grid-line" />
                        <% } %>
                        <%
                            for (int bi = 0; bi < months.length; bi++) {
                                int gx = 50 + bi * groupW;
                                long grossV = grossByMonth[bi];
                                long netV = Math.round(grossV * (1 - commissionRate));
                                int grossH = (int) Math.round(grossV * yScale);
                                int netH = (int) Math.round(netV * yScale);
                                int bx = gx + (groupW - 2 * barW - 6) / 2;
                        %>
                        <rect x="<%= bx %>" y="<%= plotBottom - grossH %>" width="<%= barW %>" height="<%= grossH %>" rx="3" fill="#d97213">
                            <title><%= months[bi] %> gross: Rs <%= String.format("%,d", grossV) %></title>
                        </rect>
                        <rect x="<%= bx + barW + 6 %>" y="<%= plotBottom - netH %>" width="<%= barW %>" height="<%= netH %>" rx="3" fill="#16a34a">
                            <title><%= months[bi] %> net: Rs <%= String.format("%,d", netV) %></title>
                        </rect>
                        <text x="<%= gx + groupW / 2 %>" y="240" class="axis-text" text-anchor="middle"><%= months[bi] %></text>
                        <% } %>
                    </svg>

                    <div class="fin-legend">
                        <span><span class="dot-legend" style="background:#d97213"></span>Gross</span>
                        <span><span class="dot-legend" style="background:#16a34a"></span>Net</span>
                    </div>
                </div>

                <div class="finance-bottom">
                    <div class="fin-card">
                        <div class="fin-title">Product-wise earnings</div>
                        <div class="earn-list">
                            <% for (SellerFinance.Earn er : earnings) {
                                   long amt = er.amount;
                                   int pct = maxEarn > 0 ? (int) Math.round(amt * 100.0 / maxEarn) : 0;
                            %>
                            <div class="earn-item">
                                <div class="earn-row">
                                    <span><%= h(er.name) %></span>
                                    <span class="earn-amt">Rs <%= String.format("%,d", amt) %></span>
                                </div>
                                <div class="earn-track"><div class="earn-fill" style="width: <%= pct %>%;"></div></div>
                            </div>
                            <% } %>
                            <% if (earnings.isEmpty()) { %><div class="muted-sm">No delivered orders yet.</div><% } %>
                        </div>
                    </div>

                    <div class="fin-card">
                        <div class="fin-title">Payout history</div>

                        <div class="payout-current">
                            <div class="payout-current-top">
                                <strong><%= fin.currentPeriod %> (current)</strong>
                                <span class="pill pill-pending">Pending</span>
                            </div>
                            <div class="payout-current-bottom">
                                <span>Gross: Rs <%= String.format("%,d", curGross) %></span>
                                <span>Commission: Rs <%= String.format("%,d", curCommission) %></span>
                                <strong>Net: Rs <%= String.format("%,d", pendingPayout) %></strong>
                            </div>
                        </div>

                        <% for (SellerFinance.Payout po : payouts) { %>
                        <div class="payout-row">
                            <div>
                                <div class="payout-period"><%= po.period %></div>
                                <div class="muted-sm"><%= po.ref %></div>
                            </div>
                            <div class="payout-mid">
                                <div class="payout-amt">Rs <%= String.format("%,d", po.net) %></div>
                                <div class="muted-sm"><%= po.date %></div>
                            </div>
                            <span class="pill <%= po.paid ? "pill-active" : "pill-pending" %>"><%= po.paid ? "Paid" : "Pending" %></span>
                        </div>
                        <% } %>
                        <% if (payouts.isEmpty()) { %><div class="muted-sm" style="margin-top:12px">No payouts yet.</div><% } %>
                    </div>
                </div>
            </div>
            <!-- ============ END VIEW: FINANCE ============ -->


            <!-- ============ VIEW: MY STORE ============ -->
            <div class="view" id="view-mystore" style="display: none;">
                <div class="page-header center-v">
                    <h1 class="page-title">My Store</h1>
                    <a href="#" class="muted-link">Public view</a>
                </div>

                <div class="store-card">
                    <div class="store-banner">
                        <%
                            String bannerUrl = (String) request.getAttribute("storeBanner");
                            boolean hasBanner = (bannerUrl != null && !bannerUrl.isEmpty());
                        %>
                        <% if (hasBanner) { %>
                            <img src="<%= h(bannerUrl) %>" alt="Store Banner" class="banner-bg-img" />
                        <% } else { %>
                            <div class="banner-placeholder">No Banner</div>
                        <% } %>

                        <div class="store-identity">
                            <div class="store-logo">
                                <%
                                    String logoUrl = (String) request.getAttribute("storeLogo");
                                    boolean hasLogo = (logoUrl != null && !logoUrl.isEmpty());
                                %>
                                <% if (hasLogo) { %>
                                    <img src="<%= h(logoUrl) %>" alt="Store Logo" />
                                <% } else { %>
                                    <div style="width:100px; height:100px; background:#ccc; color:#333; display:flex; align-items:center; justify-content:center; font-weight:bold; text-align:center; border-radius:8px;">No Logo</div>
                                <% } %>
                            </div>
                            <div>
                                <div class="store-title"><%= h(storeName) %></div>
                                <div class="store-tagline"><%= h((String) request.getAttribute("storeTagline")) %></div>
                            </div>
                        </div>
                    </div>

                    <div class="store-stats-row">
                        <div class="store-stats">
                            <div class="s-stat"><strong><%= products.length %></strong><span>Products</span></div>
                            <div class="s-stat"><strong>214</strong><span>Reviews</span></div>
                            <div class="s-stat"><strong>4.8★</strong><span>Rating</span></div>
                            <div class="s-stat"><strong>1.2k</strong><span>Followers</span></div>
                        </div>
                        <button type="button" class="btn-primary" id="followBtn">Follow store</button>
                    </div>

                    <div class="tabs store-tabs" id="storeTabs">
                        <button type="button" class="tab active" data-panel="storeProducts">Products</button>
                        <button type="button" class="tab" data-panel="storeReviews">Reviews</button>
                    </div>

                    <div class="store-panel" id="storeProducts">
                        <div class="store-grid"></div>
                    </div>

                    <div class="store-panel" id="storeReviews" style="display:none;">
                        <% for (String[] rv : reviews) {
                               int rating = Integer.parseInt(rv[1]);
                        %>
                        <div class="review-item">
                            <div class="review-avatar"><%= initial(rv[0]) %></div>
                            <div>
                                <div class="review-head">
                                    <strong><%= h(rv[0]) %></strong>
                                    <span class="stars"><%= "★★★★★".substring(0, rating) %><span class="stars-off"><%= "★★★★★".substring(0, 5 - rating) %></span></span>
                                </div>
                                <div class="muted-sm"><%= h(rv[2]) %></div>
                                <p class="review-text"><%= h(rv[3]) %></p>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <!-- ============ END VIEW: MY STORE ============ -->


            <!-- ============ VIEW: MESSAGES ============ -->
            <div class="view" id="view-messages" style="display: none;">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Messages</h1>
                        <div class="page-subtitle" id="unreadSubtitle"><%= unreadMessages %> unread</div>
                    </div>
                </div>

                <div class="messages-card">
                    <div class="msg-search">
                        <span class="material-symbols-outlined">search</span>
                        <input type="text" id="messageSearch" placeholder="Search messages...">
                    </div>

                    <div id="messageList">
                    <% for (String[] m : messages) {
                           boolean unread = "1".equals(m[4]);
                    %>
                        <div class="msg-item<%= unread ? " unread" : "" %>">
                            <div class="msg-row">
                                <span class="msg-name"><%= h(m[0]) %></span>
                                <span class="msg-time"><%= h(m[3]) %></span>
                            </div>
                            <div class="msg-subject"><%= h(m[1]) %></div>
                            <div class="msg-preview"><%= h(m[2]) %></div>
                        </div>
                    <% } %>
                    </div>
                </div>
            </div>
            <!-- ============ END VIEW: MESSAGES ============ -->

        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
var SERVER_STATUS = "<%= h(rawStatus) %>"; // "pending" | "approved" | "rejected"
</script>
<script src="${pageContext.request.contextPath}/css/seller/SellerDashboard.js?v=4"></script>
</body>
</html>
