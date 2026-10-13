<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aalmari Store</title>
    <!-- Google Material Symbols for Icons -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css?v=10">
</head>
<body>

    <!-- Top Navigation Bar -->
    <div class="top-nav">
        <!-- Logo Container -->
        <div class="logo-container">
            <a href="${pageContext.request.contextPath}/" id="logoLink">
                <img src="${pageContext.request.contextPath}/HomePageImages/logoImages/logo.png" alt="Aalmari Logo" class="logo-img">
            </a>
        </div>

        <!-- Search Bar Container -->
        <form action="${pageContext.request.contextPath}/searchResult" method="GET" class="search-container" id="searchForm">
            <input type="text"
                   name="q"
                   value="${param.q}"
                   placeholder="Search for products, categories, brands..."
                   class="search-input"
                   aria-label="Search"
                   required
                   autocomplete="off">
            <button type="submit" class="search-btn-submit" aria-label="Submit search">
                <span class="material-symbols-outlined search-icon" aria-hidden="true">search</span>
            </button>
        </form>

        <!-- Navigation Icons & User Section Container -->
        <div class="nav-icons">

            <!-- Account Dropdown Section -->
            <div class="account-dropdown-container">
                <c:choose>
                    <c:when test="${not empty sessionScope.userId}">
                        <!-- Logged In Trigger Button -->
                        <div class="account-trigger">
                            <span class="material-symbols-outlined icon-item">account_circle</span>
                            <span class="user-name">${sessionScope.userFirstName}</span>
                            <span class="material-symbols-outlined dropdown-arrow" style="color: white">expand_more</span>
                        </div>
                        <!-- Dropdown Menu (Appears on Hover) -->
                        <div class="account-dropdown-menu">
                            <div class="dropdown-header">
                                <span class="greeting">Hello,</span>
                                <strong class="user-display-name">
                                  <c:choose>
                                    <c:when test="${not empty sessionScope.userFirstName or not empty sessionScope.userLastName}">
                                      <c:out value="${sessionScope.userFirstName}" /> <c:out value="${sessionScope.userLastName}" />
                                    </c:when>
                                    <c:otherwise>
                                      Guest
                                    </c:otherwise>
                                  </c:choose>
                                </strong>
                            </div>
                            <div class="dropdown-divider"></div>
                            <a href="${pageContext.request.contextPath}/myprofile" class="dropdown-item">
                                <span class="material-symbols-outlined">person</span>
                                My Profile
                            </a>
                            <a href="${pageContext.request.contextPath}/logout" class="dropdown-item logout-item">
                                <span class="material-symbols-outlined">logout</span>
                                Log Out
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <!-- Not Logged In Button -->
                        <a href="${pageContext.request.contextPath}/login" class="account-trigger guest-trigger" title="Log In / Sign Up">
                            <span class="material-symbols-outlined icon-item">account_circle</span>
                            <span class="login-label">Login</span>
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>

            <!-- Cart Icon with Badge -->
            <a href="${pageContext.request.contextPath}/cart" class="icon-link" aria-label="Shopping cart">
                <span class="material-symbols-outlined icon-item">local_mall</span>
                <c:if test="${not empty sessionScope.cartItemCount && sessionScope.cartItemCount > 0}">
                    <span class="cart-badge">${sessionScope.cartItemCount}</span>
                </c:if>
            </a>

            <!-- Hamburger menu trigger -->
            <span class="icon-item menu-trigger" aria-label="Menu">&#9776;</span>
        </div>
    </div>

    <!-- ===== MOBILE FULL MENU ===== -->
    <div class="mobile-menu-overlay" id="mobileMenuOverlay">
        <div class="mobile-menu" id="mobileMenu">
            <!-- Close Button -->
            <button class="menu-close-btn" id="menuCloseBtn" aria-label="Close menu">&#10005;</button>

            <!-- Menu Links -->
            <nav class="menu-links">
                <!-- User Profile Header inside Mobile Menu -->
                <c:choose>
                    <c:when test="${not empty sessionScope.userId}">
                        <a href="${pageContext.request.contextPath}/myprofile" class="menu-link user-mobile-card">
                            <span class="material-symbols-outlined">account_circle</span>
                            <div>
                                <span class="mobile-user-greeting">Welcome back,</span>
                                <strong class="user-display-name">
                                  <c:choose>
                                    <c:when test="${not empty sessionScope.userFirstName or not empty sessionScope.userLastName}">
                                      <c:out value="${sessionScope.userFirstName}" /> <c:out value="${sessionScope.userLastName}" />
                                    </c:when>
                                    <c:otherwise>
                                      Guest
                                    </c:otherwise>
                                  </c:choose>
                                </strong>
                            </div>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="menu-link">
                            <span class="material-symbols-outlined">account_circle</span>
                            Login / Register
                        </a>
                    </c:otherwise>
                </c:choose>

                <!-- Categories accordion trigger -->
                <div class="menu-link categories-accordion-toggle" id="mobileCategoriesToggle">
                    <span class="material-symbols-outlined">category</span>
                    Categories
                    <span class="material-symbols-outlined chevron">expand_more</span>
                </div>
                <!-- Nested accordion renders here -->
                <div class="mobile-categories-accordion" id="mobileCategoriesAccordion"></div>

                <a href="${pageContext.request.contextPath}/cart" class="menu-link">
                    <span class="material-symbols-outlined">local_mall</span>
                    Cart
                </a>

                <a href="${pageContext.request.contextPath}/support" class="menu-link">
                    <span class="material-symbols-outlined">headset_mic</span>
                    Support
                </a>

                <c:if test="${not empty sessionScope.userId}" >
                    <a href="${pageContext.request.contextPath}/logout" class="menu-link mobile-logout-link" style="color: #FF7B00">
                        <span class="material-symbols-outlined" style="color: #FF7B00">logout</span>
                        Log Out
                    </a>
                </c:if>
            </nav>

            <!-- Footer inside menu -->
            <div class="menu-footer">
                <div style="display: flex; gap: 10px"><span class="material-symbols-outlined">call</span> +971 4 XXX XXXX</div>
                <div style="display: flex; gap: 10px"><span class="material-symbols-outlined">mail</span> support@aalmari.com</div>
            </div>
        </div>
    </div>

    <!-- JavaScript -->
    <script>
        const categories = {
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

        const CTX = '${pageContext.request.contextPath}';

        document.addEventListener('DOMContentLoaded', function () {
            const catNames = Object.keys(categories);

            /* Mobile Categories Accordion */
            const mobileAccordion = document.getElementById('mobileCategoriesAccordion');
            const mobileToggle = document.getElementById('mobileCategoriesToggle');

            if (mobileAccordion) {
                catNames.forEach(cat => {
                    const wrap = document.createElement('div');
                    wrap.className = 'mobile-cat-group';

                    const header = document.createElement('div');
                    header.className = 'mobile-cat-header';
                    header.innerHTML = '<span>' + cat + '</span><span class="material-symbols-outlined chevron">expand_more</span>';

                    const subList = document.createElement('div');
                    subList.className = 'mobile-sub-list';
                    categories[cat].forEach(sub => {
                        const a = document.createElement('a');
                        a.href = CTX + '/category?name=' + encodeURIComponent(cat) + '&sub=' + encodeURIComponent(sub);
                        a.className = 'menu-link mobile-sub-link';
                        a.textContent = sub;
                        subList.appendChild(a);
                    });

                    header.addEventListener('click', () => {
                        const isOpen = wrap.classList.contains('open');
                        document.querySelectorAll('.mobile-cat-group.open').forEach(g => g.classList.remove('open'));
                        if (!isOpen) wrap.classList.add('open');
                    });

                    wrap.appendChild(header);
                    wrap.appendChild(subList);
                    mobileAccordion.appendChild(wrap);
                });
            }

            if (mobileToggle && mobileAccordion) {
                mobileToggle.addEventListener('click', () => {
                    mobileAccordion.classList.toggle('open');
                    mobileToggle.classList.toggle('open');
                });
            }

            /* Mobile Menu Toggle */
            var overlay = document.getElementById('mobileMenuOverlay');
            var menu = document.getElementById('mobileMenu');
            var openBtn = document.querySelector('.menu-trigger');
            var closeBtn = document.getElementById('menuCloseBtn');

            function setMenu(open) {
                if (overlay) overlay.classList.toggle('active', open);
                if (menu) menu.classList.toggle('active', open);
            }

            if (openBtn) {
                openBtn.addEventListener('click', function () {
                    if (menu) setMenu(!menu.classList.contains('active'));
                });
            }

            if (closeBtn) {
                closeBtn.addEventListener('click', function () {
                    setMenu(false);
                });
            }

            if (overlay) {
                overlay.addEventListener('click', function (e) {
                    if (e.target === overlay) setMenu(false);
                });
            }

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') setMenu(false);
            });

            document.querySelectorAll('.menu-link:not(.categories-accordion-toggle)').forEach(function (link) {
                link.addEventListener('click', function () {
                    setMenu(false);
                });
            });

            /* Smooth Scroll for Logo */
            document.addEventListener('click', function(e) {
                const logoLink = e.target.closest('#logoLink');
                if (!logoLink) return;
                const isFlashPage = window.location.pathname.endsWith('/');
                if (isFlashPage) {
                    e.preventDefault();
                    window.scrollTo({ top: 0, behavior: 'smooth' });
                }
            });
        });
    </script>
</body>
</html>