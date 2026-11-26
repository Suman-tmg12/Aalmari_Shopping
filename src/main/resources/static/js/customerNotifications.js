(function () {
    'use strict';

    var trigger = document.getElementById('notificationTrigger');
    var panel = document.getElementById('notificationPanel');
    if (!trigger || !panel) return;

    var apiUrl = trigger.getAttribute('data-api-url');
    var badge = document.getElementById('notificationBadge');
    var list = document.getElementById('notificationList');
    var markAll = document.getElementById('notificationMarkAll');
    var loading = false;

    function setBadge(count) {
        var unread = Number(count) || 0;
        badge.hidden = unread === 0;
        badge.textContent = unread > 99 ? '99+' : String(unread);
        trigger.setAttribute('aria-label', unread
            ? 'Notifications, ' + unread + ' unread'
            : 'Notifications');
        markAll.disabled = unread === 0;
    }

    function showState(message, retry) {
        list.replaceChildren();
        var state = document.createElement('p');
        state.className = 'notification-state';
        state.textContent = message;
        if (retry) {
            var button = document.createElement('button');
            button.type = 'button';
            button.className = 'notification-retry';
            button.textContent = 'Try again';
            button.addEventListener('click', loadNotifications);
            state.appendChild(button);
        }
        list.appendChild(state);
    }

    function render(feed) {
        setBadge(feed.unreadCount);
        list.replaceChildren();
        if (!feed.items || feed.items.length === 0) {
            showState('You’re all caught up. New order updates will appear here.');
            return;
        }

        feed.items.forEach(function (item) {
            var link = document.createElement('a');
            link.className = 'notification-item' + (item.read ? '' : ' is-unread');
            link.href = trigger.getAttribute('data-orders-url');
            link.dataset.notificationId = item.id;

            var title = document.createElement('span');
            title.className = 'notification-item-title';
            title.textContent = item.title;
            var message = document.createElement('span');
            message.className = 'notification-item-message';
            message.textContent = item.message;
            var time = document.createElement('time');
            time.className = 'notification-item-time';
            time.textContent = item.createdAt;

            link.append(title, message, time);
            link.addEventListener('click', markReadAndNavigate);
            list.appendChild(link);
        });
    }

    async function loadNotifications() {
        if (loading) return;
        loading = true;
        try {
            var response = await fetch(apiUrl, {
                credentials: 'same-origin',
                headers: { Accept: 'application/json' }
            });
            if (!response.ok) throw new Error('Could not load notifications.');
            render(await response.json());
        } catch (error) {
            showState(error.message || 'Could not load notifications.', true);
        } finally {
            loading = false;
        }
    }

    async function markReadAndNavigate(event) {
        event.preventDefault();
        var link = event.currentTarget;
        try {
            var response = await fetch(apiUrl + '/' + encodeURIComponent(link.dataset.notificationId) + '/read', {
                method: 'POST',
                credentials: 'same-origin'
            });
            if (!response.ok) throw new Error('Could not update this notification.');
            window.location.assign(link.href);
        } catch (error) {
            showState(error.message || 'Could not update this notification.', true);
        }
    }

    trigger.addEventListener('click', function () {
        var open = panel.hidden;
        panel.hidden = !open;
        trigger.setAttribute('aria-expanded', String(open));
        if (open) loadNotifications();
    });

    markAll.addEventListener('click', async function () {
        markAll.disabled = true;
        try {
            var response = await fetch(apiUrl + '/read-all', {
                method: 'POST',
                credentials: 'same-origin'
            });
            if (!response.ok) throw new Error('Could not mark notifications as read.');
            await loadNotifications();
        } catch (error) {
            showState(error.message || 'Could not update notifications.', true);
        }
    });

    document.addEventListener('click', function (event) {
        if (!panel.hidden && !event.target.closest('.notification-container')) {
            panel.hidden = true;
            trigger.setAttribute('aria-expanded', 'false');
        }
    });

    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape' && !panel.hidden) {
            panel.hidden = true;
            trigger.setAttribute('aria-expanded', 'false');
            trigger.focus();
        }
    });

    loadNotifications();
    window.setInterval(loadNotifications, 60000);
})();
