<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Contact Aalmari customer care by phone, email or message form. Support hours are 9AM to 6PM Nepal time.">
<title>Contact Us — Aalmari Store</title>
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" />
<jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />

<!-- Structured data: contact details for search engines -->
<script type="application/ld+json">
{
  "@context": "https://schema.org",
  "@type": "ContactPage",
  "name": "Contact Aalmari",
  "mainEntity": {
    "@type": "Organization",
    "name": "Aalmari",
    "email": "support@aalmari.com",
    "telephone": "+977-1-5970597",
    "contactPoint": {
      "@type": "ContactPoint",
      "contactType": "customer support",
      "telephone": "+977-1-5970597",
      "email": "support@aalmari.com",
      "areaServed": "NP",
      "availableLanguage": ["English", "Nepali"]
    }
  }
}
</script>

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
        --ct-header-offset: 90px;          /* space for the fixed site header */
        --ct-accent: #f2994a;
        --ct-accent-text: #b45309;         /* darker orange: readable on white */
        --ct-ink: #1f2933;
        --ct-muted: #5f6b7a;
        --ct-line: #eceff3;
        --ct-warm: #fdf1e4;
        --ct-error: #b42318;
        --ct-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
    }

    html { -webkit-text-size-adjust: 100%; }

    body {
        background: linear-gradient(135deg, #ffffff 0%, #fdf1e4 40%, #f6c99a 75%, #f2a86b 100%);
        min-height: 100vh;
        color: var(--ct-ink);
    }

    [hidden] { display: none !important; }

    a:focus-visible,
    button:focus-visible,
    input:focus-visible,
    select:focus-visible,
    textarea:focus-visible {
        outline: 3px solid #1d4ed8;
        outline-offset: 2px;
    }

    /* ===== Layout ===== */
    .ct-container {
        width: 100%;
        max-width: 1000px;
        margin: 0 auto;
        padding: var(--ct-header-offset) clamp(12px, 4vw, 24px) 48px;
    }

    .ct-card {
        background: #ffffff;
        border-radius: 16px;
        padding: clamp(20px, 4vw, 32px) clamp(16px, 4vw, 32px);
        margin-bottom: 20px;
        box-shadow: var(--ct-shadow);
        scroll-margin-top: calc(var(--ct-header-offset) + 12px);
    }

    .ct-card h2 {
        font-size: clamp(18px, 3vw, 21px);
        line-height: 1.3;
        margin-bottom: 6px;
    }

    .ct-card-sub {
        font-size: 14.5px;
        color: var(--ct-muted);
        margin-bottom: 22px;
        line-height: 1.6;
        max-width: 62ch;
    }

    /* ===== Breadcrumb ===== */
    .ct-breadcrumb {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: var(--ct-muted);
        margin-bottom: 14px;
    }
    .ct-breadcrumb a { color: var(--ct-accent-text); text-decoration: none; }
    .ct-breadcrumb a:hover { text-decoration: underline; }
    .ct-breadcrumb [aria-current="page"] { color: var(--ct-ink); font-weight: 600; }

    /* ===== Hero ===== */
    .ct-hero { padding: clamp(26px, 5vw, 44px) clamp(18px, 5vw, 44px); }

    .ct-hero h1 {
        font-size: clamp(26px, 5.2vw, 36px);
        line-height: 1.2;
        letter-spacing: -0.01em;
        margin-bottom: 12px;
    }

    .ct-hero p {
        font-size: clamp(15px, 2.2vw, 16.5px);
        line-height: 1.7;
        color: var(--ct-muted);
        max-width: 58ch;
    }

    /* ===== Contact methods ===== */
    .ct-methods {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 14px;
    }

    .ct-method {
        display: flex;
        flex-direction: column;
        gap: 12px;
        padding: 18px;
        border: 1px solid var(--ct-line);
        border-radius: 14px;
    }

    .ct-method-head { display: flex; align-items: center; gap: 14px; }

    .ct-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background: var(--ct-warm);
        color: #b45309;
    }
    .ct-icon .material-symbols-outlined { font-size: 26px; }

    .ct-method-title { font-size: 15px; font-weight: 700; }
    .ct-method-sub { font-size: 13px; color: var(--ct-muted); margin-top: 2px; line-height: 1.4; word-break: break-word; }

    .ct-status {
        align-self: flex-start;
        font-size: 12px;
        font-weight: 600;
        padding: 3px 10px;
        border-radius: 999px;
    }
    .ct-status:empty { display: none; }
    .ct-status.is-open { background: #e7f6ec; color: #1a7f37; }
    .ct-status.is-closed { background: #eef0f3; color: #5f6b7a; }

    .ct-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        min-height: 46px;
        padding: 0 20px;
        border: 0;
        border-radius: 10px;
        background: var(--ct-accent);
        color: #1f1305;
        font-size: 14.5px;
        font-weight: 700;
        text-decoration: none;
        cursor: pointer;
        transition: background .15s ease;
    }
    .ct-btn:hover { background: #e98a36; }
    .ct-btn:disabled { background: #f3cfa6; cursor: not-allowed; }
    .ct-btn .material-symbols-outlined { font-size: 20px; }
    .ct-method .ct-btn { margin-top: auto; }

    .ct-btn--ghost {
        background: #fff;
        border: 1px solid #e3c9a6;
        color: #7a4a0d;
    }
    .ct-btn--ghost:hover { background: var(--ct-warm); }

    /* ===== Form + sidebar ===== */
    .ct-split {
        display: grid;
        grid-template-columns: minmax(0, 1.7fr) minmax(0, 1fr);
        gap: 20px;
        align-items: start;
        margin-bottom: 20px;
    }
    .ct-split .ct-card { margin-bottom: 0; }
    .ct-aside { display: grid; gap: 20px; }

    .ct-alert {
        display: flex;
        gap: 10px;
        align-items: flex-start;
        padding: 14px 16px;
        border-radius: 12px;
        margin-bottom: 20px;
        font-size: 14.5px;
        line-height: 1.55;
    }
    .ct-alert .material-symbols-outlined { font-size: 22px; flex-shrink: 0; }
    .ct-alert--ok  { background: #e7f6ec; color: #14532d; }
    .ct-alert--err { background: #fdecea; color: #7a1c13; }
    .ct-alert--err a { color: inherit; font-weight: 600; }

    .ct-form { display: grid; gap: 18px; }

    .ct-row {
        display: grid;
        grid-template-columns: repeat(2, minmax(0, 1fr));
        gap: 18px;
    }

    .ct-field { display: grid; gap: 6px; align-content: start; }

    .ct-field label {
        font-size: 13.5px;
        font-weight: 600;
        color: var(--ct-ink);
    }
    .ct-opt { font-weight: 400; color: var(--ct-muted); }
    .ct-req { color: var(--ct-error); }

    .ct-field input,
    .ct-field select,
    .ct-field textarea {
        outline: none;
        width: 100%;
        min-height: 48px;
        padding: 12px 14px;
        border: 1px solid #d9dee5;
        border-radius: 10px;
        background: #fafafa;
        font-size: 16px;               /* 16px stops iOS from zooming on focus */
        color: var(--ct-ink);
    }
    .ct-field textarea { min-height: 140px; resize: vertical; line-height: 1.55; }
    .ct-field input:hover,
    .ct-field select:hover,
    .ct-field textarea:hover { border-color: #c4cbd4; }
    .ct-field input:focus,
    .ct-field select:focus,
    .ct-field textarea:focus { background: #fff; border-color: #1d4ed8; }

    .ct-field [aria-invalid="true"] { border-color: var(--ct-error); background: #fffafa; }

    .ct-error { font-size: 13px; color: var(--ct-error); line-height: 1.4; }
    .ct-error:empty { display: none; }

    .ct-hint { font-size: 12.5px; color: var(--ct-muted); display: flex; justify-content: space-between; gap: 12px; }

    /* Honeypot: hidden from people, visible to simple bots */
    .ct-trap { position: absolute; left: -9999px; width: 1px; height: 1px; overflow: hidden; }

    .ct-form-foot {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 14px;
    }
    .ct-note { font-size: 12.5px; color: var(--ct-muted); line-height: 1.5; flex: 1; min-width: 200px; }

    /* ===== Aside ===== */
    .ct-hours { list-style: none; }
    .ct-hours li {
        display: flex;
        justify-content: space-between;
        gap: 12px;
        padding: 10px 0;
        border-bottom: 1px solid var(--ct-line);
        font-size: 14px;
        line-height: 1.4;
    }
    .ct-hours li:last-child { border-bottom: 0; padding-bottom: 0; }
    .ct-hours span:last-child { color: var(--ct-muted); text-align: right; }

    .ct-tips { list-style: none; display: grid; gap: 12px; }
    .ct-tips li {
        display: flex;
        gap: 10px;
        font-size: 14px;
        line-height: 1.55;
        color: #3d4753;
    }
    .ct-tips .material-symbols-outlined { font-size: 20px; color: #b45309; flex-shrink: 0; margin-top: 1px; }

    .ct-aside .ct-card-sub { margin-bottom: 14px; }

    /* ===== Toast ===== */
    .ct-toast {
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
    .ct-toast.is-on { opacity: 1; transform: translate(-50%, 0); }

    /* ===== Responsive ===== */
    @media (max-width: 800px) {
        .ct-split { grid-template-columns: 1fr; }
    }

    @media (max-width: 600px) {
        :root { --ct-header-offset: 145px; }   /* the site header is taller on phones */
        .ct-row { grid-template-columns: 1fr; }
        .ct-form-foot .ct-btn { width: 100%; }
    }

    @media (max-width: 360px) {
        .ct-method { padding: 14px; }
    }

    /* ===== Scroll reveal =====
       Blocks start hidden + 40px lower, then fade and slide up when scrolled into view.
       Nothing is hidden unless the head script added "js-reveal" to <html>. */
    .js-reveal .ct-reveal {
        opacity: 0;
        transform: translateY(40px);
        transition:
            opacity 0.7s ease,
            transform 0.7s cubic-bezier(0.22, 1, 0.36, 1);
    }
    /* `none` (not translateY(0)) so the block never becomes a containing block for fixed/sticky children */
    .js-reveal .ct-reveal.reveal--in {
        opacity: 1;
        transform: none;
    }

    @media (prefers-reduced-motion: reduce) {
        .ct-btn, .ct-toast { transition: none; }
    }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/components/header.jsp" />

<main class="ct-container" id="top">

    <!-- Breadcrumb -->
    <nav class="ct-breadcrumb" aria-label="Breadcrumb">
        <a href="${pageContext.request.contextPath}/">Home</a>
        <span aria-hidden="true">/</span>
        <span aria-current="page">Contact Us</span>
    </nav>

    <!-- Hero -->
    <section class="ct-card ct-hero ct-reveal" aria-labelledby="ctHeading">
        <h1 id="ctHeading">We are here to help</h1>
        <p>
            Call us, send an email or fill in the form below. Our customer care team replies as soon as they can.
            Times on this page are Nepal time.
        </p>
    </section>

    <!-- Contact methods -->
    <section class="ct-card ct-reveal" aria-labelledby="ctMethodsTitle">
        <h2 id="ctMethodsTitle">Choose how to reach us</h2>
        <p class="ct-card-sub">Pick the option that suits you best.</p>

        <div class="ct-methods">

            <div class="ct-method">
                <div class="ct-method-head">
                    <span class="ct-icon"><span class="material-symbols-outlined" aria-hidden="true">support_agent</span></span>
                    <div>
                        <div class="ct-method-title">Live chat</div>
                        <div class="ct-method-sub">9AM - 6PM [Mon-Sun]</div>
                    </div>
                </div>
                <span class="ct-status" data-hours="chat"></span>
                <button type="button" class="ct-btn" data-soon="Live chat">
                    <span class="material-symbols-outlined" aria-hidden="true">chat</span> Start live chat
                </button>
            </div>

            <div class="ct-method">
                <div class="ct-method-head">
                    <span class="ct-icon"><span class="material-symbols-outlined" aria-hidden="true">call</span></span>
                    <div>
                        <div class="ct-method-title">Call us 01-5970597</div>
                        <div class="ct-method-sub">9AM - 6PM [Sun-Fri]</div>
                    </div>
                </div>
                <span class="ct-status" data-hours="phone"></span>
                <a class="ct-btn" href="tel:+97715970597">
                    <span class="material-symbols-outlined" aria-hidden="true">call</span> Call now
                </a>
            </div>

            <div class="ct-method">
                <div class="ct-method-head">
                    <span class="ct-icon"><span class="material-symbols-outlined" aria-hidden="true">mail</span></span>
                    <div>
                        <div class="ct-method-title">Email us</div>
                        <div class="ct-method-sub">support@aalmari.com</div>
                    </div>
                </div>
                <a class="ct-btn" href="mailto:support@aalmari.com">
                    <span class="material-symbols-outlined" aria-hidden="true">mail</span> Send an email
                </a>
            </div>

        </div>
    </section>

    <!-- Form + sidebar -->
    <div class="ct-split">

        <section class="ct-card ct-reveal" id="message" aria-labelledby="ctFormTitle">
            <h2 id="ctFormTitle">Send us a message</h2>
            <p class="ct-card-sub">Fields marked with <span class="ct-req" aria-hidden="true">*</span><span class="sr-only" style="position:absolute;width:1px;height:1px;overflow:hidden;clip:rect(0 0 0 0);white-space:nowrap;">an asterisk</span> are required.</p>

            <!-- Shown after the server redirects back with ?sent=1 or ?error=1 -->
            <div class="ct-alert ct-alert--ok" role="status" ${param.sent eq '1' ? '' : 'hidden'}>
                <span class="material-symbols-outlined" aria-hidden="true">check_circle</span>
                <span>Thank you. Your message has been sent and our team will get back to you by email.</span>
            </div>
            <div class="ct-alert ct-alert--err" role="alert" ${param.error eq '1' ? '' : 'hidden'}>
                <span class="material-symbols-outlined" aria-hidden="true">error</span>
                <span>Sorry, we could not send your message. Please try again, or email us at <a href="mailto:support@aalmari.com">support@aalmari.com</a>.</span>
            </div>

            <form class="ct-form" id="ctForm" method="post" action="${pageContext.request.contextPath}/contactus" novalidate>

                <div class="ct-row">
                    <div class="ct-field">
                        <label for="ctName">Full name <span class="ct-req" aria-hidden="true">*</span></label>
                        <input type="text" id="ctName" name="name" maxlength="100" autocomplete="name" required aria-describedby="ctName-error">
                        <span class="ct-error" id="ctName-error"></span>
                    </div>
                    <div class="ct-field">
                        <label for="ctEmail">Email address <span class="ct-req" aria-hidden="true">*</span></label>
                        <input type="email" id="ctEmail" name="email" maxlength="150" autocomplete="email" inputmode="email" required aria-describedby="ctEmail-error">
                        <span class="ct-error" id="ctEmail-error"></span>
                    </div>
                </div>

                <div class="ct-row">
                    <div class="ct-field">
                        <label for="ctPhone">Phone number <span class="ct-opt">(optional)</span></label>
                        <input type="tel" id="ctPhone" name="phone" maxlength="20" autocomplete="tel" inputmode="tel" aria-describedby="ctPhone-error">
                        <span class="ct-error" id="ctPhone-error"></span>
                    </div>
                    <div class="ct-field">
                        <label for="ctTopic">Topic <span class="ct-req" aria-hidden="true">*</span></label>
                        <select id="ctTopic" name="topic" required aria-describedby="ctTopic-error">
                            <option value="">Select a topic</option>
                            <option value="orders">Orders &amp; Delivery</option>
                            <option value="payments">Payments &amp; Vouchers</option>
                            <option value="returns">Returns &amp; Cancellations</option>
                            <option value="account">My Account</option>
                            <option value="selling">Selling on Aalmari</option>
                            <option value="feedback">Feedback or Other</option>
                        </select>
                        <span class="ct-error" id="ctTopic-error"></span>
                    </div>
                </div>

                <div class="ct-field">
                    <label for="ctOrder">Order number <span class="ct-opt">(optional)</span></label>
                    <input type="text" id="ctOrder" name="orderNumber" maxlength="50" autocomplete="off" aria-describedby="ctOrder-hint">
                    <span class="ct-hint" id="ctOrder-hint">Add it if your message is about a specific order.</span>
                </div>

                <div class="ct-field">
                    <label for="ctMessage">Message <span class="ct-req" aria-hidden="true">*</span></label>
                    <textarea id="ctMessage" name="message" maxlength="1000" required aria-describedby="ctMessage-error ctMessage-count"></textarea>
                    <span class="ct-error" id="ctMessage-error"></span>
                    <span class="ct-hint"><span>Tell us what happened and what you need.</span><span id="ctMessage-count" aria-live="off">0 / 1000</span></span>
                </div>

                <!-- Honeypot: leave empty -->
                <div class="ct-trap" aria-hidden="true">
                    <label for="ctWebsite">Website</label>
                    <input type="text" id="ctWebsite" name="website" tabindex="-1" autocomplete="off">
                </div>

                <div class="ct-form-foot">
                    <button type="submit" class="ct-btn" id="ctSubmit">
                        <span class="material-symbols-outlined" aria-hidden="true">send</span>
                        <span id="ctSubmitLabel">Send message</span>
                    </button>
                    <p class="ct-note">We only use your details to reply to this message.</p>
                </div>
            </form>
        </section>

        <aside class="ct-aside" aria-label="Support information">

            <section class="ct-card ct-reveal" aria-labelledby="ctHoursTitle">
                <h2 id="ctHoursTitle">Support hours</h2>
                <p class="ct-card-sub">All times are Nepal time.</p>
                <ul class="ct-hours">
                    <li><span>Live chat</span><span>9AM - 6PM, Mon-Sun</span></li>
                    <li><span>Phone</span><span>9AM - 6PM, Sun-Fri</span></li>
                    <li><span>Email</span><span>Send anytime</span></li>
                </ul>
            </section>

            <section class="ct-card ct-reveal" aria-labelledby="ctTipsTitle">
                <h2 id="ctTipsTitle">Help us help you faster</h2>
                <p class="ct-card-sub">Include these details if you can.</p>
                <ul class="ct-tips">
                    <li><span class="material-symbols-outlined" aria-hidden="true">receipt_long</span><span>Your order number, if the question is about an order.</span></li>
                    <li><span class="material-symbols-outlined" aria-hidden="true">image</span><span>A screenshot, for voucher or payment problems.</span></li>
                    <li><span class="material-symbols-outlined" aria-hidden="true">mail</span><span>The email address you used to register.</span></li>
                </ul>
            </section>

        </aside>
    </div>

    <!-- Help Center link -->
    <section class="ct-card ct-reveal" aria-labelledby="ctHelpTitle">
        <h2 id="ctHelpTitle">Looking for a quick answer?</h2>
        <p class="ct-card-sub">Many common questions about orders, vouchers, returns and your account are answered in our Help Center.</p>
        <a class="ct-btn ct-btn--ghost" href="${pageContext.request.contextPath}/helpcenter">
            <span class="material-symbols-outlined" aria-hidden="true">help</span> Visit the Help Center
        </a>
    </section>

</main>

<div class="ct-toast" id="ctToast" role="status" aria-live="polite"></div>

<jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
(function () {
    'use strict';

    /* ---------- Form validation ---------- */
    var form    = document.getElementById('ctForm');
    var submit  = document.getElementById('ctSubmit');
    var label   = document.getElementById('ctSubmitLabel');
    var message = document.getElementById('ctMessage');
    var counter = document.getElementById('ctMessage-count');
    var trap    = document.getElementById('ctWebsite');

    var EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

    var rules = {
        name: function (v) {
            if (!v) return 'Enter your full name.';
            if (v.length < 2) return 'Your name must be at least 2 characters.';
            return '';
        },
        email: function (v) {
            if (!v) return 'Enter your email address.';
            if (!EMAIL.test(v)) return 'Enter a valid email address, for example name@example.com.';
            return '';
        },
        phone: function (v) {
            if (!v) return '';
            var digits = v.replace(/\D/g, '');
            if (!/^[0-9+\-\s()]+$/.test(v) || digits.length < 7 || digits.length > 15) {
                return 'Enter a valid phone number (7 to 15 digits).';
            }
            return '';
        },
        topic: function (v) {
            return v ? '' : 'Select a topic.';
        },
        message: function (v) {
            if (!v) return 'Enter your message.';
            if (v.length < 10) return 'Your message must be at least 10 characters.';
            return '';
        }
    };

    function fieldOf(name) { return form.elements[name]; }

    function showError(name, text) {
        var field = fieldOf(name);
        var out = document.getElementById(field.id + '-error');
        out.textContent = text;
        if (text) { field.setAttribute('aria-invalid', 'true'); }
        else { field.removeAttribute('aria-invalid'); }
    }

    function check(name) {
        var field = fieldOf(name);
        var text = rules[name](field.value.trim());
        showError(name, text);
        return text === '';
    }

    Object.keys(rules).forEach(function (name) {
        var field = fieldOf(name);
        field.addEventListener('blur', function () { check(name); });
        field.addEventListener('input', function () {
            if (field.getAttribute('aria-invalid') === 'true') { check(name); }
        });
        field.addEventListener('change', function () {
            if (field.getAttribute('aria-invalid') === 'true') { check(name); }
        });
    });

    function updateCount() {
        counter.textContent = message.value.length + ' / 1000';
    }
    message.addEventListener('input', updateCount);
    updateCount();

    form.addEventListener('submit', function (e) {
        var firstBad = null;
        Object.keys(rules).forEach(function (name) {
            if (!check(name) && !firstBad) { firstBad = fieldOf(name); }
        });

        if (firstBad) {
            e.preventDefault();
            firstBad.focus();
            return;
        }

        if (trap.value) {            /* a bot filled the hidden field: pretend success, send nothing */
            e.preventDefault();
            return;
        }

        submit.disabled = true;      /* stops double submits */
        label.textContent = 'Sending...';
    });

    /* Restore the button if the user comes back with the browser's back button */
    window.addEventListener('pageshow', function () {
        submit.disabled = false;
        label.textContent = 'Send message';
    });

    /* ---------- "Coming soon" toast for features that are not built yet ---------- */
    var toast = document.getElementById('ctToast');
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

        Array.prototype.forEach.call(document.querySelectorAll('.ct-reveal'), function (el) { io.observe(el); });
    }
})();
</script>

</body>
</html>
