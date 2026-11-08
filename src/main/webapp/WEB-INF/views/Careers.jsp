<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Set, java.util.LinkedHashSet, java.net.URLEncoder" %>
<%!
    /* Escapes text before it is written into HTML */
    private static String esc(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    /* ===== OPEN POSITIONS =====
       Add one row per job: { "Job title", "Department", "Location", "Job type", "Short summary" }
       Example:
           { "Customer Care Executive", "Customer Care", "Kathmandu", "Full-time", "Help shoppers with orders, vouchers and returns." }
       Leave the list empty when there are no openings: the page then shows a friendly message instead. */
    String[][] jobs = {
    };

    Set<String> departments = new LinkedHashSet<String>();
    for (String[] j : jobs) { departments.add(j[1]); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="description" content="Work at Aalmari. See our open positions and learn how we hire.">
<title>Careers — Aalmari Store</title>
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
        --cr-header-offset: 90px;          /* space for the fixed site header */
        --cr-accent: #f2994a;
        --cr-accent-text: #b45309;         /* darker orange: readable on white */
        --cr-ink: #1f2933;
        --cr-muted: #5f6b7a;
        --cr-line: #eceff3;
        --cr-warm: #fdf1e4;
        --cr-shadow: 0 2px 10px rgba(0, 0, 0, 0.06);
    }

    html { -webkit-text-size-adjust: 100%; }

    body {
        background: linear-gradient(135deg, #ffffff 0%, #fdf1e4 40%, #f6c99a 75%, #f2a86b 100%);
        min-height: 100vh;
        color: var(--cr-ink);
    }

    [hidden] { display: none !important; }

    a:focus-visible,
    button:focus-visible {
        outline: 3px solid #1d4ed8;
        outline-offset: 2px;
    }

    /* ===== Layout ===== */
    .cr-container {
        width: 100%;
        max-width: 1000px;
        margin: 0 auto;
        padding: var(--cr-header-offset) clamp(12px, 4vw, 24px) 48px;
    }

    .cr-card {
        background: #ffffff;
        border-radius: 16px;
        padding: clamp(20px, 4vw, 36px) clamp(16px, 4vw, 36px);
        margin-bottom: 20px;
        box-shadow: var(--cr-shadow);
        scroll-margin-top: calc(var(--cr-header-offset) + 12px);
    }

    .cr-card h2 {
        font-size: clamp(18px, 3vw, 22px);
        line-height: 1.3;
        margin-bottom: 6px;
    }

    .cr-card-sub {
        font-size: 14.5px;
        color: var(--cr-muted);
        margin-bottom: 22px;
        line-height: 1.6;
        max-width: 62ch;
    }

    .cr-text {
        font-size: 15px;
        line-height: 1.75;
        color: #3d4753;
        max-width: 68ch;
    }
    .cr-text + .cr-text { margin-top: 14px; }

    /* ===== Breadcrumb ===== */
    .cr-breadcrumb {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        gap: 6px;
        font-size: 13px;
        color: var(--cr-muted);
        margin-bottom: 14px;
    }
    .cr-breadcrumb a { color: var(--cr-accent-text); text-decoration: none; }
    .cr-breadcrumb a:hover { text-decoration: underline; }
    .cr-breadcrumb [aria-current="page"] { color: var(--cr-ink); font-weight: 600; }

    /* ===== Hero ===== */
    .cr-hero { padding: clamp(28px, 6vw, 56px) clamp(18px, 5vw, 48px); }

    .cr-hero h1 {
        font-size: clamp(26px, 5.5vw, 40px);
        line-height: 1.2;
        letter-spacing: -0.01em;
        max-width: 20ch;
        margin-bottom: 14px;
    }

    .cr-hero p {
        font-size: clamp(15px, 2.2vw, 17px);
        line-height: 1.7;
        color: var(--cr-muted);
        max-width: 58ch;
    }

    .cr-hero-actions {
        display: flex;
        flex-wrap: wrap;
        gap: 12px;
        margin-top: 24px;
    }

    /* ===== Buttons ===== */
    .cr-btn {
        display: inline-flex;
        align-items: center;
        justify-content: center;
        gap: 6px;
        min-height: 46px;
        padding: 0 22px;
        border: 1px solid var(--cr-accent);
        border-radius: 10px;
        background: var(--cr-accent);
        color: #1f1305;
        font-size: 14.5px;
        font-weight: 700;
        text-decoration: none;
        cursor: pointer;
        transition: background .15s ease, border-color .15s ease;
    }
    .cr-btn:hover { background: #e98a36; border-color: #e98a36; }
    .cr-btn .material-symbols-outlined { font-size: 20px; }

    .cr-btn--ghost {
        background: #fff;
        border-color: #e3c9a6;
        color: #7a4a0d;
    }
    .cr-btn--ghost:hover { background: var(--cr-warm); border-color: #d9b57f; }

    /* ===== Icon tiles ===== */
    .cr-grid {
        display: grid;
        grid-template-columns: repeat(2, 1fr);
        gap: 14px;
    }

    .cr-item {
        display: flex;
        gap: 16px;
        padding: 18px;
        border: 1px solid var(--cr-line);
        border-radius: 14px;
    }

    .cr-icon {
        display: flex;
        align-items: center;
        justify-content: center;
        flex-shrink: 0;
        width: 48px;
        height: 48px;
        border-radius: 50%;
        background: var(--cr-warm);
        color: #b45309;
    }
    .cr-icon .material-symbols-outlined { font-size: 26px; }

    .cr-item h3 { font-size: 15.5px; margin-bottom: 4px; line-height: 1.35; }
    .cr-item p  { font-size: 14px; line-height: 1.6; color: var(--cr-muted); }

    /* ===== Hiring process (a real sequence, so steps are numbered) ===== */
    .cr-steps { list-style: none; counter-reset: step; display: grid; gap: 0; max-width: 62ch; }

    .cr-steps li {
        counter-increment: step;
        position: relative;
        padding: 0 0 20px 48px;
        font-size: 14.5px;
        line-height: 1.6;
        color: #3d4753;
    }
    .cr-steps li:last-child { padding-bottom: 0; }

    .cr-steps li::before {
        content: counter(step);
        position: absolute;
        left: 0;
        top: -2px;
        width: 32px;
        height: 32px;
        border-radius: 50%;
        background: var(--cr-warm);
        color: #b45309;
        font-size: 14px;
        font-weight: 700;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .cr-steps strong { display: block; color: var(--cr-ink); font-size: 15px; margin-bottom: 2px; }

    /* ===== Openings ===== */
    .cr-filters {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 14px;
    }

    .cr-filter {
        border: 1px solid #e3e7ec;
        background: #fff;
        color: var(--cr-ink);
        border-radius: 999px;
        padding: 9px 16px;
        min-height: 40px;
        font-size: 13.5px;
        font-weight: 600;
        cursor: pointer;
        transition: background .15s ease, color .15s ease, border-color .15s ease;
    }
    .cr-filter:hover { background: var(--cr-warm); }
    .cr-filter[aria-pressed="true"] {
        background: var(--cr-accent);
        border-color: var(--cr-accent);
        color: #1f1305;
    }

    .cr-count { font-size: 13px; color: var(--cr-muted); margin-bottom: 10px; min-height: 18px; }

    .cr-jobs { display: grid; gap: 14px; }

    .cr-job {
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-between;
        gap: 16px;
        padding: 18px;
        border: 1px solid var(--cr-line);
        border-radius: 14px;
    }

    .cr-job-body { flex: 1; min-width: 220px; }
    .cr-job h3 { font-size: 16px; margin-bottom: 8px; line-height: 1.35; }

    .cr-meta {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        margin-bottom: 8px;
    }

    .cr-tag {
        display: inline-flex;
        align-items: center;
        gap: 4px;
        background: var(--cr-warm);
        color: #7a4a0d;
        font-size: 12.5px;
        font-weight: 600;
        padding: 4px 10px;
        border-radius: 999px;
    }
    .cr-tag .material-symbols-outlined { font-size: 16px; }

    .cr-job p { font-size: 14px; line-height: 1.6; color: var(--cr-muted); }

    .cr-empty {
        padding: 26px 20px;
        border: 1px dashed #e3c9a6;
        border-radius: 14px;
        background: #fffaf3;
        text-align: center;
    }
    .cr-empty .material-symbols-outlined { font-size: 34px; color: #b45309; margin-bottom: 8px; }
    .cr-empty h3 { font-size: 16.5px; margin-bottom: 6px; }
    .cr-empty p {
        font-size: 14.5px;
        line-height: 1.65;
        color: var(--cr-muted);
        max-width: 52ch;
        margin: 0 auto 16px;
    }

    /* ===== Call to action band ===== */
    .cr-cta {
        background: var(--cr-ink);
        color: #fff;
        display: flex;
        flex-wrap: wrap;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
    }
    .cr-cta h2 { color: #fff; margin-bottom: 6px; }
    .cr-cta p  { color: #cbd2d9; font-size: 14.5px; line-height: 1.6; max-width: 52ch; }

    /* ===== Contact ===== */
    .cr-contact-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 14px;
    }

    .cr-contact {
        display: flex;
        align-items: flex-start;
        gap: 14px;
        padding: 18px;
        border: 1px solid var(--cr-line);
        border-radius: 14px;
    }
    .cr-contact h3 { font-size: 15px; margin-bottom: 3px; }
    .cr-contact p  { font-size: 13.5px; line-height: 1.55; color: var(--cr-muted); }
    .cr-contact a  { color: var(--cr-accent-text); font-weight: 600; text-decoration: none; word-break: break-word; }
    .cr-contact a:hover { text-decoration: underline; }

    /* ===== Responsive ===== */
    @media (max-width: 600px) {
        :root { --cr-header-offset: 145px; }   /* the site header is taller on phones */
        .cr-grid { grid-template-columns: 1fr; }
        .cr-hero-actions .cr-btn,
        .cr-cta .cr-btn,
        .cr-job .cr-btn { width: 100%; }
    }

    @media (max-width: 360px) {
        .cr-item, .cr-contact, .cr-job { padding: 14px; gap: 12px; }
        .cr-filter { padding: 8px 12px; font-size: 13px; }
    }

    /* ===== Scroll reveal =====
       Blocks start hidden + 40px lower, then fade and slide up when scrolled into view.
       Nothing is hidden unless the head script added "js-reveal" to <html>. */
    .js-reveal .cr-reveal {
        opacity: 0;
        transform: translateY(40px);
        transition:
            opacity 0.7s ease,
            transform 0.7s cubic-bezier(0.22, 1, 0.36, 1);
    }
    /* `none` (not translateY(0)) so the block never becomes a containing block for fixed/sticky children */
    .js-reveal .cr-reveal.reveal--in {
        opacity: 1;
        transform: none;
    }

    @media (prefers-reduced-motion: reduce) {
        .cr-btn, .cr-filter { transition: none; }
    }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/components/header.jsp" />

<main class="cr-container" id="top">

    <!-- Breadcrumb -->
    <nav class="cr-breadcrumb" aria-label="Breadcrumb">
        <a href="${pageContext.request.contextPath}/">Home</a>
        <span aria-hidden="true">/</span>
        <span aria-current="page">Careers</span>
    </nav>

    <!-- Hero -->
    <section class="cr-card cr-hero cr-reveal" aria-labelledby="crHeading">
        <h1 id="crHeading">Help us build a better way to shop in Nepal</h1>
        <p>
            At Aalmari we connect shoppers with independent sellers. If you like solving real problems
            and working with a team that cares about customers and small businesses, we would like to hear from you.
        </p>
        <div class="cr-hero-actions">
            <a class="cr-btn" href="#openings">
                <span class="material-symbols-outlined" aria-hidden="true">work</span> View open roles
            </a>
            <a class="cr-btn cr-btn--ghost" href="mailto:support@aalmari.com?subject=Career%20enquiry">Send us your CV</a>
        </div>
    </section>

    <!-- Why Aalmari -->
    <section class="cr-card cr-reveal" aria-labelledby="crWhyTitle">
        <h2 id="crWhyTitle">Why work at Aalmari</h2>
        <p class="cr-card-sub">What you can expect when you join the team.</p>

        <div class="cr-grid">
            <div class="cr-item">
                <span class="cr-icon"><span class="material-symbols-outlined" aria-hidden="true">storefront</span></span>
                <div>
                    <h3>Work that helps local sellers</h3>
                    <p>Your work helps independent businesses in Nepal reach customers online.</p>
                </div>
            </div>
            <div class="cr-item">
                <span class="cr-icon"><span class="material-symbols-outlined" aria-hidden="true">trending_up</span></span>
                <div>
                    <h3>Room to learn and grow</h3>
                    <p>We are a growing marketplace, so there is plenty to learn and plenty of ways to take ownership.</p>
                </div>
            </div>
            <div class="cr-item">
                <span class="cr-icon"><span class="material-symbols-outlined" aria-hidden="true">forum</span></span>
                <div>
                    <h3>Open, honest teamwork</h3>
                    <p>We share ideas, give clear feedback and keep customers at the centre of every decision.</p>
                </div>
            </div>
            <div class="cr-item">
                <span class="cr-icon"><span class="material-symbols-outlined" aria-hidden="true">diversity_3</span></span>
                <div>
                    <h3>Everyone is welcome</h3>
                    <p>We welcome applicants from all backgrounds and judge people on their skills and potential.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Open positions -->
    <section class="cr-card cr-reveal" id="openings" aria-labelledby="crOpenTitle">
        <h2 id="crOpenTitle">Open positions</h2>
        <p class="cr-card-sub">Find a role that fits your skills and apply by email.</p>

<% if (jobs.length > 0) { %>
        <div class="cr-filters" role="group" aria-label="Filter positions by department">
            <button type="button" class="cr-filter" data-dept="all" aria-pressed="true">All</button>
<%     for (String d : departments) { %>
            <button type="button" class="cr-filter" data-dept="<%= esc(d) %>" aria-pressed="false"><%= esc(d) %></button>
<%     } %>
        </div>

        <p class="cr-count" id="crCount" aria-live="polite"></p>

        <div class="cr-jobs" id="crJobs">
<%     for (String[] j : jobs) {
           String subject = URLEncoder.encode("Application: " + j[0], "UTF-8").replace("+", "%20");
%>
            <article class="cr-job" data-dept="<%= esc(j[1]) %>">
                <div class="cr-job-body">
                    <h3><%= esc(j[0]) %></h3>
                    <div class="cr-meta">
                        <span class="cr-tag"><span class="material-symbols-outlined" aria-hidden="true">groups</span><%= esc(j[1]) %></span>
                        <span class="cr-tag"><span class="material-symbols-outlined" aria-hidden="true">location_on</span><%= esc(j[2]) %></span>
                        <span class="cr-tag"><span class="material-symbols-outlined" aria-hidden="true">schedule</span><%= esc(j[3]) %></span>
                    </div>
                    <p><%= esc(j[4]) %></p>
                </div>
                <a class="cr-btn" href="mailto:support@aalmari.com?subject=<%= subject %>" aria-label="Apply for <%= esc(j[0]) %>">Apply now</a>
            </article>
<%     } %>
        </div>
<% } else { %>
        <div class="cr-empty">
            <span class="material-symbols-outlined" aria-hidden="true">work_history</span>
            <h3>No open positions right now</h3>
            <p>We are not hiring for a specific role at the moment, but we are always happy to meet talented people. Send us your CV and we will keep it for future openings.</p>
            <a class="cr-btn" href="mailto:support@aalmari.com?subject=Career%20enquiry">
                <span class="material-symbols-outlined" aria-hidden="true">mail</span> Send your CV
            </a>
        </div>
<% } %>
    </section>

    <!-- How we hire -->
    <section class="cr-card cr-reveal" aria-labelledby="crProcessTitle">
        <h2 id="crProcessTitle">How we hire</h2>
        <p class="cr-card-sub">A simple process, so you always know what comes next.</p>

        <ol class="cr-steps">
            <li><strong>Apply</strong>Email us your CV and a short note about the role you are interested in.</li>
            <li><strong>We review your application</strong>Our team reads every application carefully.</li>
            <li><strong>Interview</strong>If your profile fits, we will contact you to arrange a conversation.</li>
            <li><strong>Decision</strong>We let you know the outcome and, if it is a yes, the next steps.</li>
        </ol>
    </section>

    <!-- Candidate call to action -->
    <section class="cr-card cr-cta cr-reveal" aria-labelledby="crCtaTitle">
        <div>
            <h2 id="crCtaTitle">Do not see the right role?</h2>
            <p>Tell us what you are good at. We keep strong applications on file for future openings.</p>
        </div>
        <a class="cr-btn" href="mailto:support@aalmari.com?subject=Career%20enquiry">Send us your CV</a>
    </section>

    <!-- Contact -->
    <section class="cr-card cr-reveal" id="contact" aria-labelledby="crContactTitle">
        <h2 id="crContactTitle">Questions about working with us?</h2>
        <p class="cr-card-sub">Our team is happy to help. Times are Nepal time.</p>

        <div class="cr-contact-grid">
            <div class="cr-contact">
                <span class="cr-icon"><span class="material-symbols-outlined" aria-hidden="true">mail</span></span>
                <div>
                    <h3>Email us</h3>
                    <p><a href="mailto:support@aalmari.com">support@aalmari.com</a></p>
                </div>
            </div>
            <div class="cr-contact">
                <span class="cr-icon"><span class="material-symbols-outlined" aria-hidden="true">call</span></span>
                <div>
                    <h3>Call us</h3>
                    <p><a href="tel:+97715970597">01-5970597</a><br>9AM - 6PM [Sun-Fri]</p>
                </div>
            </div>
        </div>
    </section>

</main>

<jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
(function () {
    'use strict';

    /* ---------- Department filter (only present when there are open positions) ---------- */
    var filters = Array.prototype.slice.call(document.querySelectorAll('.cr-filter'));
    var jobs    = Array.prototype.slice.call(document.querySelectorAll('.cr-job'));
    var count   = document.getElementById('crCount');

    function applyFilter(dept) {
        var shown = 0;

        filters.forEach(function (b) {
            b.setAttribute('aria-pressed', b.getAttribute('data-dept') === dept ? 'true' : 'false');
        });

        jobs.forEach(function (job) {
            var ok = dept === 'all' || job.getAttribute('data-dept') === dept;
            job.hidden = !ok;
            if (ok) shown++;
        });

        if (count) {
            count.textContent = shown + (shown === 1 ? ' open position' : ' open positions');
        }
    }

    if (filters.length && jobs.length) {
        filters.forEach(function (b) {
            b.addEventListener('click', function () { applyFilter(b.getAttribute('data-dept')); });
        });
        applyFilter('all');
    }

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

        Array.prototype.forEach.call(document.querySelectorAll('.cr-reveal'), function (el) { io.observe(el); });
    }
})();
</script>

</body>
</html>
