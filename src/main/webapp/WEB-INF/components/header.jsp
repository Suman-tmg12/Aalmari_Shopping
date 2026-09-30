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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css?v=6">
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

        <!-- Categories Trigger (Desktop Mega Menu) -->
        <div class="categories-trigger" id="categoriesTrigger">


            <!-- Mega Menu Panel -->
            <div class="mega-menu" id="megaMenu">
                <ul class="mega-menu-list" id="megaMenuList"></ul>
                <div class="mega-menu-panel" id="megaMenuPanel"></div>
            </div>
        </div>

        <!-- Search Bar Container -->
        <div class="search-container">
            <input type="text" placeholder="Search for products, categories, brands..." class="search-input" aria-label="Search">
            <span class="material-symbols-outlined search-icon" aria-hidden="true">search</span>
        </div>

        <!-- Navigation Icons Container -->
        <div class="nav-icons">

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

    <!-- ===== MOBILE FULL MENU (The Popup) ===== -->
    <div class="mobile-menu-overlay" id="mobileMenuOverlay">
        <div class="mobile-menu" id="mobileMenu">
            <!-- Close Button -->
            <button class="menu-close-btn" id="menuCloseBtn" aria-label="Close menu">&#10005;</button>

            <!-- Menu Links -->
            <nav class="menu-links">

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

                <c:choose>
                    <c:when test="${not empty sessionScope.userId}">
                        <a href="${pageContext.request.contextPath}/profile" class="menu-link">
                            <span class="material-symbols-outlined">person</span>
                            <span class="user-email">${sessionScope.userName}</span>
                        </a>
                        <a href="${pageContext.request.contextPath}/logout" class="menu-link">
                            <span class="material-symbols-outlined">logout</span>
                            Log Out
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="menu-link">
                            <span class="material-symbols-outlined">account_circle</span>
                            My Account
                        </a>
                    </c:otherwise>
                </c:choose>

                <a href="${pageContext.request.contextPath}/support" class="menu-link">
                    <span class="material-symbols-outlined">headset_mic</span>
                    Support
                </a>
            </nav>

            <!-- Footer inside menu -->
            <div class="menu-footer">
                <span>📞 +971 4 XXX XXXX</span>
                <span>📧 support@aalmari.com</span>
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

            function slugify(str) {
                return str.toLowerCase().replace(/&/g, 'and').replace(/[^a-z0-9]+/g, '-').replace(/(^-|-$)/g, '');
            }

            const CTX = '${pageContext.request.contextPath}';

            document.addEventListener('DOMContentLoaded', function () {

                /* Desktop Mega Menu */
                const categoriesTrigger = document.getElementById('categoriesTrigger');
                const megaMenu = document.getElementById('megaMenu');
                const megaList = document.getElementById('megaMenuList');
                const megaPanel = document.getElementById('megaMenuPanel');

                const catNames = Object.keys(categories);

                catNames.forEach((cat, idx) => {
                    const li = document.createElement('li');
                    li.className = 'mega-cat' + (idx === 0 ? ' active' : '');
                    li.textContent = cat;
                    li.dataset.cat = cat;
                    li.addEventListener('mouseenter', () => activateMegaCat(cat));
                    li.addEventListener('click', () => activateMegaCat(cat));
                    megaList.appendChild(li);
                });

                function activateMegaCat(cat) {
                    document.querySelectorAll('.mega-cat').forEach(el => {
                        el.classList.toggle('active', el.dataset.cat === cat);
                    });
                    megaPanel.innerHTML = '';
                    categories[cat].forEach(sub => {
                        const a = document.createElement('a');
                        // FIXED: Changed from /category/slug/slug to ?name=&sub= format
                        a.href = CTX + '/category?name=' + encodeURIComponent(cat) + '&sub=' + encodeURIComponent(sub);
                        a.textContent = sub;
                        a.className = 'mega-sub-link';
                        megaPanel.appendChild(a);
                    });
                }

                if (catNames.length) activateMegaCat(catNames[0]);

                if (categoriesTrigger) {
                    categoriesTrigger.addEventListener('click', function (e) {
                        if (e.target.closest('.mega-menu')) return;
                        megaMenu.classList.toggle('active');
                    });
                }
                document.addEventListener('click', function (e) {
                    if (!categoriesTrigger.contains(e.target)) {
                        megaMenu.classList.remove('active');
                    }
                });

                /* Mobile Categories Accordion */
                const mobileAccordion = document.getElementById('mobileCategoriesAccordion');
                const mobileToggle = document.getElementById('mobileCategoriesToggle');

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
                        // FIXED: Changed from /category/slug/slug to ?name=&sub= format
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

                mobileToggle.addEventListener('click', () => {
                    mobileAccordion.classList.toggle('open');
                    mobileToggle.classList.toggle('open');
                });

                /* Mobile Menu Toggle */
                var overlay = document.getElementById('mobileMenuOverlay');
                var menu = document.getElementById('mobileMenu');
                var openBtn = document.querySelector('.menu-trigger');
                var closeBtn = document.getElementById('menuCloseBtn');

                function setMenu(open) {
                    overlay.classList.toggle('active', open);
                    menu.classList.toggle('active', open);
                }

                if (openBtn) {
                    openBtn.addEventListener('click', function () {
                        setMenu(!menu.classList.contains('active'));
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