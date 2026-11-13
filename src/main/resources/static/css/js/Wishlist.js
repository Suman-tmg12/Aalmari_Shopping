// Shared wishlist logic. Loaded once from header.jsp (after Cart.js), so every page has it.
//
// Handles every heart button in the project:
//   .ar-wish      product cards (home, category, search, product page "You May Also Like", flash lists)
//   .fs-wish      home page flash-sale cards
//   .wishlist-btn big heart on product / flash product pages
//
// The product id is read from data-product-id on the button, on a parent, or (for cards)
// from the card's "Add to cart" button, so most pages need no change at all.
// Relies on the global CTX (context path) that header.jsp already defines.
(function () {
    'use strict';
    if (window.__wishlistLoaded) return;      // never bind twice
    window.__wishlistLoaded = true;

    var HEART_SEL = '.ar-wish, .fs-wish, .wishlist-btn';
    var wished = new Set();      // product ids (numbers) in this user's wishlist
    var pending = {};            // productId -> true while a request is in flight
    var sessionExpired = false;

    function ctx() { return (typeof CTX !== 'undefined') ? CTX : ''; }

    function isLoggedIn() {
        var link = document.getElementById('wishlistLink') || document.getElementById('cartLink');
        return !sessionExpired && !!link && link.dataset.loggedIn === 'true';
    }

    /* ---------- product id of a heart ---------- */
    function productIdOf(btn) {
        var holder = btn.closest('[data-product-id]');
        if (!holder) {
            var card = btn.closest('.ar-card, .fs-card');
            holder = card && card.querySelector('[data-product-id]');
        }
        var v = holder ? holder.getAttribute('data-product-id') : '';
        return /^\d+$/.test(v || '') ? Number(v) : null;
    }

    /* ---------- painting ---------- */
    function stateClass(btn) {
        if (btn.classList.contains('fs-wish')) return 'fs-wished';
        if (btn.classList.contains('wishlist-btn')) return 'wished';
        return 'ar-wished';
    }

    function paint(btn, on) {
        btn.classList.toggle(stateClass(btn), on);
        btn.setAttribute('aria-pressed', on ? 'true' : 'false');
        btn.setAttribute('aria-label', on ? 'Remove from wishlist' : 'Add to wishlist');
        btn.title = on ? 'Remove from wishlist' : 'Add to wishlist';
    }

    function paintAll(productId, on) {
        document.querySelectorAll(HEART_SEL).forEach(function (b) {
            if (productIdOf(b) === productId) paint(b, on);
        });
    }

    function refreshAll() {
        document.querySelectorAll(HEART_SEL).forEach(function (b) {
            var id = productIdOf(b);
            if (id !== null) paint(b, wished.has(id));
        });
    }

    function setState(id, on) {
        if (on) wished.add(id); else wished.delete(id);
        paintAll(id, on);
    }

    function setBadge(n) {
        var badge = document.getElementById('wishlistBadge');
        if (!badge) return;
        badge.textContent = n > 99 ? '99+' : n;
        badge.style.display = n > 0 ? '' : 'none';
    }

    /* ---------- small UI: toast + login popup (styles injected once) ---------- */
    function injectStyles() {
        if (document.getElementById('wl-style')) return;
        var s = document.createElement('style');
        s.id = 'wl-style';
        s.textContent =
            // Heart colour: the product-page heart (.wishlist-btn.wished) and the home flash-card heart
            // (.fs-wish.fs-wished) turn red and filled, like the .ar-wish cards in produc.css
            '.wishlist-btn.wished,.fs-wish.fs-wished{color:#f43f5e!important}' +
            '.wishlist-btn.wished .material-symbols-outlined,.fs-wish.fs-wished .material-symbols-outlined{' +
            'color:#f43f5e!important;font-variation-settings:"FILL" 1!important}' +
            '.wl-toast{position:fixed;left:50%;bottom:28px;transform:translate(-50%,16px);background:#222;color:#fff;' +
            'padding:12px 18px;border-radius:10px;font:500 14px/1.3 system-ui,-apple-system,Segoe UI,sans-serif;display:flex;' +
            'gap:14px;align-items:center;opacity:0;pointer-events:none;transition:opacity .25s,transform .25s;z-index:10000;' +
            'box-shadow:0 8px 24px rgba(0,0,0,.25);max-width:calc(100vw - 32px)}' +
            '.wl-toast.show{opacity:1;transform:translate(-50%,0);pointer-events:auto}' +
            '.wl-toast a{color:#FF7B00;font-weight:700;text-decoration:none;white-space:nowrap}' +
            '.wl-overlay{position:fixed;inset:0;background:rgba(0,0,0,.5);display:flex;align-items:center;' +
            'justify-content:center;z-index:10001;padding:16px}' +
            '.wl-modal{background:#fff;border-radius:16px;max-width:380px;width:100%;padding:28px 24px;text-align:center;' +
            'font-family:system-ui,-apple-system,Segoe UI,sans-serif;box-shadow:0 20px 50px rgba(0,0,0,.3)}' +
            '.wl-modal-ic{font-size:44px;color:#FF7B00;font-variation-settings:"FILL" 1}' +
            '.wl-modal h3{margin:8px 0 6px;font-size:20px;color:#111}' +
            '.wl-modal p{margin:0 0 20px;color:#666;font-size:14px;line-height:1.5}' +
            '.wl-actions{display:flex;gap:10px}' +
            '.wl-actions button,.wl-actions a{flex:1;padding:11px 14px;border-radius:10px;font:600 14px system-ui,sans-serif;' +
            'cursor:pointer;text-decoration:none;text-align:center;border:1px solid #ddd;background:#f4f4f4;color:#333}' +
            '.wl-actions a.wl-primary{background:#FF7B00;border-color:#FF7B00;color:#fff}';
        document.head.appendChild(s);
    }

    injectStyles();   // heart colours must exist from the start, not only after the first toast

    var toastEl, toastTimer;
    function showToast(msg, href, linkText) {
        injectStyles();
        if (!toastEl) {
            toastEl = document.createElement('div');
            toastEl.className = 'wl-toast';
            toastEl.setAttribute('role', 'status');
            toastEl.setAttribute('aria-live', 'polite');
            document.body.appendChild(toastEl);
        }
        toastEl.textContent = '';
        var span = document.createElement('span');
        span.textContent = msg;                       // textContent: never HTML
        toastEl.appendChild(span);
        if (href) {
            var a = document.createElement('a');
            a.href = href;
            a.textContent = linkText || 'View';
            toastEl.appendChild(a);
        }
        toastEl.classList.remove('show');
        void toastEl.offsetWidth;                     // restart the transition
        toastEl.classList.add('show');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(function () { toastEl.classList.remove('show'); }, 3000);
    }

    function showLoginModal() {
        if (document.getElementById('wlLogin')) return;
        injectStyles();

        var overlay = document.createElement('div');
        overlay.className = 'wl-overlay';
        overlay.id = 'wlLogin';
        overlay.setAttribute('role', 'dialog');
        overlay.setAttribute('aria-modal', 'true');
        overlay.setAttribute('aria-labelledby', 'wlLoginTitle');

        var box = document.createElement('div');
        box.className = 'wl-modal';

        var icon = document.createElement('span');
        icon.className = 'material-symbols-outlined wl-modal-ic';
        icon.textContent = 'favorite';

        var title = document.createElement('h3');
        title.id = 'wlLoginTitle';
        title.textContent = 'Log in to save your favourites';

        var text = document.createElement('p');
        text.textContent = 'Sign in to add products to your wishlist and find them again on any device.';

        var actions = document.createElement('div');
        actions.className = 'wl-actions';

        var cancel = document.createElement('button');
        cancel.type = 'button';
        cancel.textContent = 'Not now';

        var login = document.createElement('a');
        login.className = 'wl-primary';
        login.href = ctx() + '/login';
        login.textContent = 'Log in';

        actions.appendChild(cancel);
        actions.appendChild(login);
        box.appendChild(icon);
        box.appendChild(title);
        box.appendChild(text);
        box.appendChild(actions);
        overlay.appendChild(box);
        document.body.appendChild(overlay);

        function onKey(e) { if (e.key === 'Escape') close(); }
        function close() {
            overlay.remove();
            document.removeEventListener('keydown', onKey);
        }
        cancel.addEventListener('click', close);
        overlay.addEventListener('click', function (e) { if (e.target === overlay) close(); });
        document.addEventListener('keydown', onKey);
        login.focus();
    }

    /* ---------- the click ---------- */
    async function toggle(btn) {
        var id = productIdOf(btn);
        if (id === null) {
            console.error('[wishlist] heart button has no product id', btn);
            return;
        }
        if (!isLoggedIn()) { showLoginModal(); return; }
        if (pending[id]) return;                       // ignore double clicks while saving

        var want = !wished.has(id);
        pending[id] = true;
        setState(id, want);                            // optimistic: the heart reacts instantly

        try {
            var res = await fetch(ctx() + '/api/wishlist/items/' + id, {
                method: want ? 'PUT' : 'DELETE',
                credentials: 'same-origin'
            });

            if (res.status === 401) {                  // session ended while the page was open
                sessionExpired = true;
                setState(id, !want);
                showLoginModal();
                return;
            }

            var data = await res.json().catch(function () { return {}; });
            if (!res.ok) {
                setState(id, !want);
                showToast(data.error || 'Could not update your wishlist. Please try again.');
                return;
            }

            setBadge(data.count);
            document.dispatchEvent(new CustomEvent('wishlist:change', {
                detail: { productId: id, wished: want, count: data.count }
            }));
            if (want) showToast('Added to wishlist', ctx() + '/myprofile?tab=wishlist', 'View');
            else showToast('Removed from wishlist');
        } catch (e) {
            setState(id, !want);
            showToast('Could not update your wishlist. Check your connection.');
        } finally {
            delete pending[id];
        }
    }

    // CAPTURE phase + stopPropagation: runs before any older inline heart handler on a page,
    // so those can stay or be deleted without ever fighting with this one.
    document.addEventListener('click', function (e) {
        var btn = e.target.closest && e.target.closest(HEART_SEL);
        if (!btn) return;
        e.preventDefault();
        e.stopPropagation();
        toggle(btn);
    }, true);

    /* ---------- load the user's wishlist on every page ---------- */
    document.addEventListener('DOMContentLoaded', function () {
        if (!isLoggedIn()) return;
        fetch(ctx() + '/api/wishlist/ids', { credentials: 'same-origin' })
            .then(function (r) { return r.json(); })
            .then(function (d) {
                (d.ids || []).forEach(function (i) { wished.add(Number(i)); });
                setBadge(d.count || 0);
                refreshAll();
            })
            .catch(function () { /* hearts just stay empty, badge stays hidden */ });
    });

    // For pages that add cards later (e.g. infinite scroll): window.Wishlist.refresh()
    window.Wishlist = {
        refresh: refreshAll,
        has: function (id) { return wished.has(Number(id)); }
    };
})();