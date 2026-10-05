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
                    <input type="password" name="password" placeholder="Password" required>
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
</body>
</html>