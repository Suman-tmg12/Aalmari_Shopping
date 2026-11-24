<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Redirecting to eSewa</title>
    <style>
        body{margin:0;min-height:100vh;display:grid;place-items:center;font-family:system-ui,-apple-system,"Segoe UI",sans-serif;background:#faf7f2;color:#171717}
        .box{text-align:center}.spinner{width:36px;height:36px;border:4px solid #e5e7eb;border-top-color:#60bb46;border-radius:50%;margin:0 auto 14px;animation:spin .8s linear infinite}@keyframes spin{to{transform:rotate(360deg)}}
    </style>
</head>
<body>
<div class="box">
    <div class="spinner"></div>
    <strong>Redirecting to eSewa...</strong>
</div>
<form id="esewaForm" method="post" action="${esewaFormUrl}" style="display:none">
    <c:forEach var="field" items="${esewaFields}">
        <input type="hidden" name="${field.key}" value="${field.value}">
    </c:forEach>
</form>
<script>document.getElementById('esewaForm').submit();</script>
</body>
</html>

