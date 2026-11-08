<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Aalmari is a multi-vendor online marketplace in Nepal that connects shoppers with sellers. Learn who we are, how we work and how to reach us.">
<title>About Us — Aalmari Store</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />

<!-- Scroll reveal: switched on only if the browser supports it and the user has not asked for reduced motion -->
<script>
    (function () {
        var reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if ('IntersectionObserver' in window && !reduce) {
            document.documentElement.classList.add('js-reveal');
        }
    })();
</script>

<!-- Structured data: tells search engines who the organisation is -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "Organization",
  "name": "Aalmari",
  "description": "Multi-vendor online marketplace in Nepal.",
  "email": "support@aalmari.com",
  "telephone": "+977-1-5970597",
  "address": { "@type": "PostalAddress", "addressCountry": "NP" }
}
</script>

<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Segoe UI', Arial, sans-serif;
    }

    :root {
        --ab-header-offset: 90px;          /* space for the fixed site header */
        --ab-accent: #f2994a;
        --ab-accent-text: #b45309;         /* darker orange: readable on white */
        --ab-ink: #1f2933;
        --ab-muted: #5f6b7a;
        --ab-line: #eceff3;
        --ab-warm: #fdf1e4;
        --ab-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
    }

    html { -webkit-text-size-adjust: 100%; }

    body {
        background: linear-gradient(135deg, #ffffff 0%, #fdf1e4 40%, #f6c99a 75%, #f2a86b 100%);
        min-height: 100vh;
        color: var(--ab-ink);
    }

    a:focus-visible,
    button:focus-visible {
        outline: 3px solid #1d4ed8;
        outline-offset: 2px;
    }

    /* ===== Layout ===== */
    .ab-container {
        width: 100%;
        max-width: 1000px;
        margin: 0 auto;
        padding: var(--ab-header-offset) clamp(12px, 4vw, 24px) 48px;
    }

    .ab-card {
        background: #ffffff;
        border-radius: 16px;
        padding: clamp(20px, 4vw, 36px) clamp(16px, 4vw, 36px);
        margin-bottom: 20px;
        box-shadow: var(--ab-shadow);
        scroll-margin-top: calc(var(--ab-header-offset) + 12px);
    }

    .ab-card h2 {
        font-size: clamp(18px, 3vw, 22px);
        line-height: 1.3;
        color: var(--ab-ink);
        margin-bottom: 6px;
    }

    .ab-card-sub {
        font-size: 14.5px;
        color: var(--ab-muted);
        margin-bottom: 22px;
        line-height: 1.6;
        max-width: 62ch;
    }

    .ab-text {
        font-size: 15px;
        line-height: 1.75;
        color: #3d4753;
        max-width: 68ch;
    }
    .ab-text + .ab-text { margin-top: 14px; }

    /* ===== Breadcrumb ===== */
    .ab-breadcrumb {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: var(--ab-muted);
        margin-bottom: 14px;
    }
    .ab-breadcrumb a { color: var(--ab-accent-text); text-decoration: none; }
    .ab-breadcrumb a:hover { text-decoration: underline; }
    .ab-breadcrumb [aria-current="page"] { color: var(--ab-ink); font-weight: 600; }

    /* ===== Hero ===== */
    .ab-hero { padding: clamp(28px, 6vw, 56px) clamp(18px, 5vw, 48px); }

    .ab-hero h1 {
        font-size: clamp(26px, 5.5vw, 40px);
        line-height: 1.2;
        letter-spacing: -0.01em;
        max-width: 20ch;
        margin-bottom: 14px;
    }

    .ab-hero p {
        font-size: clamp(15px, 2.2vw, 17px);
        line-height: 1.7;
        color: var(--ab-muted);
        max-width: 60ch;
    }

    .ab-hero-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 24px;
    }

    /* ===== Buttons ===== */
    .ab-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        min-height: 46px;
        padding: 0 22px;
        border: 1px solid var(--ab-accent);
        border-radius: 10px;
        background: var(--ab-accent);
        color: #1f1305;
        font-size: 14.5px;
        font-weight: 700;
        text-decoration: none;
        cursor: pointer;
        transition: background .15s ease, border-color .15s ease;
    }
    .ab-btn:hover { background: #e98a36; border-color: #e98a36; }
    .ab-btn .material-symbols-outlined { font-size: 20px; }

    .ab-btn--ghost {
        background: #fff;
        border-color: #e3c9a6;
        color: #7a4a0d;
    }
    .ab-btn--ghost:hover { background: var(--ab-warm); border-color: #d9b57f; }

    /* ===== Icon tiles (what we offer / values) ===== */
    .ab-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 14px;
    }

    .ab-item {
        display: flex;
        gap: 16px;
        padding: 18px;
        border: 1px solid var(--ab-line);
        border-radius: 14px;
    }

    .ab-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background: var(--ab-warm);
        color: #b45309;
    }
    .ab-icon .material-symbols-outlined { font-size: 26px; }

    .ab-item h3 { font-size: 15.5px; margin-bottom: 4px; line-height: 1.35; }
    .ab-item p  { font-size: 14px; line-height: 1.6; color: var(--ab-muted); }

    /* ===== How it works (a real sequence, so steps are numbered) ===== */
    .ab-columns {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 28px;
    }

    .ab-col h3 {
        font-size: 16px;
        margin-bottom: 14px;
        padding-bottom: 10px;
        border-bottom: 2px solid var(--ab-accent);
        display: inline-block;
    }

    .ab-steps { list-style: none; counter-reset: step; }

    .ab-steps li {
        counter-increment: step;
        position: relative;
        padding: 0 0 18px 44px;
        font-size: 14.5px;
        line-height: 1.6;
        color: #3d4753;
    }
    .ab-steps li:last-child { padding-bottom: 0; }

    .ab-steps li::before {
        content: counter(step);
        position: absolute;
        left: 0;
        top: -1px;
        width: 30px;
        height: 30px;
        border-radius: 50%;
        background: var(--ab-warm);
        color: #b45309;
        font-size: 14px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .ab-steps strong { display: block; color: var(--ab-ink); font-size: 15px; margin-bottom: 2px; }

    /* ===== Call to action band ===== */
    .ab-cta {
        background: var(--ab-ink);
        color: #fff;
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
    }
    .ab-cta h2 { color: #fff; margin-bottom: 6px; }
    .ab-cta p  { color: #cbd2d9; font-size: 14.5px; line-height: 1.6; max-width: 52ch; }

    /* ===== Contact ===== */
    .ab-contact-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 14px;
    }

    .ab-contact {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        padding: 18px;
        border: 1px solid var(--ab-line);
        border-radius: 14px;
    }

    .ab-contact h3 { font-size: 15px; margin-bottom: 3px; }
    .ab-contact p  { font-size: 13.5px; line-height: 1.55; color: var(--ab-muted); }
    .ab-contact a  { color: var(--ab-accent-text); font-weight: 600; text-decoration: none; word-break: break-word; }
    .ab-contact a:hover { text-decoration: underline; }

    /* ===== Responsive ===== */
    @media (max-width: 760px) {
        .ab-columns { grid-template-columns: 1fr; gap: 24px; }
    }

    @media (max-width: 600px) {
        :root { --ab-header-offset: 145px; }   /* the site header is taller on phones */
        .ab-grid { grid-template-columns: 1fr; }
        .ab-hero-actions .ab-btn,
        .ab-cta .ab-btn { width: 100%; }
    }

    @media (max-width: 360px) {
        .ab-item, .ab-contact { padding: 14px; gap: 12px; }
    }

    /* ===== Scroll reveal =====
       Blocks start hidden + 40px lower, then fade and slide up when scrolled into view.
       Nothing is hidden unless the head script added "js-reveal" to <html>. */
    .js-reveal .ab-reveal {
        opacity: 0;
        transform: translateY(40px);
        transition:
            opacity 0.7s ease,
            transform 0.7s cubic-bezier(0.22, 1, 0.36, 1);
    }
    /* `none` (not translateY(0)) so the block never becomes a containing block for fixed/sticky children */
    .js-reveal .ab-reveal.reveal--in {
        opacity: 1;
        transform: none;
    }

    @media (prefers-reduced-motion: reduce) {
        .ab-btn { transition: none; }
    }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/components/header.jsp" />

<main class="ab-container" id="top">

    <!-- Breadcrumb -->
    <nav class="ab-breadcrumb" aria-label="Breadcrumb">
        <a href="${pageContext.request.contextPath}/">Home</a>
        <span aria-hidden="true">/</span>
        <span aria-current="page">About Us</span>
    </nav>

    <!-- Hero -->
    <section class="ab-card ab-hero ab-reveal" aria-labelledby="abHeading">
        <h1 id="abHeading">A marketplace built for Nepali shoppers and sellers</h1>
        <p>
            Aalmari brings many independent sellers together in one store, so you can find what you need
            from people you can trust, and sellers can reach customers without building a shop from scratch.
        </p>
        <div class="ab-hero-actions">
            <a class="ab-btn" href="${pageContext.request.contextPath}/">
                <span class="material-symbols-outlined" aria-hidden="true">storefront</span> Start shopping
            </a>
            <a class="ab-btn ab-btn--ghost" href="#contact">Contact us</a>
        </div>
    </section>

    <!-- Our story -->
    <section class="ab-card ab-reveal" aria-labelledby="abStoryTitle">
        <h2 id="abStoryTitle">Who we are</h2>
        <p class="ab-card-sub">A multi-vendor marketplace based in Nepal.</p>
        <p class="ab-text">
            Aalmari is an online marketplace where many sellers list their products in one place.
            Shoppers can browse by category, search for exactly what they want, and compare products from different stores
            before they buy.
        </p>
        <p class="ab-text">
            We started with a simple idea: buying and selling online in Nepal should be easy, clear and fair.
            For shoppers that means honest product information and help when it is needed.
            For sellers it means simple tools to manage products, orders and payouts from a single dashboard.
        </p>
    </section>

    <!-- What we offer -->
    <section class="ab-card ab-reveal" aria-labelledby="abOfferTitle">
        <h2 id="abOfferTitle">What you get with Aalmari</h2>
        <p class="ab-card-sub">The things we focus on for every order.</p>

        <div class="ab-grid">
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">category</span></span>
                <div>
                    <h3>Many stores, one place</h3>
                    <p>Browse products from different sellers across categories without switching between websites.</p>
                </div>
            </div>
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">verified_user</span></span>
                <div>
                    <h3>Reviewed sellers</h3>
                    <p>Sellers go through verification before they can list products, so you know who you are buying from.</p>
                </div>
            </div>
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">payments</span></span>
                <div>
                    <h3>Clear checkout</h3>
                    <p>Review your cart, see the available payment options and confirm your order in a few steps.</p>
                </div>
            </div>
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">support_agent</span></span>
                <div>
                    <h3>Real people to help</h3>
                    <p>Our customer care team answers questions about orders, vouchers, returns and your account.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- How it works -->
    <section class="ab-card ab-reveal" aria-labelledby="abHowTitle">
        <h2 id="abHowTitle">How Aalmari works</h2>
        <p class="ab-card-sub">Simple for the people who buy and the people who sell.</p>

        <div class="ab-columns">
            <div class="ab-col">
                <h3>For shoppers</h3>
                <ol class="ab-steps">
                    <li><strong>Find a product</strong>Search or browse categories and open the product page for details.</li>
                    <li><strong>Add it to your cart</strong>Choose the quantity and click Add to Cart.</li>
                    <li><strong>Check out</strong>Review your items, pick a payment option and place your order.</li>
                </ol>
            </div>
            <div class="ab-col">
                <h3>For sellers</h3>
                <ol class="ab-steps">
                    <li><strong>Create a seller account</strong>Register and complete verification.</li>
                    <li><strong>Add your products</strong>List products with photos, prices and descriptions from your Seller Dashboard.</li>
                    <li><strong>Manage orders</strong>Track orders and payouts in one place.</li>
                </ol>
            </div>
        </div>
    </section>

    <!-- Values -->
    <section class="ab-card ab-reveal" aria-labelledby="abValuesTitle">
        <h2 id="abValuesTitle">What we stand for</h2>
        <p class="ab-card-sub">The principles behind how we run the marketplace.</p>

        <div class="ab-grid">
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">visibility</span></span>
                <div>
                    <h3>Transparency</h3>
                    <p>Clear prices, clear product details and clear answers when something goes wrong.</p>
                </div>
            </div>
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">handshake</span></span>
                <div>
                    <h3>Trust</h3>
                    <p>We review sellers and moderate listings to keep the marketplace reliable.</p>
                </div>
            </div>
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">groups</span></span>
                <div>
                    <h3>Support for local sellers</h3>
                    <p>We give small and independent businesses the tools to sell online and grow.</p>
                </div>
            </div>
            <div class="ab-item">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">lock</span></span>
                <div>
                    <h3>Privacy and security</h3>
                    <p>We treat your account and personal details with care.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Seller call to action -->
    <section class="ab-card ab-cta ab-reveal" aria-labelledby="abSellTitle">
        <div>
            <h2 id="abSellTitle">Want to sell on Aalmari?</h2>
            <p>Create a seller account and start listing your products. Our team can help you get started.</p>
        </div>
        <a class="ab-btn" href="#contact">Ask how to get started</a>
    </section>

    <!-- Contact -->
    <section class="ab-card ab-reveal" id="contact" aria-labelledby="abContactTitle">
        <h2 id="abContactTitle">Get in touch</h2>
        <p class="ab-card-sub">Questions about an order, your account or selling? We are happy to help. Times are Nepal time.</p>

        <div class="ab-contact-grid">
            <div class="ab-contact">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">call</span></span>
                <div>
                    <h3>Call us</h3>
                    <p><a href="tel:+97715970597">01-5970597</a><br>9AM - 6PM [Sun-Fri]</p>
                </div>
            </div>
            <div class="ab-contact">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">mail</span></span>
                <div>
                    <h3>Email us</h3>
                    <p><a href="mailto:support@aalmari.com">support@aalmari.com</a></p>
                </div>
            </div>
            <div class="ab-contact">
                <span class="ab-icon"><span class="material-symbols-outlined" aria-hidden="true">schedule</span></span>
                <div>
                    <h3>Live chat</h3>
                    <p>9AM - 6PM [Mon-Sun]</p>
                </div>
            </div>
        </div>
    </section>

</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
(function () {
    'use strict';

    /* ---------- Scroll reveal (fade + slide up the first time a block scrolls into view) ---------- */
    if (document.documentElement.classList.contains('js-reveal')) {
        var io = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (entry.isIntersecting) {
                    entry.target.classList.add('reveal--in');
                    io.unobserve(entry.target);          // animate only the first time
                }
            });
        }, { threshold: 0, rootMargin: '0px 0px -80px 0px' });

        Array.prototype.forEach.call(document.querySelectorAll('.ab-reveal'), function (el) { io.observe(el); });
    }
})();
</script>

</body>
</html>
