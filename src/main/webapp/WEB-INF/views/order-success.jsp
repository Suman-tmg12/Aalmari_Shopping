<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<c:if test="${empty sessionScope.userId}">
    <c:redirect url="/login" />
</c:if>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order placed - Aalmari Store</title>
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/checkout.css?v=2">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<div class="co-page">

    <ol class="co-steps" aria-label="Checkout progress">
        <li class="done"><span class="dot">&#10003;</span> Cart</li>
        <li class="done"><span class="dot">&#10003;</span> Delivery &amp; payment</li>
        <li class="current"><span class="dot">&#10003;</span> Order placed</li>
    </ol>

    <section class="ok-hero">
        <div class="ok-icon" aria-hidden="true">&#10003;</div>
        <h1>Thank you, your order is placed</h1>
        <p>Order <strong><c:out value="${order.orderNumber}"/></strong>
           <c:if test="${order.paymentMethod == 'COD'}">&middot; pay <strong>Rs <fmt:formatNumber value="${order.total}" maxFractionDigits="0"/></strong> in cash when it arrives</c:if>
        </p>
    </section>

    <div class="co-layout">
        <div class="co-main">
            <section class="co-card">
                <h2 class="co-card-title">Items</h2>
                <ul class="sum-items" style="max-height:none">
                    <c:forEach var="item" items="${order.items}">
                        <li>
                            <div class="sum-img">
                                <c:if test="${not empty item.imageUrl}"><img src="${item.imageUrl}" alt=""></c:if>
                                <span class="sum-qty">${item.quantity}</span>
                            </div>
                            <span class="sum-name"><c:out value="${item.name}"/></span>
                            <span class="sum-price">Rs <fmt:formatNumber value="${item.lineTotal}" maxFractionDigits="0"/></span>
                        </li>
                    </c:forEach>
                </ul>
            </section>

            <section class="co-card">
                <h2 class="co-card-title">Delivering to</h2>
                <p class="ok-line"><strong><c:out value="${order.receiverName}"/></strong> &middot; <c:out value="${order.receiverPhone}"/></p>
                <p class="ok-line">
                    <c:out value="${order.address}"/>,
                    <c:out value="${order.city}"/>, <c:out value="${order.province}"/>
                </p>
                <c:if test="${not empty order.landmark}">
                    <p class="ok-line muted">Landmark: <c:out value="${order.landmark}"/></p>
                </c:if>
                <p class="ok-line muted">Usually arrives in 2&ndash;5 days. We'll send an SMS when it ships.</p>
            </section>
        </div>

        <aside class="co-summary">
            <h2 class="co-card-title">Payment</h2>
            <div class="sum-row">
                <span>Method</span>
                <span>
                    <c:choose>
                        <c:when test="${order.paymentMethod == 'COD'}">Cash on delivery</c:when>
                        <c:when test="${order.paymentMethod == 'ESEWA'}">eSewa</c:when>
                        <c:when test="${order.paymentMethod == 'KHALTI'}">Khalti</c:when>
                        <c:otherwise>Card</c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="sum-row">
                <span>Subtotal</span>
                <span>Rs <fmt:formatNumber value="${order.subtotal}" maxFractionDigits="0"/></span>
            </div>
            <c:if test="${order.discountAmount > 0}">
                <div class="sum-row">
                    <span>Discount</span>
                    <span class="green">-Rs <fmt:formatNumber value="${order.discountAmount}" maxFractionDigits="0"/></span>
                </div>
            </c:if>
            <div class="sum-row">
                <span>Delivery fee</span>
                <span>Rs <fmt:formatNumber value="${order.deliveryFee}" maxFractionDigits="0"/></span>
            </div>
            <div class="sum-row sum-total">
                <span>Total</span>
                <span>Rs <fmt:formatNumber value="${order.total}" maxFractionDigits="0"/></span>
            </div>

            <a class="place-btn ok-btn" href="${pageContext.request.contextPath}/">Continue shopping</a>
        </aside>
    </div>
</div>

<jsp:include page="/WEB-INF/components/footer.jsp" />
</body>
</html>
