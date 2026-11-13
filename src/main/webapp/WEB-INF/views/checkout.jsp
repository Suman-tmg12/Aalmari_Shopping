<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%-- Redirect to login page if session is empty --%>
<c:if test="${empty sessionScope.userId}">
    <c:redirect url="/login" />
</c:if>
<%-- Nothing to pay for: send back to cart --%>
<c:if test="${empty cartItems}">
    <c:redirect url="/cart" />
</c:if>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - Aalmari Store</title>
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/checkout.css?v=2">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

<div class="co-page">

    <!-- Progress -->
    <ol class="co-steps" aria-label="Checkout progress">
        <li class="done"><span class="dot">&#10003;</span> Cart</li>
        <li class="current"><span class="dot">2</span> Delivery &amp; payment</li>
        <li><span class="dot">3</span> Order placed</li>
    </ol>

    <h1 class="co-title">Checkout</h1>

    <c:if test="${not empty checkoutError}">
        <div class="co-alert" role="alert"><c:out value="${checkoutError}"/></div>
    </c:if>

    <form id="checkoutForm" class="co-layout" action="${pageContext.request.contextPath}/checkout/place"
          method="post" novalidate>

        <!-- ============ LEFT: details ============ -->
        <div class="co-main">

            <!-- 1. Delivery address -->
            <section class="co-card">
                <h2 class="co-card-title">Delivery address</h2>

                <div class="grid-2">
                    <div class="field">
                        <label for="fullName">Full name</label>
                        <input id="fullName" name="fullName" type="text" autocomplete="name" required
                               value="<c:out value='${prefill.fullName}'/>">
                        <small class="err">Enter the receiver's name.</small>
                    </div>
                    <div class="field">
                        <label for="phone">Mobile number</label>
                        <input id="phone" name="phone" type="tel" inputmode="numeric" autocomplete="tel"
                               placeholder="98XXXXXXXX" maxlength="10" pattern="9[678][0-9]{8}" required
                               value="<c:out value='${prefill.phone}'/>">
                        <small class="err">Enter a 10-digit mobile number starting with 96, 97 or 98.</small>
                    </div>
                </div>

                <div class="grid-2">
                    <div class="field">
                        <label for="province">Province</label>
                        <select id="province" name="province" required>
                            <option value="" selected disabled>Select province</option>
                            <option>Koshi</option>
                            <option>Madhesh</option>
                            <option>Bagmati</option>
                            <option>Gandaki</option>
                            <option>Lumbini</option>
                            <option>Karnali</option>
                            <option>Sudurpashchim</option>
                        </select>
                        <small class="err">Select a province.</small>
                    </div>
                    <div class="field">
                        <label for="city">City / municipality</label>
                        <input id="city" name="city" type="text" autocomplete="address-level2"
                               placeholder="e.g. Kathmandu" required>
                        <small class="err">Enter your city or municipality.</small>
                    </div>
                </div>

                <div class="field">
                    <label for="address">Street address</label>
                    <input id="address" name="address" type="text" autocomplete="street-address"
                           placeholder="Ward no., tole, house number" required>
                    <small class="err">Enter your street address.</small>
                </div>

                <div class="field">
                    <label for="landmark">Landmark <span class="opt">(optional)</span></label>
                    <input id="landmark" name="landmark" type="text" placeholder="Near a temple, school, shop...">
                </div>
            </section>

            <!-- 2. Delivery -->
            <section class="co-card">
                <h2 class="co-card-title">Delivery</h2>
                <div class="deliv">
                    <svg viewBox="0 0 24 24" width="22" height="22" fill="none" stroke="currentColor"
                         stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                        <path d="M3 7h11v9H3zM14 10h4l3 3v3h-7zM7 19a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3zM17 19a1.5 1.5 0 1 0 0-3 1.5 1.5 0 0 0 0 3z"/>
                    </svg>
                    <div>
                        <strong>Standard delivery</strong>
                        <p>Usually arrives in 2&ndash;5 days. You'll get an SMS when your order ships.</p>
                    </div>
                    <span class="deliv-fee">Rs <fmt:formatNumber value="${deliveryFee}" maxFractionDigits="0"/></span>
                </div>
            </section>

            <!-- 3. Payment -->
            <section class="co-card">
                <h2 class="co-card-title">Payment method</h2>

                <div class="pay-list" role="radiogroup" aria-label="Payment method">

                    <label class="pay-option">
                        <input type="radio" name="paymentMethod" value="COD" checked>
                        <span class="pay-head">
                            <span class="pay-logo cod">Rs</span>
                            <span class="pay-name">Cash on delivery
                                <small>Pay in cash when your order arrives</small></span>
                        </span>
                        <span class="pay-body">
                            Keep the exact amount ready. The rider can't always carry change.
                        </span>
                    </label>

                    <label class="pay-option">
                        <input type="radio" name="paymentMethod" value="ESEWA">
                        <span class="pay-head">
                            <span class="pay-logo esewa">e</span>
                            <span class="pay-name">eSewa
                                <small>Pay with your eSewa wallet</small></span>
                        </span>
                        <span class="pay-body">
                            You'll be taken to eSewa to approve the payment, then brought back here.
                        </span>
                    </label>

                    <label class="pay-option">
                        <input type="radio" name="paymentMethod" value="KHALTI">
                        <span class="pay-head">
                            <span class="pay-logo khalti">K</span>
                            <span class="pay-name">Khalti
                                <small>Pay with your Khalti wallet</small></span>
                        </span>
                        <span class="pay-body">
                            You'll be taken to Khalti to approve the payment, then brought back here.
                        </span>
                    </label>

                    <label class="pay-option">
                        <input type="radio" name="paymentMethod" value="CARD">
                        <span class="pay-head">
                            <span class="pay-logo card">
                                <svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor"
                                     stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                                    <rect x="2.5" y="5" width="19" height="14" rx="2"/><path d="M2.5 10h19"/>
                                </svg>
                            </span>
                            <span class="pay-name">Debit / credit card
                                <small>Visa, Mastercard</small></span>
                        </span>
                        <span class="pay-body card-fields">
                            <span class="field">
                                <span class="lbl">Card number</span>
                                <input id="cardNumber" type="text" inputmode="numeric" autocomplete="cc-number"
                                       placeholder="1234 5678 9012 3456" maxlength="19">
                            </span>
                            <span class="field">
                                <span class="lbl">Name on card</span>
                                <input id="cardName" type="text" autocomplete="cc-name">
                            </span>
                            <span class="grid-2">
                                <span class="field">
                                    <span class="lbl">Expiry</span>
                                    <input id="cardExp" type="text" inputmode="numeric" autocomplete="cc-exp"
                                           placeholder="MM/YY" maxlength="5">
                                </span>
                                <span class="field">
                                    <span class="lbl">CVV</span>
                                    <input id="cardCvv" type="password" inputmode="numeric" autocomplete="cc-csc"
                                           placeholder="123" maxlength="4">
                                </span>
                            </span>
                            <span class="secure-note">Card details are sent to the payment provider and never stored on our servers.</span>
                        </span>
                    </label>

                </div>
            </section>

            <!-- Order note -->
            <section class="co-card">
                <h2 class="co-card-title">Note for the seller <span class="opt">(optional)</span></h2>
                <div class="field" style="margin-bottom:0">
                    <textarea name="orderNote" rows="2" maxlength="250"
                              placeholder="Size, colour or delivery instructions"></textarea>
                </div>
            </section>
        </div>

        <!-- ============ RIGHT: summary ============ -->
        <aside class="co-summary">
            <h2 class="co-card-title">Order summary</h2>

            <ul class="sum-items">
                <c:forEach var="item" items="${cartItems}">
                    <li>
                        <div class="sum-img">
                            <c:if test="${not empty item.imageUrl}">
                                <img src="${item.imageUrl}" alt="">
                            </c:if>
                            <span class="sum-qty">${item.quantity}</span>
                        </div>
                        <span class="sum-name"><c:out value="${item.name}"/></span>
                        <span class="sum-price">
                            Rs <fmt:formatNumber value="${item.unitPrice * item.quantity}" maxFractionDigits="0"/>
                        </span>
                    </li>
                </c:forEach>
            </ul>

            <div class="promo">
                <input type="text" name="promoCode" id="promoCode" placeholder="Promo code" autocomplete="off">
                <button type="button" id="promoBtn">Apply</button>
            </div>

            <div class="sum-row">
                <span>Subtotal</span>
                <span>Rs <fmt:formatNumber value="${subtotal}" maxFractionDigits="0"/></span>
            </div>
            <c:if test="${discountAmount > 0}">
                <div class="sum-row">
                    <span>Discount (-${discountPercent}%)</span>
                    <span class="green">-Rs <fmt:formatNumber value="${discountAmount}" maxFractionDigits="0"/></span>
                </div>
            </c:if>
            <div class="sum-row">
                <span>Delivery fee</span>
                <span>Rs <fmt:formatNumber value="${deliveryFee}" maxFractionDigits="0"/></span>
            </div>

            <div class="sum-row sum-total">
                <span>Total</span>
                <span>Rs <fmt:formatNumber value="${total}" maxFractionDigits="0"/></span>
            </div>

            <button type="submit" class="place-btn" id="placeBtn">
                <span class="btn-label">Place order</span>
            </button>
            <p class="terms">By placing your order you agree to our Terms of Use and Return Policy.</p>

            <a class="back-link" href="${pageContext.request.contextPath}/cart">&larr; Back to cart</a>
        </aside>
    </form>
</div>

<jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
(function () {
    var form = document.getElementById('checkoutForm');
    var placeBtn = document.getElementById('placeBtn');
    var label = placeBtn.querySelector('.btn-label');

    /* ---------- payment option: show the details of the chosen method ---------- */
    var radios = form.querySelectorAll('input[name="paymentMethod"]');
    function syncPay() {
        radios.forEach(function (r) {
            r.closest('.pay-option').classList.toggle('selected', r.checked);
        });
        var method = form.querySelector('input[name="paymentMethod"]:checked').value;
        label.textContent = method === 'COD' ? 'Place order'
                          : method === 'CARD' ? 'Pay now'
                          : 'Continue to payment';
    }
    radios.forEach(function (r) { r.addEventListener('change', syncPay); });
    syncPay();

    /* ---------- card formatting ---------- */
    var num = document.getElementById('cardNumber');
    num.addEventListener('input', function () {
        var d = num.value.replace(/\D/g, '').slice(0, 16);
        num.value = d.replace(/(.{4})/g, '$1 ').trim();
    });
    var exp = document.getElementById('cardExp');
    exp.addEventListener('input', function () {
        var d = exp.value.replace(/\D/g, '').slice(0, 4);
        exp.value = d.length > 2 ? d.slice(0, 2) + '/' + d.slice(2) : d;
    });
    document.getElementById('cardCvv').addEventListener('input', function (e) {
        e.target.value = e.target.value.replace(/\D/g, '');
    });
    document.getElementById('phone').addEventListener('input', function (e) {
        e.target.value = e.target.value.replace(/\D/g, '');
    });

    /* ---------- validation ---------- */
    function setErr(field, bad) {
        if (field) field.classList.toggle('invalid', bad);
    }
    form.querySelectorAll('.field input[required], .field select[required]').forEach(function (el) {
        el.addEventListener('blur', function () { setErr(el.closest('.field'), !el.checkValidity()); });
        el.addEventListener('input', function () { if (el.checkValidity()) setErr(el.closest('.field'), false); });
    });

    function cardOk() {
        var n = num.value.replace(/\s/g, '');
        var m = /^(\d{2})\/(\d{2})$/.exec(exp.value);
        var okExp = false;
        if (m) {
            var mm = +m[1], yy = 2000 + (+m[2]), now = new Date();
            okExp = mm >= 1 && mm <= 12 &&
                    (yy > now.getFullYear() || (yy === now.getFullYear() && mm >= now.getMonth() + 1));
        }
        var checks = [
            [num, n.length === 16],
            [document.getElementById('cardName'), document.getElementById('cardName').value.trim().length > 1],
            [exp, okExp],
            [document.getElementById('cardCvv'), /^\d{3,4}$/.test(document.getElementById('cardCvv').value)]
        ];
        var ok = true;
        checks.forEach(function (c) {
            var bad = !c[1];
            c[0].classList.toggle('invalid-input', bad);
            if (bad) ok = false;
        });
        return ok;
    }

    form.addEventListener('submit', function (e) {
        var ok = true, first = null;
        form.querySelectorAll('.field input[required], .field select[required]').forEach(function (el) {
            var bad = !el.checkValidity();
            setErr(el.closest('.field'), bad);
            if (bad) { ok = false; if (!first) first = el; }
        });
        if (form.querySelector('input[name="paymentMethod"]:checked').value === 'CARD' && !cardOk()) {
            ok = false;
            if (!first) first = num;
        }
        if (!ok) {
            e.preventDefault();
            first.focus();
            first.scrollIntoView({ behavior: 'smooth', block: 'center' });
            return;
        }
        // stop double orders
        placeBtn.disabled = true;
        placeBtn.classList.add('loading');
        label.textContent = 'Placing your order...';
    });

    // Card fields must never be posted to your own server. They have no name attribute on purpose.
})();
</script>
</body>
</html>
