<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

  <!-- Hero Carousel Banner -->
    <div class="hero-banner">
        <div class="hero-slider" id="heroSlider">
            <!-- Slide 1 -->
            <div class="hero-slide active">
                <img src="${pageContext.request.contextPath}/HomePageImages/SliderImages/HeroSlider1.jpg"
                     alt="Promotional Banner - Special Offers">
            </div>

            <!-- Slide 2 -->
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/HomePageImages/SliderImages/HeroSlider2.jpg"
                     alt="New Arrivals">
            </div>

            <!-- Slide 3 -->
            <div class="hero-slide">
                <img src="${pageContext.request.contextPath}/HomePageImages/SliderImages/HeroSlider3.jpg"
                     alt="Flash Sale">
            </div>
        </div>

        <!-- Dots -->
        <div class="carousel-dots" id="heroDots">
            <div class="dot active" data-index="0"></div>
            <div class="dot" data-index="1"></div>
            <div class="dot" data-index="2"></div>
        </div>
    </div>
