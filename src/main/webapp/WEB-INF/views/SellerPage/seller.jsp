<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Apply to Sell - Seller Hub</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/seller.css?v=5">
</head>
<body>

   <jsp:include page="/WEB-INF/components/header.jsp" />

   <div class="main-sidebar">

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <h1 class="page-title">Apply to sell on the platform</h1>
        <p class="page-subtitle">Fill in your store details to submit an application. Our team reviews within 2 business days.</p>

        <!-- STEP INDICATOR -->
        <div class="steps" id="stepsIndicator">
            <div class="step active" data-step="1">
                <div class="step-circle">
                    <span class="step-number">1</span>
                    <svg class="step-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                </div>
                <div class="step-label">Store Info</div>
            </div>
            <div class="step-line"></div>
            <div class="step" data-step="2">
                <div class="step-circle">
                    <span class="step-number">2</span>
                    <svg class="step-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                </div>
                <div class="step-label">Contact &amp; Docs</div>
            </div>
            <div class="step-line"></div>
            <div class="step" data-step="3">
                <div class="step-circle">
                    <span class="step-number">3</span>
                    <svg class="step-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3">
                        <polyline points="20 6 9 17 4 12"></polyline>
                    </svg>
                </div>
                <div class="step-label">Banking</div>
            </div>
        </div>

        <!-- STEP 1: STORE INFO -->
        <form class="form-card" id="step1" method="post" action="submitStoreInfo.jsp" enctype="multipart/form-data">
            <h2>Store information</h2>

            <label class="banner-upload" for="storeBanner">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <rect x="3" y="3" width="18" height="18" rx="2"></rect>
                    <circle cx="8.5" cy="8.5" r="1.5"></circle>
                    <polyline points="21 15 16 10 5 21"></polyline>
                </svg>
                <span>Upload store banner (1200 x 300px)</span>
                <input type="file" id="storeBanner" name="storeBanner" accept="image/*" style="display:none;">
            </label>

            <div class="logo-field-row">
                <label class="logo-upload" for="storeLogo">
                    &#8593;
                    <span>Logo</span>
                    <input type="file" id="storeLogo" name="storeLogo" accept="image/*" style="display:none;">
                </label>

                <div class="field-group">
                    <label for="storeName">Business / Store Name <span class="required">*</span></label>
                    <input type="text" id="storeName" name="storeName" placeholder="e.g. Artisan Supply Co." required>
                </div>
            </div>

            <div class="form-group">
                <label for="storeTagline">Store Tagline</label>
                <input type="text" id="storeTagline" name="storeTagline" placeholder="One sentence describing your store">
            </div>

            <div class="form-group">
                <label for="primaryCategory">Primary Category</label>
                <select id="primaryCategory" name="primaryCategory">
                    <option value="" selected disabled>Select category...</option>
                    <option value="fashion">Fashion &amp; Apparel</option>
                    <option value="home">Home &amp; Living</option>
                    <option value="electronics">Electronics</option>
                    <option value="handmade">Handmade &amp; Crafts</option>
                    <option value="beauty">Beauty &amp; Personal Care</option>
                    <option value="other">Other</option>
                </select>
            </div>

            <button type="button" class="continue-btn" onclick="goToStep(2)">Continue</button>
        </form>

        <!-- STEP 2: CONTACT & DOCS -->
        <form class="form-card" id="step2" style="display:none;" method="post" action="submitContactDocs.jsp" enctype="multipart/form-data">
            <h2>Contact &amp; verification documents</h2>

            <div class="two-col-row">
                <div class="field-group">
                    <label for="businessEmail">Business Email <span class="required">*</span></label>
                    <input type="text" id="businessEmail" name="businessEmail" placeholder="hello@yourbrand.com" required>
                </div>
                <div class="field-group">
                    <label for="phoneNumber">Phone Number <span class="required">*</span></label>
                    <input type="text" id="phoneNumber" name="phoneNumber" placeholder="+1 555 000 0000" required>
                </div>
            </div>

            <div class="form-group">
                <label for="businessAddress">Business Address <span class="required">*</span></label>
                <input type="text" id="businessAddress" name="businessAddress" placeholder="Street, City, Country" required>
            </div>

            <div class="form-group">
                <label for="taxId">Tax ID / VAT Number</label>
                <input type="text" id="taxId" name="taxId" placeholder="e.g. US-123456789">
            </div>

            <div class="verification-box">
                <h3>Verification documents</h3>

                <div class="verification-row">
                    <span class="verification-label">Government-issued ID</span>
                    <label class="upload-link" for="docGovId">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 19V5"></path>
                            <path d="M5 12l7-7 7 7"></path>
                        </svg>
                        Upload
                        <input type="file" id="docGovId" name="docGovId" style="display:none;">
                    </label>
                </div>

                <div class="verification-row">
                    <span class="verification-label">Business registration certificate</span>
                    <label class="upload-link" for="docBizCert">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 19V5"></path>
                            <path d="M5 12l7-7 7 7"></path>
                        </svg>
                        Upload
                        <input type="file" id="docBizCert" name="docBizCert" style="display:none;">
                    </label>
                </div>

                <div class="verification-row">
                    <span class="verification-label">Proof of address (&lt; 3 months)</span>
                    <label class="upload-link" for="docAddressProof">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M12 19V5"></path>
                            <path d="M5 12l7-7 7 7"></path>
                        </svg>
                        Upload
                        <input type="file" id="docAddressProof" name="docAddressProof" style="display:none;">
                    </label>
                </div>
            </div>

            <div class="step-buttons-row">
                <button type="button" class="back-btn" onclick="goToStep(1)">Back</button>
                <button type="button" class="continue-btn" onclick="goToStep(3)">Continue</button>
            </div>
        </form>

        <!-- STEP 3: BANKING -->
        <form class="form-card" id="step3" style="display:none;" method="post" action="submitBanking.jsp">
            <h2>Banking &amp; payout details</h2>

            <div class="form-group">
                <label for="bankName">Bank Name</label>
                <input type="text" id="bankName" name="bankName" placeholder="e.g. Chase, Barclays...">
            </div>

            <div class="form-group">
                <label for="accountIban">Account / IBAN Number</label>
                <input type="text" id="accountIban" name="accountIban" placeholder="DE89 3704 0044 0532 0130 00">
            </div>

            <div class="info-notice">
                Platform commission is <strong>10%</strong> on each sale. Payouts are processed on the 5th of each month for the prior month's earnings.
            </div>

            <div class="agreement-row">
                <input type="checkbox" id="agreeTerms" name="agreeTerms" onchange="toggleSubmit()">
                <label for="agreeTerms" class="agreement-label">
                    I agree to the <a href="#" class="terms-link">Seller Terms of Service</a> and confirm that all provided information is accurate.
                </label>
            </div>

            <div class="step-buttons-row">
                <button type="button" class="back-btn" onclick="goToStep(2)">Back</button>
                <button type="submit" class="continue-btn" id="submitAppBtn" disabled>Submit application</button>
            </div>
        </form>

    </div>

   </div>

   <jsp:include page="/WEB-INF/components/footer.jsp" />

   <script>
        function goToStep(stepNum) {
            document.querySelectorAll('.main-content .form-card').forEach(function (card) {
                card.style.display = 'none';
            });

            document.getElementById('step' + stepNum).style.display = 'block';

            document.querySelectorAll('#stepsIndicator .step').forEach(function (stepEl) {
                var num = parseInt(stepEl.getAttribute('data-step'), 10);
                stepEl.classList.remove('active', 'completed');
                if (num < stepNum) {
                    stepEl.classList.add('completed');
                } else if (num === stepNum) {
                    stepEl.classList.add('active');
                }
            });

            window.scrollTo({ top: 0, behavior: 'smooth' });
        }

        function toggleSubmit() {
            var checkbox = document.getElementById('agreeTerms');
            var submitBtn = document.getElementById('submitAppBtn');
            submitBtn.disabled = !checkbox.checked;
        }
   </script>

</body>
</html>