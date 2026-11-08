// Shared add-to-cart logic. Loaded once from header.jsp, so every page has it.
// Relies on the global CTX (context path) that header.jsp already defines.
(function () {
    function ctx() {
        return (typeof CTX !== 'undefined') ? CTX : '';
    }

    function setBadge(n) {
        var badge = document.getElementById('cartBadge');
        if (!badge) return;
        badge.textContent = n;
        badge.style.display = n > 0 ? '' : 'none';
    }

    window.addToCart = async function (productId, qty, btn) {
        if (btn && btn.dataset.busy === '1') return;      // ignore double clicks
        var original = btn ? btn.innerHTML : '';
        if (btn) btn.dataset.busy = '1';

        try {
            var res = await fetch(ctx() + '/api/cart/items', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ productId: Number(productId), quantity: qty || 1 })
            });

            if (res.status === 401) {                       // not logged in
                window.location.href = ctx() + '/login';
                return;
            }

            var data = await res.json().catch(function () { return {}; });
            if (!res.ok) {
                alert(data.error || 'Could not add to cart. Please try again.');
                return;
            }

            setBadge(data.count);
            if (btn) {
                btn.textContent = 'Added \u2713';
                setTimeout(function () { btn.innerHTML = original; }, 1200);
            }
        } catch (e) {
            alert('Could not add to cart. Please try again.');
        } finally {
            if (btn) setTimeout(function () { btn.dataset.busy = '0'; }, 1200);
        }
    };

    // Click on any product card's "Add to cart" (span.js-add-to-cart)
    document.addEventListener('click', function (e) {
        var btn = e.target.closest('.js-add-to-cart');
        if (!btn) return;
        e.preventDefault();      // stops the card <a> from opening the product page
        e.stopPropagation();
        window.addToCart(btn.dataset.productId, 1, btn);
    });

    // Keyboard support for the span-buttons
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Enter' && e.key !== ' ') return;
        var btn = e.target.closest && e.target.closest('.js-add-to-cart');
        if (!btn) return;
        e.preventDefault();
        window.addToCart(btn.dataset.productId, 1, btn);
    });

    // On every page load, ask the server for the real cart count (logged-in users only)
    document.addEventListener('DOMContentLoaded', function () {
        var link = document.getElementById('cartLink');
        if (!link || link.dataset.loggedIn !== 'true') return;
        fetch(ctx() + '/api/cart/count')
            .then(function (r) { return r.json(); })
            .then(function (d) { setBadge(d.count || 0); })
            .catch(function () { /* badge just stays hidden */ });
    });
})();
