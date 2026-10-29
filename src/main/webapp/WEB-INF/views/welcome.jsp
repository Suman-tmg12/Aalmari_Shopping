<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aalmari Full Width E-commerce Design</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/welcome.css?v=3">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
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
                String[] flashIds    = {"himalaya-face-scrub", "wireless-headphone", "classic-black-shoes", "smart-fitness-band", "skin-care-set", "healthy-food-pack", "unhealthy-foods"};
                String[] flashImages = {"HimalayaFaceScrub.jpg","Wireless_headPhone.jpg","ClassicBlackShoes.jpg","SmartFitnessBand.jpg","skincare.jpg","Healthy.jpg","unhealthy-foods.jpg"};
                String[] flashTitles = {"Himalaya Face Scrub", "Wireless Headphone", "Classic Black Shoes", "Smart Fitness Band", "Skin Care Set", "Healthy", "Non-healthy"};
                String[] flashPrices = {"Rs.70", "Rs.70", "Rs.90", "Rs.120", "Rs.150", "Rs.300", "Rs.450"};
                String[] flashOldPrices = {"Rs.150", "Rs.120", "Rs.180", "Rs.240", "Rs.300", "Rs.500", "Rs.500"};
                for(int i = 0; i < flashTitles.length; i++) {
            %>

     <a href="${pageContext.request.contextPath}/flashsaleproduct?id=<%= flashIds[i] %>" style="text-decoration: none; color: inherit;">
         <div class="card-sm">
             <img src="${pageContext.request.contextPath}/HomePageImages/FlashSaleImages/<%= flashImages[i] %>" alt="<%= flashTitles[i] %>">
             <div class="card-title"><%= flashTitles[i] %></div>
             <div class="card-price"><%= flashPrices[i] %> <span><%= flashOldPrices[i] %></span></div>
         </div>
     </a>

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

   <jsp:include page="/WEB-INF/components/product.jsp" />




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
            stopAutoSlide(); // <-- THIS PREVENTS STACKING TIMERS
            autoSlideInterval = setInterval(nextSlide, 3000);
        }

        function stopAutoSlide() {
            clearInterval(autoSlideInterval);
            autoSlideInterval = null;
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