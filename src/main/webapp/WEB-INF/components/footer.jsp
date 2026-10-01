<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aalmari Store</title>
    <!-- Google Material Symbols for Icons -->
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/footer.css?v=1">
</head>
<body>

    <footer class="footer">
        <div class="footer-grid">
            <div class="footer-col">
                <h3>AALMARI</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/about">About Us</a></li>
                    <li><a href="${pageContext.request.contextPath}/stores">Our Stores</a></li>
                    <li><a href="${pageContext.request.contextPath}/contact">Contact Us</a></li>
                    <li><a href="${pageContext.request.contextPath}/careers">Careers</a></li>
                    <li><a href="${pageContext.request.contextPath}/seller">Sell on Aalmari</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>SHOP</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/category?name=Fashion&sub=Men">Men</a></li>
                    <li><a href="${pageContext.request.contextPath}/category?name=Fashion&sub=Women">Women</a></li>
                    <li><a href="${pageContext.request.contextPath}/category?name=Toys%20%26%20Games&sub=Toys">Kids</a></li>
                    <li><a href="${pageContext.request.contextPath}/category?name=Electronics">New Arrivals</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>CUSTOMER</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/support">Help Center</a></li>
                    <li><a href="${pageContext.request.contextPath}/support">FAQs</a></li>
                    <li><a href="${pageContext.request.contextPath}/shipping">Shipping</a></li>
                    <li><a href="${pageContext.request.contextPath}/returns">Returns</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>MY ACCOUNT</h3>
                <ul>
                    <li><a href="${pageContext.request.contextPath}/myProfile">My Profile</a></li>
                    <li><a href="${pageContext.request.contextPath}/orders">My Orders</a></li>
                    <li><a href="${pageContext.request.contextPath}/wishlist">Wishlist</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart">Cart</a></li>
                </ul>
            </div>
            <div class="footer-col">
                <h3>CONTACT US</h3>
                <ul>
                    <li>Kathmandu, Nepal</li>
                    <li>+977-98XXXXXXXX</li>
                    <li><a href="mailto:support@aalmari.com">support@aalmari.com</a></li>
                </ul>
            </div>
            <div class="footer-col newsletter-box">
                <h3>NEWSLETTER</h3>
                <form action="${pageContext.request.contextPath}/subscribe" method="post">
                    <input type="email" name="email" placeholder="Your email address" aria-label="Email for newsletter" required>
                    <button type="submit">Submit</button>
                </form>
            </div>
        </div>
        <div class="footer-bottom">
            <span>Privacy | Terms | Return Policy</span>
            <span>&copy; 2026 Aalmari Shopping</span>
        </div>
    </footer>

</body>
</html>