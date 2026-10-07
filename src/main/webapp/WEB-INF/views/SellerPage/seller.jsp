<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<%-- 1. Prevent browser caching so clicking "Back" after logout won't reveal this page --%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>

<%-- 2. Redirect to login page if session is empty --%>
<c:if test="${empty sessionScope.userId}">
    <c:redirect url="/login" />
</c:if>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Apply to Sell - Seller Hub</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/seller/seller.css?v=6">
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

        <!--
            ONE form for all 3 steps so every field and file is sent together on submit.
            novalidate = we show our own inline errors instead of browser pop-ups.
        -->
        <form id="sellerForm" method="post" action="${pageContext.request.contextPath}/SellerDashboard"
              enctype="multipart/form-data" novalidate>

            <!-- ============ STEP 1: STORE INFO ============ -->
            <section class="form-card" id="step1" aria-labelledby="step1-title">
                <h2 id="step1-title">Store information</h2>

                <!-- Banner (optional) -->
                <div class="form-group upload-block">
                    <label class="banner-upload dropzone" for="storeBanner">
                        <img class="upload-preview" alt="Store banner preview">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <rect x="3" y="3" width="18" height="18" rx="2"></rect>
                            <circle cx="8.5" cy="8.5" r="1.5"></circle>
                            <polyline points="21 15 16 10 5 21"></polyline>
                        </svg>
                        <span class="upload-text">Upload store banner (1200 x 300px)</span>
                        <span class="upload-overlay">Click or drop to change</span>
                        <input type="file" id="storeBanner" name="storeBanner" class="sr-file"
                               accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
                               aria-describedby="storeBanner-error">
                    </label>
                    <p class="field-hint">Optional &middot; JPG, PNG or WebP &middot; max 2 MB &middot; at least 600 x 150 px</p>
                    <div class="file-meta" id="storeBanner-meta" hidden>
                        <span class="file-name"></span><span class="file-size"></span>
                        <button type="button" class="file-remove" data-for="storeBanner">Remove</button>
                    </div>
                    <div class="field-error" id="storeBanner-error" role="alert"></div>
                </div>

                <!-- Logo (required) + Store name -->
                <div class="logo-field-row">
                    <label class="logo-upload dropzone" for="storeLogo">
                        <img class="upload-preview" alt="Store logo preview">
                        <span class="up-arrow">&#8593;</span>
                        <span class="logo-text">Logo*</span>
                        <input type="file" id="storeLogo" name="storeLogo" class="sr-file"
                               accept=".jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp"
                               aria-describedby="storeLogo-error">
                    </label>

                    <div class="field-group">
                        <label for="storeName">Business / Store Name <span class="required">*</span></label>
                        <input type="text" id="storeName" name="storeName" maxlength="60" autocomplete="organization"
                               placeholder="e.g. Artisan Supply Co." aria-describedby="storeName-error">
                        <div class="field-error" id="storeName-error" role="alert"></div>
                    </div>
                </div>
                <div class="form-group logo-extra">
                    <p class="field-hint">Logo is required &middot; JPG, PNG or WebP &middot; max 1 MB &middot; at least 100 x 100 px</p>
                    <div class="file-meta" id="storeLogo-meta" hidden>
                        <span class="file-name"></span><span class="file-size"></span>
                        <button type="button" class="file-remove" data-for="storeLogo">Remove</button>
                    </div>
                    <div class="field-error" id="storeLogo-error" role="alert"></div>
                </div>

                <div class="form-group">
                    <label for="storeTagline">Store Tagline</label>
                    <input type="text" id="storeTagline" name="storeTagline" maxlength="120"
                           placeholder="One sentence describing your store" aria-describedby="storeTagline-error">
                    <div class="field-error" id="storeTagline-error" role="alert"></div>
                    <div class="field-hint right"><span id="taglineCount">0</span>/120</div>
                </div>

                <div class="form-group">
                    <label for="primaryCategory">Primary Category <span class="required">*</span></label>
                    <select id="primaryCategory" name="primaryCategory" aria-describedby="primaryCategory-error">
                        <option value="" selected disabled>Select category...</option>
                        <option value="electronics">Electronics</option>
                        <option value="fashion">Fashion &amp; Apparel</option>
                        <option value="beauty">Beauty &amp; Personal Care</option>
                        <option value="home">Home &amp; Living</option>
                        <option value="groceries">Groceries</option>
                        <option value="sports">Sports &amp; Fitness</option>
                        <option value="books">Books &amp; Stationery</option>
                        <option value="automotive">Automotive</option>
                        <option value="toys">Toys &amp; Games</option>
                        <option value="health">Health &amp; Wellness</option>
                        <option value="other">Other</option>
                    </select>
                    <div class="field-error" id="primaryCategory-error" role="alert"></div>
                </div>

                <div class="step-alert" id="step1-alert" role="alert"></div>
                <button type="button" class="continue-btn" data-next="2">Continue</button>
            </section>

            <!-- ============ STEP 2: CONTACT & DOCS ============ -->
            <section class="form-card" id="step2" style="display:none;" aria-labelledby="step2-title">
                <h2 id="step2-title">Contact &amp; verification documents</h2>

                <div class="two-col-row">
                    <div class="field-group">
                        <label for="businessEmail">Business Email <span class="required">*</span></label>
                        <input type="email" id="businessEmail" name="businessEmail" maxlength="254" autocomplete="email"
                               placeholder="aalmari_seller@yourbrand.com" aria-describedby="businessEmail-error">
                        <div class="field-error" id="businessEmail-error" role="alert"></div>
                    </div>
                    <div class="field-group">
                        <label for="phoneNumber">Phone Number <span class="required">*</span></label>
                        <input type="tel" id="phoneNumber" name="phoneNumber" maxlength="20" autocomplete="tel"
                               placeholder="+977 9800000000" aria-describedby="phoneNumber-error">
                        <div class="field-error" id="phoneNumber-error" role="alert"></div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="businessAddress">Business Address <span class="required">*</span></label>
                    <input type="text" id="businessAddress" name="businessAddress" maxlength="200" autocomplete="street-address"
                           placeholder="Street, City, Country" aria-describedby="businessAddress-error">
                    <div class="field-error" id="businessAddress-error" role="alert"></div>
                </div>

                <div class="form-group">
                    <label for="taxId">Tax ID / VAT Number</label>
                    <input type="text" id="taxId" name="taxId" maxlength="20"
                           placeholder="e.g. NP-123456789" aria-describedby="taxId-error">
                    <div class="field-error" id="taxId-error" role="alert"></div>
                </div>

                <div class="verification-box">
                    <h3>Verification documents</h3>
                    <p class="field-hint doc-hint">All three are required &middot; JPG, PNG or PDF &middot; max 5 MB each</p>

                    <div class="verification-item">
                        <div class="verification-row">
                            <span class="verification-label">Government-issued ID <span class="required">*</span></span>
                            <label class="upload-link" for="docGovId">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 19V5"></path><path d="M5 12l7-7 7 7"></path>
                                </svg>
                                <span class="upload-text">Upload</span>
                                <input type="file" id="docGovId" name="docGovId" class="sr-file"
                                       accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf"
                                       aria-describedby="docGovId-error">
                            </label>
                        </div>
                        <div class="file-meta" id="docGovId-meta" hidden>
                            <img class="file-thumb" alt="" hidden><span class="file-badge" hidden>PDF</span>
                            <span class="file-name"></span><span class="file-size"></span>
                            <button type="button" class="file-remove" data-for="docGovId">Remove</button>
                        </div>
                        <div class="field-error" id="docGovId-error" role="alert"></div>
                    </div>

                    <div class="verification-item">
                        <div class="verification-row">
                            <span class="verification-label">Business registration certificate <span class="required">*</span></span>
                            <label class="upload-link" for="docBizCert">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 19V5"></path><path d="M5 12l7-7 7 7"></path>
                                </svg>
                                <span class="upload-text">Upload</span>
                                <input type="file" id="docBizCert" name="docBizCert" class="sr-file"
                                       accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf"
                                       aria-describedby="docBizCert-error">
                            </label>
                        </div>
                        <div class="file-meta" id="docBizCert-meta" hidden>
                            <img class="file-thumb" alt="" hidden><span class="file-badge" hidden>PDF</span>
                            <span class="file-name"></span><span class="file-size"></span>
                            <button type="button" class="file-remove" data-for="docBizCert">Remove</button>
                        </div>
                        <div class="field-error" id="docBizCert-error" role="alert"></div>
                    </div>

                    <div class="verification-item">
                        <div class="verification-row">
                            <span class="verification-label">Proof of address (&lt; 3 months) <span class="required">*</span></span>
                            <label class="upload-link" for="docAddressProof">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M12 19V5"></path><path d="M5 12l7-7 7 7"></path>
                                </svg>
                                <span class="upload-text">Upload</span>
                                <input type="file" id="docAddressProof" name="docAddressProof" class="sr-file"
                                       accept=".jpg,.jpeg,.png,.pdf,image/jpeg,image/png,application/pdf"
                                       aria-describedby="docAddressProof-error">
                            </label>
                        </div>
                        <div class="file-meta" id="docAddressProof-meta" hidden>
                            <img class="file-thumb" alt="" hidden><span class="file-badge" hidden>PDF</span>
                            <span class="file-name"></span><span class="file-size"></span>
                            <button type="button" class="file-remove" data-for="docAddressProof">Remove</button>
                        </div>
                        <div class="field-error" id="docAddressProof-error" role="alert"></div>
                    </div>
                </div>

                <div class="step-alert" id="step2-alert" role="alert"></div>
                <div class="step-buttons-row">
                    <button type="button" class="back-btn" data-back="1">Back</button>
                    <button type="button" class="continue-btn" data-next="3">Continue</button>
                </div>
            </section>

            <!-- ============ STEP 3: BANKING ============ -->
            <section class="form-card" id="step3" style="display:none;" aria-labelledby="step3-title">
                <h2 id="step3-title">Banking &amp; payout details</h2>

                <div class="form-group">
                    <label for="accountHolder">Account Holder Name <span class="required">*</span></label>
                    <input type="text" id="accountHolder" name="accountHolder" maxlength="60" autocomplete="name"
                           placeholder="Name exactly as on your bank account" aria-describedby="accountHolder-error">
                    <div class="field-error" id="accountHolder-error" role="alert"></div>
                </div>

                <div class="form-group">
                    <label for="bankName">Bank Name <span class="required">*</span></label>
                    <input type="text" id="bankName" name="bankName" maxlength="60"
                           placeholder="e.g. Nabil, Everest..." aria-describedby="bankName-error">
                    <div class="field-error" id="bankName-error" role="alert"></div>
                </div>

                <div class="form-group">
                    <label for="accountIban">Account / IBAN Number <span class="required">*</span></label>
                    <input type="text" id="accountIban" name="accountIban" maxlength="40" autocomplete="off"
                           placeholder="3704 0044 0532 0130" aria-describedby="accountIban-error">
                    <div class="field-error" id="accountIban-error" role="alert"></div>
                </div>

                <div class="info-notice">
                    Platform commission is <strong>10%</strong> on each sale. Payouts are processed on the 5th of each month for the prior month's earnings.
                </div>

                <div class="agreement-row">
                    <input type="checkbox" id="agreeTerms" name="agreeTerms" value="yes" aria-describedby="agreeTerms-error">
                    <label for="agreeTerms" class="agreement-label">
                        I agree to the <a href="#" class="terms-link">Seller Terms of Service</a> and confirm that all provided information is accurate.
                    </label>
                </div>
                <div class="field-error agree-error" id="agreeTerms-error" role="alert"></div>

                <div class="step-alert" id="step3-alert" role="alert"></div>
                <div class="step-buttons-row">
                    <button type="button" class="back-btn" data-back="2">Back</button>
                    <button type="submit" class="continue-btn" id="submitAppBtn">Submit application</button>
                </div>
            </section>

        </form>
    </div>

   </div>

   <jsp:include page="/WEB-INF/components/footer.jsp" />

   <script>
   (function () {
       'use strict';

       var MB = 1024 * 1024;
       var TOTAL = 3;
       var current = 1;
       var form = document.getElementById('sellerForm');
       var submitBtn = document.getElementById('submitAppBtn');
       var state = {};          // per-file upload state
       var seq = 0;             // token counter to ignore stale async image checks

       function $(id) { return document.getElementById(id); }

       function fmtSize(b) {
           return b < MB ? Math.max(1, Math.round(b / 1024)) + ' KB' : (b / MB).toFixed(1) + ' MB';
       }

       /* ================= TEXT FIELD RULES ================= */
       var NAME_RE   = /^[\p{L}\p{N}][\p{L}\p{N} &.,'’\-]*$/u;
       var PERSON_RE = /^[\p{L}][\p{L} .'’\-]*$/u;
       var BANK_RE   = /^[\p{L}][\p{L} &.'’\-]*$/u;

       function ibanOk(s) {
           var r = s.slice(4) + s.slice(0, 4);
           var n = r.replace(/[A-Z]/g, function (c) { return String(c.charCodeAt(0) - 55); });
           var rem = 0;
           for (var i = 0; i < n.length; i++) { rem = (rem * 10 + parseInt(n.charAt(i), 10)) % 97; }
           return rem === 1;
       }

       var textRules = {
           storeName: function (v) {
               if (!v) return 'Store name is required.';
               if (v.length < 3) return 'Store name must be at least 3 characters.';
               if (v.length > 60) return 'Store name can be at most 60 characters.';
               if (!NAME_RE.test(v)) return "Use letters, numbers and & . , ' - only, and start with a letter or number.";
               return '';
           },
           storeTagline: function (v) {
               if (v.length > 120) return 'Tagline can be at most 120 characters.';
               return '';
           },
           primaryCategory: function (v) {
               return v ? '' : 'Please select a category.';
           },
           businessEmail: function (v) {
               if (!v) return 'Business email is required.';
               if (!/^[^\s@]+@[^\s@.]+(\.[^\s@.]+)*\.[A-Za-z]{2,}$/.test(v)) return 'Enter a valid email address, e.g. name@yourbrand.com.';
               return '';
           },
           phoneNumber: function (v) {
               if (!v) return 'Phone number is required.';
               if (!/^\+?[0-9\s\-()]+$/.test(v)) return 'Use digits only (spaces, +, - and ( ) are allowed).';
               var digits = v.replace(/\D/g, '');
               if (/^\+\s*977/.test(v)) {
                   var national = digits.slice(3);
                   if (national.length < 8 || national.length > 10) return 'A Nepal number needs 8–10 digits after +977.';
               } else if (/^9[78]/.test(digits) && !/^977/.test(digits) && v.charAt(0) !== '+') {
                   if (digits.length !== 10) return 'Nepal mobile numbers must be exactly 10 digits (e.g. 9800000000).';
               } else if (digits.length < 7 || digits.length > 15) {
                   return 'Enter a valid phone number (7–15 digits).';
               }
               return '';
           },
           businessAddress: function (v) {
               if (!v) return 'Business address is required.';
               if (v.length < 10) return 'Enter the full address (street, city, country).';
               if (v.length > 200) return 'Address can be at most 200 characters.';
               return '';
           },
           taxId: function (v) {
               if (!v) return '';
               if (!/^[A-Za-z0-9][A-Za-z0-9\-\/ ]{3,19}$/.test(v)) return 'Tax ID must be 4–20 characters: letters, numbers, - or /.';
               return '';
           },
           accountHolder: function (v) {
               if (!v) return 'Account holder name is required.';
               if (v.length < 3) return 'Name must be at least 3 characters.';
               if (!PERSON_RE.test(v)) return 'Use letters, spaces and . \' - only.';
               return '';
           },
           bankName: function (v) {
               if (!v) return 'Bank name is required.';
               if (v.length < 2) return 'Bank name must be at least 2 characters.';
               if (!BANK_RE.test(v)) return 'Use letters, spaces and & . \' - only.';
               return '';
           },
           accountIban: function (v) {
               if (!v) return 'Account / IBAN number is required.';
               var s = v.replace(/[\s\-]/g, '').toUpperCase();
               if (!/^[A-Z0-9]+$/.test(s)) return 'Use only letters and numbers (spaces are fine).';
               if (/^[A-Z]{2}/.test(s)) {
                   if (s.length < 15 || s.length > 34 || !/^[A-Z]{2}\d{2}/.test(s)) return 'Enter a valid IBAN, e.g. DE89 3704 0044 0532 0130 00.';
                   if (!ibanOk(s)) return 'This IBAN is not valid. Please check for typos.';
                   return '';
               }
               if (!/^\d{8,20}$/.test(s)) return 'Account number must be 8–20 digits.';
               return '';
           }
       };

       /* ================= FILE RULES ================= */
       var IMG_TYPES = ['image/jpeg', 'image/png', 'image/webp'];
       var IMG_EXTS  = ['jpg', 'jpeg', 'png', 'webp'];
       var DOC_TYPES = ['image/jpeg', 'image/png', 'application/pdf'];
       var DOC_EXTS  = ['jpg', 'jpeg', 'png', 'pdf'];

       var fileRules = {
           storeBanner: { required: false, types: IMG_TYPES, exts: IMG_EXTS, max: 2 * MB, minW: 600, minH: 150,
                          typeMsg: 'Banner must be a JPG, PNG or WebP image.', reqMsg: '' },
           storeLogo:   { required: true,  types: IMG_TYPES, exts: IMG_EXTS, max: 1 * MB, minW: 100, minH: 100,
                          typeMsg: 'Logo must be a JPG, PNG or WebP image.', reqMsg: 'Please upload your store logo.' },
           docGovId:        { required: true, types: DOC_TYPES, exts: DOC_EXTS, max: 5 * MB,
                              typeMsg: 'Only JPG, PNG or PDF files are accepted.', reqMsg: 'Please upload your government-issued ID.' },
           docBizCert:      { required: true, types: DOC_TYPES, exts: DOC_EXTS, max: 5 * MB,
                              typeMsg: 'Only JPG, PNG or PDF files are accepted.', reqMsg: 'Please upload your business registration certificate.' },
           docAddressProof: { required: true, types: DOC_TYPES, exts: DOC_EXTS, max: 5 * MB,
                              typeMsg: 'Only JPG, PNG or PDF files are accepted.', reqMsg: 'Please upload a proof of address.' }
       };

       var stepFields = {
           1: ['storeBanner', 'storeLogo', 'storeName', 'storeTagline', 'primaryCategory'],
           2: ['businessEmail', 'phoneNumber', 'businessAddress', 'taxId', 'docGovId', 'docBizCert', 'docAddressProof'],
           3: ['accountHolder', 'bankName', 'accountIban', 'agreeTerms']
       };

       /* ================= ERROR DISPLAY ================= */
       function setError(id, msg) {
           var input = $(id), err = $(id + '-error');
           if (!input) return;
           var bad = !!msg;
           input.classList.toggle('invalid', bad);
           input.setAttribute('aria-invalid', bad ? 'true' : 'false');
           if (input.type === 'file') {
               var lbl = input.closest('label');
               if (lbl) lbl.classList.toggle('invalid', bad);
           }
           if (err) err.textContent = msg || '';
       }

       function focusField(id) {
           var input = $(id);
           if (!input) return;
           var box = input.closest('.form-group, .field-group, .verification-item, .agreement-row') || input;
           box.scrollIntoView({ behavior: 'smooth', block: 'center' });
           try { input.focus({ preventScroll: true }); } catch (e) { input.focus(); }
       }

       /* ================= VALIDATION ================= */
       function validateText(id) {
           var input = $(id);
           var msg = textRules[id](input.value.trim(), input);
           setError(id, msg);
           return msg;
       }

       function validateFile(id) {
           var cfg = fileRules[id], input = $(id), st = state[id] || {}, msg = '';
           if (st.pending) {
               msg = 'Still checking your image, please wait a moment.';
           } else if (!input.files.length) {
               msg = st.rejected ? st.rejected : (cfg.required ? cfg.reqMsg : '');
           }
           setError(id, msg);
           return msg;
       }

       function validateAgree() {
           var msg = $('agreeTerms').checked ? '' : 'You must accept the Seller Terms of Service to submit.';
           setError('agreeTerms', msg);
           return msg;
       }

       function validateId(id) {
           if (fileRules[id]) return validateFile(id);
           if (id === 'agreeTerms') return validateAgree();
           return validateText(id);
       }

       // Validates every field in a step. Returns id of first invalid field, or null.
       function validateStep(n) {
           var first = null, count = 0;
           stepFields[n].forEach(function (id) {
               if (validateId(id)) { count++; if (!first) first = id; }
           });
           var box = $('step' + n + '-alert');
           if (box) {
               box.textContent = count
                   ? 'Please fix ' + count + (count === 1 ? ' field' : ' fields') + ' highlighted above to continue.'
                   : '';
           }
           return first;
       }

       /* ================= TEXT FIELD EVENTS ================= */
       Object.keys(textRules).forEach(function (id) {
           var input = $(id), touched = false;
           if (!input) return;

           input.addEventListener('blur', function () {
               touched = true;
               if (input.tagName !== 'SELECT') input.value = input.value.trim();
               validateText(id);
           });
           input.addEventListener(input.tagName === 'SELECT' ? 'change' : 'input', function () {
               if (id === 'phoneNumber') input.value = input.value.replace(/[^0-9+\s\-()]/g, '');
               if (touched || input.classList.contains('invalid') || input.tagName === 'SELECT') validateText(id);
           });
       });

       var tagline = $('storeTagline'), counter = $('taglineCount');
       tagline.addEventListener('input', function () { counter.textContent = tagline.value.length; });

       $('agreeTerms').addEventListener('change', validateAgree);

       /* ================= FILE UPLOAD HANDLING ================= */
       function clearState(id) {
           var st = state[id];
           if (st && st.url) URL.revokeObjectURL(st.url);
           state[id] = {};
       }

       function renderFile(id) {
           var input = $(id), st = state[id] || {}, file = input.files[0];
           var ok = !!(st.ok && file);
           var label = input.closest('label');
           var meta = $(id + '-meta');
           var preview = label && label.querySelector('.upload-preview');

           if (preview) {
               if (ok && st.url) { preview.src = st.url; label.classList.add('has-preview'); }
               else { preview.removeAttribute('src'); label.classList.remove('has-preview'); }
           }

           var txt = label && label.querySelector('.upload-text');
           if (txt && label.classList.contains('upload-link')) txt.textContent = ok ? 'Replace' : 'Upload';

           if (meta) {
               meta.hidden = !ok;
               if (ok) {
                   meta.querySelector('.file-name').textContent = file.name;
                   meta.querySelector('.file-size').textContent = fmtSize(file.size);
                   var thumb = meta.querySelector('.file-thumb'), badge = meta.querySelector('.file-badge');
                   if (thumb && badge) {
                       if (st.url) { thumb.src = st.url; thumb.hidden = false; badge.hidden = true; }
                       else { thumb.hidden = true; badge.hidden = false; }
                   }
               }
           }
       }

       function rejectFile(id, msg) {
           $(id).value = '';
           clearState(id);
           state[id].rejected = msg;
           setError(id, msg);
           renderFile(id);
       }

       function handleFile(id, file) {
           var cfg = fileRules[id], input = $(id);
           clearState(id);
           if (!file) { setError(id, ''); renderFile(id); return; }

           var ext = (file.name.split('.').pop() || '').toLowerCase();
           if (cfg.types.indexOf(file.type) === -1 || cfg.exts.indexOf(ext) === -1) { rejectFile(id, cfg.typeMsg); return; }
           if (file.size === 0) { rejectFile(id, 'This file is empty. Please choose another one.'); return; }
           if (file.size > cfg.max) {
               rejectFile(id, 'File is too large (' + fmtSize(file.size) + '). Maximum size is ' + (cfg.max / MB) + ' MB.');
               return;
           }

           if (file.type.indexOf('image/') !== 0) {   // PDF: no preview, accept
               state[id] = { ok: true };
               setError(id, '');
               renderFile(id);
               return;
           }

           // Images: confirm it really is an image and check dimensions
           var st = state[id] = { pending: true, token: ++seq };
           var url = URL.createObjectURL(file);
           var img = new Image();
           img.onload = function () {
               if (state[id] !== st) { URL.revokeObjectURL(url); return; }
               if (cfg.minW && (img.naturalWidth < cfg.minW || img.naturalHeight < cfg.minH)) {
                   URL.revokeObjectURL(url);
                   rejectFile(id, 'Image is too small (' + img.naturalWidth + ' x ' + img.naturalHeight +
                              ' px). Minimum is ' + cfg.minW + ' x ' + cfg.minH + ' px.');
                   return;
               }
               state[id] = { ok: true, url: url };
               setError(id, '');
               renderFile(id);
           };
           img.onerror = function () {
               if (state[id] !== st) { URL.revokeObjectURL(url); return; }
               URL.revokeObjectURL(url);
               rejectFile(id, 'This file is corrupted or is not a valid image.');
           };
           img.src = url;
       }

       Object.keys(fileRules).forEach(function (id) {
           var input = $(id);
           input.addEventListener('change', function () { handleFile(id, input.files[0]); });
       });

       Array.prototype.forEach.call(document.querySelectorAll('.file-remove'), function (btn) {
           btn.addEventListener('click', function () {
               var id = btn.getAttribute('data-for');
               $(id).value = '';
               handleFile(id, null);
           });
       });

       // Drag & drop on banner / logo
       Array.prototype.forEach.call(document.querySelectorAll('.dropzone'), function (zone) {
           var input = zone.querySelector('input[type="file"]');
           ['dragenter', 'dragover'].forEach(function (ev) {
               zone.addEventListener(ev, function (e) { e.preventDefault(); zone.classList.add('drag-over'); });
           });
           ['dragleave', 'drop'].forEach(function (ev) {
               zone.addEventListener(ev, function () { zone.classList.remove('drag-over'); });
           });
           zone.addEventListener('drop', function (e) {
               e.preventDefault();
               if (e.dataTransfer && e.dataTransfer.files.length) {
                   input.files = e.dataTransfer.files;
                   handleFile(input.id, input.files[0]);
               }
           });
       });

       /* ================= STEP NAVIGATION ================= */
       function goToStep(n) {
           current = n;
           Array.prototype.forEach.call(document.querySelectorAll('#sellerForm .form-card'), function (card) {
               card.style.display = 'none';
           });
           $('step' + n).style.display = 'block';

           Array.prototype.forEach.call(document.querySelectorAll('#stepsIndicator .step'), function (el) {
               var num = parseInt(el.getAttribute('data-step'), 10);
               el.classList.remove('active', 'completed');
               if (num < n) el.classList.add('completed');
               else if (num === n) el.classList.add('active');
           });
           window.scrollTo({ top: 0, behavior: 'smooth' });
       }

       function nextFrom(n) {
           var bad = validateStep(n);
           if (bad) { focusField(bad); return; }
           goToStep(n + 1);
       }

       Array.prototype.forEach.call(document.querySelectorAll('[data-next]'), function (btn) {
           btn.addEventListener('click', function () { nextFrom(parseInt(btn.getAttribute('data-next'), 10) - 1); });
       });
       Array.prototype.forEach.call(document.querySelectorAll('[data-back]'), function (btn) {
           btn.addEventListener('click', function () { goToStep(parseInt(btn.getAttribute('data-back'), 10)); });
       });
       // Click a completed step in the indicator to go back to it
       Array.prototype.forEach.call(document.querySelectorAll('#stepsIndicator .step'), function (el) {
           el.addEventListener('click', function () {
               if (el.classList.contains('completed')) goToStep(parseInt(el.getAttribute('data-step'), 10));
           });
       });

       // Enter key: go to next step instead of submitting half-filled form
       form.addEventListener('keydown', function (e) {
           if (e.key !== 'Enter') return;
           var t = e.target;
           if (t.tagName !== 'INPUT' || ['text', 'email', 'tel'].indexOf(t.type) === -1) return;
           e.preventDefault();
           if (current < TOTAL) nextFrom(current); else submitBtn.click();
       });

       /* ================= SUBMIT ================= */
       form.addEventListener('submit', function (e) {
           var firstId = null, firstStep = null;
           for (var s = 1; s <= TOTAL; s++) {
               var bad = validateStep(s);
               if (bad && !firstId) { firstId = bad; firstStep = s; }
           }
           if (firstId) {
               e.preventDefault();
               goToStep(firstStep);
               setTimeout(function () { focusField(firstId); }, 80);
               return;
           }
           submitBtn.disabled = true;          // stop double submit
           submitBtn.textContent = 'Submitting…';
       });

       // Browser "Back" restores the page from cache - re-enable the button
       window.addEventListener('pageshow', function (e) {
           if (e.persisted) { submitBtn.disabled = false; submitBtn.textContent = 'Submit application'; }
       });
   })();
   </script>

</body>
</html>
