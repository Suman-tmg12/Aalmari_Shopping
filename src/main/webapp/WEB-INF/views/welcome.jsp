<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aalmari Full Width E-commerce Design</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/welcome.css?v=3">
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/HomePageImages/logoImages/logo.png">
</head>
<body>
<div class="main-wrapper" id="top">

    <!-- Header -->
    <jsp:include page="/WEB-INF/components/header.jsp" />
    <!-- Header -->

    <!-- Hero Carousel Banner -->
    <jsp:include page="/WEB-INF/components/Slider.jsp" />
    <!-- Hero Carousel Banner -->

    <!-- Flash Sale Section -->
    <div class="section-header">
        <span class="section-title">Flash Sale</span>
        <a href="${pageContext.request.contextPath}/flash" class="section-more">more</a>
    </div>
    <div class="flash-sale-wrapper">
        <div class="flash-sale-box">
            <div class="horizontal-scroll">
                <%
                    String[] flashImages = {"HimalayaFaceScrub.jpg","Wireless_headPhone.jpg","ClassicBlackShoes.jpg","SmartFitnessBand.jpg","skincare.jpg","Healthy.jpg","unhealthy-foods.jpg"};
                    String[] flashTitles = {"Himalaya Face Scrub", "Wireless Headphone", "Classic Black Shoes", "Smart Fitness Band", "Skin Care Set", "Healthy", "Non-healthy"};
                    String[] flashPrices = {"Rs.70", "Rs.70", "Rs.90", "Rs.120", "Rs.150", "Rs.300", "Rs.450"};
                    String[] flashOldPrices = {"Rs.150", "Rs.120", "Rs.180", "Rs.240", "Rs.300", "Rs.500", "Rs.500"};
                    for(int i = 0; i < flashTitles.length; i++) {
                %>
                <div class="card-sm">
                    <img src="${pageContext.request.contextPath}/HomePageImages/FlashSaleImages/<%= flashImages[i] %>" alt="<%= flashTitles[i] %>">
                    <div class="card-title"><%= flashTitles[i] %></div>
                    <div class="card-price"><%= flashPrices[i] %> <span><%= flashOldPrices[i] %></span></div>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <!-- Categories Section -->
    <div class="section-header">
        <span class="section-title">Categories</span>
        <a href="${pageContext.request.contextPath}/category" class="section-more">more</a>
    </div>

       <div class="categories-grid">
           <%
               // Just add your category names here. The code below handles the rest for ALL of them.
               String[] cats = {"Electronics", "Fashion", "Home & Living", "Groceries", "Beauty & Personal Care", "Toys & Games"};
               String[] catImages = {"Electronics.jpg", "fashion.jpg", "home&living.jpg", "grocories.jpg", "beauty.jpg", "toys.jpg"};

               for(int i = 0; i < cats.length; i++) {
                   // This single logic works for EVERY category in the list above
                   String contextPath = request.getContextPath();
                   String encodedCategory = java.net.URLEncoder.encode(cats[i], "UTF-8");
                   String categoryUrl = contextPath + "/category?name=" + encodedCategory;
           %>
               <a href="<%= categoryUrl %>" class="cat-card-link" style="text-decoration: none; display: block;">
                   <div class="cat-card">
                       <img src="<%= contextPath %>/HomePageImages/category/<%= catImages[i] %>" alt="Category">
                       <div class="cat-name"><%= cats[i] %></div>
                   </div>
               </a>
           <% } %>
       </div>

    <!-- Products Grid Section -->
    <div class="section-header">
        <span class="section-title">Products</span>
    </div>
    <div class="products-grid">
        <%
            String[] prods = {"Hair Spray", "OLIPOP Cherry", "Nike Shoes", "Black Glasses", "White Spray", "Falcon Spray", "iPhone 15 Pro", "MacBook Pro M3", "AirPods Pro"};
            String[] prodImages = {"hairSpray.jpg", "olipop.jpg", "nikeShoe.jpg", "BlackGlass.jpg", "WhiteSpray.jpg", "FalconSpray.jpg", "iphone15pro.jpg", "MacBookProm3.jpg", "Airpods.jpg"};
            String[] prodPrices = {"Rs.70", "Rs.120", "Rs.200", "Rs.90", "Rs.80", "Rs.110", "Rs.1500", "Rs.2200", "Rs.250"};
            String[] prodSold = {"4.5k sold", "3.2k sold", "8.1k sold", "2.3k sold", "1.8k sold", "5.6k sold", "12.4k sold", "9.7k sold", "15.2k sold"};
            for(int i = 0; i < prods.length; i++) {
        %>
        <div class="product-card">
            <div>
                <img src="${pageContext.request.contextPath}/HomePageImages/Products/<%= prodImages[i] %>" alt="<%= prods[i] %>">
                <div class="product-meta">
                    <div class="product-name"><%= prods[i] %></div>
                    <div class="product-price-row">
                        <span class="product-price"><%= prodPrices[i] %></span>
                        <span class="product-tag"><%= prodSold[i] %></span>
                    </div>
                </div>
            </div>
        </div>
        <% } %>
    </div>

    <!-- Pagination -->
    <div class="pagination">
        <span>&lt; Previous</span>
        <span class="active">1</span>
        <span>2</span>
        <span>3</span>
        <span>...</span>
        <span>7</span>
        <span>Next &gt;</span>
    </div>

    <!-- Footer Section -->
    <jsp:include page="/WEB-INF/components/footer.jsp" />

</div>

<!-- ===== JAVASCRIPT ===== -->
<script>
    // Search focus
    document.addEventListener('click', function(event) {
        const searchContainer = event.target.closest('.search-container');
        const searchIcon = event.target.closest('.search-icon');
        if (searchContainer || searchIcon) {
            const container = searchContainer || searchIcon.closest('.search-container');
            const input = container.querySelector('.search-input');
            if (input) {
                input.focus();
            }
        }
    });

    // ========== HERO SLIDER ==========
    (function() {
        const slides = document.querySelectorAll('.hero-slide');
        const dots = document.querySelectorAll('.dot');
        let currentIndex = 0;
        let autoSlideInterval;

        function showSlide(index) {
            slides.forEach(slide => slide.classList.remove('active'));
            dots.forEach(dot => dot.classList.remove('active'));

            slides[index].classList.add('active');
            dots[index].classList.add('active');
            currentIndex = index;
        }

        function nextSlide() {
            let nextIndex = (currentIndex + 1) % slides.length;
            showSlide(nextIndex);
        }

        function startAutoSlide() {
            autoSlideInterval = setInterval(nextSlide, 3000); // change 3000 to 1000 if you want 1 second
        }

        function stopAutoSlide() {
            clearInterval(autoSlideInterval);
        }

        // Dot click
        dots.forEach(dot => {
            dot.addEventListener('click', function() {
                const index = parseInt(this.getAttribute('data-index'));
                showSlide(index);
                stopAutoSlide();
                startAutoSlide();
            });
        });

        // Pause on hover
        const slider = document.getElementById('heroSlider');
        if (slider) {
            slider.addEventListener('mouseenter', stopAutoSlide);
            slider.addEventListener('mouseleave', startAutoSlide);
        }

        startAutoSlide();
    })();
</script>
</body>
</html>