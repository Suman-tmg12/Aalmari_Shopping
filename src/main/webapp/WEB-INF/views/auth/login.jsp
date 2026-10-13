<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Aalmari Store</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/signin.css?v=4">
</head>
<body>
<jsp:include page="/WEB-INF/components/header.jsp" />

    <div class="container">
        <!-- Left Panel (Desktop Only - Hidden on Mobile) -->
        <div class="left-panel">
            <h1>GET START</h1>
            <p>Don't have an account?</p>
            <a href="${pageContext.request.contextPath}/signin" class="login-btn">Sign up</a>
        </div>

        <!-- Right Panel (Form Panel) -->
        <div class="right-panel">
            <div class="logo">
                <img src="${pageContext.request.contextPath}/HomePageImages/logoImages/logo.png" alt="Aalmari">
            </div>

            <h2>Login Account</h2>

            <!-- Mobile Signup Link (Visible only on mobile via CSS) -->
            <div class="mobile-login-link">
                Don't have an account? <a href="${pageContext.request.contextPath}/signin">Sign up</a>
            </div>

            <c:if test="${not empty error}">
                <p class="error"><c:out value="${error}"/></p>
            </c:if>

            <c:if test="${not empty success}">
                <p class="success"><c:out value="${success}"/></p>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="post">

                <div class="form-group">
                    <input type="email" name="email" placeholder="Email address"
                           value="${param.email}" required>
                </div>

                <div class="form-group">
                  <div class="password-wrapper">
                    <input type="password" id="password" name="password" placeholder="Password" required>
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

                <div class="checkbox-group">
                    <input type="checkbox" name="rememberMe" id="rememberMe">
                    <label for="rememberMe">Remember me</label>
                </div>

                <button type="submit" class="submit-btn">Login</button>
            </form>
        </div>
    </div>

    <jsp:include page="/WEB-INF/components/footer.jsp" />

    <script>
 (function () {

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

 })();
    </script>

</body>
</html>