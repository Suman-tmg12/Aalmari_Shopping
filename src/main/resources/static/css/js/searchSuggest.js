(function () {
    'use strict';

    const form = document.getElementById('searchForm');
    if (!form) return;
    const input = form.querySelector('.search-input');
    const endpoint = form.dataset.suggestUrl;
    if (!input || !endpoint) return;

    const MIN_CHARS = 2;
    const DEBOUNCE_MS = 300;
    const CACHE_MAX = 50;

    const list = document.createElement('ul');
    list.id = 'searchSuggestList';
    list.className = 'search-suggestions';
    list.setAttribute('role', 'listbox');
    list.hidden = true;
    form.appendChild(list);

    input.setAttribute('role', 'combobox');
    input.setAttribute('aria-autocomplete', 'list');
    input.setAttribute('aria-controls', list.id);
    input.setAttribute('aria-expanded', 'false');

    const cache = new Map();
    let timer = null;
    let controller = null;
    let activeIndex = -1;
    let current = [];

    function open() {
        list.hidden = false;
        input.setAttribute('aria-expanded', 'true');
    }

    function close() {
        list.hidden = true;
        input.setAttribute('aria-expanded', 'false');
        input.removeAttribute('aria-activedescendant');
        activeIndex = -1;
    }

    function setActive(i) {
        const nodes = list.querySelectorAll('.suggestion-item');
        nodes.forEach(n => n.classList.remove('active'));
        activeIndex = i;
        if (i >= 0 && nodes[i]) {
            nodes[i].classList.add('active');
            nodes[i].scrollIntoView({ block: 'nearest' });
            input.setAttribute('aria-activedescendant', nodes[i].id);
        } else {
            input.removeAttribute('aria-activedescendant');
        }
    }

    function choose(text) {
        input.value = text;
        close();
        form.submit();
    }

    // Uses textContent only, so product names can never inject HTML
    function highlight(el, text, query) {
        const idx = text.toLowerCase().indexOf(query.toLowerCase());
        if (idx < 0) { el.textContent = text; return; }
        el.appendChild(document.createTextNode(text.slice(0, idx)));
        const mark = document.createElement('mark');
        mark.textContent = text.slice(idx, idx + query.length);
        el.appendChild(mark);
        el.appendChild(document.createTextNode(text.slice(idx + query.length)));
    }

    function render(items, query) {
        current = items;
        list.textContent = '';
        activeIndex = -1;

        if (!items.length) {
            const li = document.createElement('li');
            li.className = 'suggestion-empty';
            li.textContent = 'No suggestions found';
            list.appendChild(li);
            open();
            return;
        }

        items.forEach((text, i) => {
            const li = document.createElement('li');
            li.className = 'suggestion-item';
            li.id = 'suggestion-' + i;
            li.setAttribute('role', 'option');

            const icon = document.createElement('span');
            icon.className = 'material-symbols-outlined';
            icon.setAttribute('aria-hidden', 'true');
            icon.textContent = 'search';

            const label = document.createElement('span');
            label.className = 'suggestion-text';
            highlight(label, text, query);

            li.append(icon, label);
            // mousedown (not click) so the input doesn't lose focus first
            li.addEventListener('mousedown', e => { e.preventDefault(); choose(text); });
            li.addEventListener('mousemove', () => setActive(i));
            list.appendChild(li);
        });
        open();
    }

    async function fetchSuggestions(query) {
        if (controller) controller.abort();          // cancel the stale request
        const ctrl = new AbortController();
        controller = ctrl;
        form.classList.add('is-loading');

        try {
            const res = await fetch(endpoint + '?q=' + encodeURIComponent(query), {
                signal: ctrl.signal,
                headers: { 'Accept': 'application/json' }
            });
            if (!res.ok) throw new Error('HTTP ' + res.status);
            const data = await res.json();

            if (cache.size >= CACHE_MAX) cache.delete(cache.keys().next().value);
            cache.set(query.toLowerCase(), data);

            // Ignore the response if the user kept typing meanwhile
            if (input.value.trim() === query) render(data, query);
        } catch (err) {
            if (err.name !== 'AbortError') close();
        } finally {
            if (controller === ctrl) {
                form.classList.remove('is-loading');
                controller = null;
            }
        }
    }

    input.addEventListener('input', () => {
        clearTimeout(timer);
        const query = input.value.trim();

        if (query.length < MIN_CHARS) {
            if (controller) controller.abort();
            form.classList.remove('is-loading');
            close();
            return;
        }

        const cached = cache.get(query.toLowerCase());
        if (cached) { render(cached, query); return; }

        timer = setTimeout(() => fetchSuggestions(query), DEBOUNCE_MS);   // debounce
    });

    input.addEventListener('keydown', e => {
        const isOpen = !list.hidden && current.length > 0;
        switch (e.key) {
            case 'ArrowDown':
                if (!isOpen) return;
                e.preventDefault();
                setActive((activeIndex + 1) % current.length);
                break;
            case 'ArrowUp':
                if (!isOpen) return;
                e.preventDefault();
                setActive(activeIndex <= 0 ? current.length - 1 : activeIndex - 1);
                break;
            case 'Enter':
                if (isOpen && activeIndex >= 0) {
                    e.preventDefault();
                    choose(current[activeIndex]);
                }
                break;
            case 'Escape':
                close();
                break;
        }
    });

    input.addEventListener('focus', () => {
        if (current.length && input.value.trim().length >= MIN_CHARS) open();
    });

    document.addEventListener('click', e => {
        if (!form.contains(e.target)) close();
    });

    form.addEventListener('submit', () => {
        clearTimeout(timer);
        if (controller) controller.abort();
        close();
    });
})();