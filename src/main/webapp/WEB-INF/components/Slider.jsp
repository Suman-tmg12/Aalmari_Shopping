<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:if test="${not empty heroSlides}">
<!-- Hero Carousel Banner -->
<div class="hero-banner">
    <div class="hero-slider" id="heroSlider"
         role="region" aria-roledescription="carousel"
         aria-label="Promotional banners" tabindex="0">
        <div class="hero-slider-track" id="heroSliderTrack">
            <c:forEach var="slide" items="${heroSlides}" varStatus="status">
                <div class="hero-slide" role="group" aria-roledescription="slide"
                     aria-label="${status.count} of ${fn:length(heroSlides)}">
                    <img src="<c:out value='${slide.imageUrl}'/>"
                         alt="Promotional banner ${status.count}"
                         draggable="false"
                         <c:if test="${status.first}">fetchpriority="high"</c:if>>
                </div>
            </c:forEach>
        </div>
    </div>

    <!-- Dots -->
    <div class="carousel-dots" id="heroDots">
        <c:forEach var="slide" items="${heroSlides}" varStatus="status">
            <button type="button"
                    class="dot ${status.first ? 'active' : ''}"
                    data-index="${status.index}"
                    aria-label="Go to slide ${status.count}"
                    ${status.first ? 'aria-current="true"' : ''}></button>
        </c:forEach>
    </div>
</div>
</c:if>