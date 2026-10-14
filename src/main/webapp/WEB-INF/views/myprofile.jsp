<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- Using Jakarta EE 9+ / Spring Boot 3? Change the taglib uri above to: jakarta.tags.core --%>

<%-- 2. Redirect to login page if session is empty --%>
<c:if test="${empty sessionScope.userId}">
    <c:redirect url="/login" />
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile &amp; Account Settings - Luma Store</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/myprofile.css?v=11">
    <script src="https://unpkg.com/lucide@latest"></script>
</head>
<body>

    <jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="page">
        <div class="layout">

            <!-- SIDEBAR -->
            <aside id="sidebar-container" class="sidebar">
                <div class="sidebar-card">

                    <div class="profile-badge">
                        <div class="profile-avatar">
                            <img id="sidebar-avatar" src="${not empty profilePicUrl ? profilePicUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'}" alt="Avatar">
                            <span class="online-dot"></span>
                        </div>
                        <div class="profile-info">
                            <h3 id="sidebar-name" class="profile-name"><c:choose>
                                                                           <c:when test="${not empty sessionScope.userFirstName or not empty sessionScope.userLastName}">
                                                                             <c:out value="${sessionScope.userFirstName}" /> <c:out value="${sessionScope.userLastName}" />
                                                                           </c:when>
                                                                           <c:otherwise>
                                                                             Guest
                                                                           </c:otherwise>
                                                                         </c:choose></h3>
                            <p class="profile-email">${sessionScope.userEmail}</p>
                         <!--   <span class="vip-badge"><i data-lucide="crown"></i> Gold VIP</span> -->
                        </div>
                    </div>

                    <nav>
                        <button onclick="switchTab('overview')" data-tab="overview" class="nav-btn active">
                            <i data-lucide="layout-dashboard"></i><span>Overview</span>
                        </button>
                        <button onclick="switchTab('orders')" data-tab="orders" class="nav-btn">
                            <i data-lucide="package"></i><span>My Orders</span>
                            <span class="nav-count">3</span>
                        </button>
                        <button onclick="switchTab('wishlist')" data-tab="wishlist" class="nav-btn">
                            <i data-lucide="heart"></i><span>Wishlist</span>
                            <span class="nav-count">4</span>
                        </button>
                        <button onclick="switchTab('addresses')" data-tab="addresses" class="nav-btn">
                            <i data-lucide="map-pin"></i><span>Saved Addresses</span>
                        </button>
                        <button onclick="switchTab('payments')" data-tab="payments" class="nav-btn">
                            <i data-lucide="credit-card"></i><span>Payment Methods</span>
                        </button>
                        <button onclick="switchTab('settings')" data-tab="settings" class="nav-btn">
                            <i data-lucide="settings"></i><span>Account Settings</span>
                        </button>
                    </nav>

                    <div class="sidebar-foot">
                    <a href="${pageContext.request.contextPath}/logout">
                        <button class="signout" onclick="showToast('You have been logged out')">
                            <i data-lucide="log-out"></i><span>Sign Out</span>
                        </button>
                        </a>
                    </div>
                </div>
            </aside>

            <!-- PANELS -->
            <main>

                <!-- ===== 1. OVERVIEW ===== -->
                <div id="tab-overview" class="tab-content">

                    <div class="hero">
                        <div class="hero-glow"></div>
                        <div class="hero-text">
                            <span class="hero-tag"><i data-lucide="sparkles"></i> Customer Dashboard</span>
                            <h2>Welcome back, ${sessionScope.userFirstName}!</h2>
                            <p>Track active shipments, manage saved payment options, and customize notification alerts.</p>
                        </div>
                        <div class="points-box">
                            <p class="points-label">Reward Points</p>
                            <p class="points-value">1,450 pts</p>
                            <button class="points-btn" onclick="showToast('Reward points redeemed successfully!')">Redeem Points</button>
                        </div>
                    </div>

                    <div class="stat-grid">
                        <div class="stat">
                            <div>
                                <p class="stat-label">Total Orders</p>
                                <p class="stat-value">14</p>
                                <span class="stat-note note-green"><i data-lucide="arrow-up-right"></i> +2 this month</span>
                            </div>
                            <div class="stat-icon tone-indigo"><i data-lucide="package"></i></div>
                        </div>
                        <div class="stat">
                            <div>
                                <p class="stat-label">Wishlist Items</p>
                                <p class="stat-value">4</p>
                                <span class="stat-note note-rose"><i data-lucide="heart"></i> 2 items on sale</span>
                            </div>
                            <div class="stat-icon tone-rose"><i data-lucide="heart"></i></div>
                        </div>
                        <div class="stat">
                            <div>
                                <p class="stat-label">Addresses</p>
                                <p class="stat-value">2</p>
                                <span class="stat-note note-gray">1 Primary Default</span>
                            </div>
                            <div class="stat-icon tone-amber"><i data-lucide="map-pin"></i></div>
                        </div>
                        <div class="stat">
                            <div>
                                <p class="stat-label">Saved Cards</p>
                                <p class="stat-value">2</p>
                                <span class="stat-note note-brand">Visa &amp; Mastercard</span>
                            </div>
                            <div class="stat-icon tone-emerald"><i data-lucide="credit-card"></i></div>
                        </div>
                    </div>

                    <div class="card">
                        <div class="row-between table-head-row">
                            <div>
                                <h3 class="section-title">Recent Purchases</h3>
                                <p class="page-sub">Track and manage recent order deliveries</p>
                            </div>
                            <button class="link-brand" onclick="switchTab('orders')">
                                View All Orders <i data-lucide="chevron-right"></i>
                            </button>
                        </div>
                        <div class="table-wrap">
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th>Order ID</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Total</th>
                                        <th>Action</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td class="strong">#ORD-2026-8942</td>
                                        <td class="date">Oct 10, 2026</td>
                                        <td><span class="pill pill-amber">Processing</span></td>
                                        <td class="strong">$148.50</td>
                                        <td><button class="btn-detail" onclick="openOrderModal('#ORD-2026-8942', 'Processing', '$148.50')">View Details</button></td>
                                    </tr>
                                    <tr>
                                        <td class="strong">#ORD-2026-7819</td>
                                        <td class="date">Sep 28, 2026</td>
                                        <td><span class="pill pill-sky">Shipped</span></td>
                                        <td class="strong">$84.00</td>
                                        <td><button class="btn-detail" onclick="openOrderModal('#ORD-2026-7819', 'Shipped', '$84.00')">View Details</button></td>
                                    </tr>
                                    <tr>
                                        <td class="strong">#ORD-2026-6210</td>
                                        <td class="date">Sep 15, 2026</td>
                                        <td><span class="pill pill-green">Delivered</span></td>
                                        <td class="strong">$230.20</td>
                                        <td><button class="btn-detail" onclick="openOrderModal('#ORD-2026-6210', 'Delivered', '$230.20')">View Details</button></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- ===== 2. MY ORDERS ===== -->
                <div id="tab-orders" class="tab-content hidden">
                    <div class="head-stack">
                        <div>
                            <h2 class="page-title">My Orders</h2>
                            <p class="page-sub">Track shipment status and order history</p>
                        </div>
                        <div class="filters">
                            <button onclick="filterOrders('all', this)" class="filter-btn active">All Orders</button>
                            <button onclick="filterOrders('processing', this)" class="filter-btn">Processing</button>
                            <button onclick="filterOrders('shipped', this)" class="filter-btn">Shipped</button>
                            <button onclick="filterOrders('delivered', this)" class="filter-btn">Delivered</button>
                            <button onclick="filterOrders('cancelled', this)" class="filter-btn">Cancelled</button>
                        </div>
                    </div>

                    <div class="order-list">
                        <div class="order-card" data-status="processing">
                            <div class="order-head">
                                <div class="order-id-row">
                                    <span class="order-id">#ORD-2026-8942</span>
                                    <span class="pill pill-amber">Processing</span>
                                </div>
                                <div class="order-date">Ordered on <b>Oct 10, 2026</b></div>
                            </div>
                            <div class="order-body">
                                <div class="order-product">
                                    <img class="order-thumb" src="https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=150&q=80" alt="Headphones">
                                    <div>
                                        <h4>Wireless ANC Headphones Pro</h4>
                                        <p class="order-meta">Qty: 1 • Matte Black</p>
                                        <p class="order-price">$148.50</p>
                                    </div>
                                </div>
                                <div class="order-actions">
                                    <button class="btn btn-primary" onclick="openOrderModal('#ORD-2026-8942', 'Processing', '$148.50')">Track Order</button>
                                </div>
                            </div>
                        </div>

                        <div class="order-card" data-status="shipped">
                            <div class="order-head">
                                <div class="order-id-row">
                                    <span class="order-id">#ORD-2026-7819</span>
                                    <span class="pill pill-sky">Shipped</span>
                                </div>
                                <div class="order-date">Ordered on <b>Sep 28, 2026</b></div>
                            </div>
                            <div class="order-body">
                                <div class="order-product">
                                    <img class="order-thumb" src="https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=150&q=80" alt="Watch">
                                    <div>
                                        <h4>Leather Smartwatch Series 5</h4>
                                        <p class="order-meta">Qty: 1 • Tan Brown</p>
                                        <p class="order-price">$84.00</p>
                                    </div>
                                </div>
                                <div class="order-actions">
                                    <button class="btn btn-primary" onclick="openOrderModal('#ORD-2026-7819', 'Shipped', '$84.00')">Track Order</button>
                                </div>
                            </div>
                        </div>

                        <div class="order-card" data-status="delivered">
                            <div class="order-head">
                                <div class="order-id-row">
                                    <span class="order-id">#ORD-2026-6210</span>
                                    <span class="pill pill-green">Delivered</span>
                                </div>
                                <div class="order-date">Ordered on <b>Sep 15, 2026</b></div>
                            </div>
                            <div class="order-body">
                                <div class="order-product">
                                    <img class="order-thumb" src="https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=150&q=80" alt="Sneakers">
                                    <div>
                                        <h4>Ultra Light Running Shoes</h4>
                                        <p class="order-meta">Qty: 1 • Red / Black</p>
                                        <p class="order-price">$230.20</p>
                                    </div>
                                </div>
                                <div class="order-actions">
                                    <button class="btn btn-gray" onclick="openOrderModal('#ORD-2026-6210', 'Delivered', '$230.20')">View Invoice</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ===== 3. WISHLIST ===== -->
                <div id="tab-wishlist" class="tab-content hidden">
                    <div>
                        <h2 class="page-title">Saved Wishlist</h2>
                        <p class="page-sub">Your favorite saved items</p>
                    </div>

                    <div class="product-grid">
                        <div class="product-card">
                            <div class="product-img">
                                <img src="https://images.unsplash.com/photo-1526170375885-4d8ecf77b99f?auto=format&fit=crop&w=300&q=80" alt="Camera">
                                <button class="remove-fab" onclick="this.closest('.product-card').remove(); showToast('Removed from wishlist')" aria-label="Remove">
                                    <i data-lucide="trash-2"></i>
                                </button>
                            </div>
                            <div class="product-body">
                                <div>
                                    <h4>Vintage Retro Camera</h4>
                                    <p class="product-price">$299.00</p>
                                </div>
                                <button class="btn-cart" onclick="showToast('Added to cart!')">Add to Cart</button>
                            </div>
                        </div>

                        <div class="product-card">
                            <div class="product-img">
                                <img src="https://images.unsplash.com/photo-1491553895911-0055eca6402d?auto=format&fit=crop&w=300&q=80" alt="Sneakers">
                                <button class="remove-fab" onclick="this.closest('.product-card').remove(); showToast('Removed from wishlist')" aria-label="Remove">
                                    <i data-lucide="trash-2"></i>
                                </button>
                            </div>
                            <div class="product-body">
                                <div>
                                    <h4>Classic White Leather Sneakers</h4>
                                    <p class="product-price">$75.00</p>
                                </div>
                                <button class="btn-cart" onclick="showToast('Added to cart!')">Add to Cart</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ===== 4. ADDRESSES ===== -->
                <div id="tab-addresses" class="tab-content hidden">
                    <div class="row-between">
                        <div>
                            <h2 class="page-title">Saved Addresses</h2>
                            <p class="page-sub">Manage shipping destinations for faster checkout</p>
                        </div>
                        <button class="btn btn-primary" onclick="openAddressModal()">
                            <i data-lucide="plus"></i><span>Add Address</span>
                        </button>
                    </div>

                    <div id="address-grid" class="address-grid">
                        <div class="address-card default">
                            <span class="default-tag">Default</span>
                            <h3>Home Address</h3>
                            <p class="addr-name">Sarah Jenkins</p>
                            <p class="addr-line first">742 Evergreen Terrace, Apt 4B</p>
                            <p class="addr-line">Springfield, OR 97477</p>
                            <p class="addr-phone"><i data-lucide="phone"></i> +1 (555) 234-5678</p>
                            <div class="card-actions">
                                <button class="link-brand" onclick="openAddressModal()">Edit</button>
                                <span class="dot-sep">•</span>
                                <button class="link-faint" onclick="showToast('Cannot delete default address')">Remove</button>
                            </div>
                        </div>

                        <div class="address-card">
                            <h3>Office Address</h3>
                            <p class="addr-name">Sarah Jenkins</p>
                            <p class="addr-line first">100 Tech Park Way, Suite 300</p>
                            <p class="addr-line">Seattle, WA 98101</p>
                            <p class="addr-phone"><i data-lucide="phone"></i> +1 (555) 987-6543</p>
                            <div class="card-actions">
                                <button class="link-brand" onclick="openAddressModal()">Edit</button>
                                <span class="dot-sep">•</span>
                                <button class="link-rose" onclick="this.closest('.address-card').remove(); showToast('Address deleted')">Remove</button>
                                <span class="dot-sep">•</span>
                                <button class="link-dark" onclick="showToast('Set as default address')">Make Default</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ===== 5. PAYMENTS ===== -->
                <div id="tab-payments" class="tab-content hidden">
                    <div class="row-between">
                        <div>
                            <h2 class="page-title">Payment Methods</h2>
                            <p class="page-sub">Saved credit/debit cards and digital wallets</p>
                        </div>
                        <button class="btn btn-primary" onclick="openPaymentModal()">
                            <i data-lucide="plus"></i><span>Add Method</span>
                        </button>
                    </div>

                    <div class="pay-grid">
                        <div class="credit-card">
                            <div class="cc-top">
                                <div>
                                    <p class="cc-label">Primary Card</p>
                                    <h4 class="cc-title">Visa Platinum</h4>
                                </div>
                                <span class="cc-brand">VISA</span>
                            </div>
                            <p class="cc-number">•••• •••• •••• 4892</p>
                            <div class="cc-foot">
                                <span>Sarah Jenkins</span>
                                <span>Exp: 08/28</span>
                            </div>
                        </div>

                        <div class="wallet-card">
                            <div class="cc-top">
                                <div>
                                    <span class="wallet-tag">Digital Wallet</span>
                                    <h4>Apple Pay / Digital Wallet</h4>
                                </div>
                                <div class="wallet-ic"><i data-lucide="wallet"></i></div>
                            </div>
                            <p class="wallet-note">Connected to sarah.j@example.com</p>
                            <div class="wallet-foot">
                                <span class="active-state"><i data-lucide="check-circle-2"></i> Active</span>
                                <button class="link-rose" onclick="showToast('Wallet disconnected')">Disconnect</button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ===== 6. SETTINGS ===== -->
                <div id="tab-settings" class="tab-content gap-lg hidden">
                    <div>
                        <h2 class="page-title">Account Settings</h2>
                        <p class="page-sub">Manage your profile info, security credentials, and communication preferences</p>
                    </div>

                    <!-- 6A. Personal details -->
                    <div class="settings-card">
                        <div class="settings-head">
                            <div class="section-icon tone-indigo"><i data-lucide="user"></i></div>
                            <div>
                                <h3>Personal Profile</h3>
                                <p>Update avatar and basic contact information</p>
                            </div>
                        </div>

                        <form class="form" action="${pageContext.request.contextPath}/myprofile/update" method="post" enctype="multipart/form-data">

                            <div class="avatar-upload">
                                <img id="settings-avatar-preview" src="${not empty profilePicUrl ? profilePicUrl : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80'}" alt="Avatar">
                                <div>
                                    <div class="avatar-actions">
                                        <label class="file-label">
                                            <span>Change Photo</span>
                                            <input type="file" name="profilePic" accept="image/*" onchange="previewImage(event)">
                                        </label>
                                        <button type="button" class="link-muted" onclick="showToast('Avatar reset to default')">Remove</button>
                                    </div>
                                    <p class="avatar-hint">JPG, PNG or GIF. Max size 2MB.</p>
                                </div>
                            </div>

                            <div class="form-grid">
                                <div>
                                    <label class="label">First Name</label>
                                    <input type="text" name="firstName" id="input-first-name" class="input" value="${sessionScope.userFirstName}" required>
                                </div>
                                <div>
                                    <label class="label">Last Name</label>
                                    <input type="text" name="lastName" id="input-last-name" class="input" value="${sessionScope.userLastName}" required>
                                </div>
                            </div>

                            <div class="form-grid">
                                <div>
                                    <label class="label">Email Address</label>
                                    <div class="input-wrap">
                                        <input type="email" class="input pad-right" value="${sessionScope.userEmail}" readonly required>
                                        <span class="verified"><i data-lucide="check"></i> Verified</span>
                                    </div>
                                </div>
                                <div>
                                    <label class="label">Phone Number</label>
                                    <div class="phone-row">
                                        <select class="country-select">
                                            <option value="+977">🇳🇵 +977</option>
                                            <option value="+1">🇺🇸 +1</option>
                                            <option value="+44">🇬🇧 +44</option>
                                            <option value="+91">🇮🇳 +91</option>
                                        </select>
                                        <div class="input-wrap">
                                            <input type="tel" name="phone" class="input pad-right" value="${sessionScope.userPhone}">
                                            <span class="verified"><i data-lucide="shield-check"></i> Verified</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="form-foot">
                                <button type="submit" class="btn btn-primary btn-lg">Save Personal Details</button>
                            </div>
                        </form>
                    </div>

                    <!-- 6B. Security -->
                    <div class="settings-card">
                        <div class="settings-head">
                            <div class="section-icon tone-amber"><i data-lucide="shield-alert"></i></div>
                            <div>
                                <h3>Security &amp; Password</h3>
                                <p>Update password and configure Two-Factor Authentication</p>
                            </div>
                        </div>

                        <form class="form narrow" onsubmit="handlePasswordChange(event)">
                            <div>
                                <label class="label">Current Password</label>
                                <div class="input-wrap">
                                    <input type="password" id="pass-current" class="input eye-pad" required placeholder="••••••••">
                                    <button type="button" class="eye-btn" onclick="togglePassVisibility('pass-current')" aria-label="Show password"><i data-lucide="eye"></i></button>
                                </div>
                            </div>

                            <div class="form-grid">
                                <div>
                                    <label class="label">New Password</label>
                                    <div class="input-wrap">
                                        <input type="password" id="pass-new" class="input eye-pad" oninput="checkPasswordStrength(this.value)" required placeholder="••••••••">
                                        <button type="button" class="eye-btn" onclick="togglePassVisibility('pass-new')" aria-label="Show password"><i data-lucide="eye"></i></button>
                                    </div>
                                    <div class="strength">
                                        <div class="strength-track"><div id="strength-bar" class="strength-bar"></div></div>
                                        <p id="strength-text" class="strength-text">Strength: Minimum 8 characters</p>
                                    </div>
                                </div>
                                <div>
                                    <label class="label">Confirm New Password</label>
                                    <div class="input-wrap">
                                        <input type="password" id="pass-confirm" class="input eye-pad" required placeholder="••••••••">
                                        <button type="button" class="eye-btn" onclick="togglePassVisibility('pass-confirm')" aria-label="Show password"><i data-lucide="eye"></i></button>
                                    </div>
                                </div>
                            </div>

                            <div class="form-foot">
                                <button type="submit" class="btn btn-dark">Update Password</button>
                            </div>
                        </form>

                        <div class="twofa">
                            <div>
                                <h4>Two-Factor Authentication (2FA)</h4>
                                <p>Add an extra layer of security to your account using SMS or Authenticator app</p>
                            </div>
                            <label class="switch">
                                <input type="checkbox" checked onchange="showToast(this.checked ? 'Two-Factor Auth Enabled' : 'Two-Factor Auth Disabled')">
                                <span class="switch-track"></span>
                            </label>
                        </div>
                    </div>

                    <!-- 6C. Notifications -->
                    <div class="settings-card">
                        <div class="settings-head">
                            <div class="section-icon tone-emerald"><i data-lucide="bell-ring"></i></div>
                            <div>
                                <h3>Notification Preferences</h3>
                                <p>Choose how and when you want to receive alerts and promotional updates</p>
                            </div>
                        </div>

                        <div class="pref-group">
                            <h4 class="pref-group-title">Email Notifications</h4>
                            <div class="pref-list">
                                <div class="pref-row">
                                    <div><b>Order &amp; Delivery Updates</b><span>Receive tracking status changes and order receipts</span></div>
                                    <input type="checkbox" checked onchange="showToast('Email preference updated')">
                                </div>
                                <div class="pref-row">
                                    <div><b>Promotions &amp; Discount Offers</b><span>Special seasonal discounts and member-exclusive flash sales</span></div>
                                    <input type="checkbox" checked onchange="showToast('Email preference updated')">
                                </div>
                                <div class="pref-row">
                                    <div><b>Newsletter &amp; Product Launches</b><span>Weekly digest of trending arrivals and buyer guides</span></div>
                                    <input type="checkbox" onchange="showToast('Email preference updated')">
                                </div>
                            </div>
                        </div>

                        <div class="pref-group">
                            <h4 class="pref-group-title">SMS &amp; WhatsApp Alerts</h4>
                            <div class="pref-list">
                                <div class="pref-row">
                                    <div><b>Instant Delivery SMS</b><span>Get instant SMS code when delivery agent is near</span></div>
                                    <input type="checkbox" checked onchange="showToast('SMS preference updated')">
                                </div>
                                <div class="pref-row">
                                    <div><b>WhatsApp Order Tracking</b><span>Receive live tracking links directly on WhatsApp</span></div>
                                    <input type="checkbox" checked onchange="showToast('WhatsApp preference updated')">
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- 6D. Danger zone -->
                    <div class="danger">
                        <div class="danger-head">
                            <div class="section-icon" style="background: var(--rose-100); color: var(--rose-600);"><i data-lucide="alert-triangle"></i></div>
                            <div>
                                <h3>Danger Zone</h3>
                                <p>Irreversible actions regarding your customer account</p>
                            </div>
                        </div>
                        <p class="danger-text">Deleting your account will permanently clear your reward points (1,450 pts), order history, and saved addresses. This action cannot be undone.</p>
                        <button class="btn btn-danger" onclick="openDeleteModal()">
                            <i data-lucide="trash-2"></i><span>Deactivate or Delete Account</span>
                        </button>
                    </div>
                </div>

            </main>
        </div>
    </div>

    <!-- ============ MODALS ============ -->

    <!-- Order details -->
    <div id="order-modal" class="modal-overlay hidden">
        <div class="modal">
            <button class="modal-close" onclick="closeOrderModal()" aria-label="Close"><i data-lucide="x"></i></button>
            <div class="modal-order-head">
                <div class="modal-order-ic"><i data-lucide="package"></i></div>
                <div>
                    <h3 id="modal-order-id">#ORD-2026-8942</h3>
                    <p id="modal-order-status">Processing</p>
                </div>
            </div>
            <div class="modal-stack">
                <div class="info-box">
                    <div class="info-row"><span>Shipping Address:</span><b>742 Evergreen Terrace</b></div>
                    <div class="info-row"><span>Payment Method:</span><b>Visa ending 4892</b></div>
                </div>
                <div class="total-box">
                    <span class="tl">Total Paid</span>
                    <span id="modal-order-total" class="tv">$148.50</span>
                </div>
            </div>
            <div class="modal-foot">
                <button class="btn btn-gray btn-lg" onclick="closeOrderModal()">Close</button>
            </div>
        </div>
    </div>

    <!-- Add address -->
    <div id="address-modal" class="modal-overlay hidden">
        <div class="modal">
            <button class="modal-close" onclick="closeAddressModal()" aria-label="Close"><i data-lucide="x"></i></button>
            <h3 class="modal-title">Add Shipping Address</h3>
            <form class="form" onsubmit="handleAddressSubmit(event)">
                <div>
                    <label class="label tight">Address Label</label>
                    <input type="text" class="input sm" placeholder="e.g. Home, Office, Vacation House" required>
                </div>
                <div>
                    <label class="label tight">Street Address</label>
                    <input type="text" class="input sm" placeholder="123 Main Street" required>
                </div>
                <div class="form-grid two">
                    <div>
                        <label class="label tight">City</label>
                        <input type="text" class="input sm" placeholder="Seattle" required>
                    </div>
                    <div>
                        <label class="label tight">Zip Code</label>
                        <input type="text" class="input sm" placeholder="98101" required>
                    </div>
                </div>
                <div class="form-foot">
                    <button type="button" class="btn btn-gray" onclick="closeAddressModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Address</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Add payment -->
    <div id="payment-modal" class="modal-overlay hidden">
        <div class="modal">
            <button class="modal-close" onclick="closePaymentModal()" aria-label="Close"><i data-lucide="x"></i></button>
            <h3 class="modal-title">Add Payment Method</h3>
            <form class="form" onsubmit="handlePaymentSubmit(event)">
                <div>
                    <label class="label tight">Cardholder Name</label>
                    <input type="text" class="input sm" placeholder="Sarah Jenkins" required>
                </div>
                <div>
                    <label class="label tight">Card Number</label>
                    <input type="text" class="input sm" placeholder="4532 •••• •••• 8912" required>
                </div>
                <div class="form-grid two">
                    <div>
                        <label class="label tight">Expiry Date</label>
                        <input type="text" class="input sm" placeholder="MM/YY" required>
                    </div>
                    <div>
                        <label class="label tight">CVC / CVV</label>
                        <input type="password" class="input sm" maxlength="4" placeholder="123" required>
                    </div>
                </div>
                <div class="form-foot">
                    <button type="button" class="btn btn-gray" onclick="closePaymentModal()">Cancel</button>
                    <button type="submit" class="btn btn-primary">Add Card</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Delete account -->
    <div id="delete-modal" class="modal-overlay hidden">
        <div class="modal sm">
            <div class="warn-ic"><i data-lucide="octagon-alert"></i></div>
            <h3 class="modal-title">Delete Account?</h3>
            <p class="modal-text">Are you sure you want to delete your profile? All purchase records, saved addresses, and 1,450 loyalty reward points will be permanently lost.</p>
            <div class="modal-foot center">
                <button class="btn btn-gray btn-lg" onclick="closeDeleteModal()">Cancel</button>
                <button class="btn btn-danger" onclick="closeDeleteModal(); showToast('Account deactivation request submitted');">Confirm Delete</button>
            </div>
        </div>
    </div>

    <!-- Toasts -->
    <div id="toast-container"></div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
        document.addEventListener('DOMContentLoaded', function () {
            lucide.createIcons();

            // Show a success toast after redirect back from the profile-save POST
            var params = new URLSearchParams(window.location.search);
            if (params.get('saved') === 'true') {
                showToast('Personal profile saved successfully!');
            }
        });

        // NOTE: In JSP, a dollar sign followed by braces is parsed as EL even inside <script>.
        // Template literals were therefore replaced with string concatenation below.

        // ===== Tabs =====
        function switchTab(tabId) {
            document.querySelectorAll('.tab-content').forEach(function (tab) { tab.classList.add('hidden'); });

            var targetTab = document.getElementById('tab-' + tabId);
            if (targetTab) targetTab.classList.remove('hidden');

            document.querySelectorAll('.nav-btn').forEach(function (btn) {
                btn.classList.toggle('active', btn.dataset.tab === tabId);
            });

            // Close mobile sidebar after navigating
            document.getElementById('sidebar-container').classList.remove('open');

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        // ===== Password =====
        function togglePassVisibility(inputId) {
            var input = document.getElementById(inputId);
            if (input) input.type = input.type === 'password' ? 'text' : 'password';
        }

        function checkPasswordStrength(password) {
            var bar = document.getElementById('strength-bar');
            var text = document.getElementById('strength-text');

            var score = 0;
            if (password.length >= 8) score++;
            if (/[A-Z]/.test(password)) score++;
            if (/[0-9]/.test(password)) score++;
            if (/[^A-Za-z0-9]/.test(password)) score++;

            bar.classList.remove('weak', 'medium', 'strong');

            if (password.length === 0) {
                bar.style.width = '0%';
                text.innerText = 'Strength: Minimum 8 characters';
            } else if (score <= 1) {
                bar.style.width = '25%';
                bar.classList.add('weak');
                text.innerText = 'Strength: Weak';
            } else if (score <= 3) {
                bar.style.width = '60%';
                bar.classList.add('medium');
                text.innerText = 'Strength: Medium';
            } else {
                bar.style.width = '100%';
                bar.classList.add('strong');
                text.innerText = 'Strength: Strong';
            }
        }

        function handlePasswordChange(event) {
            event.preventDefault();
            var newPass = document.getElementById('pass-new').value;
            var confirmPass = document.getElementById('pass-confirm').value;

            if (newPass !== confirmPass) {
                showToast('New passwords do not match!');
                return;
            }

            showToast('Password updated successfully!');
            document.getElementById('pass-current').value = '';
            document.getElementById('pass-new').value = '';
            document.getElementById('pass-confirm').value = '';
            checkPasswordStrength('');
        }

        function previewImage(event) {
            var file = event.target.files[0];
            if (!file) return;
            var reader = new FileReader();
            reader.onload = function (e) {
                var src = e.target.result;
                document.getElementById('settings-avatar-preview').src = src;
                // header-avatar does not exist on this page, so guard against null
                var headerAvatar = document.getElementById('header-avatar');
                if (headerAvatar) headerAvatar.src = src;
                document.getElementById('sidebar-avatar').src = src;
            };
            reader.readAsDataURL(file);
        }

        // ===== Orders =====
        function filterOrders(status, btnElement) {
            document.querySelectorAll('.filter-btn').forEach(function (btn) { btn.classList.remove('active'); });
            btnElement.classList.add('active');

            document.querySelectorAll('.order-card').forEach(function (card) {
                card.style.display = (status === 'all' || card.dataset.status === status) ? 'block' : 'none';
            });
        }

        // ===== Modals =====
        function openOrderModal(id, status, total) {
            document.getElementById('modal-order-id').innerText = id;
            document.getElementById('modal-order-status').innerText = status;
            document.getElementById('modal-order-total').innerText = total;
            document.getElementById('order-modal').classList.remove('hidden');
        }
        function closeOrderModal() { document.getElementById('order-modal').classList.add('hidden'); }

        function openAddressModal() { document.getElementById('address-modal').classList.remove('hidden'); }
        function closeAddressModal() { document.getElementById('address-modal').classList.add('hidden'); }
        function handleAddressSubmit(e) {
            e.preventDefault();
            e.target.reset();
            closeAddressModal();
            showToast('New shipping address saved!');
        }

        function openPaymentModal() { document.getElementById('payment-modal').classList.remove('hidden'); }
        function closePaymentModal() { document.getElementById('payment-modal').classList.add('hidden'); }
        function handlePaymentSubmit(e) {
            e.preventDefault();
            e.target.reset();
            closePaymentModal();
            showToast('New payment card added!');
        }

        function openDeleteModal() { document.getElementById('delete-modal').classList.remove('hidden'); }
        function closeDeleteModal() { document.getElementById('delete-modal').classList.add('hidden'); }

        // Close any modal when clicking the dark backdrop
        document.querySelectorAll('.modal-overlay').forEach(function (overlay) {
            overlay.addEventListener('click', function (e) {
                if (e.target === overlay) overlay.classList.add('hidden');
            });
        });

        // ===== Mobile sidebar =====
        function toggleMobileSidebar() {
            document.getElementById('sidebar-container').classList.toggle('open');
        }

        // ===== Toasts =====
        function showToast(message) {
            var container = document.getElementById('toast-container');
            var toast = document.createElement('div');
            toast.className = 'toast';

            var icon = document.createElement('i');
            icon.setAttribute('data-lucide', 'check-circle-2');
            var text = document.createElement('span');
            text.textContent = message;
            toast.append(icon, text);

            container.appendChild(toast);
            lucide.createIcons();

            setTimeout(function () { toast.classList.add('show'); }, 10);
            setTimeout(function () {
                toast.classList.remove('show');
                setTimeout(function () { toast.remove(); }, 300);
            }, 3000);
        }
    </script>
</body>
</html>