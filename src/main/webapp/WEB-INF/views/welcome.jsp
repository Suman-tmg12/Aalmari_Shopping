<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Aalmari Full Width E-commerce Design</title>
    <link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&icon" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/welcome.css?v=3">
    <jsp:include page="/WEB-INF/components/tabbarlogoimages.jsp" />
</head>
<body>
<div class="main-wrapper" id="top">

    <!-- Header -->
    <jsp:include page="/WEB-INF/components/header.jsp" />
    <!-- Header -->

    <!-- Hero Carousel Banner -->
    <jsp:include page="/WEB-INF/components/Slider.jsp" />
    <!-- Hero Carousel Banner -->

    <!-- Flash Sale Section -->
    <div class="section-header">
        <span class="section-title">Flash Sale</span>
        <a href="${pageContext.request.contextPath}/flash" class="section-more">more</a>
    </div>
<div class="flash-sale-wrapper">
    <div class="flash-sale-box">
        <div class="horizontal-scroll">
            <%
                String[] flashIds    = {"himalaya-face-scrub", "wireless-headphone", "classic-black-shoes", "smart-fitness-band", "skin-care-set", "healthy-food-pack", "unhealthy-foods"};
                String[] flashImages = {"HimalayaFaceScrub.jpg","Wireless_headPhone.jpg","ClassicBlackShoes.jpg","SmartFitnessBand.jpg","skincare.jpg","Healthy.jpg","unhealthy-foods.jpg"};
                String[] flashTitles = {"Himalaya Face Scrub", "Wireless Headphone", "Classic Black Shoes", "Smart Fitness Band", "Skin Care Set", "Healthy", "Non-healthy"};
                String[] flashPrices = {"Rs.70", "Rs.70", "Rs.90", "Rs.120", "Rs.150", "Rs.300", "Rs.450"};
                String[] flashOldPrices = {"Rs.150", "Rs.120", "Rs.180", "Rs.240", "Rs.300", "Rs.500", "Rs.500"};
                for(int i = 0; i < flashTitles.length; i++) {
            %>

     <a href="${pageContext.request.contextPath}/flashsaleproduct?id=<%= flashIds[i] %>" style="text-decoration: none; color: inherit;">
         <div class="card-sm">
             <img src="${pageContext.request.contextPath}/HomePageImages/FlashSaleImages/<%= flashImages[i] %>" alt="<%= flashTitles[i] %>">
             <div class="card-title"><%= flashTitles[i] %></div>
             <div class="card-price"><%= flashPrices[i] %> <span><%= flashOldPrices[i] %></span></div>
         </div>
     </a>

            <% } %>
        </div>
    </div>
</div>

    <!-- Categories Section -->
    <div class="section-header">
        <span class="section-title">Categories</span>
         <a href="${pageContext.request.contextPath}/category" class="section-more">more</a>
    </div>

       <div class="categories-grid">
           <%
               // Just add your category names here. The code below handles the rest for ALL of them.
               String[] cats = {"Electronics", "Fashion", "Home & Living", "Groceries", "Beauty & Personal Care", "Toys & Games"};
               String[] catImages = {"Electronics.jpg", "fashion.jpg", "home&living.jpg", "grocories.jpg", "beauty.jpg", "toys.jpg"};

               for(int i = 0; i < cats.length; i++) {
                   // This single logic works for EVERY category in the list above
                   String contextPath = request.getContextPath();
                   String encodedCategory = java.net.URLEncoder.encode(cats[i], "UTF-8");
                   String categoryUrl = contextPath + "/category?name=" + encodedCategory;
           %>
               <a href="<%= categoryUrl %>" class="cat-card-link" style="text-decoration: none; display: block;">
                   <div class="cat-card">
                       <img src="<%= contextPath %>/HomePageImages/category/<%= catImages[i] %>" alt="Category">
                       <div class="cat-name"><%= cats[i] %></div>
                   </div>
               </a>
           <% } %>
       </div>

   <jsp:include page="/WEB-INF/components/product.jsp" />




    <!-- Footer Section -->
    <jsp:include page="/WEB-INF/components/footer.jsp" />

</div>

<!-- ===== JAVASCRIPT ===== -->
<script>
    // Search focus
    document.addEventListener('click', function (event) {
        const searchContainer = event.target.closest('.search-container');
        const searchIcon = event.target.closest('.search-icon');
        if (searchContainer || searchIcon) {
            const container = searchContainer || searchIcon.closest('.search-container');
            const input = container.querySelector('.search-input');
            if (input) input.focus();
        }
    });

    // ========== HERO SLIDER (infinite loop, drag / swipe / keyboard) ==========
    (function () {
        'use strict';

        var slider   = document.getElementById('heroSlider');
        var track    = document.getElementById('heroSliderTrack');
        var dotsWrap = document.getElementById('heroDots');
        if (!slider || !track) return;

        var originals = Array.prototype.slice.call(track.querySelectorAll('.hero-slide'));
        var total = originals.length;
        var dots = dotsWrap ? Array.prototype.slice.call(dotsWrap.querySelectorAll('.dot')) : [];

        if (total === 0) return;
        if (total === 1) {                       // nothing to slide
            slider.style.cursor = 'default';
            if (dotsWrap) dotsWrap.style.display = 'none';
            return;
        }

        /* ---------- Config ---------- */
        var DURATION   = 450;                    // ms
        var EASING     = 'cubic-bezier(0.25, 0.8, 0.25, 1)';
        var AUTO_DELAY = 3000;                   // ms
        var DRAG_START = 6;                      // px before a press counts as a drag
        var FLICK_SPEED = 0.5;                   // px/ms

        var motionQuery = window.matchMedia ? window.matchMedia('(prefers-reduced-motion: reduce)') : null;
        function reduceMotion() { return !!(motionQuery && motionQuery.matches); }

        /* ---------- Clones for seamless looping ----------
           track: [clone of last] [1] [2] ... [n] [clone of first]  */
        function makeClone(node) {
            var c = node.cloneNode(true);
            c.setAttribute('aria-hidden', 'true');
            c.removeAttribute('role');
            c.removeAttribute('aria-label');
            c.removeAttribute('aria-roledescription');
            return c;
        }
        track.insertBefore(makeClone(originals[total - 1]), track.firstChild);
        track.appendChild(makeClone(originals[0]));

        /* ---------- State ---------- */
        var pos = 1;                             // position inside the track (1 = first real slide)
        var animating = false;
        var fallbackTimer = null;
        var autoTimer = null;
        var drag = null;
        var suppressClick = false;

        var hovering = false, dragging = false, focused = false;
        var pageVisible = !document.hidden;
        var inView = true;

        /* ---------- Rendering ---------- */
        function setTransform(dx, animate) {
            track.style.transition = (animate && !reduceMotion())
                ? 'transform ' + DURATION + 'ms ' + EASING
                : 'none';
            track.style.transform =
                'translate3d(calc(' + (-pos * 100) + '% + ' + (dx || 0) + 'px), 0, 0)';
        }

        function updateDots() {
            var active = (pos - 1 + total) % total;
            dots.forEach(function (d, i) {
                var on = i === active;
                d.classList.toggle('active', on);
                if (on) d.setAttribute('aria-current', 'true');
                else d.removeAttribute('aria-current');
            });
        }

        // Instant, invisible jump from a clone to its real twin
        function jump(p) {
            pos = p;
            setTransform(0, false);
            void track.offsetWidth;              // flush so the next transition starts cleanly
        }

        function finishMove() {
            clearTimeout(fallbackTimer);
            animating = false;
            if (pos === 0) jump(total);
            else if (pos === total + 1) jump(1);
        }

        function goTo(newPos) {
            if (animating) return;               // ignore input mid-transition
            pos = newPos;
            updateDots();
            setTransform(0, true);

            if (reduceMotion()) { finishMove(); return; }

            animating = true;
            clearTimeout(fallbackTimer);
            fallbackTimer = setTimeout(finishMove, DURATION + 120);  // safety net
        }

        function next() { goTo(pos + 1); }
        function prev() { goTo(pos - 1); }

        track.addEventListener('transitionend', function (e) {
            if (e.target === track && e.propertyName === 'transform' && animating) finishMove();
        });

        /* ---------- Autoplay ---------- */
        function shouldPlay() {
            return !reduceMotion() && !hovering && !dragging && !focused && pageVisible && inView;
        }
        function startAuto() { if (!autoTimer) autoTimer = setInterval(next, AUTO_DELAY); }
        function stopAuto()  { clearInterval(autoTimer); autoTimer = null; }
        function updateAuto() { shouldPlay() ? startAuto() : stopAuto(); }
        function restartAuto() { stopAuto(); updateAuto(); }   // fresh countdown after user input

        document.addEventListener('visibilitychange', function () {
            pageVisible = !document.hidden;
            updateAuto();
        });

        if ('IntersectionObserver' in window) {
            new IntersectionObserver(function (entries) {
                inView = entries[0].isIntersecting;
                updateAuto();
            }).observe(slider);
        }

        if (motionQuery && motionQuery.addEventListener) {
            motionQuery.addEventListener('change', updateAuto);
        }

        // Hover pause: mouse only (touch "hover" would leave autoplay stuck off)
        slider.addEventListener('pointerenter', function (e) {
            if (e.pointerType === 'mouse') { hovering = true; updateAuto(); }
        });
        slider.addEventListener('pointerleave', function (e) {
            if (e.pointerType === 'mouse') { hovering = false; updateAuto(); }
        });

        // Keyboard focus pause (only real keyboard focus, not a mouse click)
        slider.addEventListener('focusin', function (e) {
            try { focused = e.target.matches(':focus-visible'); } catch (err) { focused = false; }
            updateAuto();
        });
        slider.addEventListener('focusout', function () { focused = false; updateAuto(); });

        slider.addEventListener('keydown', function (e) {
            if (e.key === 'ArrowLeft')  { e.preventDefault(); prev(); restartAuto(); }
            if (e.key === 'ArrowRight') { e.preventDefault(); next(); restartAuto(); }
        });

        /* ---------- Drag / swipe ---------- */
        function onPointerDown(e) {
            if (animating || drag) return;
            if (e.pointerType === 'mouse' && e.button !== 0) return;
            drag = {
                id: e.pointerId,
                startX: e.clientX,
                lastX: e.clientX,
                lastT: e.timeStamp,
                v: 0,
                dx: 0,
                captured: false,
                width: slider.offsetWidth || 1
            };
            dragging = true;
            updateAuto();
        }

        function onPointerMove(e) {
            if (!drag || e.pointerId !== drag.id) return;

            var dx = e.clientX - drag.startX;

            if (!drag.captured) {
                if (Math.abs(dx) < DRAG_START) return;
                drag.captured = true;            // only now is it a drag (keeps plain clicks working)
                slider.classList.add('dragging');
                try { slider.setPointerCapture(e.pointerId); } catch (err) {}
            }

            var dt = e.timeStamp - drag.lastT;
            if (dt > 0) {
                drag.v = 0.7 * ((e.clientX - drag.lastX) / dt) + 0.3 * drag.v;
                drag.lastX = e.clientX;
                drag.lastT = e.timeStamp;
            }

            // never drag further than one slide (clones cover that range)
            dx = Math.max(-drag.width, Math.min(drag.width, dx));
            drag.dx = dx;
            setTransform(dx, false);             // 1:1 with the finger / cursor
        }

        function endDrag(e) {
            if (!drag || e.pointerId !== drag.id) return;

            var d = drag;
            drag = null;
            dragging = false;
            slider.classList.remove('dragging');
            try {
                if (slider.hasPointerCapture(e.pointerId)) slider.releasePointerCapture(e.pointerId);
            } catch (err) {}

            if (!d.captured) { updateAuto(); return; }   // it was just a click/tap

            // A drag must not trigger a click on whatever is underneath
            suppressClick = true;
            setTimeout(function () { suppressClick = false; }, 0);

            // Stale velocity (finger paused before release) doesn't count as a flick
            var v = (e.timeStamp - d.lastT > 100) ? 0 : d.v;

            var threshold = Math.min(d.width * 0.2, 120);
            var flick = Math.abs(v) > FLICK_SPEED && Math.abs(d.dx) > 20;
            var dir = 0;

            if (e.type !== 'pointercancel') {
                if (d.dx <= -threshold || (flick && d.dx < 0)) dir = 1;
                else if (d.dx >= threshold || (flick && d.dx > 0)) dir = -1;
            }

            goTo(pos + dir);                     // animated snap (or snap back when dir = 0)
            restartAuto();
        }

        slider.addEventListener('pointerdown', onPointerDown);
        slider.addEventListener('pointermove', onPointerMove);
        slider.addEventListener('pointerup', endDrag);
        slider.addEventListener('pointercancel', endDrag);

        slider.addEventListener('click', function (e) {
            if (suppressClick) { e.preventDefault(); e.stopPropagation(); }
        }, true);

        /* ---------- Dots ---------- */
        dots.forEach(function (dot) {
            dot.addEventListener('click', function () {
                var index = parseInt(dot.getAttribute('data-index'), 10);
                if (isNaN(index)) return;
                goTo(index + 1);                 // +1 because of the leading clone
                restartAuto();
            });
        });

        /* ---------- Init ---------- */
        setTransform(0, false);
        updateDots();
        updateAuto();
    })();
</script>
</body>
</html>