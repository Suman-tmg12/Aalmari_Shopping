<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aalmari Store</title>
    <!-- Google Material Symbols for Icons -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/header.css?v=3">
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
        <div class="search-container">
            <input type="text" placeholder="Search for products, categories, brands..." class="search-input" aria-label="Search">
            <span class="material-symbols-outlined search-icon" aria-hidden="true">
                search
            </span>
        </div>

        <!-- Navigation Icons Container -->
        <div class="nav-icons">
           <a href="${pageContext.request.contextPath}/cart" class="icon-item" aria-label="Shopping cart">
            <span class="material-symbols-outlined icon-item">
                local_mall
            </span>
            </a>
            <!-- Hamburger menu trigger -->
            <span class="icon-item" aria-label="Menu">&#9776;</span>
        </div>
    </div>

    <!-- ===== MOBILE FULL MENU (The Popup) ===== -->
    <div class="mobile-menu-overlay" id="mobileMenuOverlay">
        <div class="mobile-menu" id="mobileMenu">
            <!-- Close Button -->
            <button class="menu-close-btn" id="menuCloseBtn" aria-label="Close menu">
                &#10005;
            </button>

            <!-- Menu Links -->
            <nav class="menu-links">
                <a href="${pageContext.request.contextPath}/" class="menu-link">
                    <span class="material-symbols-outlined">home</span>
                    Home
                </a>
                <a href="${pageContext.request.contextPath}/cart" class="menu-link">
                    <span class="material-symbols-outlined">shopping_bag</span>
                    Shop
                </a>
                <a href="${pageContext.request.contextPath}/category" class="menu-link">
                    <span class="material-symbols-outlined">category</span>
                    Categories
                </a>
                <a href="#" class="menu-link">
                    <span class="material-symbols-outlined">local_mall</span>
                    Cart
                </a>
                <a href="${pageContext.request.contextPath}/account" class="menu-link">
                    <span class="material-symbols-outlined">account_circle</span>
                    My Account
                </a>
                <a href="#" class="menu-link">
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

    <!-- JavaScript for Mobile Menu Toggle -->
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var overlay = document.getElementById('mobileMenuOverlay');
            var menu = document.getElementById('mobileMenu');
            // Select the hamburger icon from your existing nav
            var openBtn = document.querySelector('.nav-icons .icon-item[aria-label="Menu"]');
            var closeBtn = document.getElementById('menuCloseBtn');

            // Opens or closes the overlay + panel in one place
            function setMenu(open) {
                overlay.classList.toggle('active', open);
                menu.classList.toggle('active', open);
            }

            // Toggle menu when hamburger is clicked
            if (openBtn) {
                openBtn.addEventListener('click', function () {
                    setMenu(!menu.classList.contains('active'));
                });
            }

            // Close via X button
            if (closeBtn) {
                closeBtn.addEventListener('click', function () {
                    setMenu(false);
                });
            }

            // Close when clicking on the dark overlay outside the menu
            if (overlay) {
                overlay.addEventListener('click', function (e) {
                    if (e.target === overlay) setMenu(false);
                });
            }

            // Close when pressing Escape key
            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') setMenu(false);
            });

            // Close when clicking any link inside the menu
            document.querySelectorAll('.menu-link').forEach(function (link) {
                link.addEventListener('click', function () {
                    setMenu(false);
                });
            });
        });

        // Smooth Scroll for Logo Click
     document.addEventListener('click', function(e) {
         const logoLink = e.target.closest('#logoLink');
         if (!logoLink) return;

         const isFlashPage = window.location.pathname.endsWith('/');
         if (isFlashPage) {
             // On the flash/home page: just scroll to top
             e.preventDefault();
             window.scrollTo({
                 top: 0,
                 behavior: 'smooth'
             });
         } else {
             // On any other page: allow normal navigation to /flash
             // (do nothing, let the link work)
         }
     });
    </script>
</body>
</html>