<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Aalmari Help Center</title>
<style>
    * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
        font-family: 'Segoe UI', Arial, sans-serif;
    }

    body {
        background: linear-gradient(135deg, #ffffff 0%, #fdf1e4 40%, #f6c99a 75%, #f2a86b 100%);
        min-height: 100vh;

    }

    .container {
        max-width: 760px;
        margin: 0 auto;
        padding-top: 90px;
        padding-bottom: 20px;
    }

    /* Header */
    .header-card {
        background: #ffffff;
        border-radius: 16px;
        padding: 20px 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        margin-bottom: 20px;
    }

    .top-bar {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 25px;
    }

    .logo-area {
        display: flex;
        align-items: center;
        gap: 8px;
        font-size: 15px;
        color: #333;
    }

    .logo-icon {
        width: 22px;
        height: 22px;
        background: #e2574c;
        border-radius: 4px;
        display: inline-block;
    }

    .logo-area .brand {
        font-weight: 700;
        color: #1a1a1a;
    }

    .logo-area .divider {
        color: #ccc;
        margin: 0 4px;
    }

    .nav-links {
        display: flex;
        gap: 25px;
        font-size: 14px;
    }

    .nav-links a {
        text-decoration: none;
        color: #333;
    }

    .nav-links a.active {
        color: #f2994a;
        font-weight: 600;
    }

    .greeting {
        text-align: center;
        font-size: 18px;
        font-weight: 600;
        color: #222;
        margin-bottom: 20px;
    }

    .search-wrap {
        display: flex;
        max-width: 500px;
        margin: 0 auto;
    }

    .search-wrap input {
        flex: 1;
        padding: 12px 18px;
        border: 1px solid #e0e0e0;
        border-radius: 8px 0 0 8px;
        outline: none;
        font-size: 14px;
        background: #fafafa;
    }

    .search-btn {
        background: #f6ddb3;
        border: none;
        padding: 0 20px;
        border-radius: 0 8px 8px 0;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
    }

    .search-btn svg {
        width: 18px;
        height: 18px;
        stroke: #8a6d3b;
    }

    /* Self Service Tools */
    .card {
        background: #ffffff;
        border-radius: 16px;
        padding: 25px 30px;
        margin-bottom: 20px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }

    .section-title {
        font-size: 14px;
        color: #333;
        margin-bottom: 20px;
    }

    .tools-grid {
        display: grid;
        grid-template-columns: repeat(4, 1fr);
        row-gap: 25px;
        text-align: center;
    }

    .tool-item {
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
        cursor: pointer;
    }

    .tool-circle {
        width: 55px;
        height: 55px;
        border-radius: 50%;
        background: #d9d9d9;
        transition: transform 0.2s;
    }

    .tool-item:hover .tool-circle {
        transform: scale(1.08);
        background: #cfcfcf;
    }

    .tool-item span {
        font-size: 13px;
        color: #333;
    }

    /* Top Questions */
    .top-questions {
        border: 2px solid #4aa8f0;
        border-radius: 14px;
        padding: 20px 30px;
        margin-bottom: 20px;
        background: #ffffff;
    }

    .top-questions .section-title {
        margin-bottom: 15px;
    }

    .questions-grid {
        display: grid;
        grid-template-columns: repeat(3, 1fr);
        gap: 18px;
        font-size: 13.5px;
        color: #222;
    }

    .questions-grid a {
        color: #222;
        text-decoration: none;
        line-height: 1.4;
    }

    .questions-grid a:hover {
        color: #4aa8f0;
        text-decoration: underline;
    }

    /* Virtual Assistant note */
    .va-note {
        text-align: center;
        font-size: 14px;
        color: #333;
        margin: 25px 0;
    }

    .va-note strong {
        font-weight: 600;
    }

    /* Contact section */
    .contact-card {
        background: #ffffff;
        border-radius: 16px;
        padding: 25px 30px;
        box-shadow: 0 2px 10px rgba(0,0,0,0.05);
    }

    .contact-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .contact-item {
        display: flex;
        align-items: center;
        gap: 15px;
    }

    .contact-circle {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        background: #d9d9d9;
        flex-shrink: 0;
    }

    .contact-text .title {
        font-size: 14px;
        font-weight: 600;
        color: #222;
        margin-bottom: 4px;
    }

    .contact-text .subtitle {
        font-size: 12px;
        color: #888;
    }

    @media (max-width: 600px) {
        .tools-grid {
            grid-template-columns: repeat(2, 1fr);
        }
        .container {
        padding-top: 145px;
        padding-left: 10px;
        padding-right: 10px;
        padding-bottom: 10px;
        }
        .questions-grid {
            grid-template-columns: 1fr;
        }
        .contact-grid {
            grid-template-columns: 1fr;
        }
        .top-bar {
            flex-direction: column;
            gap: 10px;
        }
    }
</style>
</head>
<body>

    <jsp:include page="/WEB-INF/components/header.jsp" />

<div class="container">

    <!-- Header -->
    <div class="header-card">
        <div class="top-bar">
            <div class="logo-area">

                  <img src="${pageContext.request.contextPath}/HomePageImages/logoImages/logo.png" alt="Aalmari Logo" class="logo-img">
                <span class="divider">|</span>
                <span>Help Center</span>
            </div>
            <div class="nav-links">
                <a href="#" class="active">Homepage</a>
                <a href="#">FAQ</a>
            </div>
        </div>

        <div class="greeting">Hi, How can we help?</div>

        <form class="search-wrap" action="search" method="get">
            <input type="text" name="query" placeholder="Search for topics, questions...">
            <button type="submit" class="search-btn">
                <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round">
                    <circle cx="11" cy="11" r="7"></circle>
                    <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
            </button>
        </form>
    </div>

    <!-- Self Service Tools -->
    <div class="card">
        <div class="section-title">Self Service Tools</div>
        <div class="tools-grid">
            <a class="tool-item" href="orders.jsp">
                <div class="tool-circle"></div>
                <span>My Orders</span>
            </a>
            <a class="tool-item" href="resetPassword.jsp">
                <div class="tool-circle"></div>
                <span>Reset Password</span>
            </a>
            <a class="tool-item" href="vouchers.jsp">
                <div class="tool-circle"></div>
                <span>My Vouchers</span>
            </a>
            <a class="tool-item" href="cancellations.jsp">
                <div class="tool-circle"></div>
                <span>My Cancellations</span>
            </a>
            <a class="tool-item" href="returns.jsp">
                <div class="tool-circle"></div>
                <span>My Returns</span>
            </a>
            <a class="tool-item" href="paymentOptions.jsp">
                <div class="tool-circle"></div>
                <span>My payment Options</span>
            </a>
            <a class="tool-item" href="deliveryAddress.jsp">
                <div class="tool-circle"></div>
                <span>Change Delivery Addresss</span>
            </a>
            <a class="tool-item" href="profile.jsp">
                <div class="tool-circle"></div>
                <span>My Profile</span>
            </a>
        </div>
    </div>

    <!-- Top Questions -->
    <div class="top-questions">
        <div class="section-title">Top Questions</div>
        <div class="questions-grid">
            <a href="#">How do I place an order on Daraz?</a>
            <a href="#">Can I change my order details after placing an order?</a>
            <a href="#">What is Daraz collection point service and how to avail it?</a>
            <a href="#">Why am I unable to use my collectible vouchers?</a>
        </div>
    </div>

    <!-- Virtual Assistant Note -->
    <div class="va-note">
        Need more help? <strong>Aalmari, your automated Virtual Assistant</strong>, is available 24 hours a day.
    </div>

    <!-- Contact Section -->
    <div class="contact-card">
        <div class="contact-grid">
            <div class="contact-item">
                <div class="contact-circle"></div>
                <div class="contact-text">
                    <div class="title">Contact Customer Care</div>
                    <div class="subtitle">Live Chat: 9AM - 6PM [Mon-Sun]</div>
                </div>
            </div>
            <div class="contact-item">
                <div class="contact-circle"></div>
                <div class="contact-text">
                    <div class="title">Call us 01-5970597</div>
                    <div class="subtitle">9Am-6PM [Sun-Fri]</div>
                </div>
            </div>
        </div>
    </div>

</div>

 <jsp:include page="/WEB-INF/components/footer.jsp" />

</body>
</html>