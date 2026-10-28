<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // ✅ EXISTING declarations FIRST (from your original code)
    String rawStatus = (String) request.getAttribute("status");
    if (rawStatus == null) rawStatus = "pending";
    String storeName = (String) request.getAttribute("storeName");
    if (storeName == null) storeName = "";
    String rejectionReason = (String) request.getAttribute("rejectionReason");

    boolean isApproved   = "approved".equalsIgnoreCase(rawStatus);
    boolean isRejected   = "rejected".equalsIgnoreCase(rawStatus);
    boolean isUnderReview = "pending".equalsIgnoreCase(rawStatus);

    String status = isApproved ? "Approved" : isRejected ? "Rejected" : "Under Review";
    int unreadMessages = 2;
    String activeMenu = "Dashboard";

    // ✅ HARDCODED DATA (required for dashboard)
    String[] months = {"Mar", "Apr", "May", "Jun", "Jul", "Aug"};
    int[] grossByMonth = {4200, 5800, 4900, 7300, 8100, 9640};
    double commissionRate = 0.10;
    int grossTotal = 0;
    for (int gv : grossByMonth) grossTotal += gv;
    int commissionTotal = (int) Math.round(grossTotal * commissionRate);
    int netTotal = grossTotal - commissionTotal;
    int curGross = grossByMonth[grossByMonth.length - 1];
    int curCommission = (int) Math.round(curGross * commissionRate);
    int pendingPayout = curGross - curCommission;

    StringBuilder csvBuilder = new StringBuilder("Month,Gross,Net\n");
    for (int ci = 0; ci < months.length; ci++) {
        csvBuilder.append(months[ci]).append(",").append(grossByMonth[ci]).append(",")
                  .append(Math.round(grossByMonth[ci] * (1 - commissionRate))).append("\n");
    }
    String csvData = csvBuilder.toString().replace("\n", "&#10;");

    // ✅ ORDERS (required for dashboard)
    String[][] orders = {
        {"#ORD-8821", "Aug 12, 2026", "Marta Kowalczyk", "Waxed Canvas Tote Bag", "pending", "Pending", "178"},
        {"#ORD-8819", "Aug 11, 2026", "James Okafor", "Merino Wool Scarf", "confirmed", "Confirmed", "58"},
        {"#ORD-8814", "Aug 10, 2026", "Priya Nair", "Hand-Thrown Ceramic Mug", "shipped", "Shipped", "126"},
        {"#ORD-8808", "Aug 8, 2026", "Søren Lindqvist", "Full-Grain Leather Wallet", "delivered", "Delivered", "113"},
        {"#ORD-8802", "Aug 6, 2026", "Ana Ferreira", "White Oak Serving Tray", "return", "Return Req.", "95"},
        {"#ORD-8798", "Aug 5, 2026", "Tomás García", "Merino Wool Scarf", "cancelled", "Cancelled", "116"}
    };
    int cPending = 0, cConfirmed = 0, cShipped = 0, cDelivered = 0, cReturn = 0;
    for (String[] od : orders) {
        if ("pending".equals(od[4])) cPending++;
        if ("confirmed".equals(od[4])) cConfirmed++;
        if ("shipped".equals(od[4])) cShipped++;
        if ("delivered".equals(od[4])) cDelivered++;
        if ("return".equals(od[4])) cReturn++;
    }

    // ✅ EARNINGS (required for finance view)
    String[][] earnings = {
        {"Waxed Canvas Tote Bag", "30260"},
        {"Full-Grain Leather Wallet", "23625"},
        {"Hand-Thrown Ceramic Mug", "7560"},
        {"Merino Wool Scarf", "8959"},
        {"White Oak Serving Tray", "12540"},
        {"Brass Pen Holder", "4840"}
    };
    int maxEarn = 0;
    for (String[] er : earnings) maxEarn = Math.max(maxEarn, Integer.parseInt(er[1]));

    // ✅ PAYOUTS (required for finance view)
    String[][] payouts = {
        {"Jul 1–31", "PAY-441", "7290", "Aug 5"},
        {"Jun 1–30", "PAY-398", "6570", "Jul 5"},
        {"May 1–31", "PAY-352", "4410", "Jun 5"}
    };

    // ✅ REVIEWS (required for my store view)
    String[][] reviews = {
        {"Priya Nair", "5", "Hand-Thrown Ceramic Mug", "Beautiful glaze and it feels perfect in the hand."},
        {"Søren Lindqvist", "5", "Full-Grain Leather Wallet", "Great quality leather, stitching is flawless."},
        {"James Okafor", "4", "Merino Wool Scarf", "Very soft and warm. Colour was slightly darker."},
        {"Marta Kowalczyk", "5", "Waxed Canvas Tote Bag", "Sturdy, roomy and looks even better after use."}
    };

    // ✅ MESSAGES (required for messages view)
    String[][] messages = {
        {"Priya Nair", "Question about ceramic mug sizes", "Hi, do you offer the mug in a larger 400ml version?", "2h ago", "1"},
        {"James Okafor", "Shipping to Nigeria", "Is express shipping available to Abuja?", "Yesterday", "1"},
        {"Marta Kowalczyk", "Custom monogram on tote?", "Can I request a monogram on the canvas tote?", "Aug 10", "0"}
    };

   // ✅ THEN fetch products from database
   List<com.example.aalmari.model.SellerProduct> realProducts =
       (List<com.example.aalmari.model.SellerProduct>) request.getAttribute("products");
   if (realProducts == null) realProducts = new ArrayList<>();

   // UPDATED: INCLUDES FULL DATA (14 columns now)
   String[][] products = new String[realProducts.size()][14];
   int i = 0;
   for (com.example.aalmari.model.SellerProduct p : realProducts) {
       products[i][0] = p.getName();
       products[i][1] = p.getSku();
       products[i][2] = p.getCategory();
       products[i][3] = String.valueOf(p.getPrice());
       products[i][4] = String.valueOf(p.getDiscount());
       products[i][5] = String.valueOf(p.getStock());
       products[i][6] = String.valueOf(p.getSold());
       products[i][7] = p.getActive() ? "Active" : "Inactive";
       products[i][8] = p.getSubCategory();
       products[i][9] = (p.getInfoImageUrl() != null) ? p.getInfoImageUrl() : "";
       products[i][10] = (p.getImageUrlsJson() != null) ? p.getImageUrlsJson() : "[]";
       products[i][11] = String.valueOf(p.getId());

       // NEW: Store Description and Attributes (escaped for JSON)
       String desc = (p.getDescription() != null) ? p.getDescription().replace("\"", "\\\"").replace("\n", "\\n") : "";
       String attrs = (p.getAttributesJson() != null) ? p.getAttributesJson() : "{}";
       products[i][12] = desc;
       products[i][13] = attrs;

       i++;
   }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Seller Hub - Dashboard</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/seller/SellerDashboard.css?v=14">
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
                <span class="store-name nav-text"><%= storeName %></span>
            </div>

            <div class="nav" id="sidebarNav">
                <%
                    String[][] items = {
                        {"<span class=\"material-symbols-outlined\">dashboard</span>", "Dashboard"},
                        {"<span class=\"material-symbols-outlined\">package_2</span>", "Products"},
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

            <!-- Sidebar Footer -->

        </div>

        <!-- Main Content Area -->
        <div class="main">

            <!-- ============ VIEW: DASHBOARD ============ -->
            <div class="view" id="view-dashboard">

                <!-- Initial State: Application Under Review -->
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

                <!-- Rejected State -->
                <div class="review-card" id="rejectedState" style="display:none;">
                    <div class="review-icon">✕</div>
                    <h1>Application rejected</h1>
                    <p>
                        <% if (rejectionReason != null && !rejectionReason.isEmpty()) { %>
                            Reason: <%= rejectionReason %>
                        <% } else { %>
                            Your seller application was not approved this time.
                        <% } %>
                    </p>
                    <a href="${pageContext.request.contextPath}/seller" class="btn-primary" style="text-decoration:none;">
                        Re-apply
                    </a>
                </div>

                <!-- Active State: Approved Dashboard Layout -->
                <div id="approvedDashboard" style="display: none;">
                    <%
                        // ---- Dashboard data ----
                        int[] ordersByMonth = {40, 55, 47, 70, 78, 91};
                        int inactiveCount = 0;
                        String lowName = null; int lowStock = 0;
                        for (String[] dp : products) {
                            if (!"Active".equals(dp[7])) inactiveCount++;
                            int ds = Integer.parseInt(dp[5]);
                            if (ds > 0 && ds <= 5 && lowName == null) { lowName = dp[0]; lowStock = ds; }
                        }
                        String returnCustomer = null, returnProduct = null;
                        for (String[] dr : orders) {
                            if ("return".equals(dr[4])) { returnCustomer = dr[2]; returnProduct = dr[3]; break; }
                        }

                        // ---- Smooth line + area chart geometry ----
                        int chartLeft = 50, chartStep = 180, chartBase = 220;
                        int[] rx = new int[months.length], ry = new int[months.length], oy = new int[months.length];
                        for (int ci2 = 0; ci2 < months.length; ci2++) {
                            rx[ci2] = chartLeft + ci2 * chartStep;
                            ry[ci2] = chartBase - (int) Math.round(grossByMonth[ci2] * 0.02);
                            oy[ci2] = chartBase - (int) Math.round(ordersByMonth[ci2] * 105 * 0.02);
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

                        // ---- Top products (short label, units sold) ----
                        String[] topLabels = {"Canvas Tote", "Leather Wallet", "Ceramic Mug", "Wool Scarf", "Oak Tray"};
                        int topMax = 340;
                    %>

                    <!-- Page header -->
                    <div class="page-header center-v">
                        <div>
                            <h1 class="page-title">Seller Dashboard</h1>
                            <div class="page-subtitle">August 2026 · <%= storeName %></div>
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
                                <span class="stat-label">Revenue (Aug)</span>
                                <span class="stat-icon ic-orange"><span class="material-symbols-outlined">currency_rupee</span></span>
                            </div>
                            <div class="stat-value">Rs <%= String.format("%,d", curGross) %></div>
                            <div class="stat-sub up"><span class="material-symbols-outlined">north_east</span> +19% vs last month</div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-top">
                                <span class="stat-label">Orders</span>
                                <span class="stat-icon ic-blue"><span class="material-symbols-outlined">shopping_bag</span></span>
                            </div>
                            <div class="stat-value"><%= ordersByMonth[ordersByMonth.length - 1] %></div>
                            <div class="stat-sub up"><span class="material-symbols-outlined">north_east</span> +23% vs last month</div>
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

                    <!-- Alerts -->
                    <div class="alerts-grid">
                        <% if (lowName != null) { %>
                        <div class="alert-card warning">
                            <span class="material-symbols-outlined alert-icon">warning</span>
                            <div class="alert-content">
                                <div class="alert-title">Low stock alert</div>
                                <div class="alert-body"><%= lowName %> — only <%= lowStock %> units left.</div>
                            </div>
                        </div>
                        <% } %>
                        <% if (returnCustomer != null) { %>
                        <div class="alert-card orange">
                            <span class="material-symbols-outlined alert-icon">published_with_changes</span>
                            <div class="alert-content">
                                <div class="alert-title">Return request</div>
                                <div class="alert-body"><%= returnCustomer %> — <%= returnProduct %>.</div>
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
                                    <div class="card-subtitle">Last 6 months</div>
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

                                <% for (int gv2 = 0; gv2 <= 10000; gv2 += 2500) {
                                       int gy = chartBase - (int) Math.round(gv2 * 0.02); %>
                                <line x1="50" y1="<%= gy %>" x2="950" y2="<%= gy %>" class="grid-line" />
                                <text x="40" y="<%= gy + 4 %>" class="axis-text" text-anchor="end"><%= gv2 %></text>
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
                                                                                     <% for (int ti = 0; ti < topLabels.length && ti < products.length; ti++) {
                                                                                            // ✅ FIX: Safe access with bounds check
                                                                                            String[] p = products[ti];
                                                                                            if (p == null || p.length < 7) continue;
                                                                                            int sold = Integer.parseInt(p[6]);
                                                                                            int tw = (int) Math.round(sold * 100.0 / topMax); %>
                                                                                     <div class="hbar-row">
                                                                                         <span class="hbar-label"><%= topLabels[ti] %></span>
                                                                                         <div class="hbar-track"><div class="hbar-fill" style="width: <%= tw %>%;"></div></div>
                                                                                     </div>
                                                                                     <% } %>
                                <div class="hbar-axis">
                                    <span>0</span><span>85</span><span>170</span><span>255</span><span>340</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Recent orders -->
                    <div class="recent-orders-card">
                        <div class="orders-header">
                            <h3>Recent orders</h3>
                            <a href="#" class="view-all-link">View all</a>
                        </div>
                        <div class="orders-table-wrapper">
                            <table class="orders-table">
                                <tbody>
                                <% for (int ro = 0; ro < 4; ro++) { String[] rod = orders[ro]; %>
                                    <tr>
                                        <td class="order-id"><%= rod[0] %></td>
                                        <td class="customer-name"><%= rod[2] %></td>
                                        <td class="product-name"><%= rod[3] %></td>
                                        <td class="order-status"><span class="status-badge <%= rod[4] %>"><%= rod[5] %></span></td>
                                        <td class="order-price">Rs <%= rod[6] %></td>
                                    </tr>
                                <% } %>
                                </tbody>
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
                              String sub = p.length > 8 ? p[8] : "";

                              // Build the JSON string for the Edit Form
                              // We use single quotes for the attribute and double quotes for the JSON keys
                              String jsonStr = "{\"name\":\"" + p[0].replace("\"", "\\\"") + "\"," +
                                               "\"cat\":\"" + p[2].replace("\"", "\\\"") + "\"," +
                                               "\"sub\":\"" + p[8].replace("\"", "\\\"") + "\"," +
                                               "\"price\":" + p[3] + "," +
                                               "\"disc\":" + p[4] + "," +
                                               "\"stock\":" + p[5] + "," +
                                               "\"active\":" + active + "," +
                                               "\"description\":\"" + p[12] + "\"," +
                                               "\"attrs\":" + p[13] + "," +
                                               "\"infoImage\":\"" + p[9].replace("\"", "\\\"") + "\"}";
                                // Get the JSON string of image URLs
                                  String imagesJson = p[10];
                                  // Escape single quotes for the HTML attribute
                                  String safeImagesJson = imagesJson.replace("'", "&#39;");
                          %>
                          <tr data-id="<%= p[11] %>" data-json='<%= jsonStr %>' data-images='<%= safeImagesJson %>'>
                              <td>
                                  <div class="prod-cell">
                                      <div class="prod-thumb">
                                          <% if (!p[9].isEmpty()) { %>
                                              <img src="<%= p[9] %>" alt="Product Image" style="width:100%; height:100%; object-fit:cover; border-radius:4px;" onerror="this.onerror=null; this.parentElement.innerHTML='<div style=\'width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#ccc; color:#666; font-weight:bold; border-radius:4px;\'><%= p[0].substring(0, 1) %></div>'">
                                          <% } else { %>
                                              <div style="width:100%; height:100%; display:flex; align-items:center; justify-content:center; background:#ccc; color:#666; font-weight:bold; border-radius:4px;">
                                                  <%= p[0].substring(0, 1) %>
                                              </div>
                                          <% } %>
                                      </div>
                                      <div>
                                          <div class="prod-name"><%= p[0] %></div>
                                          <div class="prod-sku"><%= p[1] %></div>
                                      </div>
                                  </div>
                              </td>
                              <td>
                                  <span class="cat-tag">
                                      <span class="material-symbols-outlined">sell</span><%= p[2] %>
                                  </span>
                                  <% if (!sub.isEmpty()) { %><div class="sub-tag"><%= sub %></div><% } %>
                              </td>
                              <td class="num price">
                                  Rs <%= p[3] %>
                                  <% if (!p[4].isEmpty() && !p[4].equals("0")) { %><span class="discount">-<%= p[4] %>%</span><% } %>
                              </td>
                              <td class="num stock <%= stock == 0 ? "out" : (stock <= 5 ? "low" : "") %>">
                                  <%= stock %><%= stock == 0 ? " <small>Out</small>" : "" %>
                              </td>
                              <td class="num sold"><%= p[6] %></td>
                              <td>
                                  <span class="pill <%= active ? "pill-active" : "pill-inactive" %>"><%= p[7] %></span>
                              </td>
                              <td class="actions">
                                  <span class="material-symbols-outlined" data-act="edit">edit</span>
                                  <span class="material-symbols-outlined" data-act="del">delete</span>
                              </td>
                          </tr>
                          <% } %>
                      </tbody>
                    </table>
                </div>
            </div>
            <!-- ============ END VIEW: PRODUCTS ============ -->


            <!-- ============ VIEW: ORDERS ============ -->
            <div class="view" id="view-orders" style="display: none;">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Order Management</h1>
                        <div class="page-subtitle"><%= orders.length %> total orders</div>
                    </div>
                </div>

                <div class="tabs" id="orderTabs">
                    <button type="button" class="tab active" data-filter="all">All <span class="tab-count"><%= orders.length %></span></button>
                    <button type="button" class="tab" data-filter="pending">Pending <span class="tab-count"><%= cPending %></span></button>
                    <button type="button" class="tab" data-filter="confirmed">Confirmed <span class="tab-count"><%= cConfirmed %></span></button>
                    <button type="button" class="tab" data-filter="shipped">Shipped <span class="tab-count"><%= cShipped %></span></button>
                    <button type="button" class="tab" data-filter="delivered">Delivered <span class="tab-count"><%= cDelivered %></span></button>
                    <button type="button" class="tab" data-filter="return">Returns <span class="tab-count"><%= cReturn %></span></button>
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
                        <tbody>
                        <% for (String[] od : orders) { %>
                            <tr data-status="<%= od[4] %>">
                                <td>
                                    <div class="order-ref"><%= od[0] %></div>
                                    <div class="muted-sm"><%= od[1] %></div>
                                </td>
                                <td>
                                    <div class="cust-name"><%= od[2] %></div>
                                    <div class="muted-sm"><%= od[3] %></div>
                                </td>
                                <td class="center"><span class="o-badge <%= od[4] %>"><%= od[5] %></span></td>
                                <td class="num price">Rs <%= od[6] %></td>
                                <td class="chev"><span class="material-symbols-outlined">chevron_right</span></td>
                            </tr>
                        <% } %>
                        </tbody>
                    </table>
                    <div class="empty-note" id="ordersEmpty" style="display:none;">No orders in this category.</div>
                </div>
            </div>
            <!-- ============ END VIEW: ORDERS ============ -->


            <!-- ============ VIEW: FINANCE ============ -->
            <div class="view" id="view-finance" style="display: none;">
                <div class="page-header">
                    <div>
                        <h1 class="page-title">Sales &amp; Finance</h1>
                        <div class="page-subtitle">6-month summary · March – August 2026</div>
                    </div>
                </div>

                <div class="stat-grid">
                    <div class="stat-card">
                        <div class="stat-top">
                            <span class="stat-label">Gross revenue</span>
                            <span class="stat-icon ic-orange"><span class="material-symbols-outlined">trending_up</span></span>
                        </div>
                        <div class="stat-value">Rs <%= String.format("%,d", grossTotal) %></div>
                        <div class="stat-sub">All time earnings</div>
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
                        <div class="stat-sub">Releases Aug 5</div>
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
                            for (int v = 0; v <= 10000; v += 2500) {
                                int y = plotBottom - (int) Math.round(v * 0.02);
                        %>
                        <line x1="50" y1="<%= y %>" x2="878" y2="<%= y %>" class="<%= v == 0 ? "axis-line" : "grid-line" %>" />
                        <text x="40" y="<%= y + 4 %>" class="axis-text" text-anchor="end"><%= v %></text>
                        <% } %>
                        <% for (int gi = 0; gi <= months.length; gi++) { %>
                        <line x1="<%= 50 + gi * groupW %>" y1="20" x2="<%= 50 + gi * groupW %>" y2="220" class="grid-line" />
                        <% } %>
                        <%
                            for (int bi = 0; bi < months.length; bi++) {
                                int gx = 50 + bi * groupW;
                                int grossV = grossByMonth[bi];
                                int netV = (int) Math.round(grossV * (1 - commissionRate));
                                int grossH = (int) Math.round(grossV * 0.02);
                                int netH = (int) Math.round(netV * 0.02);
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
                            <% for (String[] er : earnings) {
                                   int amt = Integer.parseInt(er[1]);
                                   int pct = (int) Math.round(amt * 100.0 / maxEarn);
                            %>
                            <div class="earn-item">
                                <div class="earn-row">
                                    <span><%= er[0] %></span>
                                    <span class="earn-amt">Rs <%= String.format("%,d", amt) %></span>
                                </div>
                                <div class="earn-track"><div class="earn-fill" style="width: <%= pct %>%;"></div></div>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <div class="fin-card">
                        <div class="fin-title">Payout history</div>

                        <div class="payout-current">
                            <div class="payout-current-top">
                                <strong>Aug 1–31 (current)</strong>
                                <span class="pill pill-pending">Pending</span>
                            </div>
                            <div class="payout-current-bottom">
                                <span>Gross: Rs <%= String.format("%,d", curGross) %></span>
                                <span>Commission: Rs <%= String.format("%,d", curCommission) %></span>
                                <strong>Net: Rs <%= String.format("%,d", pendingPayout) %></strong>
                            </div>
                        </div>

                        <% for (String[] po : payouts) { %>
                        <div class="payout-row">
                            <div>
                                <div class="payout-period"><%= po[0] %></div>
                                <div class="muted-sm"><%= po[1] %></div>
                            </div>
                            <div class="payout-mid">
                                <div class="payout-amt">Rs <%= String.format("%,d", Integer.parseInt(po[2])) %></div>
                                <div class="muted-sm"><%= po[3] %></div>
                            </div>
                            <span class="pill pill-active">Paid</span>
                        </div>
                        <% } %>
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
                         <!-- Added a class 'banner-bg-img' to target it precisely -->
                         <img src="<%= bannerUrl %>" alt="Store Banner" class="banner-bg-img" />
                     <% } else { %>
                         <div class="banner-placeholder">
                             No Banner
                         </div>
                     <% } %>

                       <div class="store-identity">
                           <div class="store-logo">
                               <%
                                   String logoUrl = (String) request.getAttribute("storeLogo");
                                   boolean hasLogo = (logoUrl != null && !logoUrl.isEmpty());
                               %>

                               <% if (hasLogo) { %>
                                   <img src="<%= logoUrl %>" alt="Store Logo" />
                               <% } else { %>
                                   <div style="width:100px; height:100px; background:#ccc; color:#333; display:flex; align-items:center; justify-content:center; font-weight:bold; text-align:center; border-radius:8px;">
                                       No Logo
                                   </div>
                               <% } %>
                           </div>
                           <div>
                               <div class="store-title"><%= storeName %></div>
                               <div class="store-tagline">${storeTagline}</div>
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
                        <div class="store-grid">
                            <% for (String[] p : products) {
                                   int listPrice = Integer.parseInt(p[3]);
                                   int disc = p[4].isEmpty() ? 0 : Integer.parseInt(p[4]);
                                   int salePrice = disc > 0 ? (int) Math.round(listPrice * (100 - disc) / 100.0) : listPrice;
                                   int stk = Integer.parseInt(p[5]);
                                   int soldN = Integer.parseInt(p[6]);
                                   String soldTxt = soldN >= 1000 ? String.format("%.1fk", soldN / 1000.0) : String.valueOf(soldN);
                            %>
                            <div class="pcard">
                                <div class="pcard-img">
                                    <%= p[0].substring(0, 1) %>
                                    <% if (disc > 0) { %><span class="pcard-badge">-<%= disc %>%</span><% } %>
                                    <button type="button" class="pcard-heart" aria-label="Wishlist"><span class="material-symbols-outlined">favorite</span></button>
                                </div>
                                <div class="pcard-top"><span class="pcard-cat"><%= p[2] %></span><span class="pcard-sold"><%= soldTxt %> sold</span></div>
                                <h4 class="pcard-name"><%= p[0] %></h4>
                                <div class="pcard-bottom">
                                    <div>
                                        <span class="pcard-price">Rs <%= salePrice %></span>
                                        <% if (disc > 0) { %><span class="pcard-old">Rs <%= listPrice %></span><% } %>
                                        <span class="pcard-stock <%= stk == 0 ? "out" : (stk <= 5 ? "low" : "") %>"><%= stk == 0 ? "Out of stock" : (stk <= 5 ? "Only " + stk + " left" : stk + " in stock") %></span>
                                    </div>
                                    <button type="button" class="pcard-btn" data-go="products">Edit</button>
                                </div>
                            </div>
                            <% } %>
                        </div>
                    </div>

                    <div class="store-panel" id="storeReviews" style="display:none;">
                        <% for (String[] rv : reviews) {
                               int rating = Integer.parseInt(rv[1]);
                        %>
                        <div class="review-item">
                            <div class="review-avatar"><%= rv[0].substring(0, 1) %></div>
                            <div>
                                <div class="review-head">
                                    <strong><%= rv[0] %></strong>
                                    <span class="stars"><%= "★★★★★".substring(0, rating) %><span class="stars-off"><%= "★★★★★".substring(0, 5 - rating) %></span></span>
                                </div>
                                <div class="muted-sm"><%= rv[2] %></div>
                                <p class="review-text"><%= rv[3] %></p>
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
                        <div class="msg-item<%= unread ? " unread" : "" %>"
                             data-search="<%= (m[0] + " " + m[1] + " " + m[2]).toLowerCase() %>">
                            <div class="msg-row">
                                <span class="msg-name"><%= m[0] %></span>
                                <span class="msg-time"><%= m[3] %></span>
                            </div>
                            <div class="msg-subject"><%= m[1] %></div>
                            <div class="msg-preview"><%= m[2] %></div>
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
var SERVER_STATUS = "<%= rawStatus %>"; // "pending" | "approved" | "rejected"
</script>    <script>
         (function () {
         'use strict';
         const $ = (s, r) => (r || document).querySelector(s);
         const $$ = (s, r) => [...(r || document).querySelectorAll(s)];
         const el = (t, c, h) => { const e = document.createElement(t); if (c) e.className = c; if (h) e.innerHTML = h; return e; };
         const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
         const num = s => parseInt(String(s || '').replace(/\D/g, ''), 10) || 0;
         const fmt = n => Number(n).toLocaleString('en-US');
         const store = {
             get: k => { try { return localStorage.getItem(k); } catch (e) { return null; } },
             set: (k, v) => { try { localStorage.setItem(k, v); } catch (e) {} }
         };
         const LABEL = { pending: 'Pending', confirmed: 'Confirmed', shipped: 'Shipped', delivered: 'Delivered', return: 'Return Req.', cancelled: 'Cancelled' };
         const NEXT = { pending: 'confirmed', confirmed: 'shipped', shipped: 'delivered' };
         const NEXT_BTN = { pending: 'Confirm order', confirmed: 'Mark as shipped', shipped: 'Mark as delivered' };

         /* ============ Category → Sub-category → Attribute fields ============ */
         const A_BRAND = 'Brand', A_COLOR = 'Color', A_MATERIAL = 'Material', A_EXPIRY = 'Expiry date@date';
         const A_RAM = 'RAM:2 GB|4 GB|6 GB|8 GB|12 GB|16 GB|32 GB|64 GB';
         const A_STORAGE = 'Storage capacity:32 GB|64 GB|128 GB|256 GB|512 GB|1 TB|2 TB';
         const A_CSIZE = 'Size:XS|S|M|L|XL|XXL|XXXL';
         const A_GENDER = 'Gender:Men|Women|Unisex|Kids';
         const A_WEIGHT = 'Weight / quantity';
         const A_VOLUME = 'Volume / quantity';
         const CATALOG = {
             'Electronics': {
                 'Mobiles':      [A_BRAND, A_RAM, A_STORAGE, A_COLOR, 'Screen size'],
                 'Laptops':      [A_BRAND, 'Processor', A_RAM, A_STORAGE, A_COLOR],
                 'Tablets':      [A_BRAND, A_RAM, A_STORAGE, A_COLOR, 'Screen size'],
                 'Headphones':   [A_BRAND, 'Type:Over-ear|On-ear|In-ear|Earbuds', 'Connectivity:Wired|Bluetooth|Both', A_COLOR],
                 'Cameras':      [A_BRAND, 'Type:DSLR|Mirrorless|Point & shoot|Action|Instant', 'Megapixels', A_COLOR],
                 'Smart Watches':[A_BRAND, 'Strap material', 'Display size', A_COLOR],
                 'Accessories':  [A_BRAND, 'Compatible with', A_COLOR]
             },
             'Fashion': {
                 'Men':      [A_CSIZE, A_COLOR, A_MATERIAL, 'Fit:Slim|Regular|Loose'],
                 'Women':    [A_CSIZE, A_COLOR, A_MATERIAL, 'Fit:Slim|Regular|Loose'],
                 'Kids':     ['Age group:0-2 yrs|3-5 yrs|6-8 yrs|9-12 yrs|13-16 yrs', A_CSIZE, A_COLOR, A_MATERIAL],
                 'Shoes':    ['Size (EU):35|36|37|38|39|40|41|42|43|44|45|46', A_GENDER, A_COLOR, A_MATERIAL],
                 'Bags':     ['Type:Backpack|Handbag|Tote|Wallet|Travel bag|Laptop bag', A_COLOR, A_MATERIAL, 'Capacity'],
                 'Watches':  [A_BRAND, A_GENDER, 'Strap material', A_COLOR],
                 'Clothing': [A_CSIZE, A_GENDER, A_COLOR, A_MATERIAL]
             },
             'Beauty & Personal Care': {
                 'Skincare':      [A_BRAND, 'Skin type:All|Oily|Dry|Combination|Sensitive', A_VOLUME, A_EXPIRY],
                 'Makeup':        [A_BRAND, 'Shade', 'Finish:Matte|Glossy|Satin|Natural', A_EXPIRY],
                 'Hair Care':     [A_BRAND, 'Hair type:All|Dry|Oily|Curly|Colored', A_VOLUME, A_EXPIRY],
                 'Fragrances':    [A_BRAND, A_GENDER, 'Fragrance type:Eau de Parfum|Eau de Toilette|Cologne|Body mist', A_VOLUME],
                 'Personal Care': [A_BRAND, A_VOLUME, A_EXPIRY]
             },
             'Home & Living': {
                 'Furniture':  [A_MATERIAL, A_COLOR, 'Dimensions (L×W×H)', 'Assembly required:Yes|No'],
                 'Kitchen':    [A_BRAND, A_MATERIAL, 'Capacity', A_COLOR],
                 'Home Decor': [A_MATERIAL, A_COLOR, 'Dimensions (L×W×H)'],
                 'Bedding':    ['Bed size:Single|Double|Queen|King', A_MATERIAL, A_COLOR, 'Thread count'],
                 'Lighting':   ['Type:Ceiling|Table lamp|Floor lamp|Wall|String lights', 'Wattage', A_COLOR],
                 'Storage':    [A_MATERIAL, A_COLOR, 'Capacity', 'Dimensions (L×W×H)']
             },
             'Groceries': {
                 'Fruits & Vegetables':  [A_WEIGHT, 'Origin', 'Organic:Yes|No', A_EXPIRY],
                 'Snacks':               [A_BRAND, A_WEIGHT, 'Flavor', A_EXPIRY],
                 'Beverages':            [A_BRAND, A_VOLUME, 'Flavor', A_EXPIRY],
                 'Dairy':                [A_BRAND, A_WEIGHT, A_EXPIRY, 'Storage:Refrigerated|Room temperature'],
                 'Rice & Grains':        [A_BRAND, A_WEIGHT, 'Type', A_EXPIRY],
                 'Household Essentials': [A_BRAND, A_WEIGHT, A_EXPIRY]
             },
             'Sports & Fitness': {
                 'Sports Equipment':     [A_BRAND, 'Sport', A_MATERIAL, 'Size'],
                 'Gym Equipment':        [A_BRAND, 'Weight', 'Max user weight', A_MATERIAL],
                 'Fitness Accessories':  [A_BRAND, A_MATERIAL, A_COLOR],
                 'Outdoor Gear':         [A_BRAND, 'Capacity', A_MATERIAL, A_COLOR],
                 'Sportswear':           [A_CSIZE, A_GENDER, A_COLOR, A_MATERIAL]
             },
             'Books & Stationery': {
                 'Books':            ['Author', 'Publisher', 'Language', 'Format:Paperback|Hardcover|eBook'],
                 'Notebooks':        [A_BRAND, 'Pages', 'Size:A4|A5|A6|B5', 'Ruling:Ruled|Plain|Grid|Dotted'],
                 'Pens & Pencils':   [A_BRAND, 'Type:Ballpoint|Gel|Fountain|Pencil|Marker', 'Ink color', 'Pack size'],
                 'School Supplies':  [A_BRAND, 'Type', A_COLOR, 'Pack size'],
                 'Office Supplies':  [A_BRAND, A_MATERIAL, A_COLOR, 'Pack size']
             },
             'Automotive': {
                 'Car Accessories':  [A_BRAND, 'Compatible with', A_COLOR, A_MATERIAL],
                 'Bike Accessories': [A_BRAND, 'Compatible with', A_COLOR, A_MATERIAL],
                 'Car Care':         [A_BRAND, 'Type', A_VOLUME],
                 'Spare Parts':      [A_BRAND, 'Part number', 'Compatible vehicle', 'Condition:New|Refurbished'],
                 'Helmets':          [A_BRAND, 'Size:S|M|L|XL', 'Type:Full face|Half face|Modular|Open face', A_COLOR]
             },
             'Toys & Games': {
                 'Toys':                 [A_BRAND, 'Age group:0-2 yrs|3-5 yrs|6-8 yrs|9-12 yrs|13+ yrs', A_MATERIAL, A_COLOR],
                 'Board Games':          [A_BRAND, 'Players', 'Age group:6+|8+|12+|16+', 'Play time'],
                 'Video Games':          ['Platform:PC|PlayStation|Xbox|Nintendo Switch|Mobile', 'Genre', 'Rating', 'Edition'],
                 'Educational Toys':     [A_BRAND, 'Age group:0-2 yrs|3-5 yrs|6-8 yrs|9-12 yrs|13+ yrs', 'Skill focus', A_MATERIAL],
                 'Remote-Control Toys':  [A_BRAND, 'Battery type', 'Range', A_COLOR]
             },
             'Health & Wellness': {
                 'Vitamins & Supplements': [A_BRAND, 'Form:Tablet|Capsule|Powder|Liquid|Gummy', 'Quantity', A_EXPIRY],
                 'Fitness':                [A_BRAND, 'Type', A_MATERIAL, A_COLOR],
                 'Healthcare Products':    [A_BRAND, 'Type', 'Quantity', A_EXPIRY],
                 'Personal Wellness':      [A_BRAND, 'Type', A_VOLUME, A_EXPIRY]
             }
         };
         const CAT_NAMES = Object.keys(CATALOG);
         function parseAttr(s) {
             let m;
             if ((m = s.match(/^(.+?)@(\w+)$/))) return { label: m[1], type: m[2] };
             if ((m = s.match(/^(.+?):(.+)$/))) return { label: m[1], type: 'select', opts: m[2].split('|') };
             return { label: s, type: 'text' };
         }

         document.addEventListener('DOMContentLoaded', function () {
             const sidebar = $('#sidebar'), main = $('.main');
             const mq = window.matchMedia('(max-width: 900px)');

             /* ============ Shell: drawer, scrim, toasts ============ */
             const scrim = el('div', 'scrim'); document.body.appendChild(scrim);
             const toasts = el('div', 'toasts'); document.body.appendChild(toasts);
             const burger = el('button', 'menu-toggle', '<span class="material-symbols-outlined">menu</span> Menu');
             burger.type = 'button'; burger.setAttribute('aria-label', 'Open menu'); main.prepend(burger);

             function drawer(open) {
                 sidebar.classList.toggle('open', open);
                 scrim.classList.toggle('show', open && mq.matches);
                 document.body.classList.toggle('no-scroll', open && mq.matches);
             }
             burger.onclick = () => drawer(!sidebar.classList.contains('open'));
             scrim.onclick = () => drawer(false);
             $('#collapseBtn').onclick = function (e) {
                 e.stopPropagation();
                 if (mq.matches) return drawer(false);
                 sidebar.classList.toggle('collapsed');
                 store.set('sellerSidebar', sidebar.classList.contains('collapsed') ? '1' : '0');
             };
             $('.sidebar-header .icon-box').onclick = () => sidebar.classList.remove('collapsed');
             function applyLayout() {
                 if (mq.matches) { sidebar.classList.remove('collapsed'); drawer(false); }
                 else { drawer(false); sidebar.classList.toggle('collapsed', store.get('sellerSidebar') === '1'); }
             }
             mq.addEventListener('change', applyLayout); applyLayout();

             function toast(msg, type, go) {
                 const t = el('div', 'toast ' + (type || ''), esc(msg));
                 if (go) { t.classList.add('clickable'); t.onclick = () => show(go, true); }
                 toasts.appendChild(t);
                 requestAnimationFrame(() => t.classList.add('show'));
                 setTimeout(() => { t.classList.remove('show'); setTimeout(() => t.remove(), 300); }, 3800);
             }

             /* ============ Modal + popover helpers ============ */
             function closeModal() { const m = $('.modal-backdrop'); if (m) m.remove(); document.body.classList.remove('no-scroll'); }
             function modal(title, body, buttons) {
                 closeModal();
                 const b = el('div', 'modal-backdrop',
                     '<div class="modal" role="dialog" aria-modal="true"><div class="modal-head"><h3>' + esc(title) +
                     '</h3><button type="button" class="modal-x" aria-label="Close">&times;</button></div>' +
                     '<div class="modal-body">' + body + '</div><div class="modal-foot"></div></div>');
                 (buttons || []).forEach(function (d) {
                     const bt = el('button', d[1], esc(d[0])); bt.type = 'button'; bt.onclick = d[2];
                     $('.modal-foot', b).appendChild(bt);
                 });
                 b.addEventListener('mousedown', e => { if (e.target === b) closeModal(); });
                 $('.modal-x', b).onclick = closeModal;
                 document.body.appendChild(b); document.body.classList.add('no-scroll');
                 const f = $('input, textarea, select', b); if (f) f.focus();
                 return b;
             }
             function confirmBox(title, text, label, fn) {
                 modal(title, '<p class="modal-text">' + text + '</p>', [['Cancel', 'btn-outline', closeModal],
                     [label, 'btn-primary danger', function () { closeModal(); fn(); }]]);
             }

             let pop = null;
             function closePop() { if (pop) { pop.remove(); pop = null; } }
             function popover(anchor, html, alignRight) {
                 if (pop && pop._a === anchor) return closePop();
                 closePop();
                 pop = el('div', 'popover', html); pop._a = anchor; document.body.appendChild(pop);
                 const r = anchor.getBoundingClientRect(), w = pop.offsetWidth;
                 let left = (alignRight ? r.right - w : r.left) + window.scrollX;
                 pop.style.left = Math.max(8, Math.min(left, window.innerWidth - w - 8)) + 'px';
                 pop.style.top = (r.bottom + window.scrollY + 6) + 'px';
                 return pop;
             }
             document.addEventListener('click', function (e) {
                 if (pop && !pop.contains(e.target) && !pop._a.contains(e.target)) closePop();
                 const g = e.target.closest('[data-go]');
                 if (g) { closePop(); show(g.dataset.go, true); }
                 const h = e.target.closest('.pcard-heart');
                 if (h) h.classList.toggle('on');
             });
             document.addEventListener('keydown', function (e) {
                 if (e.key === 'Escape') { closeModal(); closePop(); drawer(false); }
             });

             /* ============ State (read once from the server-rendered DOM) ============ */
            const P = $$('#productsTable tbody tr').map(function (r) {
                const t = r.children, subEl = $('.sub-tag', r);
                // Parse the JSON data from the hidden attribute
                let jsonData = {};
                if (r.dataset.json) {
                    try { jsonData = JSON.parse(r.dataset.json); } catch (e) { jsonData = {}; }
                }
                    // NEW: Parse the product images
                    let imagesList = [];
                    if (r.dataset.images) {
                        try { imagesList = JSON.parse(r.dataset.images); } catch (e) { imagesList = []; }
                    }

                return {
                    id: r.dataset.id || null,
                    // Keep existing fields for display
                    name: $('.prod-name', r).textContent.trim(),
                    sku: $('.prod-sku', r).textContent.trim(),
                    cat: $('.cat-tag', r).lastChild.textContent.trim(),
                    sub: subEl ? subEl.textContent.trim() : '',
                    price: num(t[2].childNodes[0].textContent),
                    disc: num($('.discount', r) && $('.discount', r).textContent),
                    stock: num(t[3].childNodes[0].textContent),
                    sold: num(t[4].textContent),
                    active: $('.pill', r).textContent.trim() === 'Active',
                    imageUrl: $('.prod-thumb img', r) ? $('.prod-thumb img', r).src : '',
                    // ADD THIS: Store the full data for editing
                    editData: jsonData,
                    images: imagesList
                };
            });
             const O = $$('#ordersTable tbody tr').map(function (r) {
                 return {
                     ref: $('.order-ref', r).textContent.trim(), date: $('.order-ref', r).nextElementSibling.textContent.trim(),
                     cust: $('.cust-name', r).textContent.trim(), product: $('.cust-name', r).nextElementSibling.textContent.trim(),
                     status: r.dataset.status, total: num($('.price', r).textContent)
                 };
             });
             const M = $$('#messageList .msg-item').map(function (i) {
                 return {
                     name: $('.msg-name', i).textContent.trim(), subject: $('.msg-subject', i).textContent.trim(),
                     time: $('.msg-time', i).textContent.trim(), unread: i.classList.contains('unread'),
                     thread: [{ me: false, text: $('.msg-preview', i).textContent.trim() }]
                 };
             });
             const dashCards = $$('#approvedDashboard .stat-card');
             let revenue = num($('.stat-value', dashCards[0]).textContent);
             let orderCount = num($('.stat-value', dashCards[1]).textContent);
             const ui = { pq: '', pf: 'all', sort: null, dir: 1, oq: '', of: 'all', mq: '' };
             const FILTERS = { all: 'All products', active: 'Active', inactive: 'Inactive', low: 'Low stock (≤5)', out: 'Out of stock' };

             /* ============ Alerts (also feed the bell) ============ */
             function alertList() {
                 const a = [], low = P.find(p => p.active && p.stock > 0 && p.stock <= 5);
                 const out = P.find(p => p.active && p.stock === 0), ret = O.find(o => o.status === 'return');
                 const unread = M.filter(m => m.unread).length;
                 if (low) a.push({ cls: 'warning', icon: 'warning', title: 'Low stock alert', body: low.name + ' — only ' + low.stock + ' unit' + (low.stock > 1 ? 's' : '') + ' left.', go: 'products' });
                 if (out) a.push({ cls: 'warning', icon: 'production_quantity_limits', title: 'Out of stock', body: out.name + ' is sold out but still active.', go: 'products' });
                 if (ret) a.push({ cls: 'orange', icon: 'published_with_changes', title: 'Return request', body: ret.cust + ' — ' + ret.product + '.', go: 'orders' });
                 if (unread) a.push({ cls: 'info', icon: 'inbox', title: unread + ' unread message' + (unread > 1 ? 's' : ''), body: 'Customer inquiries awaiting reply.', go: 'messages' });
                 return a;
             }

             /* ============ Renderers ============ */
             function renderProducts() {
                 const q = ui.pq.toLowerCase();
                 let list = P.filter(function (p) {
                     const f = ui.pf;
                     const okF = f === 'all' || (f === 'active' && p.active) || (f === 'inactive' && !p.active) ||
                         (f === 'low' && p.stock > 0 && p.stock <= 5) || (f === 'out' && p.stock === 0);
                     const hay = (p.name + ' ' + p.sku + ' ' + p.cat + ' ' + (p.sub || '') + ' ' + Object.values(p.attrs || {}).join(' ')).toLowerCase();
                     return okF && (!q || hay.includes(q));
                 });
                 if (ui.sort) list.sort(function (a, b) {
                     const x = a[ui.sort], y = b[ui.sort];
                     return (typeof x === 'string' ? x.localeCompare(y) : x - y) * ui.dir;
                 });
                 $('#productsTable tbody').innerHTML = list.map(function (p) {
                     const attrTxt = Object.keys(p.attrs || {}).map(k => p.attrs[k]).join(' · ');
                     // CRITICAL: Ensure data-id is preserved in re-rendered rows
                     return '<tr data-sku="' + esc(p.sku) + '" data-id="' + esc(p.id) + '"><td><div class="prod-cell"><div class="prod-thumb">' +
                     (p.imageUrl ? '<img src="' + esc(p.imageUrl) + '" style="width:100%; height:100%; object-fit:cover; border-radius:4px;">' : esc(p.name.charAt(0))) +
                     '</div><div><div class="prod-name">' + esc(p.name) + '</div><div class="prod-sku">' + esc(p.sku) + '</div>' +
                     (attrTxt ? '<div class="prod-attrs">' + esc(attrTxt) + '</div>' : '') + '</div></div></td>' +
                     '<td><span class="cat-tag"><span class="material-symbols-outlined">sell</span>' + esc(p.cat) + '</span>' +
                     (p.sub ? '<div class="sub-tag">' + esc(p.sub) + '</div>' : '') + '</td>' +
                     '<td class="num price">Rs ' + fmt(p.price) + (p.disc ? '<span class="discount">-' + p.disc + '%</span>' : '') + '</td>' +
                     '<td class="num stock ' + (p.stock === 0 ? 'out' : p.stock <= 5 ? 'low' : '') + '">' + p.stock + (p.stock === 0 ? ' <small>Out</small>' : '') + '</td>' +
                     '<td class="num sold">' + p.sold + '</td>' +
                     '<td><button type="button" class="pill ' + (p.active ? 'pill-active' : 'pill-inactive') + '" data-act="toggle" title="Click to change status">' + (p.active ? 'Active' : 'Inactive') + '</button></td>' +
                     '<td class="actions"><span class="material-symbols-outlined" data-act="edit" title="Edit">edit</span><span class="material-symbols-outlined" data-act="del" title="Delete">delete</span></td></tr>';
                 }).join('') || '<tr><td colspan="7" class="empty-note">No products match your search or filter.</td></tr>';
                 $('#view-products .page-subtitle').textContent = P.length + ' listing' + (P.length === 1 ? '' : 's') +
                     (list.length !== P.length ? ' · ' + list.length + ' shown' : '');
                 $$('#productsTable thead th').forEach(function (th, i) {
                     const k = ['name', 'cat', 'price', 'stock', 'sold'][i]; if (!k) return;
                     th.dataset.key = k; th.classList.add('sortable');
                     th.classList.toggle('asc', ui.sort === k && ui.dir === 1);
                     th.classList.toggle('desc', ui.sort === k && ui.dir === -1);
                 });
                 const fb = $('#view-products .btn-filter');
                 fb.innerHTML = '<span class="material-symbols-outlined">filter_alt</span> ' + (ui.pf === 'all' ? 'Filter' : FILTERS[ui.pf]);
                 fb.classList.toggle('on', ui.pf !== 'all');
             }

             function renderOrders() {
                 const q = ui.oq.toLowerCase();
                 const list = O.filter(o => (ui.of === 'all' || o.status === ui.of) &&
                     (!q || (o.ref + ' ' + o.cust + ' ' + o.product).toLowerCase().includes(q)));
                 $('#ordersTable tbody').innerHTML = list.map(o =>
                     '<tr data-ref="' + esc(o.ref) + '" data-status="' + o.status + '"><td><div class="order-ref">' + esc(o.ref) + '</div><div class="muted-sm">' + esc(o.date) +
                     '</div></td><td><div class="cust-name">' + esc(o.cust) + '</div><div class="muted-sm">' + esc(o.product) + '</div></td>' +
                     '<td class="center"><span class="o-badge ' + o.status + '">' + LABEL[o.status] + '</span></td><td class="num price">Rs ' + fmt(o.total) +
                     '</td><td class="chev"><span class="material-symbols-outlined">chevron_right</span></td></tr>').join('');
                 $('#ordersEmpty').style.display = list.length ? 'none' : 'block';
                 $$('#orderTabs .tab').forEach(function (t) {
                     const f = t.dataset.filter;
                     $('.tab-count', t).textContent = f === 'all' ? O.length : O.filter(o => o.status === f).length;
                 });
                 $('#view-orders .page-subtitle').textContent = O.length + ' total orders';
             }

             function renderStore() {
                 const act = P.filter(p => p.active);
                 $('.store-grid').innerHTML = act.map(function (p) {
                     const sale = p.disc ? Math.round(p.price * (100 - p.disc) / 100) : p.price;
                     const sold = p.sold >= 1000 ? (p.sold / 1000).toFixed(1) + 'k' : p.sold;
                     const stock = p.stock === 0 ? ['out', 'Out of stock'] : p.stock <= 5 ? ['low', 'Only ' + p.stock + ' left'] : ['', p.stock + ' in stock'];
                     return '<div class="pcard"><div class="pcard-img">' +
                     (p.imageUrl ? '<img src="' + esc(p.imageUrl) + '" style="width:100%; height:100%; object-fit:cover;">' : esc(p.name.charAt(0))) +
                     (p.disc ? '<span class="pcard-badge">-' + p.disc + '%</span>' : '') +
                     '<button type="button" class="pcard-heart" aria-label="Wishlist"><span class="material-symbols-outlined">favorite</span></button></div>' +
                     '<div class="pcard-top"><span class="pcard-cat">' + esc(p.sub || p.cat) + '</span><span class="pcard-sold">' + sold + ' sold</span></div>' +
                     '<h4 class="pcard-name">' + esc(p.name) + '</h4>' +
                     '<div class="pcard-bottom"><div><span class="pcard-price">Rs ' + fmt(sale) + '</span>' +
                     (p.disc ? '<span class="pcard-old">Rs ' + fmt(p.price) + '</span>' : '') +
                     '<span class="pcard-stock ' + stock[0] + '">' + stock[1] + '</span></div>' +
                     '<button type="button" class="pcard-btn" data-go="products">Edit</button></div></div>';
                 }).join('');
                 $('#view-mystore .s-stat strong').textContent = act.length;
             }

             function renderMessages() {
                 const q = ui.mq.toLowerCase();
                 const html = M.map((m, i) => ({ m: m, i: i })).filter(x => !q || (x.m.name + ' ' + x.m.subject + ' ' + x.m.thread.map(t => t.text).join(' ')).toLowerCase().includes(q))
                     .map(x => '<div class="msg-item' + (x.m.unread ? ' unread' : '') + '" data-i="' + x.i + '"><div class="msg-row"><span class="msg-name">' + esc(x.m.name) +
                         '</span><span class="msg-time">' + esc(x.m.time) + '</span></div><div class="msg-subject">' + esc(x.m.subject) + '</div><div class="msg-preview">' +
                         esc((x.m.thread[x.m.thread.length - 1].me ? 'You: ' : '') + x.m.thread[x.m.thread.length - 1].text) + '</div></div>').join('');
                 $('#messageList').innerHTML = html || '<div class="empty-note">No messages found.</div>';
             }

             function syncDash() {
                 $('.stat-value', dashCards[0]).textContent = 'Rs ' + fmt(revenue);
                 $('.stat-value', dashCards[1]).textContent = orderCount;
                 $('.stat-value', dashCards[2]).textContent = P.length;
                 $('.stat-sub', dashCards[2]).textContent = P.filter(p => !p.active).length + ' inactive';

                 const al = alertList();
                 $('#approvedDashboard .alerts-grid').innerHTML = al.map(a =>
                     '<div class="alert-card ' + a.cls + ' clickable" data-go="' + a.go + '"><span class="material-symbols-outlined alert-icon">' + a.icon +
                     '</span><div class="alert-content"><div class="alert-title">' + esc(a.title) + '</div><div class="alert-body">' + esc(a.body) + '</div></div></div>').join('');
                 const bell = $('.icon-btn[aria-label="Notifications"]');
                 if (bell) { if (al.length) bell.dataset.count = al.length; else delete bell.dataset.count; }

                 $('.orders-table tbody').innerHTML = O.slice(0, 4).map(o =>
                     '<tr><td class="order-id">' + esc(o.ref) + '</td><td class="customer-name">' + esc(o.cust) + '</td><td class="product-name">' + esc(o.product) +
                     '</td><td class="order-status"><span class="status-badge ' + o.status + '">' + LABEL[o.status] + '</span></td><td class="order-price">Rs ' + fmt(o.total) + '</td></tr>').join('');

                 const n = M.filter(m => m.unread).length;
                 $('#unreadSubtitle').textContent = n + ' unread';
                 let badge = $('#sidebarNav .nav-item[data-view="messages"] .badge');
                 if (!badge && n) { badge = el('span', 'badge'); $('#sidebarNav .nav-item[data-view="messages"]').appendChild(badge); }
                 if (badge) { badge.textContent = n; badge.style.display = n ? '' : 'none'; }
             }
             function refresh() { renderProducts(); renderOrders(); renderStore(); renderMessages(); syncDash(); }

             /* ============ Routing (hash + back button) ============ */
             const VIEWS = ['dashboard', 'products', 'orders', 'finance', 'mystore', 'messages'];
             let approved = false;
             function show(v, push) {
                 if (VIEWS.indexOf(v) < 0 || !approved) v = 'dashboard';
                 VIEWS.forEach(k => { $('#view-' + k).style.display = k === v ? 'block' : 'none'; });
                 $$('#sidebarNav .nav-item').forEach(i => i.classList.toggle('active', i.dataset.view === v));
                 if (push && location.hash !== '#' + v) history.pushState(null, '', '#' + v);
                 closePop(); drawer(false); window.scrollTo(0, 0);
             }
             $$('#sidebarNav .nav-item').forEach(i => i.addEventListener('click', () => { if (!i.classList.contains('disabled')) show(i.dataset.view, true); }));
             window.addEventListener('popstate', () => show(location.hash.slice(1), false));
             const va = $('.view-all-link'); if (va) va.addEventListener('click', e => { e.preventDefault(); show('orders', true); });

             /* ============ Products ============ */
             const pTable = $('#productsTable');
             $('#productSearch').addEventListener('input', function () { ui.pq = this.value; renderProducts(); });
             $('#view-products .btn-filter').addEventListener('click', function (e) {
                 const p = popover(this, Object.keys(FILTERS).map(k => '<button type="button" data-f="' + k + '" class="' + (ui.pf === k ? 'on' : '') + '">' + FILTERS[k] + '</button>').join(''));
                 if (p) p.onclick = ev => { const b = ev.target.closest('[data-f]'); if (b) { ui.pf = b.dataset.f; closePop(); renderProducts(); } };
             });
             $('#view-products .btn-primary').addEventListener('click', () => productForm(null));
             $('#productsTable thead').addEventListener('click', function (e) {
                 const th = e.target.closest('th[data-key]'); if (!th) return;
                 ui.dir = ui.sort === th.dataset.key ? -ui.dir : 1; ui.sort = th.dataset.key; renderProducts();
             });

             // FIXED: DELETE HANDLER NOW CALLS API
             $('tbody', pTable).addEventListener('click', function (e) {
                 const a = e.target.closest('[data-act]'); if (!a) return;
                 const p = P.find(x => x.sku === a.closest('tr').dataset.sku); if (!p) return;

                 if (a.dataset.act === 'edit') productForm(p);

                 if (a.dataset.act === 'toggle') {
                     p.active = !p.active;
                     refresh();
                     toast(p.name + ' is now ' + (p.active ? 'active' : 'inactive') + '.');
                 }

                 if (a.dataset.act === 'del') {
                     confirmBox('Delete product', 'Delete <strong>' + esc(p.name) + '</strong>? This cannot be undone.', 'Delete', function () {
                         if (!p.id) {
                             toast('Product ID missing. Cannot delete.', 'error');
                             return;
                         }
                         const deleteData = new FormData();
                         deleteData.append('id', p.id);

                         fetch('/api/products/delete', {
                             method: 'POST',
                             body: deleteData
                         })
                         .then(response => {
                             if (response.ok) {
                                 P.splice(P.indexOf(p), 1);
                                 refresh();
                                 toast('Product deleted successfully.', 'ok');
                             } else {
                                 response.text().then(msg => toast('Error: ' + msg, 'error'));
                             }
                         })
                         .catch(error => {
                             console.error(error);
                             toast('Network error. Please try again.', 'error');
                         });
                     });
                 }
             });

         function cleanHtml(html) {
             const t = document.createElement('div');
             t.innerHTML = html || '';
             const ok = { B: 1, STRONG: 1, I: 1, EM: 1, UL: 1, LI: 1, BR: 1, DIV: 1, P: 1, A: 1 };
             (function walk(n) {
                 [...n.childNodes].forEach(function (c) {
                     if (c.nodeType === 3) return;
                     if (c.nodeType !== 1) { c.remove(); return; }
                     if (/^(SCRIPT|STYLE|IFRAME|OBJECT|EMBED)$/.test(c.tagName)) { c.remove(); return; }
                     if (!ok[c.tagName]) { walk(c); c.replaceWith(...c.childNodes); return; }
                     [...c.attributes].forEach(function (a) {
                         if (!(c.tagName === 'A' && a.name === 'href' && /^https?:\/\/\S+$/i.test(a.value))) c.removeAttribute(a.name);
                     });
                     if (c.tagName === 'A') { c.target = '_blank'; c.rel = 'noopener noreferrer'; }
                     walk(c);
                 });
             })(t);
             return t.innerHTML;
         }

         // FIXED: PRODUCT FORM WITH ID HANDLING
         function productForm(p) {
             const isNew = !p;
             let currentProductId = null;

             // SET ID IF EDITING
             if (!isNew && p.id) {
                 currentProductId = p.id;
             }

               const d = (p && p.editData && Object.keys(p.editData).length > 0)
                    ? p.editData
                    : { name: '', cat: CAT_NAMES[0], sub: '', attrs: {}, price: '', disc: 0, stock: '', active: true, description: '', infoImage: '' };
             const cats = [...new Set(CAT_NAMES.concat(P.map(x => x.cat)))];

             const m = modal(isNew ? 'Add product' : 'Edit product',
                 '<label class="fld">Product name<input id="f-name" maxlength="60" value="' + esc(d.name) + '"><span class="err"></span></label>' +
                 '<div class="fld-row"><label class="fld">Category<select id="f-cat">' + cats.map(c => '<option' + (c === d.cat ? ' selected' : '') + '>' + esc(c) + '</option>').join('') + '</select></label>' +
                 '<label class="fld">Sub-category<select id="f-sub"></select><span class="err"></span></label></div>' +
                 '<div id="f-attrs"></div>' +
                 '<div class="fld-row"><label class="fld">Price (Rs)<input id="f-price" type="number" min="1" value="' + d.price + '"><span class="err"></span></label>' +
                 '<label class="fld">Discount %<input id="f-disc" type="number" min="0" max="90" value="' + (d.disc || 0) + '"><span class="err"></span></label></div>' +
                 '<div class="fld-row"><label class="fld">Stock<input id="f-stock" type="number" min="0" value="' + d.stock + '"><span class="err"></span></label></div>' +

                 '<div class="rich-editor">' +
                     '<div class="editor-label"><span>DETAILED DESCRIPTION &amp; SPECIFICATIONS</span><span class="editor-support">Supports Rich Text</span></div>' +
                     '<div class="editor-box">' +
                         '<div class="editor-toolbar">' +
                             '<button type="button" data-cmd="bold" title="Bold"><b>B</b></button>' +
                             '<button type="button" data-cmd="italic" title="Italic"><i>I</i></button>' +
                             '<button type="button" data-cmd="insertUnorderedList" title="Bullet list">☷</button>' +
                             '<button type="button" data-cmd="justifyLeft" title="Align left">☰</button>' +
                             '<button type="button" data-link title="Insert link">🔗</button>' +
                         '</div>' +
                         '<div id="f-description" class="editor-content" contenteditable="true" ' +
                             'data-placeholder="Enter comprehensive product story, key features, dimensions, technical specs..." ' +
                             'role="textbox" aria-multiline="true">' + cleanHtml(d.description) + '</div>' +
                     '</div>' +
                     '<span class="err" id="description-err"></span>' +
                 '</div>' +

                 '<div class="image-upload-section">' +
                     '<div class="editor-label"><span>DETAILED INFORMATION IMAGE</span><span class="editor-support">Spec sheet / Info graphic</span></div>' +
                     '<div class="image-dropzone single" id="f-infoimage-zone">' +
                         '<input type="file" id="f-infoimage" accept="image/*" hidden>' +
                         '<div class="dz-content">' +
                             '<div class="dz-placeholder">Click or drag image here</div>' +
                             '<div class="dz-preview hidden" id="f-infoimage-preview"></div>' +
                         '</div>' +
                         '<button type="button" class="dz-remove hidden" id="f-infoimage-remove" title="Remove">×</button>' +
                     '</div>' +
                     '<span class="err" id="infoimage-err"></span>' +
                 '</div>' +

                 '<div class="image-upload-section">' +
                     '<div class="editor-label"><span>PRODUCT IMAGES</span><span class="editor-support" id="prod-img-count">0 / 8</span></div>' +
                     '<div class="image-dropzone multi" id="f-prodimages-zone">' +
                         '<input type="file" id="f-prodimages" accept="image/*" multiple hidden>' +
                         '<div class="dz-content">' +
                             '<div class="dz-placeholder">Click or drag images here (1–8)</div>' +
                             '<div class="dz-gallery" id="f-prodimages-gallery"></div>' +
                         '</div>' +
                     '</div>' +
                     '<span class="err" id="prodimages-err"></span>' +
                 '</div>' +

                 '<label class="chk"><input id="f-active" type="checkbox"' + (d.active ? ' checked' : '') + '> Listed as active</label>',
                 [['Cancel', 'btn-outline', closeModal], [isNew ? 'Add product' : 'Save changes', 'btn-primary', save]]);

             const catSel = $('#f-cat', m), subSel = $('#f-sub', m), box = $('#f-attrs', m);
             let infoImage = d.infoImage || '';
             let prodImages = (p && p.images && p.images.length > 0) ? [...p.images] : [];

             const editor = $('#f-description', m), toolbar = $('.editor-toolbar', m);
             let savedRange = null;

             function rememberRange() {
                 const s = window.getSelection();
                 if (s.rangeCount && editor.contains(s.getRangeAt(0).commonAncestorContainer)) savedRange = s.getRangeAt(0).cloneRange();
             }
             function restoreRange() {
                 editor.focus();
                 if (savedRange) { const s = window.getSelection(); s.removeAllRanges(); s.addRange(savedRange); }
             }
             ['keyup', 'mouseup', 'input', 'focus'].forEach(ev => editor.addEventListener(ev, rememberRange));

             toolbar.addEventListener('mousedown', function (e) { if (e.target.closest('button')) e.preventDefault(); });
             toolbar.addEventListener('click', function (e) {
                 const btn = e.target.closest('button'); if (!btn) return;
                 restoreRange();
                 if (btn.dataset.cmd) document.execCommand(btn.dataset.cmd, false, null);
                 if (btn.hasAttribute('data-link')) {
                     const url = (prompt('Enter the URL (https://...):') || '').trim();
                     restoreRange();
                     if (url && /^https?:\/\/\S+$/i.test(url)) document.execCommand('createLink', false, url);
                     else if (url) toast('Link must start with http:// or https://');
                 }
                 rememberRange();
             });
             editor.addEventListener('paste', function (e) {
                 e.preventDefault();
                 const txt = (e.clipboardData || window.clipboardData).getData('text/plain');
                 document.execCommand('insertText', false, txt);
             });

             const infoZone = $('#f-infoimage-zone', m);
             const infoInput = $('#f-infoimage', m);
             const infoPreview = $('#f-infoimage-preview', m);
             const infoRemove = $('#f-infoimage-remove', m);

             infoZone.addEventListener('click', () => infoInput.click());
             infoInput.addEventListener('change', function () {
                 if (this.files && this.files[0]) {
                     const r = new FileReader();
                     r.onload = e => { infoImage = e.target.result; updateInfoPreview(); };
                     r.readAsDataURL(this.files[0]);
                 }
             });
             infoRemove.addEventListener('click', e => { e.stopPropagation(); infoImage = ''; updateInfoPreview(); });

             function updateInfoPreview() {
                 if (infoImage) {
                     infoPreview.innerHTML = '<img src="' + infoImage + '">';
                     infoPreview.classList.remove('hidden');
                     infoRemove.classList.remove('hidden');
                     $('.dz-placeholder', infoZone).classList.add('hidden');
                 } else {
                     infoPreview.innerHTML = '';
                     infoPreview.classList.add('hidden');
                     infoRemove.classList.add('hidden');
                     $('.dz-placeholder', infoZone).classList.remove('hidden');
                 }
             }
             updateInfoPreview();

             ['dragenter', 'dragover'].forEach(ev => infoZone.addEventListener(ev, e => { e.preventDefault(); infoZone.classList.add('dragover'); }));
             ['dragleave', 'drop'].forEach(ev => infoZone.addEventListener(ev, e => { e.preventDefault(); infoZone.classList.remove('dragover'); }));
             infoZone.addEventListener('drop', e => {
                 const f = e.dataTransfer.files[0];
                 if (f && f.type.startsWith('image/')) {
                     const r = new FileReader();
                     r.onload = ev => { infoImage = ev.target.result; updateInfoPreview(); };
                     r.readAsDataURL(f);
                 }
             });

             const prodZone = $('#f-prodimages-zone', m);
             const prodInput = $('#f-prodimages', m);
             const prodGallery = $('#f-prodimages-gallery', m);
             const prodCount = $('#prod-img-count', m);

             prodZone.addEventListener('click', e => { if (e.target === prodZone || e.target.closest('.dz-content')) prodInput.click(); });
             prodInput.addEventListener('change', function () {
                 [...this.files].forEach(f => {
                     if (!f.type.startsWith('image/')) return;
                     if (prodImages.length >= 8) return;
                     const r = new FileReader();
                     r.onload = e => { prodImages.push(e.target.result); updateProdGallery(); };
                     r.readAsDataURL(f);
                 });
                 this.value = '';
             });

             function updateProdGallery() {
                 prodCount.textContent = prodImages.length + ' / 8';
                 if (prodImages.length === 0) {
                     prodGallery.innerHTML = '';
                     $('.dz-placeholder', prodZone).classList.remove('hidden');
                 } else {
                     $('.dz-placeholder', prodZone).classList.add('hidden');
                     prodGallery.innerHTML = prodImages.map((src, i) =>
                         '<div class="thumb"><img src="' + src + '"><button type="button" data-idx="' + i + '" class="del">×</button></div>'
                     ).join('');
                 }
                 $$('.dz-gallery .del', m).forEach(b => b.addEventListener('click', e => {
                     e.stopPropagation();
                     prodImages.splice(Number(b.dataset.idx), 1);
                     updateProdGallery();
                 }));
             }
             updateProdGallery();

             ['dragenter', 'dragover'].forEach(ev => prodZone.addEventListener(ev, e => { e.preventDefault(); prodZone.classList.add('dragover'); }));
             ['dragleave', 'drop'].forEach(ev => prodZone.addEventListener(ev, e => { e.preventDefault(); prodZone.classList.remove('dragover'); }));
             prodZone.addEventListener('drop', e => {
                 [...e.dataTransfer.files].forEach(f => {
                     if (!f.type.startsWith('image/')) return;
                     if (prodImages.length >= 8) return;
                     const r = new FileReader();
                     r.onload = ev => { prodImages.push(ev.target.result); updateProdGallery(); };
                     r.readAsDataURL(f);
                 });
             });

             function fillAttrs() {
                 const specs = (((CATALOG[catSel.value] || {})[subSel.value]) || []).map(parseAttr);
                 const keep = (catSel.value === d.cat && subSel.value === d.sub) ? (d.attrs || {}) : {};
                 if (!specs.length) { box.innerHTML = ''; return; }
                 box.innerHTML = '<div class="attr-head">' + esc(subSel.value) + ' details</div><div class="attr-grid">' + specs.map(function (a) {
                     const v = keep[a.label] || '', lab = esc(a.label);
                     if (a.type === 'select') {
                         return '<label class="fld">' + lab + '<select data-attr="' + lab + '"><option value="">Select</option>' +
                             a.opts.map(o => '<option' + (o === v ? ' selected' : '') + '>' + esc(o) + '</option>').join('') + '</select></label>';
                     }
                     return '<label class="fld">' + lab + '<input data-attr="' + lab + '" type="' + (a.type === 'date' ? 'date' : 'text') + '" maxlength="60" value="' + esc(v) + '"></label>';
                 }).join('') + '</div>';
             }
             function fillSubs(selected) {
                 const subs = Object.keys(CATALOG[catSel.value] || {});
                 subSel.innerHTML = '<option value="">' + (subs.length ? 'Select sub-category' : 'No sub-categories') + '</option>' +
                     subs.map(s => '<option' + (s === selected ? ' selected' : '') + '>' + esc(s) + '</option>').join('');
                 subSel.disabled = !subs.length;
                 fillAttrs();
             }
             catSel.addEventListener('change', function () { fillSubs(''); });
             subSel.addEventListener('change', function () { err('f-sub', ''); fillAttrs(); });
             fillSubs(d.sub);

             function err(id, msg) {
                 const f = $('#' + id, m); f.classList.toggle('bad', !!msg);
                 $('.err', f.parentNode).textContent = msg || '';
                 return !msg;
             }

            function save() {
                const needSub = Object.keys(CATALOG[catSel.value] || {}).length > 0;
                const attrs = {};
                $$('[data-attr]', m).forEach(i => {
                    if (i.value.trim()) attrs[i.dataset.attr] = i.value.trim();
                });

                const name = $('#f-name', m).value.trim();
                const price = Number($('#f-price', m).value);
                const disc = Number($('#f-disc', m).value || 0);
                const stock = $('#f-stock', m).value;
                const descLen = editor.textContent.trim().length;
                const descMsg = descLen > 3000 ? 'Description is too long (max 3000 characters).' : '';
                $('#description-err', m).textContent = descMsg;
                editor.parentNode.classList.toggle('bad', !!descMsg);

                // Validation for Product Images (only required for NEW products)
                const prodImagesErr = prodImages.length === 0 && isNew ? 'At least one product image is required.' : prodImages.length > 8 ? 'Maximum 8 product images allowed.' : '';
                $('#prodimages-err', m).textContent = prodImagesErr;
                prodZone.classList.toggle('bad', !!prodImagesErr);

                const ok = [
                    err('f-name', !name ? 'Name is required.' : ''),
                    err('f-sub', needSub && !subSel.value ? 'Select a sub-category.' : ''),
                    err('f-price', !(price >= 1) ? 'Enter a price of at least 1.' : ''),
                    err('f-disc', !(disc >= 0 && disc <= 90) ? '0 – 90 only.' : ''),
                    err('f-stock', stock === '' || Number(stock) < 0 || !Number.isInteger(Number(stock)) ? 'Whole number, 0 or more.' : ''),
                    !descMsg,
                    !prodImagesErr
                ].every(Boolean);
                if (!ok) return;

                const formData = new FormData();
                formData.append('name', name);
                formData.append('category', catSel.value);
                formData.append('subCategory', subSel.value);
                formData.append('price', $('#f-price', m).value);
                formData.append('stock', $('#f-stock', m).value);
                formData.append('discount', $('#f-disc', m).value || '0');
                formData.append('description', editor.innerHTML);
                formData.append('attributes', JSON.stringify(attrs));

                /*
                   LOGIC FIX:
                   We check if the image string starts with 'data:' (Base64 from user upload)
                   or 'http' (Existing URL from database).
                   We ONLY fetch/upload if it's a 'data:' string.
                */

                const isNewInfoImage = infoImage && infoImage.startsWith('data:');
                // Filter prodImages to only include NEW uploads (data:), ignoring existing URLs (http:)
                const newProdImages = prodImages.filter(img => img && img.startsWith('data:'));

                // Helper to process a single data-url into a blob and append to formData
                const processImage = (src) => {
                    return fetch(src)
                        .then(res => res.blob())
                        .then(blob => {
                            // Determine filename based on context if needed, but generic is fine
                            formData.append('productImages', blob, 'product-image.png');
                        });
                };

                if (isNewInfoImage) {
                    // 1. Process Info Image (New Upload)
                    fetch(infoImage)
                        .then(res => res.blob())
                        .then(blob => {
                            formData.append('infoImage', blob, 'info-image.png');

                            // 2. Process New Product Images if any
                            if (newProdImages.length > 0) {
                                const promises = newProdImages.map(processImage);
                                Promise.all(promises).then(() => submitProduct(formData, m, isNew));
                            } else {
                                submitProduct(formData, m, isNew);
                            }
                        })
                        .catch(err => {
                            console.error(err);
                            toast('Error processing images.', 'error');
                        });
                } else {
                    // Info Image is NOT new (either empty or existing URL).
                    // If editing, backend keeps old one. If new, validation should have caught missing image earlier if required.

                    if (newProdImages.length > 0) {
                        // Only uploading new product images
                        const promises = newProdImages.map(processImage);
                        Promise.all(promises).then(() => submitProduct(formData, m, isNew));
                    } else {
                        // No new images at all. Just submit text data.
                        submitProduct(formData, m, isNew);
                    }
                }
            }

             function submitProduct(formData, modalElement, isNew) {
                 const url = isNew ? '/api/products/create' : '/api/products/update';

                 if (!isNew) {
                     if (!currentProductId) {
                         toast('Product ID not found. Cannot update.', 'error');
                         return;
                     }
                     formData.append('id', currentProductId);
                 }

                 fetch(url, {
                     method: 'POST',
                     body: formData
                 })
                 .then(response => {
                     if (response.ok) {
                         if (modalElement) closeModal();
                         refresh();
                         toast(isNew ? 'Product added successfully.' : 'Product updated successfully.', 'ok');
                     } else {
                         response.text().then(errMsg => {
                             toast('Error: ' + errMsg, 'error');
                         });
                     }
                 })
                 .catch(error => {
                     console.error(error);
                     toast('Network error. Please try again.', 'error');
                 });
             }
         }

             /* ============ Orders ============ */
             $$('#orderTabs .tab').forEach(t => t.addEventListener('click', function () {
                 $$('#orderTabs .tab').forEach(x => x.classList.remove('active')); t.classList.add('active');
                 ui.of = t.dataset.filter; renderOrders();
             }));
             const os = el('div', 'toolbar', '<div class="search-box"><span class="material-symbols-outlined">search</span><input type="text" id="orderSearch" placeholder="Search by order, customer or product..."></div>');
             $('#orderTabs').before(os);
             $('#orderSearch').addEventListener('input', function () { ui.oq = this.value; renderOrders(); });
             $('#ordersTable tbody').addEventListener('click', function (e) {
                 const r = e.target.closest('tr[data-ref]'); if (r) orderDetail(O.find(o => o.ref === r.dataset.ref));
             });

             function setStatus(o, s) {
                 const prev = o.status, p = P.find(x => x.name === o.product); o.status = s;
                 if (p) { if (s === 'cancelled' && prev !== 'cancelled') p.stock++; if (s === 'delivered' && prev !== 'delivered') p.sold++; }
                 refresh();
             }
             function orderDetail(o) {
                 const steps = ['pending', 'confirmed', 'shipped', 'delivered'], idx = steps.indexOf(o.status);
                 const tl = '<div class="timeline">' + steps.map((s, i) => '<div class="tl-step' + (idx >= i ? ' done' : '') + (o.status === 'cancelled' || o.status === 'return' ? ' off' : '') + '"><span></span>' + LABEL[s] + '</div>').join('') + '</div>';
                 const btns = [['Close', 'btn-outline', closeModal]];
                 if (NEXT[o.status]) btns.push([NEXT_BTN[o.status], 'btn-primary', function () { setStatus(o, NEXT[o.status]); toast(o.ref + ' → ' + LABEL[o.status], 'ok'); orderDetail(o); }]);
                 if (o.status === 'pending' || o.status === 'confirmed') btns.splice(1, 0, ['Cancel order', 'btn-outline danger', () => confirmBox('Cancel order', 'Cancel <strong>' + esc(o.ref) + '</strong>? Stock will be restored.', 'Cancel order', () => { setStatus(o, 'cancelled'); toast(o.ref + ' cancelled.'); })]);
                 if (o.status === 'return') {
                     btns.splice(1, 0, ['Reject return', 'btn-outline danger', () => { setStatus(o, 'delivered'); toast('Return rejected.'); closeModal(); }]);
                     btns.push(['Approve return', 'btn-primary', () => { setStatus(o, 'cancelled'); toast('Return approved · Rs ' + fmt(o.total) + ' refund queued.', 'ok'); closeModal(); }]);
                 }
                 modal(o.ref, '<div class="od-head"><span class="o-badge ' + o.status + '">' + LABEL[o.status] + '</span><span class="muted-sm">' + esc(o.date) + '</span></div>' +
                     '<dl class="od"><dt>Customer</dt><dd>' + esc(o.cust) + '</dd><dt>Product</dt><dd>' + esc(o.product) + '</dd><dt>Total</dt><dd>Rs ' + fmt(o.total) + '</dd></dl>' + tl, btns);
             }

             /* ============ Messages ============ */
             $('#messageSearch').addEventListener('input', function () { ui.mq = this.value; renderMessages(); });
             $('#messageList').addEventListener('click', function (e) { const i = e.target.closest('.msg-item'); if (i) openThread(M[+i.dataset.i]); });
             function bubbles(m) { return m.thread.map(t => '<div class="bubble ' + (t.me ? 'me' : 'them') + '">' + esc(t.text) + '</div>').join(''); }
             function openThread(m) {
                 m.unread = false; renderMessages(); syncDash();
                 const b = modal(m.name + ' · ' + m.subject, '<div class="thread">' + bubbles(m) + '</div><textarea id="reply" rows="3" placeholder="Write a reply..."></textarea>',
                     [['Close', 'btn-outline', closeModal], ['Send reply', 'btn-primary', function () {
                         const ta = $('#reply', b), t = ta.value.trim(); if (!t) { ta.classList.add('bad'); return; }
                         m.thread.push({ me: true, text: t }); m.time = 'Just now';
                         $('.thread', b).innerHTML = bubbles(m); ta.value = ''; renderMessages(); toast('Reply sent to ' + m.name + '.', 'ok');
                         $('.thread', b).scrollTop = 9999;
                     }]]);
                 $('.thread', b).scrollTop = 9999;
             }

             /* ============ Finance / My Store ============ */
             const ex = $('#exportCsvBtn');
             if (ex) ex.addEventListener('click', function () {
                 const a = el('a'); a.href = URL.createObjectURL(new Blob([ex.dataset.csv], { type: 'text/csv;charset=utf-8;' }));
                 a.download = 'monthly-revenue.csv'; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(a.href); toast('CSV downloaded.', 'ok');
             });
             $$('#storeTabs .tab').forEach(t => t.addEventListener('click', function () {
                 $$('#storeTabs .tab').forEach(x => x.classList.remove('active')); t.classList.add('active');
                 $$('.store-panel').forEach(p => { p.style.display = p.id === t.dataset.panel ? 'block' : 'none'; });
             }));
             const fb = $('#followBtn');
             if (fb) fb.addEventListener('click', function () { const f = fb.classList.toggle('following'); fb.textContent = f ? 'Following' : 'Follow store'; });

             /* ============ Bell ============ */
             const bell = $('.icon-btn[aria-label="Notifications"]');
             if (bell) bell.addEventListener('click', function () {
                 const al = alertList();
                 popover(bell, '<div class="pop-title">Notifications</div>' + (al.map(a => '<button type="button" data-go="' + a.go + '"><strong>' + esc(a.title) + '</strong><span>' + esc(a.body) + '</span></button>').join('') || '<div class="pop-empty">You\'re all caught up.</div>'), true);
             });

             /* ============ Live activity (simulated feed – replace with fetch()/WebSocket) ============ */
             const NAMES = ['Lena Fischer', 'Arjun Mehta', 'Chloe Martin', 'Omar Haddad', 'Sita Gurung', 'Diego Ramos'];
             function newOrder() {
                 const pool = P.filter(p => p.active && p.stock > 0); if (!pool.length) return;
                 const p = pool[Math.floor(Math.random() * pool.length)], d = new Date();
                 const ref = '#ORD-' + (Math.max.apply(null, O.map(o => num(o.ref))) + 1 + Math.floor(Math.random() * 4));
                 const o = { ref: ref, date: d.toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }), cust: NAMES[Math.floor(Math.random() * NAMES.length)],
                     product: p.name, status: 'pending', total: Math.round(p.price * (1 - p.disc / 100)) };
                 O.unshift(o); p.stock--; revenue += o.total; orderCount++; refresh();
                 toast('New order ' + o.ref + ' from ' + o.cust, 'ok', 'orders');
             }
             function newMessage() {
                 const n = NAMES[Math.floor(Math.random() * NAMES.length)];
                 M.unshift({ name: n, subject: 'Is this item still available?', time: 'Just now', unread: true, thread: [{ me: false, text: 'Hi! Is the ' + P[0].name.toLowerCase() + ' available for delivery this week?' }] });
                 refresh(); toast('New message from ' + n, '', 'messages');
             }
             setInterval(function () {
                 if (!approved || document.hidden || $('.modal-backdrop')) return;
                 Math.random() < 0.6 ? newOrder() : newMessage();
             }, 30000);

             /* ============ Status flow (server-driven, no faking) ============ */
             function applyServerStatus() {
                 $('#reviewState').style.display = 'none';
                 $('#rejectedState').style.display = 'none';
                 $('#approvedDashboard').style.display = 'none';

                 if (SERVER_STATUS === 'approved') {
                     approved = true;
                     $('#approvedDashboard').style.display = 'block';
                     $('#statusText').textContent = 'Approved';
                     $('#sidebarStatus').classList.add('approved');
                     $$('#sidebarNav .nav-item').forEach(i => { i.classList.remove('disabled'); i.title = $('.nav-text', i).textContent.trim(); });
                 } else if (SERVER_STATUS === 'rejected') {
                     approved = false;
                     $('#rejectedState').style.display = 'block';
                 } else {
                     approved = false;
                     $('#reviewState').style.display = 'block';
                 }
                 show(location.hash.slice(1), false);
             }
             refresh();
             applyServerStatus();
         });
         })();
             </script>
</body>
</html>
