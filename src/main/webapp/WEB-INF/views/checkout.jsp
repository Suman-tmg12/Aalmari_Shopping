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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/checkout.css?v=3">
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

            <!-- 1. Delivery address (address book) -->
            <section class="co-card">
                <div class="addr-head">
                    <h2 class="co-card-title">Delivery address</h2>
                    <button type="button" class="link-btn" id="addAddrBtn">+ Add new address</button>
                </div>

                <input type="hidden" name="addressId" id="addressId" value="">

                <div class="addr-list" id="addrList"></div>
                <small class="err-block" id="addrErr">Choose a delivery address.</small>

                <!-- Add / edit form. These inputs have no name attribute on purpose: they are never posted with the order. -->
                <div class="addr-editor" id="addrEditor" hidden
                     data-name="<c:out value='${prefill.fullName}'/>"
                     data-phone="<c:out value='${prefill.phone}'/>">
                    <h3 class="addr-editor-title" id="addrEditorTitle">Add new address</h3>

                    <div class="field">
                        <span class="lbl">Save as</span>
                        <div class="chips" id="addrChips">
                            <button type="button" class="chip active" data-label="Home">Home</button>
                            <button type="button" class="chip" data-label="Office">Office</button>
                            <button type="button" class="chip" data-label="Other">Other</button>
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="field">
                            <label for="addrName">Full name</label>
                            <input id="addrName" type="text" autocomplete="name">
                        </div>
                        <div class="field">
                            <label for="addrPhone">Mobile number</label>
                            <input id="addrPhone" type="tel" inputmode="numeric" autocomplete="tel"
                                   placeholder="98XXXXXXXX" maxlength="10">
                        </div>
                    </div>

                    <div class="grid-2">
                        <div class="field">
                            <label for="addrProvince">Province</label>
                            <select id="addrProvince">
                                <option value="" selected disabled>Select province</option>
                                <option>Koshi</option>
                                <option>Madhesh</option>
                                <option>Bagmati</option>
                                <option>Gandaki</option>
                                <option>Lumbini</option>
                                <option>Karnali</option>
                                <option>Sudurpashchim</option>
                            </select>
                        </div>
                        <div class="field">
                            <label for="addrCity">City / municipality</label>
                            <input id="addrCity" type="text" autocomplete="address-level2" placeholder="e.g. Kathmandu">
                        </div>
                    </div>

                    <div class="field">
                        <label for="addrStreet">Street address</label>
                        <input id="addrStreet" type="text" autocomplete="street-address"
                               placeholder="Ward no., tole, house number">
                    </div>

                    <div class="field">
                        <label for="addrLandmark">Landmark <span class="opt">(optional)</span></label>
                        <input id="addrLandmark" type="text" placeholder="Near a temple, school, shop...">
                    </div>

                    <label class="check"><input type="checkbox" id="addrDefault"> Make this my default address</label>

                    <div class="co-alert" id="addrFormErr" role="alert" hidden></div>

                    <div class="addr-editor-actions">
                        <button type="button" class="btn-ghost" id="addrCancel">Cancel</button>
                        <button type="button" class="btn-dark" id="addrSave">Save and deliver here</button>
                    </div>
                </div>

                <script type="application/json" id="addrData">${addressesJson}</script>
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
    var CTX = '${pageContext.request.contextPath}';
    var form = document.getElementById('checkoutForm');
    var placeBtn = document.getElementById('placeBtn');
    var label = placeBtn.querySelector('.btn-label');

    /* ====================================================================== */
    /*  Address book                                                          */
    /* ====================================================================== */
    var addrList = document.getElementById('addrList');
    var addrIdInput = document.getElementById('addressId');
    var addrErr = document.getElementById('addrErr');
    var addBtn = document.getElementById('addAddrBtn');
    var editor = document.getElementById('addrEditor');
    var editorTitle = document.getElementById('addrEditorTitle');
    var editorErr = document.getElementById('addrFormErr');
    var saveBtn = document.getElementById('addrSave');
    var cancelBtn = document.getElementById('addrCancel');
    var chips = document.querySelectorAll('#addrChips .chip');

    var f = {
        name: document.getElementById('addrName'),
        phone: document.getElementById('addrPhone'),
        province: document.getElementById('addrProvince'),
        city: document.getElementById('addrCity'),
        street: document.getElementById('addrStreet'),
        landmark: document.getElementById('addrLandmark'),
        makeDefault: document.getElementById('addrDefault')
    };

    var addresses = [];
    try { addresses = JSON.parse(document.getElementById('addrData').textContent) || []; } catch (e) { addresses = []; }
    var selectedId = null;
    var editingId = null;
    var chosenLabel = 'Home';

    function esc(s) {
        return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
        });
    }

    function findAddr(id) {
        for (var i = 0; i < addresses.length; i++) if (addresses[i].id === id) return addresses[i];
        return null;
    }

    function pickDefault() {
        var d = null;
        for (var i = 0; i < addresses.length; i++) if (addresses[i].primary) { d = addresses[i]; break; }
        if (!d && addresses.length) d = addresses[0];
        selectedId = d ? d.id : null;
    }

    function showListErr(msg) {
        addrErr.textContent = msg;
        addrErr.style.display = 'block';
    }
    function hideListErr() { addrErr.style.display = 'none'; }

    function renderAddresses() {
        addrIdInput.value = selectedId == null ? '' : selectedId;
        addrList.innerHTML = addresses.map(function (a) {
            var sel = a.id === selectedId;
            return '<div class="addr-card' + (sel ? ' selected' : '') + '" data-id="' + a.id + '">' +
                '<span class="addr-radio" aria-hidden="true"></span>' +
                '<div class="addr-body">' +
                '<div class="addr-top"><span class="addr-badge ' + esc(a.label).toLowerCase() + '">' + esc(a.label) + '</span>' +
                (a.primary ? '<span class="addr-default">Default</span>' : '') + '</div>' +
                '<div class="addr-name">' + esc(a.name) + ' &middot; ' + esc(a.phone) + '</div>' +
                '<div class="addr-line">' + esc(a.street) + ', ' + esc(a.city) + ', ' + esc(a.province) + '</div>' +
                (a.landmark ? '<div class="addr-line muted">Landmark: ' + esc(a.landmark) + '</div>' : '') +
                '<div class="addr-actions">' +
                '<button type="button" data-act="edit">Edit</button>' +
                '<button type="button" data-act="delete">Delete</button>' +
                (a.primary ? '' : '<button type="button" data-act="default">Set as default</button>') +
                '</div></div></div>';
        }).join('');
    }

    function setChip(name) {
        chosenLabel = name;
        for (var i = 0; i < chips.length; i++) {
            chips[i].classList.toggle('active', chips[i].getAttribute('data-label') === name);
        }
    }
    for (var c = 0; c < chips.length; c++) {
        chips[c].addEventListener('click', function () { setChip(this.getAttribute('data-label')); });
    }

    function openEditor(a) {
        editingId = a ? a.id : null;
        editorTitle.textContent = a ? 'Edit address' : 'Add new address';
        f.name.value = a ? a.name : (editor.getAttribute('data-name') || '');
        f.phone.value = a ? a.phone : (editor.getAttribute('data-phone') || '');
        f.province.value = a ? a.province : '';
        f.city.value = a ? a.city : '';
        f.street.value = a ? a.street : '';
        f.landmark.value = a ? a.landmark : '';
        f.makeDefault.checked = a ? a.primary : addresses.length === 0;
        setChip(a ? a.label : 'Home');
        editorErr.hidden = true;
        cancelBtn.hidden = addresses.length === 0;      // first address: nothing to go back to
        saveBtn.disabled = false;
        saveBtn.textContent = a ? 'Save changes' : 'Save and deliver here';
        editor.hidden = false;
        addBtn.hidden = true;
        f.name.focus();
    }

    function closeEditor() {
        editor.hidden = true;
        addBtn.hidden = false;
        editingId = null;
    }

    function post(path, data) {
        var p = new URLSearchParams();
        Object.keys(data).forEach(function (k) { if (data[k] != null) p.append(k, data[k]); });
        return fetch(CTX + path, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: p.toString(),
            credentials: 'same-origin'
        }).then(function (r) {
            if (r.ok) return r.json();
            return r.text().then(function (t) { throw new Error(t || 'Something went wrong. Please try again.'); });
        });
    }

    addBtn.addEventListener('click', function () { openEditor(null); });
    cancelBtn.addEventListener('click', closeEditor);

    // Enter inside the address form must not submit the whole order
    editor.addEventListener('keydown', function (e) {
        if (e.key === 'Enter' && e.target.tagName !== 'BUTTON') {
            e.preventDefault();
            saveBtn.click();
        }
    });
    f.phone.addEventListener('input', function () { f.phone.value = f.phone.value.replace(/\D/g, ''); });

    saveBtn.addEventListener('click', function () {
        var d = {
            id: editingId,
            label: chosenLabel,
            fullName: f.name.value.trim(),
            phone: f.phone.value.trim(),
            province: f.province.value,
            city: f.city.value.trim(),
            address: f.street.value.trim(),
            landmark: f.landmark.value.trim(),
            makeDefault: f.makeDefault.checked ? 'true' : 'false'
        };
        var msg = '';
        if (d.fullName.length < 2) msg = "Enter the receiver's name.";
        else if (!/^9[678][0-9]{8}$/.test(d.phone)) msg = 'Enter a 10-digit mobile number starting with 96, 97 or 98.';
        else if (!d.province) msg = 'Select a province.';
        else if (d.city.length < 2) msg = 'Enter your city or municipality.';
        else if (d.address.length < 3) msg = 'Enter your street address.';
        if (msg) { editorErr.textContent = msg; editorErr.hidden = false; return; }

        editorErr.hidden = true;
        saveBtn.disabled = true;
        saveBtn.textContent = 'Saving...';
        post('/checkout/address/save', d).then(function (res) {
            addresses = res.addresses;
            selectedId = res.id;
            closeEditor();
            hideListErr();
            renderAddresses();
        }).catch(function (err) {
            saveBtn.disabled = false;
            saveBtn.textContent = editingId ? 'Save changes' : 'Save and deliver here';
            editorErr.textContent = err.message;
            editorErr.hidden = false;
        });
    });

    addrList.addEventListener('click', function (e) {
        var card = e.target.closest('.addr-card');
        if (!card) return;
        var id = Number(card.getAttribute('data-id'));
        var btn = e.target.closest('button[data-act]');

        if (!btn) {                                   // clicking the card selects it
            selectedId = id;
            hideListErr();
            renderAddresses();
            return;
        }
        var act = btn.getAttribute('data-act');
        if (act === 'edit') {
            openEditor(findAddr(id));
        } else if (act === 'delete') {
            if (!window.confirm('Delete this address?')) return;
            post('/checkout/address/delete', { id: id }).then(function (res) {
                addresses = res.addresses;
                if (selectedId === id) pickDefault();
                renderAddresses();
                if (!addresses.length) openEditor(null);
            }).catch(function (err) { showListErr(err.message); });
        } else if (act === 'default') {
            post('/checkout/address/default', { id: id }).then(function (res) {
                addresses = res.addresses;
                renderAddresses();
            }).catch(function (err) { showListErr(err.message); });
        }
    });

    pickDefault();
    renderAddresses();
    if (!addresses.length) openEditor(null);          // first order: show the form straight away

    /* ====================================================================== */
    /*  Payment option: show the details of the chosen method                 */
    /* ====================================================================== */
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

    /* ---------- validation ---------- */
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

        // a saved address must be chosen
        if (!addrIdInput.value) {
            ok = false;
            showListErr(editor.hidden ? 'Choose a delivery address.'
                                      : 'Save this address first, then place your order.');
            first = editor.hidden ? addBtn : saveBtn;
        }

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

    // Card fields and the address form must never be posted to your own server. They have no name attribute on purpose.
})();
</script>
</body>
</html>