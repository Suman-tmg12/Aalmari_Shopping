<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${pageTitle} - Aalmari</title>
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
    <style>
        :root { --a-bg:#faf5ed; --a-card:#fff; --a-ink:#171717; --a-muted:#666; --a-line:#eadfd1; --a-accent:#e2691b; }
        body { margin:0; background:linear-gradient(135deg,#faf7f0,#f3dbc2); color:var(--a-ink); font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif; }
        .legal-page { max-width:980px; margin:0 auto; padding:130px 20px 70px; }
        .legal-card { background:var(--a-card); border:1px solid var(--a-line); border-radius:18px; padding:clamp(24px,5vw,48px); box-shadow:0 14px 38px rgba(70,43,20,.08); }
        .legal-tabs { display:flex; flex-wrap:wrap; gap:8px; margin-bottom:28px; }
        .legal-tabs a { color:var(--a-ink); text-decoration:none; border:1px solid var(--a-line); border-radius:999px; padding:9px 14px; font-size:14px; font-weight:700; }
        .legal-tabs a.active { background:var(--a-ink); color:#fff; border-color:var(--a-ink); }
        .legal-card h1 { margin:0 0 8px; font-size:clamp(28px,5vw,42px); }
        .effective { color:var(--a-muted); margin:0 0 28px; }
        .legal-card h2 { margin:28px 0 8px; font-size:20px; }
        .legal-card p,.legal-card li { color:#4d4d4d; line-height:1.75; }
        .legal-card ul { padding-left:22px; }
        .legal-card section { scroll-margin-top:120px; }
        .legal-contact { margin-top:30px; padding:18px; border-radius:12px; background:#fff7ed; border:1px solid #fed7aa; }
        @media(max-width:560px){.legal-page{padding:110px 12px 40px}.legal-card{padding:22px 18px}.legal-tabs a{font-size:13px}}
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />
<main class="legal-page">
    <article class="legal-card">
        <nav class="legal-tabs" aria-label="Legal documents">
            <a class="${document == 'terms' ? 'active' : ''}" href="${pageContext.request.contextPath}/legal?document=terms">Terms</a>
            <a class="${document == 'privacy' ? 'active' : ''}" href="${pageContext.request.contextPath}/legal?document=privacy">Privacy</a>
            <a class="${document == 'returns' ? 'active' : ''}" href="${pageContext.request.contextPath}/legal?document=returns">Returns &amp; Refunds</a>
            <a class="${document == 'seller' ? 'active' : ''}" href="${pageContext.request.contextPath}/legal?document=seller">Seller Terms</a>
        </nav>

        <c:choose>
            <c:when test="${document == 'privacy'}">
                <h1>Privacy Policy</h1><p class="effective">Effective: November 24, 2026</p>
                <section><h2>1. Information we collect</h2><p>We collect account details, contact information, delivery addresses, order history, payment references, and customer-support messages needed to operate Aalmari.</p></section>
                <section><h2>2. How we use information</h2><ul><li>Create and secure customer accounts.</li><li>Process and deliver orders.</li><li>Prevent fraud, misuse, and unauthorized transactions.</li><li>Provide customer support and service updates.</li><li>Improve products, website performance, and marketplace safety.</li></ul></section>
                <section><h2>3. Payment information</h2><p>We do not ask for or store eSewa passwords or card security codes. A manual eSewa payment may require a transaction/reference ID for verification.</p></section>
                <section><h2>4. Information sharing</h2><p>We share necessary information with sellers for order fulfillment and with payment, delivery, or fraud-prevention providers. We do not sell personal information.</p></section>
                <section><h2>5. Data security and retention</h2><p>We use reasonable technical and organizational safeguards. We retain personal data only while necessary for accounts, transactions, legal obligations, and dispute resolution.</p></section>
                <section><h2>6. Your choices</h2><p>You may request access, correction, or deletion of eligible account information by contacting support, subject to legal and transaction-record requirements.</p></section>
            </c:when>
            <c:when test="${document == 'returns'}">
                <h1>Return &amp; Refund Policy</h1><p class="effective">Effective: November 24, 2026</p>
                <section><h2>1. Eligibility</h2><p>Returns may be requested for damaged, defective, incorrect, or significantly misrepresented items. Items must remain unused, complete, and in original packaging where applicable.</p></section>
                <section><h2>2. Return window</h2><p>Customers must submit a return request within seven days of confirmed delivery, unless the seller's displayed return terms provide a longer period.</p></section>
                <section><h2>3. Non-returnable items</h2><p>Perishable, opened personal-care, hygiene-sensitive, customized, digital, and intentionally final-sale items may not be returnable unless defective or incorrectly delivered.</p></section>
                <section><h2>4. Approval and pickup</h2><p>After a request is reviewed, Aalmari or the seller may approve a replacement, exchange, or pickup. Return shipping responsibility depends on the reason and applicable seller terms.</p></section>
                <section><h2>5. Refunds</h2><p>Approved refunds are issued to the original payment method or as store credit where permitted. Cash-on-delivery refunds require verified account and bank details. Processing time may vary.</p></section>
                <section><h2>6. Disputes</h2><p>Customers and sellers must provide evidence, including photos or delivery records. Aalmari may review evidence and make a final marketplace decision.</p></section>
            </c:when>
            <c:when test="${document == 'seller'}">
                <h1>Seller Terms of Service</h1><p class="effective">Effective: November 24, 2026</p>
                <section><h2>1. Seller eligibility</h2><p>Seller accounts require accurate registration, identity, business, contact, tax, and banking information. Aalmari may reject or suspend applications that fail verification.</p></section>
                <section><h2>2. Product listings</h2><p>Sellers must provide accurate titles, images, prices, descriptions, stock levels, and specifications. Counterfeit, illegal, unsafe, or restricted goods are prohibited.</p></section>
                <section><h2>3. Orders and fulfillment</h2><p>Sellers must confirm, ship, deliver, cancel, and update orders truthfully. Sellers may not manipulate orders, create fake sales, or purchase their own listings to gain rankings or promotions.</p></section>
                <section><h2>4. Fees and payouts</h2><p>Sellers authorize applicable marketplace commission, payment, and refund deductions. Payout calculations are based on delivered and approved orders, subject to disputes and chargebacks.</p></section>
                <section><h2>5. Returns and customer service</h2><p>Sellers must follow marketplace return rules, respond to buyer concerns, and provide evidence for disputes. Repeated complaints may result in penalties or suspension.</p></section>
                <section><h2>6. Suspension</h2><p>Aalmari may pause listings or accounts for fraud, prohibited goods, policy breaches, excessive cancellations, counterfeit activity, or safety risks.</p></section>
            </c:when>
            <c:otherwise>
                <h1>Terms of Service</h1><p class="effective">Effective: November 24, 2026</p>
                <section><h2>1. Acceptance of terms</h2><p>By creating an account or using Aalmari, you agree to these terms, our Privacy Policy, and all applicable seller and return policies.</p></section>
                <section><h2>2. Accounts and security</h2><p>You must provide accurate information and keep your login credentials confidential. You are responsible for activity performed through your account, except where prohibited by law.</p></section>
                <section><h2>3. Orders and availability</h2><p>Placing an order is an offer to purchase. An order is accepted only after confirmation and remains subject to stock, address, payment, and fraud checks. Sellers are responsible for their listings and fulfillment.</p></section>
                <section><h2>4. Prices and payments</h2><p>Prices are displayed in Nepalese rupees. Applicable taxes, delivery fees, discounts, and flash-sale limits are shown before confirmation. Manual payments require a valid transaction reference and may remain pending verification.</p></section>
                <section><h2>5. Delivery and returns</h2><p>Estimated delivery dates are not guarantees. Returns, replacements, and refunds are handled under the Return &amp; Refund Policy and applicable seller terms.</p></section>
                <section><h2>6. Prohibited conduct</h2><p>Users may not manipulate sales, ratings, reviews, coupons, inventory, or order records; use another person's account; submit fraudulent payment proof; or sell prohibited goods.</p></section>
                <section><h2>7. Intellectual property</h2><p>Aalmari, its brand assets, and platform content may not be copied or used commercially without permission. Sellers retain rights to their genuine listings and warrant that they have permission to use submitted content.</p></section>
                <section><h2>8. Limitation of liability</h2><p>To the maximum extent allowed by law, Aalmari is not liable for indirect or consequential losses arising from seller products, delivery delays, platform interruptions, or unauthorized account activity.</p></section>
                <section><h2>9. Changes and contact</h2><p>We may update these terms when services or laws change. Material updates are posted before they take effect. Continued use constitutes acceptance of the revised terms.</p></section>
            </c:otherwise>
        </c:choose>

        <div class="legal-contact"><strong>Questions?</strong><br>Support: <a href="mailto:support@aalmari.com">support@aalmari.com</a><br>Kathmandu, Nepal</div>
    </article>
</main>
<jsp:include page="/WEB-INF/components/footer.jsp" />
</body>
</html>

