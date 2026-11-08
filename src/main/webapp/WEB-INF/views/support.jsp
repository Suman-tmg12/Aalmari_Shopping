<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Aalmari Help Center: find answers, use self-service tools and contact customer care.">
<title>Help Center — Aalmari Store</title>
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

<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Segoe UI', Arial, sans-serif;
    }

    :root {
        --hc-header-offset: 90px;          /* space for the fixed site header */
        --hc-accent: #f2994a;
        --hc-accent-text: #b45309;         /* darker orange: readable on white */
        --hc-ink: #1f2933;
        --hc-muted: #5f6b7a;
        --hc-line: #eceff3;
        --hc-warm: #fdf1e4;
        --hc-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
    }

    html { -webkit-text-size-adjust: 100%; }

    body {
        background: linear-gradient(135deg, #ffffff 0%, #fdf1e4 40%, #f6c99a 75%, #f2a86b 100%);
        min-height: 100vh;
        color: var(--hc-ink);
    }

    [hidden] { display: none !important; }

    a:focus-visible,
    button:focus-visible,
    input:focus-visible,
    summary:focus-visible {
        outline: 3px solid #1d4ed8;
        outline-offset: 2px;
    }

    /* ===== Layout ===== */
    .hc-container {
        width: 100%;
        max-width: 1000px;
        margin: 0 auto;
        padding: var(--hc-header-offset) clamp(12px, 4vw, 24px) 48px;
    }

    .hc-card {
        background: #ffffff;
        border-radius: 16px;
        padding: clamp(18px, 3.5vw, 28px) clamp(16px, 4vw, 32px);
        margin-bottom: 20px;
        box-shadow: var(--hc-shadow);
        scroll-margin-top: calc(var(--hc-header-offset) + 12px);
    }

    .hc-card-title {
        font-size: 16px;
        font-weight: 700;
        color: var(--hc-ink);
        margin-bottom: 4px;
    }

    .hc-card-sub {
        font-size: 14px;
        color: var(--hc-muted);
        margin-bottom: 18px;
        line-height: 1.5;
    }

    /* ===== Breadcrumb ===== */
    .hc-breadcrumb {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: var(--hc-muted);
        margin-bottom: 14px;
    }
    .hc-breadcrumb a { color: var(--hc-accent-text); text-decoration: none; }
    .hc-breadcrumb a:hover { text-decoration: underline; }
    .hc-breadcrumb [aria-current="page"] { color: var(--hc-ink); font-weight: 600; }

    /* ===== Hero + search ===== */
    .hc-hero { text-align: center; }

    .hc-hero h1 {
        font-size: clamp(22px, 4.5vw, 30px);
        line-height: 1.25;
        margin-bottom: 8px;
    }

    .hc-hero p {
        font-size: 15px;
        color: var(--hc-muted);
        margin-bottom: 20px;
    }

    .hc-search {
        display: flex;
        max-width: 560px;
        margin: 0 auto;
    }

    .hc-search input {
        flex: 1;
        min-width: 0;
        height: 48px;
        padding: 0 16px;
        border: 1px solid #d9dee5;
        border-right: 0;
        border-radius: 10px 0 0 10px;
        background: #fafafa;
        font-size: 16px;               /* 16px stops iOS from zooming on focus */
        color: var(--hc-ink);
        outline: none;
    }

    .hc-search button {
        flex-shrink: 0;
        width: 56px;
        height: 48px;
        border: 0;
        border-radius: 0 10px 10px 0;
        background: #f6ddb3;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .hc-search button:hover { background: #f2cf93; }
    .hc-search svg { width: 20px; height: 20px; stroke: #6b4e12; }

    .hc-popular {
        display: flex;
        flex-wrap: wrap;
        justify-content: center;
        align-items: center;
        gap: 8px;
        margin-top: 16px;
        font-size: 13px;
        color: var(--hc-muted);
    }

    .hc-chip {
        border: 1px solid #f0d9bd;
        background: var(--hc-warm);
        color: #7a4a0d;
        border-radius: 999px;
        padding: 7px 14px;
        font-size: 13px;
        cursor: pointer;
    }
    .hc-chip:hover { background: #fbe3c4; }

    /* ===== Self-service tools ===== */
    .hc-tools {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        gap: 14px;
    }

    .hc-tool {
        position: relative;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        gap: 10px;
        min-height: 112px;
        padding: 14px 8px;
        text-align: center;
        text-decoration: none;
        color: var(--hc-ink);
        border: 1px solid var(--hc-line);
        border-radius: 14px;
        background: #fff;
        transition: transform .2s ease, box-shadow .2s ease, border-color .2s ease;
    }
    .hc-tool:hover {
        transform: translateY(-2px);
        border-color: #f2c48f;
        box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
    }

    .hc-tool-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 52px;
        height: 52px;
        border-radius: 50%;
        background: var(--hc-warm);
        color: #b45309;
    }
    .hc-tool-icon .material-symbols-outlined { font-size: 28px; }

    .hc-tool-label { font-size: 13.5px; font-weight: 600; line-height: 1.3; }

    .hc-soon-tag {
        position: absolute;
        top: 8px;
        right: 8px;
        background: #eef0f3;
        color: var(--hc-muted);
        font-size: 10.5px;
        font-weight: 600;
        padding: 2px 7px;
        border-radius: 999px;
        letter-spacing: .02em;
    }

    /* ===== Topics + FAQ ===== */
    .hc-topics {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 14px;
    }

    .hc-topic {
        border: 1px solid #e3e7ec;
        background: #fff;
        color: var(--hc-ink);
        border-radius: 999px;
        padding: 9px 16px;
        min-height: 40px;
        font-size: 13.5px;
        font-weight: 600;
        cursor: pointer;
        transition: background .15s ease, color .15s ease, border-color .15s ease;
    }
    .hc-topic:hover { background: var(--hc-warm); }
    .hc-topic[aria-pressed="true"] {
        background: var(--hc-accent);
        border-color: var(--hc-accent);
        color: #1f1305;
    }

    .hc-count { font-size: 13px; color: var(--hc-muted); margin-bottom: 6px; min-height: 18px; }

    .hc-faq-list { border-top: 1px solid var(--hc-line); }

    .hc-faq { border-bottom: 1px solid var(--hc-line); }

    .hc-faq summary {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        min-height: 52px;
        padding: 12px 4px;
        list-style: none;
        cursor: pointer;
        font-size: 15px;
        font-weight: 600;
        line-height: 1.4;
    }
    .hc-faq summary::-webkit-details-marker { display: none; }
    .hc-faq summary:hover { color: var(--hc-accent-text); }
    .hc-faq summary::after {
        content: "";
        flex-shrink: 0;
        width: 9px;
        height: 9px;
        margin-right: 4px;
        border-right: 2px solid #8a6d3b;
        border-bottom: 2px solid #8a6d3b;
        transform: rotate(45deg);
        transition: transform .2s ease;
    }
    .hc-faq[open] summary::after { transform: rotate(-135deg); }

    .hc-answer {
        padding: 0 4px 18px;
        font-size: 14.5px;
        line-height: 1.65;
        color: #3d4753;
    }
    .hc-answer a { color: var(--hc-accent-text); }

    .hc-empty {
        padding: 28px 8px 8px;
        text-align: center;
        color: var(--hc-muted);
        font-size: 14.5px;
        line-height: 1.6;
    }
    .hc-empty a { color: var(--hc-accent-text); font-weight: 600; }

    /* ===== Contact ===== */
    .hc-contact-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 14px;
    }

    .hc-contact {
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding: 18px;
        border: 1px solid var(--hc-line);
        border-radius: 14px;
    }

    .hc-contact-head { display: flex; align-items: center; gap: 14px; }

    .hc-contact-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background: var(--hc-warm);
        color: #b45309;
    }

    .hc-contact-title { font-size: 15px; font-weight: 700; }
    .hc-contact-sub { font-size: 13px; color: var(--hc-muted); margin-top: 2px; line-height: 1.4; }

    .hc-status {
        align-self: flex-start;
        font-size: 12px;
        font-weight: 600;
        padding: 3px 10px;
        border-radius: 999px;
    }
    .hc-status:empty { display: none; }
    .hc-status.is-open { background: #e7f6ec; color: #1a7f37; }
    .hc-status.is-closed { background: #eef0f3; color: #5f6b7a; }

    .hc-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        min-height: 44px;
        padding: 0 18px;
        border: 0;
        border-radius: 10px;
        background: var(--hc-accent);
        color: #1f1305;
        font-size: 14px;
        font-weight: 700;
        text-decoration: none;
        cursor: pointer;
        margin-top: auto;
    }
    .hc-btn:hover { background: #e98a36; }
    .hc-btn .material-symbols-outlined { font-size: 20px; }

    /* ===== Toast ===== */
    .hc-toast {
        position: fixed;
        left: 50%;
        bottom: calc(20px + env(safe-area-inset-bottom, 0px));
        transform: translate(-50%, 20px);
        max-width: calc(100% - 32px);
        background: #1f2933;
        color: #fff;
        padding: 12px 18px;
        border-radius: 10px;
        font-size: 14px;
        opacity: 0;
        pointer-events: none;
        transition: opacity .25s ease, transform .25s ease;
        z-index: 1000;
    }
    .hc-toast.is-on { opacity: 1; transform: translate(-50%, 0); }

    /* ===== Responsive ===== */
    @media (max-width: 760px) {
        .hc-tools { grid-template-columns: repeat(3, 1fr); }
    }

    @media (max-width: 600px) {
        :root { --hc-header-offset: 145px; }   /* the site header is taller on phones */
        .hc-tools { grid-template-columns: repeat(2, 1fr); gap: 10px; }
        .hc-popular { font-size: 12.5px; }
    }

    @media (max-width: 360px) {
        .hc-tool-label { font-size: 12.5px; }
        .hc-topic { padding: 8px 12px; font-size: 13px; }
    }

    /* ===== Scroll reveal =====
       Blocks start hidden + 40px lower, then fade and slide up when scrolled into view.
       Nothing is hidden unless the head script added "js-reveal" to <html>. */
    .js-reveal .hc-reveal {
        opacity: 0;
        transform: translateY(40px);
        transition:
            opacity 0.7s ease,
            transform 0.7s cubic-bezier(0.22, 1, 0.36, 1);
    }
    /* `none` (not translateY(0)) so the block never becomes a containing block for fixed/sticky children */
    .js-reveal .hc-reveal.reveal--in {
        opacity: 1;
        transform: none;
    }

    @media (prefers-reduced-motion: reduce) {
        .hc-tool, .hc-topic, .hc-faq summary::after, .hc-toast { transition: none; }
        .hc-tool:hover { transform: none; }
    }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/components/header.jsp" />

<main class="hc-container" id="top">

    <!-- Breadcrumb -->
    <nav class="hc-breadcrumb" aria-label="Breadcrumb">
        <a href="${pageContext.request.contextPath}/">Home</a>
        <span aria-hidden="true">/</span>
        <span aria-current="page">Help Center</span>
    </nav>

    <!-- Hero + search -->
    <section class="hc-card hc-hero hc-reveal" aria-labelledby="hcHeading">
        <h1 id="hcHeading">Hi, how can we help?</h1>
        <p>Search our help articles or pick a topic below.</p>

        <form class="hc-search" id="hcSearchForm" role="search">
            <label for="hcSearch" class="sr-only" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap;">Search help articles</label>
            <input type="search" id="hcSearch" name="q" placeholder="Search for topics, questions..." autocomplete="off">
            <button type="submit" aria-label="Search">
                <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" aria-hidden="true">
                    <circle cx="11" cy="11" r="7"></circle>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
            </button>
        </form>

        <div class="hc-popular">
            <span>Popular:</span>
            <button type="button" class="hc-chip" data-q="order">Placing an order</button>
            <button type="button" class="hc-chip" data-q="voucher">Vouchers</button>
            <button type="button" class="hc-chip" data-q="return">Returns</button>
            <button type="button" class="hc-chip" data-q="profile">My profile</button>
        </div>
    </section>

    <!-- Self-service tools -->
    <section class="hc-card hc-reveal" aria-labelledby="hcToolsTitle">
        <h2 class="hc-card-title" id="hcToolsTitle">Self Service Tools</h2>
        <p class="hc-card-sub">Manage your account without waiting for support.</p>

        <div class="hc-tools">
            <a class="hc-tool" href="#" data-soon="My Orders">
                <span class="hc-soon-tag">Soon</span>
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">receipt_long</span></span>
                <span class="hc-tool-label">My Orders</span>
            </a>
            <a class="hc-tool" href="#" data-soon="Password reset">
                <span class="hc-soon-tag">Soon</span>
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">lock_reset</span></span>
                <span class="hc-tool-label">Reset Password</span>
            </a>
            <a class="hc-tool" href="#" data-soon="My Vouchers">
                <span class="hc-soon-tag">Soon</span>
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">local_activity</span></span>
                <span class="hc-tool-label">My Vouchers</span>
            </a>
            <a class="hc-tool" href="#" data-soon="My Cancellations">
                <span class="hc-soon-tag">Soon</span>
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">free_cancellation</span></span>
                <span class="hc-tool-label">My Cancellations</span>
            </a>
            <a class="hc-tool" href="#" data-soon="My Returns">
                <span class="hc-soon-tag">Soon</span>
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">assignment_return</span></span>
                <span class="hc-tool-label">My Returns</span>
            </a>
            <a class="hc-tool" href="#" data-soon="Payment options">
                <span class="hc-soon-tag">Soon</span>
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">payments</span></span>
                <span class="hc-tool-label">My Payment Options</span>
            </a>
            <a class="hc-tool" href="#" data-soon="Delivery address changes">
                <span class="hc-soon-tag">Soon</span>
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">location_on</span></span>
                <span class="hc-tool-label">Change Delivery Address</span>
            </a>
            <a class="hc-tool" href="${pageContext.request.contextPath}/myprofile">
                <span class="hc-tool-icon"><span class="material-symbols-outlined" aria-hidden="true">account_circle</span></span>
                <span class="hc-tool-label">My Profile</span>
            </a>
        </div>
    </section>

    <!-- Topics + FAQ -->
    <section class="hc-card hc-reveal" id="faq" aria-labelledby="hcFaqTitle">
        <h2 class="hc-card-title" id="hcFaqTitle">Top Questions</h2>
        <p class="hc-card-sub">Choose a topic or use the search box above.</p>

        <div class="hc-topics" role="group" aria-label="Filter questions by topic">
            <button type="button" class="hc-topic" data-topic="all" aria-pressed="true">All</button>
            <button type="button" class="hc-topic" data-topic="orders" aria-pressed="false">Orders &amp; Delivery</button>
            <button type="button" class="hc-topic" data-topic="payments" aria-pressed="false">Payments &amp; Vouchers</button>
            <button type="button" class="hc-topic" data-topic="returns" aria-pressed="false">Returns &amp; Cancellations</button>
            <button type="button" class="hc-topic" data-topic="account" aria-pressed="false">Account</button>
            <button type="button" class="hc-topic" data-topic="selling" aria-pressed="false">Selling</button>
        </div>

        <p class="hc-count" id="hcCount" aria-live="polite"></p>

        <div class="hc-faq-list" id="hcFaqList">

            <details class="hc-faq" data-topic="orders">
                <summary>How do I place an order on Aalmari?</summary>
                <div class="hc-answer">
                    Open the product you want, choose the quantity and click <strong>Add to Cart</strong>.
                    Then open your cart from the bag icon at the top right to review your items and continue.
                </div>
            </details>

            <details class="hc-faq" data-topic="orders">
                <summary>Can I change my order details after placing an order?</summary>
                <div class="hc-answer">
                    It depends on whether the seller has already started processing your order.
                    Contact customer care as soon as possible with your order details and we will check what can be changed.
                </div>
            </details>

            <details class="hc-faq" data-topic="orders">
                <summary>What is the Aalmari collection point service and how do I use it?</summary>
                <div class="hc-answer">
                    A collection point lets you pick up your parcel from a nearby location instead of having it delivered to your door.
                    Availability depends on your area, so contact customer care to ask which locations near you are supported.
                </div>
            </details>

            <details class="hc-faq" data-topic="orders">
                <summary>How can I contact the seller of a product?</summary>
                <div class="hc-answer">
                    Open the product page and click <strong>Go to Store</strong> to visit the seller's store and see their other products.
                </div>
            </details>

            <details class="hc-faq" data-topic="payments">
                <summary>Why am I unable to use my collectible vouchers?</summary>
                <div class="hc-answer">
                    Vouchers can come with conditions such as a minimum spend, an expiry date or specific eligible categories.
                    Check the voucher terms first. If it still does not apply, contact customer care and include a screenshot.
                </div>
            </details>

            <details class="hc-faq" data-topic="payments">
                <summary>What payment options are available?</summary>
                <div class="hc-answer">
                    The payment methods you can use are shown at checkout.
                    If a method you expect is missing, contact customer care and tell us which one you were looking for.
                </div>
            </details>

            <details class="hc-faq" data-topic="returns">
                <summary>How do I return an item or cancel an order?</summary>
                <div class="hc-answer">
                    Eligibility depends on the product and the seller. Contact customer care with your order number and the reason,
                    and we will guide you through the next steps.
                </div>
            </details>

            <details class="hc-faq" data-topic="account">
                <summary>How do I update my profile details?</summary>
                <div class="hc-answer">
                    Open <a href="${pageContext.request.contextPath}/myprofile">My Profile</a> from the account menu at the top right of any page.
                </div>
            </details>

            <details class="hc-faq" data-topic="selling">
                <summary>How do I sell my products on Aalmari?</summary>
                <div class="hc-answer">
                    Create a seller account and add your products from the Seller Dashboard.
                    If you need help getting started, contact customer care.
                </div>
            </details>

        </div>

        <div class="hc-empty" id="hcEmpty" hidden>
            <p>No articles match your search.</p>
            <p>Try different keywords, or <a href="#contact">contact our team</a>.</p>
        </div>
    </section>

    <!-- Contact -->
    <section class="hc-card hc-reveal" id="contact" aria-labelledby="hcContactTitle">
        <h2 class="hc-card-title" id="hcContactTitle">Still need help?</h2>
        <p class="hc-card-sub">Our customer care team is happy to help. Times are Nepal time.</p>

        <div class="hc-contact-grid">

            <div class="hc-contact">
                <div class="hc-contact-head">
                    <span class="hc-contact-icon"><span class="material-symbols-outlined" aria-hidden="true">support_agent</span></span>
                    <div>
                        <div class="hc-contact-title">Contact Customer Care</div>
                        <div class="hc-contact-sub">Live Chat: 9AM - 6PM [Mon-Sun]</div>
                    </div>
                </div>
                <span class="hc-status" data-hours="chat"></span>
                <button type="button" class="hc-btn" data-soon="Live chat">
                    <span class="material-symbols-outlined" aria-hidden="true">chat</span> Start live chat
                </button>
            </div>

            <div class="hc-contact">
                <div class="hc-contact-head">
                    <span class="hc-contact-icon"><span class="material-symbols-outlined" aria-hidden="true">call</span></span>
                    <div>
                        <div class="hc-contact-title">Call us 01-5970597</div>
                        <div class="hc-contact-sub">9AM - 6PM [Sun-Fri]</div>
                    </div>
                </div>
                <span class="hc-status" data-hours="phone"></span>
                <a class="hc-btn" href="tel:+97715970597">
                    <span class="material-symbols-outlined" aria-hidden="true">call</span> Call now
                </a>
            </div>

            <div class="hc-contact">
                <div class="hc-contact-head">
                    <span class="hc-contact-icon"><span class="material-symbols-outlined" aria-hidden="true">mail</span></span>
                    <div>
                        <div class="hc-contact-title">Email us</div>
                        <div class="hc-contact-sub">support@aalmari.com</div>
                    </div>
                </div>
                <a class="hc-btn" href="mailto:support@aalmari.com">
                    <span class="material-symbols-outlined" aria-hidden="true">mail</span> Send an email
                </a>
            </div>

        </div>
    </section>

</main>

<div class="hc-toast" id="hcToast" role="status" aria-live="polite"></div>

<jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
(function () {
    'use strict';

    var reduceMotion = !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);

    /* ---------- Search + topic filter ---------- */
    var items     = Array.prototype.slice.call(document.querySelectorAll('.hc-faq'));
    var topicBtns = Array.prototype.slice.call(document.querySelectorAll('.hc-topic'));
    var chips     = Array.prototype.slice.call(document.querySelectorAll('.hc-chip'));
    var input     = document.getElementById('hcSearch');
    var form      = document.getElementById('hcSearchForm');
    var empty     = document.getElementById('hcEmpty');
    var count     = document.getElementById('hcCount');
    var faq       = document.getElementById('faq');
    var topic     = 'all';

    function setTopic(t) {
        topic = t;
        topicBtns.forEach(function (b) {
            b.setAttribute('aria-pressed', b.getAttribute('data-topic') === t ? 'true' : 'false');
        });
    }

    function apply() {
        var q = input.value.trim().toLowerCase();
        var words = q ? q.split(/\s+/) : [];
        var shown = 0;

        items.forEach(function (item) {
            var okTopic = topic === 'all' || item.getAttribute('data-topic') === topic;
            var text = item.textContent.toLowerCase();
            var okQuery = words.every(function (w) { return text.indexOf(w) !== -1; });
            var ok = okTopic && okQuery;
            item.hidden = !ok;
            if (ok) shown++;
        });

        empty.hidden = shown !== 0;
        count.textContent = shown + (shown === 1 ? ' article' : ' articles');
    }

    function scrollToFaq() {
        faq.scrollIntoView({ behavior: reduceMotion ? 'auto' : 'smooth', block: 'start' });
    }

    input.addEventListener('input', function () { setTopic('all'); apply(); });
    input.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && input.value) { input.value = ''; apply(); }
    });
    form.addEventListener('submit', function (e) { e.preventDefault(); apply(); scrollToFaq(); });

    topicBtns.forEach(function (b) {
        b.addEventListener('click', function () {
            input.value = '';
            setTopic(b.getAttribute('data-topic'));
            apply();
        });
    });

    chips.forEach(function (c) {
        c.addEventListener('click', function () {
            input.value = c.getAttribute('data-q');
            setTopic('all');
            apply();
            scrollToFaq();
        });
    });

    apply();

    /* ---------- "Coming soon" toast for features that are not built yet ---------- */
    var toast = document.getElementById('hcToast');
    var toastTimer = null;

    function showToast(msg) {
        toast.textContent = msg;
        toast.classList.add('is-on');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { toast.classList.remove('is-on'); }, 2600);
    }

    document.addEventListener('click', function (e) {
        var el = e.target.closest('[data-soon]');
        if (!el) return;
        e.preventDefault();
        showToast(el.getAttribute('data-soon') + ' is coming soon.');
    });

    /* ---------- Open / closed badges (Nepal time, UTC+5:45) ---------- */
    function nepalNow() {
        var parts = new Intl.DateTimeFormat('en-US', {
            timeZone: 'Asia/Kathmandu', weekday: 'short', hour: 'numeric', hour12: false
        }).formatToParts(new Date());
        var o = {};
        parts.forEach(function (p) { o[p.type] = p.value; });
        return { day: o.weekday, hour: parseInt(o.hour, 10) % 24 };
    }

    function updateHours() {
        try {
            var now = nepalNow();
            var inHours = now.hour >= 9 && now.hour < 18;
            Array.prototype.forEach.call(document.querySelectorAll('[data-hours]'), function (el) {
                var phone = el.getAttribute('data-hours') === 'phone';
                var open = inHours && (!phone || now.day !== 'Sat');   // phone line: Sun-Fri
                el.textContent = open ? 'Open now' : 'Closed now';
                el.classList.toggle('is-open', open);
                el.classList.toggle('is-closed', !open);
            });
        } catch (err) { /* badges simply stay hidden */ }
    }
    updateHours();
    setInterval(updateHours, 60000);

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

        Array.prototype.forEach.call(document.querySelectorAll('.hc-reveal'), function (el) { io.observe(el); });
    }
})();
</script>

</body>
</html>
