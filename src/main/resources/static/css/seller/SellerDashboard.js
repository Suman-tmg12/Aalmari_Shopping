(function () {
    'use strict';
    const $ = (s, r) => (r || document).querySelector(s);
    const $$ = (s, r) => [...(r || document).querySelectorAll(s)];
    const el = (t, c, h) => { const e = document.createElement(t); if (c) e.className = c; if (h) e.innerHTML = h; return e; };
    const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
    const num = s => parseInt(String(s || '').replace(/\D/g, ''), 10) || 0;
    const fmt = n => Number(n).toLocaleString('en-US');
    const store = {
        get: k => { try { return localStorage.getItem(k); } catch (e) { return null; } },
        set: (k, v) => { try { localStorage.setItem(k, v); } catch (e) {} }
    };
    const LABEL = { pending: 'Pending', confirmed: 'Confirmed', shipped: 'Shipped', delivered: 'Delivered', return: 'Return Req.', cancelled: 'Cancelled' };
    const NEXT = { pending: 'confirmed', confirmed: 'shipped', shipped: 'delivered' };
    const NEXT_BTN = { pending: 'Confirm order', confirmed: 'Mark as shipped', shipped: 'Mark as delivered' };

    /* ============ Category → Sub-category → Attribute fields ============ */
    const A_BRAND = 'Brand', A_COLOR = 'Color', A_MATERIAL = 'Material', A_EXPIRY = 'Expiry date@date';
    const A_RAM = 'RAM:2 GB|4 GB|6 GB|8 GB|12 GB|16 GB|32 GB|64 GB';
    const A_STORAGE = 'Storage capacity:32 GB|64 GB|128 GB|256 GB|512 GB|1 TB|2 TB';
    const A_CSIZE = 'Size:XS|S|M|L|XL|XXL|XXXL';
    const A_GENDER = 'Gender:Men|Women|Unisex|Kids';
    const A_WEIGHT = 'Weight / quantity';
    const A_VOLUME = 'Volume / quantity';
    const CATALOG = {
        'Electronics': {
            'Mobiles':      [A_BRAND, A_RAM, A_STORAGE, A_COLOR, 'Screen size'],
            'Laptops':      [A_BRAND, 'Processor', A_RAM, A_STORAGE, A_COLOR],
            'Tablets':      [A_BRAND, A_RAM, A_STORAGE, A_COLOR, 'Screen size'],
            'Headphones':   [A_BRAND, 'Type:Over-ear|On-ear|In-ear|Earbuds', 'Connectivity:Wired|Bluetooth|Both', A_COLOR],
            'Cameras':      [A_BRAND, 'Type:DSLR|Mirrorless|Point & shoot|Action|Instant', 'Megapixels', A_COLOR],
            'Smart Watches':[A_BRAND, 'Strap material', 'Display size', A_COLOR],
            'Accessories':  [A_BRAND, 'Compatible with', A_COLOR]
        },
        'Fashion': {
            'Men':      [A_CSIZE, A_COLOR, A_MATERIAL, 'Fit:Slim|Regular|Loose'],
            'Women':    [A_CSIZE, A_COLOR, A_MATERIAL, 'Fit:Slim|Regular|Loose'],
            'Kids':     ['Age group:0-2 yrs|3-5 yrs|6-8 yrs|9-12 yrs|13-16 yrs', A_CSIZE, A_COLOR, A_MATERIAL],
            'Shoes':    ['Size (EU):35|36|37|38|39|40|41|42|43|44|45|46', A_GENDER, A_COLOR, A_MATERIAL],
            'Bags':     ['Type:Backpack|Handbag|Tote|Wallet|Travel bag|Laptop bag', A_COLOR, A_MATERIAL, 'Capacity'],
            'Watches':  [A_BRAND, A_GENDER, 'Strap material', A_COLOR],
            'Clothing': [A_CSIZE, A_GENDER, A_COLOR, A_MATERIAL]
        },
        'Beauty & Personal Care': {
            'Skincare':      [A_BRAND, 'Skin type:All|Oily|Dry|Combination|Sensitive', A_VOLUME, A_EXPIRY],
            'Makeup':        [A_BRAND, 'Shade', 'Finish:Matte|Glossy|Satin|Natural', A_EXPIRY],
            'Hair Care':     [A_BRAND, 'Hair type:All|Dry|Oily|Curly|Colored', A_VOLUME, A_EXPIRY],
            'Fragrances':    [A_BRAND, A_GENDER, 'Fragrance type:Eau de Parfum|Eau de Toilette|Cologne|Body mist', A_VOLUME],
            'Personal Care': [A_BRAND, A_VOLUME, A_EXPIRY]
        },
        'Home & Living': {
            'Furniture':  [A_MATERIAL, A_COLOR, 'Dimensions (L×W×H)', 'Assembly required:Yes|No'],
            'Kitchen':    [A_BRAND, A_MATERIAL, 'Capacity', A_COLOR],
            'Home Decor': [A_MATERIAL, A_COLOR, 'Dimensions (L×W×H)'],
            'Bedding':    ['Bed size:Single|Double|Queen|King', A_MATERIAL, A_COLOR, 'Thread count'],
            'Lighting':   ['Type:Ceiling|Table lamp|Floor lamp|Wall|String lights', 'Wattage', A_COLOR],
            'Storage':    [A_MATERIAL, A_COLOR, 'Capacity', 'Dimensions (L×W×H)']
        },
        'Groceries': {
            'Fruits & Vegetables':  [A_WEIGHT, 'Origin', 'Organic:Yes|No', A_EXPIRY],
            'Snacks':               [A_BRAND, A_WEIGHT, 'Flavor', A_EXPIRY],
            'Beverages':            [A_BRAND, A_VOLUME, 'Flavor', A_EXPIRY],
            'Dairy':                [A_BRAND, A_WEIGHT, A_EXPIRY, 'Storage:Refrigerated|Room temperature'],
            'Rice & Grains':        [A_BRAND, A_WEIGHT, 'Type', A_EXPIRY],
            'Household Essentials': [A_BRAND, A_WEIGHT, A_EXPIRY]
        },
        'Sports & Fitness': {
            'Sports Equipment':     [A_BRAND, 'Sport', A_MATERIAL, 'Size'],
            'Gym Equipment':        [A_BRAND, 'Weight', 'Max user weight', A_MATERIAL],
            'Fitness Accessories':  [A_BRAND, A_MATERIAL, A_COLOR],
            'Outdoor Gear':         [A_BRAND, 'Capacity', A_MATERIAL, A_COLOR],
            'Sportswear':           [A_CSIZE, A_GENDER, A_COLOR, A_MATERIAL]
        },
        'Books & Stationery': {
            'Books':            ['Author', 'Publisher', 'Language', 'Format:Paperback|Hardcover|eBook'],
            'Notebooks':        [A_BRAND, 'Pages', 'Size:A4|A5|A6|B5', 'Ruling:Ruled|Plain|Grid|Dotted'],
            'Pens & Pencils':   [A_BRAND, 'Type:Ballpoint|Gel|Fountain|Pencil|Marker', 'Ink color', 'Pack size'],
            'School Supplies':  [A_BRAND, 'Type', A_COLOR, 'Pack size'],
            'Office Supplies':  [A_BRAND, A_MATERIAL, A_COLOR, 'Pack size']
        },
        'Automotive': {
            'Car Accessories':  [A_BRAND, 'Compatible with', A_COLOR, A_MATERIAL],
            'Bike Accessories': [A_BRAND, 'Compatible with', A_COLOR, A_MATERIAL],
            'Car Care':         [A_BRAND, 'Type', A_VOLUME],
            'Spare Parts':      [A_BRAND, 'Part number', 'Compatible vehicle', 'Condition:New|Refurbished'],
            'Helmets':          [A_BRAND, 'Size:S|M|L|XL', 'Type:Full face|Half face|Modular|Open face', A_COLOR]
        },
        'Toys & Games': {
            'Toys':                 [A_BRAND, 'Age group:0-2 yrs|3-5 yrs|6-8 yrs|9-12 yrs|13+ yrs', A_MATERIAL, A_COLOR],
            'Board Games':          [A_BRAND, 'Players', 'Age group:6+|8+|12+|16+', 'Play time'],
            'Video Games':          ['Platform:PC|PlayStation|Xbox|Nintendo Switch|Mobile', 'Genre', 'Rating', 'Edition'],
            'Educational Toys':     [A_BRAND, 'Age group:0-2 yrs|3-5 yrs|6-8 yrs|9-12 yrs|13+ yrs', 'Skill focus', A_MATERIAL],
            'Remote-Control Toys':  [A_BRAND, 'Battery type', 'Range', A_COLOR]
        },
        'Health & Wellness': {
            'Vitamins & Supplements': [A_BRAND, 'Form:Tablet|Capsule|Powder|Liquid|Gummy', 'Quantity', A_EXPIRY],
            'Fitness':                [A_BRAND, 'Type', A_MATERIAL, A_COLOR],
            'Healthcare Products':    [A_BRAND, 'Type', 'Quantity', A_EXPIRY],
            'Personal Wellness':      [A_BRAND, 'Type', A_VOLUME, A_EXPIRY]
        }
    };
    const CAT_NAMES = Object.keys(CATALOG);
    function parseAttr(s) {
        let m;
        if ((m = s.match(/^(.+?)@(\w+)$/))) return { label: m[1], type: m[2] };
        if ((m = s.match(/^(.+?):(.+)$/))) return { label: m[1], type: 'select', opts: m[2].split('|') };
        return { label: s, type: 'text' };
    }

    document.addEventListener('DOMContentLoaded', function () {
        const sidebar = $('#sidebar'), main = $('.main');
        const mq = window.matchMedia('(max-width: 900px)');

        /* ============ Shell: drawer, scrim, toasts ============ */
        const scrim = el('div', 'scrim'); document.body.appendChild(scrim);
        const toasts = el('div', 'toasts'); document.body.appendChild(toasts);
        const burger = el('button', 'menu-toggle', '<span class="material-symbols-outlined">menu</span> Menu');
        burger.type = 'button'; burger.setAttribute('aria-label', 'Open menu'); main.prepend(burger);

        function drawer(open) {
            sidebar.classList.toggle('open', open);
            scrim.classList.toggle('show', open && mq.matches);
            document.body.classList.toggle('no-scroll', open && mq.matches);
        }
        burger.onclick = () => drawer(!sidebar.classList.contains('open'));
        scrim.onclick = () => drawer(false);
        $('#collapseBtn').onclick = function (e) {
            e.stopPropagation();
            if (mq.matches) return drawer(false);
            sidebar.classList.toggle('collapsed');
            store.set('sellerSidebar', sidebar.classList.contains('collapsed') ? '1' : '0');
        };
        $('.sidebar-header .icon-box').onclick = () => sidebar.classList.remove('collapsed');
        function applyLayout() {
            if (mq.matches) { sidebar.classList.remove('collapsed'); drawer(false); }
            else { drawer(false); sidebar.classList.toggle('collapsed', store.get('sellerSidebar') === '1'); }
        }
        mq.addEventListener('change', applyLayout); applyLayout();

        function toast(msg, type, go) {
            const t = el('div', 'toast ' + (type || ''), esc(msg));
            if (go) { t.classList.add('clickable'); t.onclick = () => show(go, true); }
            toasts.appendChild(t);
            requestAnimationFrame(() => t.classList.add('show'));
            setTimeout(() => { t.classList.remove('show'); setTimeout(() => t.remove(), 300); }, 3800);
        }

        /* ============ Modal + popover helpers ============ */
        function closeModal() { const m = $('.modal-backdrop'); if (m) m.remove(); document.body.classList.remove('no-scroll'); }
        function modal(title, body, buttons) {
            closeModal();
            const b = el('div', 'modal-backdrop',
                '<div class="modal" role="dialog" aria-modal="true"><div class="modal-head"><h3>' + esc(title) +
                '</h3><button type="button" class="modal-x" aria-label="Close">&times;</button></div>' +
                '<div class="modal-body">' + body + '</div><div class="modal-foot"></div></div>');
            (buttons || []).forEach(function (d) {
                const bt = el('button', d[1], esc(d[0])); bt.type = 'button'; bt.onclick = d[2];
                $('.modal-foot', b).appendChild(bt);
            });
            b.addEventListener('mousedown', e => { if (e.target === b) closeModal(); });
            $('.modal-x', b).onclick = closeModal;
            document.body.appendChild(b); document.body.classList.add('no-scroll');
            const f = $('input, textarea, select', b); if (f) f.focus();
            return b;
        }
        function confirmBox(title, text, label, fn) {
            modal(title, '<p class="modal-text">' + text + '</p>', [['Cancel', 'btn-outline', closeModal],
                [label, 'btn-primary danger', function () { closeModal(); fn(); }]]);
        }

        let pop = null;
        function closePop() { if (pop) { pop.remove(); pop = null; } }
        function popover(anchor, html, alignRight) {
            if (pop && pop._a === anchor) return closePop();
            closePop();
            pop = el('div', 'popover', html); pop._a = anchor; document.body.appendChild(pop);
            const r = anchor.getBoundingClientRect(), w = pop.offsetWidth;
            let left = (alignRight ? r.right - w : r.left) + window.scrollX;
            pop.style.left = Math.max(8, Math.min(left, window.innerWidth - w - 8)) + 'px';
            pop.style.top = (r.bottom + window.scrollY + 6) + 'px';
            return pop;
        }
        document.addEventListener('click', function (e) {
            if (pop && !pop.contains(e.target) && !pop._a.contains(e.target)) closePop();
            const g = e.target.closest('[data-go]');
            if (g) { closePop(); show(g.dataset.go, true); }
            const h = e.target.closest('.pcard-heart');
            if (h) h.classList.toggle('on');
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { closeModal(); closePop(); drawer(false); }
        });

        /* ============ State (read once from the server-rendered DOM) ============ */
        const P = $$('#productsTable tbody tr').map(function (r) {
            const t = r.children, subEl = $('.sub-tag', r);
            let jsonData = {};
            if (r.dataset.json) {
                try { jsonData = JSON.parse(r.dataset.json); } catch (e) { jsonData = {}; }
            }
            let imagesList = [];
            if (r.dataset.images) {
                try { imagesList = JSON.parse(r.dataset.images); } catch (e) { imagesList = []; }
            }

            return {
                id: r.dataset.id || null,
                name: $('.prod-name', r).textContent.trim(),
                sku: $('.prod-sku', r).textContent.trim(),
                cat: $('.cat-tag', r).lastChild.textContent.trim(),
                sub: subEl ? subEl.textContent.trim() : '',
                price: num(t[2].childNodes[0].textContent),
                disc: num($('.discount', r) && $('.discount', r).textContent),
                stock: num(t[3].childNodes[0].textContent),
                sold: num(t[4].textContent),
                active: $('.pill', r).textContent.trim() === 'Active',
                imageUrl: $('.prod-thumb img', r) ? $('.prod-thumb img', r).src : '',
                editData: jsonData,
                images: imagesList
            };
        });
        let O = [];
        try { O = JSON.parse($('#orderData').textContent) || []; } catch (e) { O = []; }
        O.forEach(function (o) {
            o.product = o.items.length > 1
                ? o.items[0].name + ' +' + (o.items.length - 1) + ' more'
                : (o.items[0] ? o.items[0].name : '');
        });
        const M = $$('#messageList .msg-item').map(function (i) {
            return {
                name: $('.msg-name', i).textContent.trim(), subject: $('.msg-subject', i).textContent.trim(),
                time: $('.msg-time', i).textContent.trim(), unread: i.classList.contains('unread'),
                thread: [{ me: false, text: $('.msg-preview', i).textContent.trim() }]
            };
        });
        const dashCards = $$('#approvedDashboard .stat-card');
        let revenue = num($('.stat-value', dashCards[0]).textContent);
        let orderCount = num($('.stat-value', dashCards[1]).textContent);

        // PAGINATION: `page` = current products page, PAGE_SIZE = rows per page
        const PAGE_SIZE = 5;
        const ui = { pq: '', pf: 'all', sort: null, dir: 1, oq: '', of: 'all', mq: '', page: 1 };
        const FILTERS = { all: 'All products', active: 'Active', inactive: 'Inactive', low: 'Low stock (≤5)', out: 'Out of stock' };

        /* ============ Alerts (also feed the bell) ============ */
        function alertList() {
            const a = [], low = P.find(p => p.active && p.stock > 0 && p.stock <= 5);
            const out = P.find(p => p.active && p.stock === 0), ret = O.find(o => o.status === 'return');
            const unread = M.filter(m => m.unread).length;
            if (low) a.push({ cls: 'warning', icon: 'warning', title: 'Low stock alert', body: low.name + ' — only ' + low.stock + ' unit' + (low.stock > 1 ? 's' : '') + ' left.', go: 'products' });
            if (out) a.push({ cls: 'warning', icon: 'production_quantity_limits', title: 'Out of stock', body: out.name + ' is sold out but still active.', go: 'products' });
            if (ret) a.push({ cls: 'orange', icon: 'published_with_changes', title: 'Return request', body: ret.cust + ' — ' + ret.product + '.', go: 'orders' });
            if (unread) a.push({ cls: 'info', icon: 'inbox', title: unread + ' unread message' + (unread > 1 ? 's' : ''), body: 'Customer inquiries awaiting reply.', go: 'messages' });
            return a;
        }

        /* ============ Pagination helpers ============ */
        // Builds e.g. [1, '…', 4, 5, 6, '…', 20]
        function pageNumbers(cur, total) {
            if (total <= 7) return Array.from({ length: total }, (_, i) => i + 1);
            const s = new Set([1, total, cur - 1, cur, cur + 1]);
            if (cur <= 3) { s.add(2); s.add(3); s.add(4); }
            if (cur >= total - 2) { s.add(total - 1); s.add(total - 2); s.add(total - 3); }
            const arr = [...s].filter(n => n >= 1 && n <= total).sort((a, b) => a - b);
            const out = [];
            arr.forEach((n, i) => { if (i && n - arr[i - 1] > 1) out.push('…'); out.push(n); });
            return out;
        }

        function renderPager(total, pages, start, shown) {
            const box = $('#productsPagination');
            if (!box) return;
            if (total <= PAGE_SIZE) { box.style.display = 'none'; box.innerHTML = ''; return; }
            box.style.display = 'flex';
            box.innerHTML =
                '<div class="pg-info">Showing <strong>' + (start + 1) + '–' + (start + shown) + '</strong> of <strong>' + total + '</strong> products</div>' +
                '<div class="pg-controls">' +
                '<button type="button" class="pg-btn pg-nav" data-page="' + (ui.page - 1) + '"' + (ui.page === 1 ? ' disabled' : '') + ' aria-label="Previous page"><span class="material-symbols-outlined">chevron_left</span></button>' +
                pageNumbers(ui.page, pages).map(n => n === '…'
                    ? '<span class="pg-dots">…</span>'
                    : '<button type="button" class="pg-btn' + (n === ui.page ? ' active' : '') + '" data-page="' + n + '"' + (n === ui.page ? ' aria-current="page"' : '') + '>' + n + '</button>').join('') +
                '<button type="button" class="pg-btn pg-nav" data-page="' + (ui.page + 1) + '"' + (ui.page === pages ? ' disabled' : '') + ' aria-label="Next page"><span class="material-symbols-outlined">chevron_right</span></button>' +
                '</div>';
        }

        /* ============ Renderers ============ */
        function renderProducts() {
            const q = ui.pq.toLowerCase();
            let list = P.filter(function (p) {
                const f = ui.pf;
                const okF = f === 'all' || (f === 'active' && p.active) || (f === 'inactive' && !p.active) ||
                    (f === 'low' && p.stock > 0 && p.stock <= 5) || (f === 'out' && p.stock === 0);
                const hay = (p.name + ' ' + p.sku + ' ' + p.cat + ' ' + (p.sub || '') + ' ' + Object.values(p.attrs || {}).join(' ')).toLowerCase();
                return okF && (!q || hay.includes(q));
            });
            if (ui.sort) list.sort(function (a, b) {
                const x = a[ui.sort], y = b[ui.sort];
                return (typeof x === 'string' ? x.localeCompare(y) : x - y) * ui.dir;
            });

            // PAGINATION: slice the filtered + sorted list to the current page
            const totalPages = Math.max(1, Math.ceil(list.length / PAGE_SIZE));
            if (ui.page > totalPages) ui.page = totalPages;   // e.g. after deleting the last item on a page
            if (ui.page < 1) ui.page = 1;
            const start = (ui.page - 1) * PAGE_SIZE;
            const pageList = list.slice(start, start + PAGE_SIZE);

            $('#productsTable tbody').innerHTML = pageList.map(function (p) {
                const attrTxt = Object.keys(p.attrs || {}).map(k => p.attrs[k]).join(' · ');
                return '<tr data-sku="' + esc(p.sku) + '" data-id="' + esc(p.id) + '"><td><div class="prod-cell"><div class="prod-thumb">' +
                    (p.imageUrl ? '<img src="' + esc(p.imageUrl) + '" style="width:100%; height:100%; object-fit:cover; border-radius:4px;">' : esc(p.name.charAt(0))) +
                    '</div><div><div class="prod-name">' + esc(p.name) + '</div><div class="prod-sku">' + esc(p.sku) + '</div>' +
                    (attrTxt ? '<div class="prod-attrs">' + esc(attrTxt) + '</div>' : '') + '</div></div></td>' +
                    '<td><span class="cat-tag"><span class="material-symbols-outlined">sell</span>' + esc(p.cat) + '</span>' +
                    (p.sub ? '<div class="sub-tag">' + esc(p.sub) + '</div>' : '') + '</td>' +
                    '<td class="num price">Rs ' + fmt(p.price) + (p.disc ? '<span class="discount">-' + p.disc + '%</span>' : '') + '</td>' +
                    '<td class="num stock ' + (p.stock === 0 ? 'out' : p.stock <= 5 ? 'low' : '') + '">' + p.stock + (p.stock === 0 ? ' <small>Out</small>' : '') + '</td>' +
                    '<td class="num sold">' + p.sold + '</td>' +
                    '<td><button type="button" class="pill ' + (p.active ? 'pill-active' : 'pill-inactive') + '" data-act="toggle" title="Click to change status">' + (p.active ? 'Active' : 'Inactive') + '</button></td>' +
                    '<td class="actions"><span class="material-symbols-outlined" data-act="edit" title="Edit">edit</span><span class="material-symbols-outlined" data-act="del" title="Delete">delete</span></td></tr>';
            }).join('') || '<tr><td colspan="7" class="empty-note">No products match your search or filter.</td></tr>';
            $('#view-products .page-subtitle').textContent = P.length + ' listing' + (P.length === 1 ? '' : 's') +
                (list.length !== P.length ? ' · ' + list.length + ' shown' : '');
            $$('#productsTable thead th').forEach(function (th, i) {
                const k = ['name', 'cat', 'price', 'stock', 'sold'][i]; if (!k) return;
                th.dataset.key = k; th.classList.add('sortable');
                th.classList.toggle('asc', ui.sort === k && ui.dir === 1);
                th.classList.toggle('desc', ui.sort === k && ui.dir === -1);
            });
            const fb = $('#view-products .btn-filter');
            fb.innerHTML = '<span class="material-symbols-outlined">filter_alt</span> ' + (ui.pf === 'all' ? 'Filter' : FILTERS[ui.pf]);
            fb.classList.toggle('on', ui.pf !== 'all');

            renderPager(list.length, totalPages, start, pageList.length);
        }

        function renderOrders() {
            const q = ui.oq.toLowerCase();
            const list = O.filter(o => (ui.of === 'all' || o.status === ui.of) &&
                (!q || (o.ref + ' ' + o.cust + ' ' + o.product).toLowerCase().includes(q)));
            $('#ordersTable tbody').innerHTML = list.map(o =>
                '<tr data-ref="' + esc(o.ref) + '" data-status="' + o.status + '"><td><div class="order-ref">' + esc(o.ref) + '</div><div class="muted-sm">' + esc(o.date) +
                '</div></td><td><div class="cust-name">' + esc(o.cust) + '</div><div class="muted-sm">' + esc(o.product) + '</div></td>' +
                '<td class="center"><span class="o-badge ' + o.status + '">' + LABEL[o.status] + '</span></td><td class="num price">Rs ' + fmt(o.total) +
                '</td><td class="chev"><span class="material-symbols-outlined">chevron_right</span></td></tr>').join('');
            $('#ordersEmpty').style.display = list.length ? 'none' : 'block';
            $$('#orderTabs .tab').forEach(function (t) {
                const f = t.dataset.filter;
                $('.tab-count', t).textContent = f === 'all' ? O.length : O.filter(o => o.status === f).length;
            });
            $('#view-orders .page-subtitle').textContent = O.length + ' total orders';
        }

        function renderStore() {
            const act = P.filter(p => p.active);
            $('.store-grid').innerHTML = act.map(function (p) {
                const sale = p.disc ? Math.round(p.price * (100 - p.disc) / 100) : p.price;
                const sold = p.sold >= 1000 ? (p.sold / 1000).toFixed(1) + 'k' : p.sold;
                const stock = p.stock === 0 ? ['out', 'Out of stock'] : p.stock <= 5 ? ['low', 'Only ' + p.stock + ' left'] : ['', p.stock + ' in stock'];
                return '<div class="pcard"><div class="pcard-img">' +
                    (p.imageUrl ? '<img src="' + esc(p.imageUrl) + '" style="width:100%; height:100%; object-fit:cover;">' : esc(p.name.charAt(0))) +
                    (p.disc ? '<span class="pcard-badge">-' + p.disc + '%</span>' : '') +
                    '<button type="button" class="pcard-heart" aria-label="Wishlist"><span class="material-symbols-outlined">favorite</span></button></div>' +
                    '<div class="pcard-top"><span class="pcard-cat">' + esc(p.sub || p.cat) + '</span><span class="pcard-sold">' + sold + ' sold</span></div>' +
                    '<h4 class="pcard-name">' + esc(p.name) + '</h4>' +
                    '<div class="pcard-bottom"><div><span class="pcard-price">Rs ' + fmt(sale) + '</span>' +
                    (p.disc ? '<span class="pcard-old">Rs ' + fmt(p.price) + '</span>' : '') +
                    '<span class="pcard-stock ' + stock[0] + '">' + stock[1] + '</span></div>' +
                    '<button type="button" class="pcard-btn" data-go="products">Edit</button></div></div>';
            }).join('');
            $('#view-mystore .s-stat strong').textContent = act.length;
        }

        function renderMessages() {
            const q = ui.mq.toLowerCase();
            const html = M.map((m, i) => ({ m: m, i: i })).filter(x => !q || (x.m.name + ' ' + x.m.subject + ' ' + x.m.thread.map(t => t.text).join(' ')).toLowerCase().includes(q))
                .map(x => '<div class="msg-item' + (x.m.unread ? ' unread' : '') + '" data-i="' + x.i + '"><div class="msg-row"><span class="msg-name">' + esc(x.m.name) +
                    '</span><span class="msg-time">' + esc(x.m.time) + '</span></div><div class="msg-subject">' + esc(x.m.subject) + '</div><div class="msg-preview">' +
                    esc((x.m.thread[x.m.thread.length - 1].me ? 'You: ' : '') + x.m.thread[x.m.thread.length - 1].text) + '</div></div>').join('');
            $('#messageList').innerHTML = html || '<div class="empty-note">No messages found.</div>';
        }

        function syncDash() {
            $('.stat-value', dashCards[0]).textContent = 'Rs ' + fmt(revenue);
            $('.stat-value', dashCards[1]).textContent = orderCount;
            $('.stat-value', dashCards[2]).textContent = P.length;
            $('.stat-sub', dashCards[2]).textContent = P.filter(p => !p.active).length + ' inactive';

            const al = alertList();
            $('#approvedDashboard .alerts-grid').innerHTML = al.map(a =>
                '<div class="alert-card ' + a.cls + ' clickable" data-go="' + a.go + '"><span class="material-symbols-outlined alert-icon">' + a.icon +
                '</span><div class="alert-content"><div class="alert-title">' + esc(a.title) + '</div><div class="alert-body">' + esc(a.body) + '</div></div></div>').join('');
            const bell = $('.icon-btn[aria-label="Notifications"]');
            if (bell) { if (al.length) bell.dataset.count = al.length; else delete bell.dataset.count; }

            $('.orders-table tbody').innerHTML = O.slice(0, 4).map(o =>
                '<tr><td class="order-id">' + esc(o.ref) + '</td><td class="customer-name">' + esc(o.cust) + '</td><td class="product-name">' + esc(o.product) +
                '</td><td class="order-status"><span class="status-badge ' + o.status + '">' + LABEL[o.status] + '</span></td><td class="order-price">Rs ' + fmt(o.total) + '</td></tr>').join('');

            const n = M.filter(m => m.unread).length;
            $('#unreadSubtitle').textContent = n + ' unread';
            let badge = $('#sidebarNav .nav-item[data-view="messages"] .badge');
            if (!badge && n) { badge = el('span', 'badge'); $('#sidebarNav .nav-item[data-view="messages"]').appendChild(badge); }
            if (badge) { badge.textContent = n; badge.style.display = n ? '' : 'none'; }
        }
        function refresh() { renderProducts(); renderFlash(); renderOrders(); renderStore(); renderMessages(); syncDash(); }

        /* ============ Routing (hash + back button) ============ */
        const VIEWS = ['dashboard', 'products', 'flashsale', 'orders', 'finance', 'mystore', 'messages'];
        let approved = false;
        function show(v, push) {
            if (VIEWS.indexOf(v) < 0 || !approved) v = 'dashboard';
            VIEWS.forEach(k => { $('#view-' + k).style.display = k === v ? 'block' : 'none'; });
            $$('#sidebarNav .nav-item').forEach(i => i.classList.toggle('active', i.dataset.view === v));
            if (push && location.hash !== '#' + v) history.pushState(null, '', '#' + v);
            closePop(); drawer(false); window.scrollTo(0, 0);
        }
        $$('#sidebarNav .nav-item').forEach(i => i.addEventListener('click', () => { if (!i.classList.contains('disabled')) show(i.dataset.view, true); }));
        window.addEventListener('popstate', () => show(location.hash.slice(1), false));
        const va = $('.view-all-link'); if (va) va.addEventListener('click', e => { e.preventDefault(); show('orders', true); });

        /* ============ Products ============ */
        const pTable = $('#productsTable');
        $('#productSearch').addEventListener('input', function () { ui.pq = this.value; ui.page = 1; renderProducts(); });
        $('#view-products .btn-filter').addEventListener('click', function (e) {
            const p = popover(this, Object.keys(FILTERS).map(k => '<button type="button" data-f="' + k + '" class="' + (ui.pf === k ? 'on' : '') + '">' + FILTERS[k] + '</button>').join(''));
            if (p) p.onclick = ev => { const b = ev.target.closest('[data-f]'); if (b) { ui.pf = b.dataset.f; ui.page = 1; closePop(); renderProducts(); } };
        });
        $('#view-products .btn-primary').addEventListener('click', () => productForm(null));
        $('#productsTable thead').addEventListener('click', function (e) {
            const th = e.target.closest('th[data-key]'); if (!th) return;
            ui.dir = ui.sort === th.dataset.key ? -ui.dir : 1; ui.sort = th.dataset.key; ui.page = 1; renderProducts();
        });

        // PAGINATION: page button / prev / next clicks
        const pager = $('#productsPagination');
        if (pager) pager.addEventListener('click', function (e) {
            const b = e.target.closest('[data-page]');
            if (!b || b.disabled) return;
            ui.page = Number(b.dataset.page);
            renderProducts();
            const tb = $('#view-products .toolbar');
            if (tb) tb.scrollIntoView({ behavior: 'smooth', block: 'start' });
        });

        // EDIT / TOGGLE / DELETE HANDLERS (all persist via API)
        $('tbody', pTable).addEventListener('click', function (e) {
            const a = e.target.closest('[data-act]'); if (!a) return;
            const p = P.find(x => x.sku === a.closest('tr').dataset.sku); if (!p) return;

            if (a.dataset.act === 'edit') productForm(p);

            // The Active/Inactive pill persists to the database via the API
            if (a.dataset.act === 'toggle') {
                if (!p.id) {
                    toast('Product ID missing. Cannot update.', 'error');
                    return;
                }
                const target = !p.active;
                const fd = new FormData();
                fd.append('id', p.id);
                fd.append('active', String(target));

                fetch('/api/products/toggleActive', {
                    method: 'POST',
                    body: fd
                })
                    .then(response => {
                        if (response.ok) {
                            p.active = target;
                            refresh();
                            toast(p.name + ' is now ' + (target ? 'active' : 'inactive') + '.');
                        } else {
                            response.text().then(msg => toast('Error: ' + msg, 'error'));
                        }
                    })
                    .catch(error => {
                        console.error(error);
                        toast('Network error. Please try again.', 'error');
                    });
            }

            if (a.dataset.act === 'del') {
                confirmBox('Delete product', 'Delete <strong>' + esc(p.name) + '</strong>? This cannot be undone.', 'Delete', function () {
                    if (!p.id) {
                        toast('Product ID missing. Cannot delete.', 'error');
                        return;
                    }
                    const deleteData = new FormData();
                    deleteData.append('id', p.id);

                    fetch('/api/products/delete', {
                        method: 'POST',
                        body: deleteData
                    })
                        .then(response => {
                            if (response.ok) {
                                P.splice(P.indexOf(p), 1);
                                refresh();   // renderProducts() moves back a page if this one is now empty
                                toast('Product deleted successfully.', 'ok');
                            } else {
                                response.text().then(msg => toast('Error: ' + msg, 'error'));
                            }
                        })
                        .catch(error => {
                            console.error(error);
                            toast('Network error. Please try again.', 'error');
                        });
                });
            }
        });

        function cleanHtml(html) {
            const t = document.createElement('div');
            t.innerHTML = html || '';
            const ok = { B: 1, STRONG: 1, I: 1, EM: 1, UL: 1, LI: 1, BR: 1, DIV: 1, P: 1, A: 1 };
            (function walk(n) {
                [...n.childNodes].forEach(function (c) {
                    if (c.nodeType === 3) return;
                    if (c.nodeType !== 1) { c.remove(); return; }
                    if (/^(SCRIPT|STYLE|IFRAME|OBJECT|EMBED)$/.test(c.tagName)) { c.remove(); return; }
                    if (!ok[c.tagName]) { walk(c); c.replaceWith(...c.childNodes); return; }
                    [...c.attributes].forEach(function (a) {
                        if (!(c.tagName === 'A' && a.name === 'href' && /^https?:\/\/\S+$/i.test(a.value))) c.removeAttribute(a.name);
                    });
                    if (c.tagName === 'A') { c.target = '_blank'; c.rel = 'noopener noreferrer'; }
                    walk(c);
                });
            })(t);
            return t.innerHTML;
        }

        // PRODUCT FORM
        function productForm(p) {
            const isNew = !p;
            let currentProductId = null;

            if (!isNew && p.id) {
                currentProductId = p.id;
            }

            const d = (p && p.editData && Object.keys(p.editData).length > 0)
                ? p.editData
                : { name: '', cat: CAT_NAMES[0], sub: '', attrs: {}, price: '', disc: 0, stock: '', active: true, description: '', infoImage: '' };
            const cats = [...new Set(CAT_NAMES.concat(P.map(x => x.cat)))];

            const m = modal(isNew ? 'Add product' : 'Edit product',
                '<label class="fld">Product name<input id="f-name" maxlength="60" value="' + esc(d.name) + '"><span class="err"></span></label>' +
                '<div class="fld-row"><label class="fld">Category<select id="f-cat">' + cats.map(c => '<option' + (c === d.cat ? ' selected' : '') + '>' + esc(c) + '</option>').join('') + '</select></label>' +
                '<label class="fld">Sub-category<select id="f-sub"></select><span class="err"></span></label></div>' +
                '<div id="f-attrs"></div>' +
                '<div class="fld-row"><label class="fld">Price (Rs)<input id="f-price" type="number" min="1" value="' + d.price + '"><span class="err"></span></label>' +
                '<label class="fld">Discount %<input id="f-disc" type="number" min="0" max="90" value="' + (d.disc || 0) + '"><span class="err"></span></label></div>' +
                '<div class="fld-row"><label class="fld">Stock<input id="f-stock" type="number" min="0" value="' + d.stock + '"><span class="err"></span></label></div>' +

                '<div class="rich-editor">' +
                '<div class="editor-label"><span>DETAILED DESCRIPTION &amp; SPECIFICATIONS</span><span class="editor-support">Supports Rich Text</span></div>' +
                '<div class="editor-box">' +
                '<div class="editor-toolbar">' +
                '<button type="button" data-cmd="bold" title="Bold"><b>B</b></button>' +
                '<button type="button" data-cmd="italic" title="Italic"><i>I</i></button>' +
                '<button type="button" data-cmd="insertUnorderedList" title="Bullet list">☷</button>' +
                '<button type="button" data-cmd="justifyLeft" title="Align left">☰</button>' +
                '<button type="button" data-link title="Insert link">🔗</button>' +
                '</div>' +
                '<div id="f-description" class="editor-content" contenteditable="true" ' +
                'data-placeholder="Enter comprehensive product story, key features, dimensions, technical specs..." ' +
                'role="textbox" aria-multiline="true">' + cleanHtml(d.description) + '</div>' +
                '</div>' +
                '<span class="err" id="description-err"></span>' +
                '</div>' +

                '<div class="image-upload-section">' +
                '<div class="editor-label"><span>DETAILED INFORMATION IMAGE</span><span class="editor-support">Spec sheet / Info graphic</span></div>' +
                '<div class="image-dropzone single" id="f-infoimage-zone">' +
                '<input type="file" id="f-infoimage" accept="image/*" hidden>' +
                '<div class="dz-content">' +
                '<div class="dz-placeholder">Click or drag image here</div>' +
                '<div class="dz-preview hidden" id="f-infoimage-preview"></div>' +
                '</div>' +
                '<button type="button" class="dz-remove hidden" id="f-infoimage-remove" title="Remove">×</button>' +
                '</div>' +
                '<span class="err" id="infoimage-err"></span>' +
                '</div>' +

                '<div class="image-upload-section">' +
                '<div class="editor-label"><span>PRODUCT IMAGES</span><span class="editor-support" id="prod-img-count">0 / 8</span></div>' +
                '<div class="image-dropzone multi" id="f-prodimages-zone">' +
                '<input type="file" id="f-prodimages" accept="image/*" multiple hidden>' +
                '<div class="dz-content">' +
                '<div class="dz-placeholder">Click or drag images here (1–8)</div>' +
                '<div class="dz-gallery" id="f-prodimages-gallery"></div>' +
                '</div>' +
                '</div>' +
                '<span class="err" id="prodimages-err"></span>' +
                '</div>' +

                '<label class="chk"><input id="f-active" type="checkbox"' + (d.active ? ' checked' : '') + '> Listed as active</label>',
                [['Cancel', 'btn-outline', closeModal], [isNew ? 'Add product' : 'Save changes', 'btn-primary', save]]);

            // save button + "Adding..." / "Saving..." state
            const saveBtn = $('.modal-foot .btn-primary', m);
            const idleLabel = isNew ? 'Add product' : 'Save changes';
            const busyLabel = isNew ? 'Adding...' : 'Saving...';
            let busy = false;
            function setBusy(state) {
                busy = state;
                if (!saveBtn) return;
                saveBtn.disabled = state;
                saveBtn.textContent = state ? busyLabel : idleLabel;
            }

            const catSel = $('#f-cat', m), subSel = $('#f-sub', m), box = $('#f-attrs', m);
            let infoImage = d.infoImage || '';
            let prodImages = (p && p.images && p.images.length > 0) ? [...p.images] : [];

            const editor = $('#f-description', m), toolbar = $('.editor-toolbar', m);
            let savedRange = null;

            function rememberRange() {
                const s = window.getSelection();
                if (s.rangeCount && editor.contains(s.getRangeAt(0).commonAncestorContainer)) savedRange = s.getRangeAt(0).cloneRange();
            }
            function restoreRange() {
                editor.focus();
                if (savedRange) { const s = window.getSelection(); s.removeAllRanges(); s.addRange(savedRange); }
            }
            ['keyup', 'mouseup', 'input', 'focus'].forEach(ev => editor.addEventListener(ev, rememberRange));

            toolbar.addEventListener('mousedown', function (e) { if (e.target.closest('button')) e.preventDefault(); });
            toolbar.addEventListener('click', function (e) {
                const btn = e.target.closest('button'); if (!btn) return;
                restoreRange();
                if (btn.dataset.cmd) document.execCommand(btn.dataset.cmd, false, null);
                if (btn.hasAttribute('data-link')) {
                    const url = (prompt('Enter the URL (https://...):') || '').trim();
                    restoreRange();
                    if (url && /^https?:\/\/\S+$/i.test(url)) document.execCommand('createLink', false, url);
                    else if (url) toast('Link must start with http:// or https://');
                }
                rememberRange();
            });
            editor.addEventListener('paste', function (e) {
                e.preventDefault();
                const txt = (e.clipboardData || window.clipboardData).getData('text/plain');
                document.execCommand('insertText', false, txt);
            });

            const infoZone = $('#f-infoimage-zone', m);
            const infoInput = $('#f-infoimage', m);
            const infoPreview = $('#f-infoimage-preview', m);
            const infoRemove = $('#f-infoimage-remove', m);

            infoZone.addEventListener('click', () => infoInput.click());
            infoInput.addEventListener('change', function () {
                if (this.files && this.files[0]) {
                    const r = new FileReader();
                    r.onload = e => { infoImage = e.target.result; updateInfoPreview(); };
                    r.readAsDataURL(this.files[0]);
                }
            });
            infoRemove.addEventListener('click', e => { e.stopPropagation(); infoImage = ''; updateInfoPreview(); });

            function updateInfoPreview() {
                if (infoImage) {
                    infoPreview.innerHTML = '<img src="' + infoImage + '">';
                    infoPreview.classList.remove('hidden');
                    infoRemove.classList.remove('hidden');
                    $('.dz-placeholder', infoZone).classList.add('hidden');
                } else {
                    infoPreview.innerHTML = '';
                    infoPreview.classList.add('hidden');
                    infoRemove.classList.add('hidden');
                    $('.dz-placeholder', infoZone).classList.remove('hidden');
                }
            }
            updateInfoPreview();

            ['dragenter', 'dragover'].forEach(ev => infoZone.addEventListener(ev, e => { e.preventDefault(); infoZone.classList.add('dragover'); }));
            ['dragleave', 'drop'].forEach(ev => infoZone.addEventListener(ev, e => { e.preventDefault(); infoZone.classList.remove('dragover'); }));
            infoZone.addEventListener('drop', e => {
                const f = e.dataTransfer.files[0];
                if (f && f.type.startsWith('image/')) {
                    const r = new FileReader();
                    r.onload = ev => { infoImage = ev.target.result; updateInfoPreview(); };
                    r.readAsDataURL(f);
                }
            });

            const prodZone = $('#f-prodimages-zone', m);
            const prodInput = $('#f-prodimages', m);
            const prodGallery = $('#f-prodimages-gallery', m);
            const prodCount = $('#prod-img-count', m);

            prodZone.addEventListener('click', e => { if (e.target === prodZone || e.target.closest('.dz-content')) prodInput.click(); });
            prodInput.addEventListener('change', function () {
                [...this.files].forEach(f => {
                    if (!f.type.startsWith('image/')) return;
                    if (prodImages.length >= 8) return;
                    const r = new FileReader();
                    r.onload = e => { prodImages.push(e.target.result); updateProdGallery(); };
                    r.readAsDataURL(f);
                });
                this.value = '';
            });

            function updateProdGallery() {
                prodCount.textContent = prodImages.length + ' / 8';
                if (prodImages.length === 0) {
                    prodGallery.innerHTML = '';
                    $('.dz-placeholder', prodZone).classList.remove('hidden');
                } else {
                    $('.dz-placeholder', prodZone).classList.add('hidden');
                    prodGallery.innerHTML = prodImages.map((src, i) =>
                        '<div class="thumb"><img src="' + src + '"><button type="button" data-idx="' + i + '" class="del">×</button></div>'
                    ).join('');
                }
                $$('.dz-gallery .del', m).forEach(b => b.addEventListener('click', e => {
                    e.stopPropagation();
                    prodImages.splice(Number(b.dataset.idx), 1);
                    updateProdGallery();
                }));
            }
            updateProdGallery();

            ['dragenter', 'dragover'].forEach(ev => prodZone.addEventListener(ev, e => { e.preventDefault(); prodZone.classList.add('dragover'); }));
            ['dragleave', 'drop'].forEach(ev => prodZone.addEventListener(ev, e => { e.preventDefault(); prodZone.classList.remove('dragover'); }));
            prodZone.addEventListener('drop', e => {
                [...e.dataTransfer.files].forEach(f => {
                    if (!f.type.startsWith('image/')) return;
                    if (prodImages.length >= 8) return;
                    const r = new FileReader();
                    r.onload = ev => { prodImages.push(ev.target.result); updateProdGallery(); };
                    r.readAsDataURL(f);
                });
            });

            function fillAttrs() {
                const specs = (((CATALOG[catSel.value] || {})[subSel.value]) || []).map(parseAttr);
                const keep = (catSel.value === d.cat && subSel.value === d.sub) ? (d.attrs || {}) : {};
                if (!specs.length) { box.innerHTML = ''; return; }
                box.innerHTML = '<div class="attr-head">' + esc(subSel.value) + ' details</div><div class="attr-grid">' + specs.map(function (a) {
                    const v = keep[a.label] || '', lab = esc(a.label);
                    if (a.type === 'select') {
                        return '<label class="fld">' + lab + '<select data-attr="' + lab + '"><option value="">Select</option>' +
                            a.opts.map(o => '<option' + (o === v ? ' selected' : '') + '>' + esc(o) + '</option>').join('') + '</select></label>';
                    }
                    return '<label class="fld">' + lab + '<input data-attr="' + lab + '" type="' + (a.type === 'date' ? 'date' : 'text') + '" maxlength="60" value="' + esc(v) + '"></label>';
                }).join('') + '</div>';
            }
            function fillSubs(selected) {
                const subs = Object.keys(CATALOG[catSel.value] || {});
                subSel.innerHTML = '<option value="">' + (subs.length ? 'Select sub-category' : 'No sub-categories') + '</option>' +
                    subs.map(s => '<option' + (s === selected ? ' selected' : '') + '>' + esc(s) + '</option>').join('');
                subSel.disabled = !subs.length;
                fillAttrs();
            }
            catSel.addEventListener('change', function () { fillSubs(''); });
            subSel.addEventListener('change', function () { err('f-sub', ''); fillAttrs(); });
            fillSubs(d.sub);

            function err(id, msg) {
                const f = $('#' + id, m); f.classList.toggle('bad', !!msg);
                $('.err', f.parentNode).textContent = msg || '';
                return !msg;
            }

            function save() {
                if (busy) return;

                const needSub = Object.keys(CATALOG[catSel.value] || {}).length > 0;
                const attrs = {};
                $$('[data-attr]', m).forEach(i => {
                    if (i.value.trim()) attrs[i.dataset.attr] = i.value.trim();
                });

                const name = $('#f-name', m).value.trim();
                const price = Number($('#f-price', m).value);
                const disc = Number($('#f-disc', m).value || 0);
                const stock = $('#f-stock', m).value;
                const descLen = editor.textContent.trim().length;
                const descMsg = descLen > 3000 ? 'Description is too long (max 3000 characters).' : '';
                $('#description-err', m).textContent = descMsg;
                editor.parentNode.classList.toggle('bad', !!descMsg);

                const prodImagesErr = prodImages.length === 0 && isNew ? 'At least one product image is required.' : prodImages.length > 8 ? 'Maximum 8 product images allowed.' : '';
                $('#prodimages-err', m).textContent = prodImagesErr;
                prodZone.classList.toggle('bad', !!prodImagesErr);

                const ok = [
                    err('f-name', !name ? 'Name is required.' : ''),
                    err('f-sub', needSub && !subSel.value ? 'Select a sub-category.' : ''),
                    err('f-price', !(price >= 1) ? 'Enter a price of at least 1.' : ''),
                    err('f-disc', !(disc >= 0 && disc <= 90) ? '0 – 90 only.' : ''),
                    err('f-stock', stock === '' || Number(stock) < 0 || !Number.isInteger(Number(stock)) ? 'Whole number, 0 or more.' : ''),
                    !descMsg,
                    !prodImagesErr
                ].every(Boolean);
                if (!ok) return;

                setBusy(true);

                const formData = new FormData();
                formData.append('name', name);
                formData.append('category', catSel.value);
                formData.append('subCategory', subSel.value);
                formData.append('price', $('#f-price', m).value);
                formData.append('stock', $('#f-stock', m).value);
                formData.append('discount', $('#f-disc', m).value || '0');
                formData.append('description', editor.innerHTML);
                formData.append('attributes', JSON.stringify(attrs));
                // Send the "Listed as active" checkbox to the server
                formData.append('active', $('#f-active', m).checked ? 'true' : 'false');

                const isNewInfoImage = infoImage && infoImage.startsWith('data:');
                const newProdImages = prodImages.filter(img => img && img.startsWith('data:'));

                const toBlob = src => fetch(src).then(res => res.blob());

                const tasks = [];
                if (isNewInfoImage) {
                    tasks.push(toBlob(infoImage).then(blob => formData.append('infoImage', blob, 'info-image.png')));
                }
                newProdImages.forEach(src => {
                    tasks.push(toBlob(src).then(blob => formData.append('productImages', blob, 'product-image.png')));
                });

                Promise.all(tasks)
                    .then(() => submitProduct(formData, m, isNew))
                    .catch(e => {
                        console.error(e);
                        toast('Error processing images.', 'error');
                        setBusy(false);
                    });
            }

            function submitProduct(formData, modalElement, isNew) {
                const url = isNew ? '/api/products/create' : '/api/products/update';

                if (!isNew) {
                    if (!currentProductId) {
                        toast('Product ID not found. Cannot update.', 'error');
                        setBusy(false);
                        return;
                    }
                    formData.append('id', currentProductId);
                }

                fetch(url, {
                    method: 'POST',
                    body: formData
                })
                    .then(response => {
                        if (response.ok) {
                            try {
                                sessionStorage.setItem('sellerToast', isNew ? 'Product added successfully.' : 'Product updated successfully.');
                            } catch (e) {
                            }
                            if (modalElement) closeModal();
                            location.hash = '#products';
                            location.reload();
                        } else {
                            setBusy(false);
                            response.text().then(errMsg => {
                                toast('Error: ' + errMsg, 'error');
                            });
                        }
                    })
                    .catch(error => {
                        console.error(error);
                        setBusy(false);
                        toast('Network error. Please try again.', 'error');
                    });
            }
            }
            /* ============ Flash Sale ============ */
            const FS = { MIN_DISC: 10, MAX_DISC: 90, MIN_LEAD: 15 * 60e3, MIN_DUR: 3600e3, MAX_DUR: 72 * 3600e3, MAX_ITEMS: 20 };
            let F = [];
            try { F = JSON.parse($('#flashData').textContent) || []; } catch (e) { F = []; }
            let fsFilter = 'all', fsSig = '';

            const pad2 = n => String(n).padStart(2, '0');
            const fsStatus = f => (f.endedEarly || Date.now() >= f.end) ? 'ended' : (Date.now() < f.start ? 'scheduled' : 'live');
            const fsPrice = (price, disc) => Math.round(price * (100 - disc) / 100);
            const fsDate = ms => new Date(ms).toLocaleString('en-US', { month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' });
            const toInput = ms => new Date(ms - new Date(ms).getTimezoneOffset() * 60000).toISOString().slice(0, 16);
            function fsLeft(ms) {
                let s = Math.max(0, Math.floor(ms / 1000));
                const d = Math.floor(s / 86400); s %= 86400;
                const h = Math.floor(s / 3600); s %= 3600;
                const m = Math.floor(s / 60); s %= 60;
                return (d ? d + 'd ' : '') + pad2(h) + ':' + pad2(m) + ':' + pad2(s);
            }
            function fsCountText(f) {
                const st = fsStatus(f);
                if (st === 'live') return 'Ends in ' + fsLeft(f.end - Date.now());
                if (st === 'scheduled') return 'Starts in ' + fsLeft(f.start - Date.now());
                return f.endedEarly ? 'Ended early' : 'Finished';
            }
            function fsSignature() { return F.map(f => f.id + ':' + fsStatus(f)).join('|'); }

            function renderFlash() {
                if (!$('#flashList')) return;
                const by = { live: [], scheduled: [], ended: [] };
                F.forEach(f => by[fsStatus(f)].push(f));
                let units = 0, rev = 0;
                F.forEach(f => f.items.forEach(i => { units += i.sold || 0; rev += (i.sold || 0) * fsPrice(i.price, i.disc); }));

                $('#flashStats').innerHTML =
                    [['Live now', by.live.length, 'bolt', 'ic-orange'], ['Scheduled', by.scheduled.length, 'schedule', 'ic-blue'],
                        ['Flash units sold', fmt(units), 'shopping_bag', 'ic-green'], ['Flash revenue', 'Rs ' + fmt(rev), 'currency_rupee', 'ic-purple']]
                        .map(s => '<div class="stat-card"><div class="stat-top"><span class="stat-label">' + s[0] + '</span><span class="stat-icon ' + s[3] +
                            '"><span class="material-symbols-outlined">' + s[2] + '</span></span></div><div class="stat-value">' + s[1] + '</div></div>').join('');

                $$('#flashTabs .tab').forEach(t => {
                    const k = t.dataset.filter;
                    $('.tab-count', t).textContent = k === 'all' ? F.length : by[k].length;
                    t.classList.toggle('active', k === fsFilter);
                });

                const order = { live: 0, scheduled: 1, ended: 2 };
                const list = F.filter(f => fsFilter === 'all' || fsStatus(f) === fsFilter)
                    .sort((a, b) => order[fsStatus(a)] - order[fsStatus(b)] || (fsStatus(a) === 'ended' ? b.end - a.end : a.start - b.start));

                $('#flashList').innerHTML = list.map(function (f) {
                    const st = fsStatus(f);
                    const actions = st === 'scheduled'
                        ? '<button type="button" class="btn-outline" data-fa="edit"><span class="material-symbols-outlined">edit</span> Edit</button>' +
                        '<button type="button" class="btn-outline danger" data-fa="del"><span class="material-symbols-outlined">delete</span> Delete</button>'
                        : st === 'live'
                            ? '<button type="button" class="btn-outline danger" data-fa="end"><span class="material-symbols-outlined">stop_circle</span> End now</button>'
                            : '<button type="button" class="btn-outline" data-fa="dup"><span class="material-symbols-outlined">content_copy</span> Duplicate</button>' +
                            '<button type="button" class="btn-outline danger" data-fa="del"><span class="material-symbols-outlined">delete</span> Delete</button>';
                    return '<div class="fs-card ' + st + '" data-id="' + esc(f.id) + '"><div class="fs-head"><div>' +
                        '<div class="fs-title"><span class="material-symbols-outlined">bolt</span>' + esc(f.name) + '<span class="pill pill-' + st + '">' + st.charAt(0).toUpperCase() + st.slice(1) + '</span></div>' +
                        '<div class="fs-time">' + fsDate(f.start) + ' → ' + fsDate(f.end) + ' · <span class="fs-count' + (st === 'ended' ? ' muted' : '') + '" data-cd="' + esc(f.id) + '">' + fsCountText(f) + '</span></div></div>' +
                        '<div class="fs-actions">' + actions + '</div></div>' +
                        '<div class="fs-card-wrap"><table class="fs-items"><thead><tr><th>PRODUCT</th><th class="num">REGULAR</th><th class="num">FLASH PRICE</th><th>SOLD / QTY</th><th class="num">LIMIT</th></tr></thead><tbody>' +
                        f.items.map(function (i) {
                            const pct = i.qty ? Math.min(100, Math.round((i.sold || 0) * 100 / i.qty)) : 0;
                            return '<tr><td>' + esc(i.name) + '</td><td class="num"><span class="fs-old">Rs ' + fmt(i.price) + '</span></td>' +
                                '<td class="num"><span class="fs-new">Rs ' + fmt(fsPrice(i.price, i.disc)) + '</span><span class="fs-off">-' + i.disc + '%</span></td>' +
                                '<td>' + (i.sold || 0) + ' / ' + i.qty + '<div class="fs-bar"><div style="width:' + pct + '%"></div></div></td><td class="num">' + i.limit + '</td></tr>';
                        }).join('') + '</tbody></table></div></div>';
                }).join('');
                $('#flashEmpty').style.display = list.length ? 'none' : 'block';
                $('#flashSubtitle').textContent = F.length + ' flash sale' + (F.length === 1 ? '' : 's') + (by.live.length ? ' · ' + by.live.length + ' live' : '');
                fsSig = fsSignature();
            }

            /* live countdown + automatic status change */
            setInterval(function () {
                if (!$('#flashList') || document.hidden) return;
                if (fsSignature() !== fsSig) return renderFlash();
                $$('[data-cd]').forEach(s => { const f = F.find(x => String(x.id) === s.dataset.cd); if (f) s.textContent = fsCountText(f); });
            }, 1000);

            $$('#flashTabs .tab').forEach(t => t.addEventListener('click', function () { fsFilter = t.dataset.filter; renderFlash(); }));
            $('#newFlashBtn').addEventListener('click', () => flashForm(null));

            function fsPost(url, data, okMsg) {
                const fd = new FormData(); Object.keys(data).forEach(k => fd.append(k, data[k]));
                fetch(url, { method: 'POST', body: fd }).then(function (r) {
                    if (r.ok) {
                        try { sessionStorage.setItem('sellerToast', okMsg); } catch (e) {}
                        location.hash = '#flashsale'; location.reload();
                    } else r.text().then(m => toast('Error: ' + m, 'error'));
                }).catch(function () { toast('Network error. Please try again.', 'error'); });
            }

            $('#flashList').addEventListener('click', function (e) {
                const b = e.target.closest('[data-fa]'); if (!b) return;
                const f = F.find(x => String(x.id) === b.closest('.fs-card').dataset.id); if (!f) return;
                const a = b.dataset.fa;
                if (a === 'edit') flashForm(f);
                if (a === 'dup') flashForm(Object.assign({}, f, { id: null, name: f.name + ' (copy)', items: f.items.map(i => Object.assign({}, i, { sold: 0 })) }), true);
                if (a === 'end') confirmBox('End flash sale', 'End <strong>' + esc(f.name) + '</strong> now? Products return to their regular price immediately.', 'End now',
                    () => fsPost('/api/flashsales/end', { id: f.id }, 'Flash sale ended.'));
                if (a === 'del') confirmBox('Delete flash sale', 'Delete <strong>' + esc(f.name) + '</strong>? This cannot be undone.', 'Delete',
                    () => fsPost('/api/flashsales/delete', { id: f.id }, 'Flash sale deleted.'));
            });

            function flashForm(f, isCopy) {
                const isNew = !f || !f.id;
                const t0 = Math.ceil((Date.now() + 3600e3) / 900e3) * 900e3;           // next quarter-hour, ~1h ahead
                const d = (f && !isCopy) ? f : { name: f ? f.name : '', start: t0, end: t0 + 6 * 3600e3, items: f ? f.items : [] };
                const byPid = {}; d.items.forEach(i => { byPid[String(i.pid)] = i; });
                const pool = P.filter(p => p.id && (byPid[String(p.id)] || (p.active && p.stock > 0)));

                const rows = pool.map(function (p) {
                    const it = byPid[String(p.id)];
                    return '<div class="fs-row' + (it ? ' on' : '') + '" data-pid="' + esc(p.id) + '" data-name="' + esc(p.name.toLowerCase()) + '">' +
                        '<label class="fs-pick"><input type="checkbox" class="fs-chk"' + (it ? ' checked' : '') + '><div class="prod-thumb">' +
                        (p.imageUrl ? '<img src="' + esc(p.imageUrl) + '">' : esc(p.name.charAt(0))) + '</div><div><div class="prod-name">' + esc(p.name) +
                        '</div><div class="muted-sm">Rs ' + fmt(p.price) + ' · ' + p.stock + ' in stock</div></div></label>' +
                        '<div class="fs-fields"><label>Discount %<input type="number" class="fs-disc" min="' + FS.MIN_DISC + '" max="' + FS.MAX_DISC + '" value="' + (it ? it.disc : '') + '" placeholder="10–90"></label>' +
                        '<label>Flash qty<input type="number" class="fs-qty" min="1" max="' + p.stock + '" value="' + (it ? it.qty : '') + '"></label>' +
                        '<label>Limit / customer<input type="number" class="fs-lim" min="1" value="' + (it ? it.limit : '') + '"></label>' +
                        '<div class="fs-prev">—</div></div></div>';
                }).join('') || '<div class="pop-empty">No active, in-stock products available. Add or activate a product first.</div>';

                const m = modal(isNew ? 'Create flash sale' : 'Edit flash sale',
                    '<div class="fs-rules"><strong>Flash sale rules:</strong> minimum discount ' + FS.MIN_DISC + '%, maximum ' + FS.MAX_DISC + '%. Starts at least 15 minutes from now, runs 1–72 hours. ' +
                    'A product can only be in one sale at a time. Flash quantity cannot exceed current stock.</div>' +
                    '<label class="fld">Campaign name<input id="fs-name" maxlength="60" value="' + esc(d.name) + '" placeholder="e.g. Weekend Mega Deal"></label>' +
                    '<div class="fld-row"><label class="fld">Starts<input id="fs-start" type="datetime-local" value="' + toInput(d.start) + '"></label>' +
                    '<label class="fld">Ends<input id="fs-end" type="datetime-local" value="' + toInput(d.end) + '"></label></div>' +
                    '<div class="editor-label"><span>SELECT PRODUCTS</span><span class="editor-support" id="fs-count">0 selected</span></div>' +
                    '<div class="fs-bulk"><label class="fld">Discount for all selected<input id="fs-bulk" type="number" min="' + FS.MIN_DISC + '" max="' + FS.MAX_DISC + '" placeholder="10–90 %"></label>' +
                    '<button type="button" class="btn-outline" id="fs-bulk-btn">Apply to selected</button>' +
                    '<div class="search-box" style="flex:1;min-width:160px;width:auto"><span class="material-symbols-outlined">search</span><input type="text" id="fs-search" placeholder="Filter products..."></div></div>' +
                    '<div class="fs-list" id="fs-list">' + rows + '</div><div class="fs-error" id="fs-error"></div>',
                    [['Cancel', 'btn-outline', closeModal], [isNew ? 'Schedule sale' : 'Save changes', 'btn-primary', save]]);
                $('.modal', m).classList.add('modal-lg');

                const list = $('#fs-list', m), saveBtn = $('.modal-foot .btn-primary', m);
                let busy = false;
                const rowP = r => P.find(x => String(x.id) === r.dataset.pid);

                function preview(r) {
                    const p = rowP(r), disc = Number($('.fs-disc', r).value), box = $('.fs-prev', r);
                    box.innerHTML = (disc >= FS.MIN_DISC && disc <= FS.MAX_DISC)
                        ? '<strong>Rs ' + fmt(fsPrice(p.price, disc)) + '</strong>save Rs ' + fmt(p.price - fsPrice(p.price, disc)) : '—';
                }
                function count() { $('#fs-count', m).textContent = $$('.fs-row.on', m).length + ' selected'; }
                $$('.fs-row.on', m).forEach(preview); count();

                list.addEventListener('change', function (e) {
                    if (!e.target.classList.contains('fs-chk')) return;
                    const r = e.target.closest('.fs-row'), p = rowP(r);
                    r.classList.toggle('on', e.target.checked);
                    if (e.target.checked) {
                        if (!$('.fs-disc', r).value) $('.fs-disc', r).value = $('#fs-bulk', m).value || FS.MIN_DISC;
                        if (!$('.fs-qty', r).value) $('.fs-qty', r).value = p.stock;
                        if (!$('.fs-lim', r).value) $('.fs-lim', r).value = 1;
                        preview(r);
                    }
                    count();
                });
                list.addEventListener('input', e => { const r = e.target.closest('.fs-row'); if (r) { e.target.classList.remove('bad'); preview(r); } });
                $('#fs-bulk-btn', m).onclick = function () {
                    const v = Number($('#fs-bulk', m).value);
                    if (!(v >= FS.MIN_DISC && v <= FS.MAX_DISC)) { $('#fs-error', m).textContent = 'Bulk discount must be between ' + FS.MIN_DISC + '% and ' + FS.MAX_DISC + '%.'; return; }
                    $('#fs-error', m).textContent = '';
                    $$('.fs-row.on', m).forEach(r => { $('.fs-disc', r).value = v; preview(r); });
                };
                $('#fs-search', m).addEventListener('input', function () {
                    const q = this.value.toLowerCase();
                    $$('.fs-row', m).forEach(r => { r.style.display = !q || r.dataset.name.includes(q) ? '' : 'none'; });
                });

                function save() {
                    if (busy) return;
                    const errBox = $('#fs-error', m); errBox.textContent = '';
                    $$('.bad', m).forEach(x => x.classList.remove('bad'));
                    const fail = msg => { errBox.textContent = msg; return false; };

                    const name = $('#fs-name', m).value.trim();
                    const start = new Date($('#fs-start', m).value).getTime(), end = new Date($('#fs-end', m).value).getTime();
                    if (!name) return fail('Campaign name is required.');
                    if (isNaN(start) || isNaN(end)) return fail('Choose a valid start and end time.');
                    const timeChanged = isNew || start !== d.start;
                    if (timeChanged && start < Date.now() + FS.MIN_LEAD) return fail('Sale must start at least 15 minutes from now.');
                    if (end - start < FS.MIN_DUR) return fail('Sale must run for at least 1 hour.');
                    if (end - start > FS.MAX_DUR) return fail('Sale can run for at most 72 hours.');

                    const rowsOn = $$('.fs-row.on', m);
                    if (!rowsOn.length) return fail('Select at least one product.');
                    if (rowsOn.length > FS.MAX_ITEMS) return fail('You can add up to ' + FS.MAX_ITEMS + ' products per sale.');

                    const items = [];
                    for (const r of rowsOn) {
                        const p = rowP(r), disc = Number($('.fs-disc', r).value), qty = Number($('.fs-qty', r).value), lim = Number($('.fs-lim', r).value);
                        if (!Number.isInteger(disc) || disc < FS.MIN_DISC || disc > FS.MAX_DISC) { $('.fs-disc', r).classList.add('bad'); return fail(p.name + ': discount must be ' + FS.MIN_DISC + '–' + FS.MAX_DISC + '%.'); }
                        if (!Number.isInteger(qty) || qty < 1 || qty > p.stock) { $('.fs-qty', r).classList.add('bad'); return fail(p.name + ': flash quantity must be 1–' + p.stock + ' (current stock).'); }
                        if (!Number.isInteger(lim) || lim < 1 || lim > qty) { $('.fs-lim', r).classList.add('bad'); return fail(p.name + ': limit per customer must be 1–' + qty + '.'); }
                        items.push({ productId: p.id, discount: disc, qty: qty, limit: lim });
                    }
                    // no product in two overlapping sales
                    const clash = [];
                    F.forEach(o => {
                        if ((!isNew && String(o.id) === String(d.id)) || fsStatus(o) === 'ended') return;
                        if (start < o.end && end > o.start) o.items.forEach(oi => { if (items.some(i => String(i.productId) === String(oi.pid))) clash.push(oi.name); });
                    });
                    if (clash.length) return fail('Already in another sale during this time: ' + [...new Set(clash)].join(', ') + '.');

                    busy = true; saveBtn.disabled = true; saveBtn.textContent = 'Saving...';
                    fetch('/api/flashsales/save', {
                        method: 'POST', headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ id: isNew ? null : d.id, name: name, start: start, end: end, items: items })
                    }).then(function (r) {
                        if (r.ok) {
                            try { sessionStorage.setItem('sellerToast', isNew ? 'Flash sale scheduled.' : 'Flash sale updated.'); } catch (e) {}
                            closeModal(); location.hash = '#flashsale'; location.reload();
                        } else r.text().then(function (msg) { busy = false; saveBtn.disabled = false; saveBtn.textContent = isNew ? 'Schedule sale' : 'Save changes'; fail(msg); });
                    }).catch(function () { busy = false; saveBtn.disabled = false; saveBtn.textContent = isNew ? 'Schedule sale' : 'Save changes'; fail('Network error. Please try again.'); });
                }
            }


        /* ============ Orders ============ */
        $$('#orderTabs .tab').forEach(t => t.addEventListener('click', function () {
            $$('#orderTabs .tab').forEach(x => x.classList.remove('active')); t.classList.add('active');
            ui.of = t.dataset.filter; renderOrders();
        }));
        const os = el('div', 'toolbar', '<div class="search-box"><span class="material-symbols-outlined">search</span><input type="text" id="orderSearch" placeholder="Search by order, customer or product..."></div>');
        $('#orderTabs').before(os);
        $('#orderSearch').addEventListener('input', function () { ui.oq = this.value; renderOrders(); });
        $('#ordersTable tbody').addEventListener('click', function (e) {
            const r = e.target.closest('tr[data-ref]'); if (r) orderDetail(O.find(o => o.ref === r.dataset.ref));
        });


        function orderDetail(o) {
            const steps = ['pending', 'confirmed', 'shipped', 'delivered'], idx = steps.indexOf(o.status);
            const off = (o.status === 'cancelled' || o.status === 'return') ? ' off' : '';
            const tl = '<div class="timeline">' + steps.map((s, i) =>
                '<div class="tl-step' + (idx >= i ? ' done' : '') + off + '"><span></span>' + LABEL[s] + '</div>').join('') + '</div>';
            const lines = o.items.map(i =>
                '<div class="muted-sm" style="display:flex;justify-content:space-between;padding:4px 0"><span>' +
                esc(i.name) + ' × ' + i.qty + '</span><span>Rs ' + fmt(i.line) + '</span></div>').join('');
            modal(o.ref,
                '<div class="od-head"><span class="o-badge ' + o.status + '">' + LABEL[o.status] + '</span><span class="muted-sm">' + esc(o.date) + '</span></div>' +
                '<dl class="od"><dt>Customer</dt><dd>' + esc(o.cust) + ' · ' + esc(o.phone) + '</dd>' +
                '<dt>Deliver to</dt><dd>' + esc(o.address) + '</dd>' +
                '<dt>Payment</dt><dd>' + esc(o.payment) + '</dd>' +
                (o.note ? '<dt>Note</dt><dd>' + esc(o.note) + '</dd>' : '') + '</dl>' +
                '<div class="muted-sm" style="margin:12px 0 6px">Your items in this order</div>' + lines +
                '<dl class="od"><dt>Your total</dt><dd>Rs ' + fmt(o.total) + '</dd></dl>' + tl,
                [['Close', 'btn-outline', closeModal]]);
        }

        /* ============ Messages ============ */
        $('#messageSearch').addEventListener('input', function () { ui.mq = this.value; renderMessages(); });
        $('#messageList').addEventListener('click', function (e) { const i = e.target.closest('.msg-item'); if (i) openThread(M[+i.dataset.i]); });
        function bubbles(m) { return m.thread.map(t => '<div class="bubble ' + (t.me ? 'me' : 'them') + '">' + esc(t.text) + '</div>').join(''); }
        function openThread(m) {
            m.unread = false; renderMessages(); syncDash();
            const b = modal(m.name + ' · ' + m.subject, '<div class="thread">' + bubbles(m) + '</div><textarea id="reply" rows="3" placeholder="Write a reply..."></textarea>',
                [['Close', 'btn-outline', closeModal], ['Send reply', 'btn-primary', function () {
                    const ta = $('#reply', b), t = ta.value.trim(); if (!t) { ta.classList.add('bad'); return; }
                    m.thread.push({ me: true, text: t }); m.time = 'Just now';
                    $('.thread', b).innerHTML = bubbles(m); ta.value = ''; renderMessages(); toast('Reply sent to ' + m.name + '.', 'ok');
                    $('.thread', b).scrollTop = 9999;
                }]]);
            $('.thread', b).scrollTop = 9999;
        }

        /* ============ Finance / My Store ============ */
        const ex = $('#exportCsvBtn');
        if (ex) ex.addEventListener('click', function () {
            const a = el('a'); a.href = URL.createObjectURL(new Blob([ex.dataset.csv], { type: 'text/csv;charset=utf-8;' }));
            a.download = 'monthly-revenue.csv'; document.body.appendChild(a); a.click(); a.remove(); URL.revokeObjectURL(a.href); toast('CSV downloaded.', 'ok');
        });
        $$('#storeTabs .tab').forEach(t => t.addEventListener('click', function () {
            $$('#storeTabs .tab').forEach(x => x.classList.remove('active')); t.classList.add('active');
            $$('.store-panel').forEach(p => { p.style.display = p.id === t.dataset.panel ? 'block' : 'none'; });
        }));
        const fb = $('#followBtn');
        if (fb) fb.addEventListener('click', function () { const f = fb.classList.toggle('following'); fb.textContent = f ? 'Following' : 'Follow store'; });

        /* ============ Bell ============ */
        const bell = $('.icon-btn[aria-label="Notifications"]');
        if (bell) bell.addEventListener('click', function () {
            const al = alertList();
            popover(bell, '<div class="pop-title">Notifications</div>' + (al.map(a => '<button type="button" data-go="' + a.go + '"><strong>' + esc(a.title) + '</strong><span>' + esc(a.body) + '</span></button>').join('') || '<div class="pop-empty">You\'re all caught up.</div>'), true);
        });

        /* ============ Live activity (simulated feed – replace with fetch()/WebSocket) ============ */
        const NAMES = ['Lena Fischer', 'Arjun Mehta', 'Chloe Martin', 'Omar Haddad', 'Sita Gurung', 'Diego Ramos'];

        function newMessage() {
            if (!P.length) return;
            const n = NAMES[Math.floor(Math.random() * NAMES.length)];
            M.unshift({ name: n, subject: 'Is this item still available?', time: 'Just now', unread: true, thread: [{ me: false, text: 'Hi! Is the ' + P[0].name.toLowerCase() + ' available for delivery this week?' }] });
            refresh(); toast('New message from ' + n, '', 'messages');
        }
        setInterval(function () {
            if (!approved || document.hidden || $('.modal-backdrop')) return;
            newMessage();
        }, 30000);

        /* ============ Status flow (server-driven, no faking) ============ */
        function applyServerStatus() {
            $('#reviewState').style.display = 'none';
            $('#rejectedState').style.display = 'none';
            $('#approvedDashboard').style.display = 'none';

            if (SERVER_STATUS === 'approved') {
                approved = true;
                $('#approvedDashboard').style.display = 'block';
                $('#statusText').textContent = 'Approved';
                $('#sidebarStatus').classList.add('approved');
                $$('#sidebarNav .nav-item').forEach(i => { i.classList.remove('disabled'); i.title = $('.nav-text', i).textContent.trim(); });
            } else if (SERVER_STATUS === 'rejected') {
                approved = false;
                $('#rejectedState').style.display = 'block';
            } else {
                approved = false;
                $('#reviewState').style.display = 'block';
            }
            show(location.hash.slice(1), false);
        }
        refresh();
        applyServerStatus();

        // Show the success message saved before the page reloaded
        try {
            const pending = sessionStorage.getItem('sellerToast');
            if (pending) {
                sessionStorage.removeItem('sellerToast');
                toast(pending, 'ok');
            }
        } catch (e) {}
    });
})();