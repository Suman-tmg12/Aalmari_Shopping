<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- Redirect to login page if session is empty --%>
<c:if test="${empty sessionScope.userId}">
    <c:redirect url="/login" />
</c:if>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Your Cart - Aalmari Store</title>
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/cart.css?v=2">
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
                                    <a href="${pageContext.request.contextPath}/product/${item.productId}">
                                        <img src="${item.imageUrl}" alt="<c:out value='${item.name}'/>">
                                    </a>
                                </c:if>
                            </div>

                            <div class="item-details">
                                <div class="item-top">
                                    <div class="item-info">
                                        <h3 class="item-name">
                                            <a href="${pageContext.request.contextPath}/product/${item.productId}"
                                               style="color:inherit; text-decoration:none;">
                                                <c:out value="${item.name}"/>
                                            </a>
                                        </h3>
                                        <c:if test="${item.originalPrice > item.unitPrice}">
                                            <p class="item-meta" style="text-decoration:line-through;">
                                                Rs <fmt:formatNumber value="${item.originalPrice}" maxFractionDigits="0"/>
                                            </p>
                                        </c:if>
                                    </div>

                                    <form action="${pageContext.request.contextPath}/cart/remove" method="post" class="delete-form js-cart-form">
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
                                        Rs <fmt:formatNumber value="${item.unitPrice}" maxFractionDigits="0"/>
                                    </span>

                                    <form action="${pageContext.request.contextPath}/cart/update" method="post" class="qty-form js-cart-form">
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
                <span>Rs <fmt:formatNumber value="${subtotal}" maxFractionDigits="0"/></span>
            </div>

            <c:if test="${discountAmount > 0}">
                <div class="summary-row">
                    <span>Discount (-${discountPercent}%)</span>
                    <span class="discount-value">
                        -Rs <fmt:formatNumber value="${discountAmount}" maxFractionDigits="0"/>
                    </span>
                </div>
            </c:if>

            <div class="summary-row">
                <span>Delivery Fee</span>
                <span>Rs <fmt:formatNumber value="${deliveryFee}" maxFractionDigits="0"/></span>
            </div>

            <hr class="summary-divider">

            <div class="summary-row total-row">
                <span>Total</span>
                <span>Rs <fmt:formatNumber value="${total}" maxFractionDigits="0"/></span>
            </div>

            <form action="${pageContext.request.contextPath}/checkout" method="get">
                <button type="submit" class="checkout-btn"
                        <c:if test="${empty cartItems}">disabled</c:if>>Go to Checkout</button>
            </form>
        </div>

    </div>
</div>

<jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
    // Remove / quantity buttons are sent with fetch() and the page is reloaded with
    // location.replace(), which swaps the current history entry instead of adding a new one
    // (so Back doesn't have to be pressed once per click).
    //
    // IMPORTANT: the quantity form has buttons named "action", so form.action returns the
    // <button> element instead of the URL. Always use form.getAttribute('action') here.
    (function () {
        var CART_URL = '${pageContext.request.contextPath}/cart';
        var busy = false;

        document.querySelectorAll('.js-cart-form').forEach(function (form) {
            form.addEventListener('submit', function (e) {
                e.preventDefault();
                if (busy) return;
                busy = true;

                var btn = e.submitter;   // the button that was clicked (decrease / increase / delete)
                var params = new URLSearchParams();
                new FormData(form).forEach(function (v, k) { params.append(k, v); });
                // the clicked button is not part of FormData, add it by hand
                if (btn && btn.name) params.append(btn.name, btn.value);

                var url = form.getAttribute('action');

                fetch(url, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                    body: params.toString(),
                    credentials: 'same-origin'
                }).then(function (res) {
                    if (!res.ok) throw new Error('HTTP ' + res.status);
                    location.replace(CART_URL);
                }).catch(function (err) {
                    console.error('[cart] request failed, falling back to normal submit', err);
                    busy = false;
                    // form.submit() does not send the clicked button's name/value, so re-add it
                    if (btn && btn.name) {
                        var h = document.createElement('input');
                        h.type = 'hidden';
                        h.name = btn.name;
                        h.value = btn.value;
                        form.appendChild(h);
                    }
                    // form.submit can also be shadowed by a child named "submit", so call it safely
                    HTMLFormElement.prototype.submit.call(form);
                });
            });
        });
    })();
</script>
</body>
</html>
