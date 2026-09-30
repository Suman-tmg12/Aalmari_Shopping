<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Create Account - Aalmari Store</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/signin.css?v=4">
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

            <form action="register" method="post">
                <div class="form-group">
                    <input type="text" name="name" placeholder="Name" required>
                </div>

                <div class="form-group">
                    <input type="email" name="email" placeholder="Email address" required>
                </div>

                <div class="form-group">
                    <input type="text" name="country" placeholder="Country" required>
                </div>

                <div class="form-group">
                    <input type="tel" name="phone" placeholder="Phone" required>
                </div>

                <div class="form-group">
                    <input type="password" name="password" placeholder="Password" required>
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
</body>
</html>