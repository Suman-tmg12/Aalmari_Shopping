package com.example.aalmari.controller;

import com.example.aalmari.model.SellerDocumentation;
import com.example.aalmari.repository.SellerDocumentationRepository;
import com.example.aalmari.service.impl.S3Service;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

@Controller
public class SellerController {

    private final S3Service s3Service;
    private final SellerDocumentationRepository sellerDocumentationRepository;

    public SellerController(S3Service s3Service, SellerDocumentationRepository sellerDocumentationRepository) {
        this.s3Service = s3Service;
        this.sellerDocumentationRepository = sellerDocumentationRepository;
    }

    // Shows the Seller registration / intro page
    @GetMapping("/seller")
    public String sellerController(HttpSession session) {
        Object userIdAttr = session.getAttribute("userId");
        if (userIdAttr == null) {
            return "redirect:/login";
        }
        Long userId = Long.valueOf(userIdAttr.toString());

        Optional<SellerDocumentation> existing = sellerDocumentationRepository.findByUserId(userId);
        if (existing.isPresent() && !"rejected".equalsIgnoreCase(existing.get().getStatus())) {
            // Already applied and pending/approved -> nothing left to fill in here.
            // This is what fixes the Back-button bug: no more re-showing a blank form.
            return "redirect:/SellerDashboard";
        }
        // No application yet, or it was rejected -> let them (re)apply.
        return "SellerPage/seller";
    }

    // Handles the POST request when submitting the seller form
    @PostMapping("/SellerDashboard")
    public String handleSellerSubmit(
            HttpSession session,
            @RequestParam(value = "storeBanner", required = false) MultipartFile storeBanner,
            @RequestParam("storeLogo") MultipartFile storeLogo,
            @RequestParam("storeName") String storeName,
            @RequestParam(value = "storeTagline", required = false) String storeTagline,
            @RequestParam("primaryCategory") String primaryCategory,
            @RequestParam("businessEmail") String businessEmail,
            @RequestParam("phoneNumber") String phoneNumber,
            @RequestParam("businessAddress") String businessRegistrationNumber,
            @RequestParam(value = "taxId", required = false) String taxId,
            @RequestParam("docGovId") MultipartFile docGovId,
            @RequestParam("docBizCert") MultipartFile docBizCert,
            @RequestParam("docAddressProof") MultipartFile docAddressProof,
            @RequestParam("accountHolder") String accountHolder,
            @RequestParam("bankName") String bankName,
            @RequestParam("accountIban") String accountIban,
            @RequestParam(value = "agreeTerms", required = false) String agreeTerms
    ) {
        Object userIdAttr = session.getAttribute("userId");
        if (userIdAttr == null) {
            return "redirect:/login";
        }
        Long userId = Long.valueOf(userIdAttr.toString());

        // ---- Server-side guardrails (never trust client-side JS alone) ----
        if (storeLogo.isEmpty() || docGovId.isEmpty() || docBizCert.isEmpty() || docAddressProof.isEmpty()) {
            return "redirect:/seller?error=missing_required_files";
        }
        if (!"yes".equals(agreeTerms)) {
            return "redirect:/seller?error=terms_not_accepted";
        }

        // ---- Upsert: one row per user (matches uk_seller_apps_user) ----
        SellerDocumentation doc = sellerDocumentationRepository.findByUserId(userId)
                .orElse(new SellerDocumentation());
        doc.setUserId(userId);

        if (storeBanner != null && !storeBanner.isEmpty()) {
            doc.setStoreBannerPath(s3Service.upload(storeBanner, userId, "banner"));
        }
        doc.setStoreLogoPath(s3Service.upload(storeLogo, userId, "logo"));
        doc.setStoreName(storeName.trim());
        doc.setStoreTagline(storeTagline);
        doc.setPrimaryCategory(primaryCategory);

        doc.setBusinessEmail(businessEmail.trim());
        doc.setPhoneNumber(phoneNumber.trim());
        doc.setBusinessRegistrationNumber(businessRegistrationNumber.trim());
        doc.setTaxId(taxId);

        doc.setDocGovIdPath(s3Service.upload(docGovId, userId, "docs/gov-id"));
        doc.setDocBizCertPath(s3Service.upload(docBizCert, userId, "docs/biz-cert"));
        doc.setDocAddressProofPath(s3Service.upload(docAddressProof, userId, "docs/address-proof"));

        doc.setAccountHolder(accountHolder.trim());
        doc.setBankName(bankName.trim());
        doc.setAccountIban(accountIban.replaceAll("[\\s-]", "").toUpperCase());
        doc.setAgreeTerms(true);
        doc.setStatus("pending"); // resubmission goes back to review queue
        doc.setRejectionReason(null); // clear any previous rejection note on resubmit

        sellerDocumentationRepository.save(doc);

        return "redirect:/SellerDashboard"; // GET handler below renders the real status
    }

    // Displays the Seller Dashboard page, driven by the real application status
    @GetMapping("/SellerDashboard")
    public String showSellerDashboard(HttpSession session, Model model) {
        Object userIdAttr = session.getAttribute("userId");
        if (userIdAttr == null) {
            return "redirect:/login";
        }
        Long userId = Long.valueOf(userIdAttr.toString());

        SellerDocumentation doc = sellerDocumentationRepository.findByUserId(userId).orElse(null);
        if (doc == null) {
            // Never applied -> nothing to show here, send them to the form.
            return "redirect:/seller";
        }

        model.addAttribute("storeName", doc.getStoreName());
        model.addAttribute("status", doc.getStatus());               // "pending" | "approved" | "rejected"
        model.addAttribute("rejectionReason", doc.getRejectionReason());

        return "SellerPage/SellerDashboard"; // -> /WEB-INF/views/SellerPage/SellerDashboard.jsp
    }
}