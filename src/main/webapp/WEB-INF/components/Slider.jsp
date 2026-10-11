<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!-- Hero Carousel Banner -->
<div class="hero-banner">
    <div class="hero-slider" id="heroSlider">
        <c:forEach var="slide" items="${heroSlides}" varStatus="status">
            <div class="hero-slide ${status.first ? 'active' : ''}">
                <img src="${slide.imageUrl}" alt="Promotional Banner">
            </div>
        </c:forEach>
    </div>

    <!-- Dots -->
    <div class="carousel-dots" id="heroDots">
        <c:forEach var="slide" items="${heroSlides}" varStatus="status">
            <div class="dot ${status.first ? 'active' : ''}" data-index="${status.index}"></div>
        </c:forEach>
    </div>
</div>