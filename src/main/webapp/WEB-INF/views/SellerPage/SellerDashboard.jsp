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
</script>
<script src="${pageContext.request.contextPath}/css/seller/SellerDashboard.js"></script>
</body>
</html>
