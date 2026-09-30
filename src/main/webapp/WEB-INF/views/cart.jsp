<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Your Cart - Aalmari Store</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cart.css?v=1">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<div class="cart-page">
    <h1 class="cart-title">YOUR CART</h1>

    <div class="cart-container">

        <!-- Cart Items Panel -->
        <div class="cart-items-panel">
            <c:choose>
                <c:when test="${empty cartItems}">
                    <p class="empty-cart">Your cart is empty.</p>
                </c:when>
                <c:otherwise>
                    <c:forEach var="item" items="${cartItems}" varStatus="status">
                        <div class="cart-item">
                            <div class="item-image">
                                <c:if test="${not empty item.imageUrl}">
                                    <img src="${pageContext.request.contextPath}${item.imageUrl}" alt="${item.name}">
                                </c:if>
                            </div>

                            <div class="item-details">
                                <div class="item-top">
                                    <div class="item-info">
                                        <h3 class="item-name">${item.name}</h3>
                                        <p class="item-meta">Size: ${item.size}</p>
                                        <p class="item-meta">Color: ${item.color}</p>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/cart/remove" method="post" class="delete-form">
                                        <input type="hidden" name="itemId" value="${item.id}">
                                        <button type="submit" class="delete-btn" title="Remove item">
                                            <svg viewBox="0 0 24 24" width="18" height="18" fill="none" xmlns="http://www.w3.org/2000/svg">
                                                <path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2m3 0-1 14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2L4 6h16Z"
                                                      stroke="#e74c3c" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"/>
                                            </svg>
                                        </button>
                                    </form>
                                </div>

                                <div class="item-bottom">
                                    <span class="item-price">
                                        <fmt:formatNumber value="${item.price}" type="currency" currencySymbol="$"/>
                                    </span>

                                    <form action="${pageContext.request.contextPath}/cart/update" method="post" class="qty-form">
                                        <input type="hidden" name="itemId" value="${item.id}">
                                        <button type="submit" name="action" value="decrease" class="qty-btn">-</button>
                                        <span class="qty-value">${item.quantity}</span>
                                        <button type="submit" name="action" value="increase" class="qty-btn">+</button>
                                    </form>
                                </div>
                            </div>
                        </div>
                        <c:if test="${!status.last}"><hr class="item-divider"></c:if>
                    </c:forEach>
                </c:otherwise>
            </c:choose>
        </div>

        <!-- Order Summary Panel -->
        <div class="order-summary-panel">
            <h2 class="summary-title">Order Summary</h2>

            <div class="summary-row">
                <span>Subtotal</span>
                <span><fmt:formatNumber value="${subtotal}" type="currency" currencySymbol="$"/></span>
            </div>

            <div class="summary-row">
                <span>Discount (-${discountPercent}%)</span>
                <span class="discount-value">
                    -<fmt:formatNumber value="${discountAmount}" type="currency" currencySymbol="$"/>
                </span>
            </div>

            <div class="summary-row">
                <span>Delivery Fee</span>
                <span><fmt:formatNumber value="${deliveryFee}" type="currency" currencySymbol="$"/></span>
            </div>

            <hr class="summary-divider">

            <div class="summary-row total-row">
                <span>Total</span>
                <span><fmt:formatNumber value="${total}" type="currency" currencySymbol="$"/></span>
            </div>

            <form action="${pageContext.request.contextPath}/checkout" method="get">
                <button type="submit" class="checkout-btn">Go to Checkout</button>
            </form>
        </div>

    </div>
</div>

<jsp:include page="/WEB-INF/components/footer.jsp" />
</body>
</html>