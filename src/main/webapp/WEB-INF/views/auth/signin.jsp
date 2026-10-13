<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Create Account - Aalmari Store</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/signin.css?v=6">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="container">
        <!-- Left Panel (Desktop Only - Hidden on Mobile) -->
        <div class="left-panel">
            <h1>GET START</h1>
            <p>Already have an account?</p>
            <a href="login" class="login-btn">Login In</a>
        </div>

        <!-- Right Panel (Form Panel) -->
        <div class="right-panel">
            <div class="logo">
                <img src="${pageContext.request.contextPath}/HomePageImages/logoImages/logo.png" alt="Aalmari">
            </div>

            <h2>Create Account</h2>

            <!-- Mobile Login Link (Visible only on mobile via CSS) -->
            <div class="mobile-login-link">
                Already have an account? <a href="login">Log in</a>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <p class="error"><%= request.getAttribute("error") %></p>
            <% } %>

            <form action="register" method="post" id="registerForm" novalidate>
                <div class="form-group" style="display: flex; gap: 10px">
                    <input type="text" name="firstName" placeholder="First name" required>
                    <input type="text" name="lastName" placeholder="Last name" required>
                </div>

                <div class="form-group">
                    <input type="email" name="email" placeholder="Email address" required>
                </div>

                <div class="form-group" style="display: flex; gap: 10px">
                    <input type="text" name="country" placeholder="Country" required>
                    <input type="tel" name="phone" placeholder="Phone" required>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <div class="password-wrapper">
                        <input type="password" name="password" id="password" placeholder="Password" required minlength="8">
                        <button type="button" class="toggle-password" data-target="password"
                                aria-label="Show password" aria-pressed="false">
                            <svg class="icon-eye" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                            <svg class="icon-eye-off" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M17.94 17.94A10.94 10.94 0 0 1 12 20C5 20 1 12 1 12a18.5 18.5 0 0 1 5.06-5.94"/>
                                <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                                <path d="M14.12 14.12a3 3 0 1 1-4.24-4.24"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Confirm Password (name changed so it no longer clashes with "password") -->
                <div class="form-group" style="margin-bottom: -20px">
                    <div class="password-wrapper">
                        <input type="password" name="confirmPassword" id="confirmPassword" placeholder="Confirm Password" required>
                        <button type="button" class="toggle-password" data-target="confirmPassword"
                                aria-label="Show password" aria-pressed="false">
                            <svg class="icon-eye" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                            <svg class="icon-eye-off" viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M17.94 17.94A10.94 10.94 0 0 1 12 20C5 20 1 12 1 12a18.5 18.5 0 0 1 5.06-5.94"/>
                                <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                                <path d="M14.12 14.12a3 3 0 1 1-4.24-4.24"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
                    </div>
                    <p class="field-msg" id="matchMsg" aria-live="polite"></p>
                </div>

                <div class="checkbox-group">
                    <input type="checkbox" name="terms" id="terms" required>
                    <label for="terms">Terms of Service and Privacy Policy</label>
                </div>

                <button type="submit" class="submit-btn">Sign up</button>
            </form>
        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

<script>
(function () {
    var form     = document.getElementById('registerForm');
    var pass     = document.getElementById('password');
    var confirm  = document.getElementById('confirmPassword');
    var msg      = document.getElementById('matchMsg');

    // ---- Show / hide password ----
    document.querySelectorAll('.toggle-password').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var input  = document.getElementById(btn.getAttribute('data-target'));
            var showing = input.type === 'text';
            input.type = showing ? 'password' : 'text';
            btn.classList.toggle('active', !showing);
            btn.setAttribute('aria-pressed', String(!showing));
            btn.setAttribute('aria-label', showing ? 'Show password' : 'Hide password');
        });
    });

    // ---- Confirm password check ----
    function checkMatch() {
        if (confirm.value === '') {
            msg.textContent = '';
            msg.className = 'field-msg';
            confirm.setCustomValidity('');
            return true;
        }
        if (pass.value === confirm.value) {
            msg.textContent = 'Passwords match';
            msg.className = 'field-msg ok';
            confirm.setCustomValidity('');
            return true;
        }
        msg.textContent = 'Passwords do not match';
        msg.className = 'field-msg bad';
        confirm.setCustomValidity('Passwords do not match');
        return false;
    }

    pass.addEventListener('input', checkMatch);
    confirm.addEventListener('input', checkMatch);

    form.addEventListener('submit', function (e) {
        if (!form.checkValidity() || !checkMatch()) {
            e.preventDefault();
            form.reportValidity();
        }
    });
})();
</script>
</body>
</html>
