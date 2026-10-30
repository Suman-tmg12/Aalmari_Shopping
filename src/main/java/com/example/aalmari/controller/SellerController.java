package com.example.aalmari.controller;

import com.example.aalmari.model.SellerDocumentation;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.UserRepository;
import com.example.aalmari.repository.SellerDocumentationRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.service.impl.S3Service;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Controller
public class SellerController {

    private final S3Service s3Service;
    private final SellerDocumentationRepository sellerDocumentationRepository;
    private final SellerProductRepository sellerProductRepository;
    private final UserRepository userRepository;

    public SellerController(S3Service s3Service,
                            SellerDocumentationRepository sellerDocumentationRepository,
                            SellerProductRepository sellerProductRepository,
                            UserRepository userRepository) {
        this.s3Service = s3Service;
        this.sellerDocumentationRepository = sellerDocumentationRepository;
        this.sellerProductRepository = sellerProductRepository;
        this.userRepository = userRepository;
    }

    // S3 Bucket URL - Replace with your actual bucket URL
    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";

    @GetMapping("/seller")
    public String sellerController(HttpSession session) {
        Object userIdAttr = session.getAttribute("userId");
        if (userIdAttr == null) {
            return "redirect:/login";
        }
        Long userId = Long.valueOf(userIdAttr.toString());

        Optional<SellerDocumentation> existing = sellerDocumentationRepository.findByUserId(userId);
        if (existing.isPresent() && !"rejected".equalsIgnoreCase(existing.get().getStatus())) {
            return "redirect:/SellerDashboard";
        }
        return "SellerPage/seller";
    }

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

        if (storeLogo.isEmpty() || docGovId.isEmpty() || docBizCert.isEmpty() || docAddressProof.isEmpty()) {
            return "redirect:/seller?error=missing_required_files";
        }
        if (!"yes".equals(agreeTerms)) {
            return "redirect:/seller?error=terms_not_accepted";
        }

        SellerDocumentation doc = sellerDocumentationRepository.findByUserId(userId)
                .orElse(new SellerDocumentation());
        doc.setUserId(userId);

        if (storeBanner != null && !storeBanner.isEmpty()) {
            doc.setStoreBannerPath(s3Service.upload(storeBanner, userId, "banner"));
        }

        String logoPath = s3Service.upload(storeLogo, userId, "logo");
        doc.setStoreLogoPath(logoPath);

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
        doc.setStatus("pending");
        doc.setRejectionReason(null);

        sellerDocumentationRepository.save(doc);

        return "redirect:/SellerDashboard";
    }

    @GetMapping("/SellerDashboard")
    public String showSellerDashboard(HttpSession session, Model model) {
        Object userIdAttr = session.getAttribute("userId");
        if (userIdAttr == null) {
            return "redirect:/login";
        }
        Long userId = Long.valueOf(userIdAttr.toString());

        SellerDocumentation doc = sellerDocumentationRepository.findByUserId(userId).orElse(null);
        if (doc == null) {
            return "redirect:/seller";
        }

        // --- Construct full S3 URLs from relative paths ---
        String storeLogoUrl = "";
        String storeBannerUrl = "";

        if (doc.getStoreLogoPath() != null && !doc.getStoreLogoPath().isEmpty()) {
            if (doc.getStoreLogoPath().startsWith("http")) {
                storeLogoUrl = doc.getStoreLogoPath();
            } else {
                storeLogoUrl = S3_BUCKET_URL + doc.getStoreLogoPath();
            }
        }

        if (doc.getStoreBannerPath() != null && !doc.getStoreBannerPath().isEmpty()) {
            if (doc.getStoreBannerPath().startsWith("http")) {
                storeBannerUrl = doc.getStoreBannerPath();
            } else {
                storeBannerUrl = S3_BUCKET_URL + doc.getStoreBannerPath();
            }
        }

        model.addAttribute("storeLogo", storeLogoUrl);
        model.addAttribute("storeBanner", storeBannerUrl);
        model.addAttribute("storeName", doc.getStoreName());
        model.addAttribute("storeTagline", doc.getStoreTagline());
        model.addAttribute("status", doc.getStatus());
        model.addAttribute("rejectionReason", doc.getRejectionReason());

        // --- Filter products by user and convert image paths to URLs ---
        List<SellerProduct> allProducts = sellerProductRepository.findAll();
        List<SellerProduct> myProducts = new ArrayList<>();

        for (SellerProduct p : allProducts) {
            if (p.getSeller() != null && p.getSeller().getId().equals(userId)) {
                // Convert relative S3 paths to full URLs for product images
                if (p.getInfoImageUrl() != null && !p.getInfoImageUrl().isEmpty()) {
                    if (!p.getInfoImageUrl().startsWith("http")) {
                        p.setInfoImageUrl(S3_BUCKET_URL + p.getInfoImageUrl());
                    }
                }

                if (p.getImageUrlsJson() != null && !p.getImageUrlsJson().isEmpty()) {
                    try {
                        ObjectMapper mapper = new ObjectMapper();
                        List<String> urls = mapper.readValue(p.getImageUrlsJson(), List.class);
                        List<String> fullUrls = new ArrayList<>();
                        for (String url : urls) {
                            if (url != null && !url.isEmpty() && !url.startsWith("http")) {
                                fullUrls.add(S3_BUCKET_URL + url);
                            } else {
                                fullUrls.add(url);
                            }
                        }
                        p.setImageUrlsJson(mapper.writeValueAsString(fullUrls));
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
                myProducts.add(p);
            }
        }

        model.addAttribute("products", myProducts);

        return "SellerPage/SellerDashboard";
    }

    @PostMapping("/api/products/create")
    public ResponseEntity<?> createProduct(
            @RequestParam("name") String name,
            @RequestParam("category") String category,
            @RequestParam("subCategory") String subCategory,
            @RequestParam("price") String priceStr,
            @RequestParam("stock") String stockStr,
            @RequestParam("discount") String discountStr,
            @RequestParam("description") String description,
            @RequestParam("attributes") String attributesJson,
            @RequestParam("infoImage") MultipartFile infoImage,
            @RequestParam(value = "productImages", required = false) List<MultipartFile> productImages,
            HttpSession session
    ) {
        try {
            Object userIdAttr = session.getAttribute("userId");
            if (userIdAttr == null) {
                return ResponseEntity.status(401).body("Unauthorized");
            }
            Long userId = Long.valueOf(userIdAttr.toString());

            User seller = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

            if (infoImage.isEmpty()) {
                return ResponseEntity.badRequest().body("Info image is required");
            }

            // Upload info image to S3
            String infoImageUrl = s3Service.uploadProductImage(infoImage, "info-" + name, userId);

            // Upload product images to S3
            List<String> uploadedImageUrls = new ArrayList<>();
            if (productImages != null && !productImages.isEmpty()) {
                for (MultipartFile file : productImages) {
                    if (!file.isEmpty()) {
                        String url = s3Service.uploadProductImage(file, "product-" + name, userId);
                        uploadedImageUrls.add(url);
                    }
                }
            }

            SellerProduct product = new SellerProduct();
            product.setName(name);
            product.setCategory(category);
            product.setSubCategory(subCategory);
            product.setPrice(Integer.parseInt(priceStr));
            product.setStock(Integer.parseInt(stockStr));
            product.setDiscount(Integer.parseInt(discountStr));
            product.setDescription(description);
            product.setAttributesJson(attributesJson);
            product.setInfoImageUrl(infoImageUrl);

            ObjectMapper mapper = new ObjectMapper();
            product.setImageUrlsJson(mapper.writeValueAsString(uploadedImageUrls));

            product.setActive(true);
            product.setSold(0);
            product.setSku("SP" + System.currentTimeMillis());

            product.setSeller(seller);

            sellerProductRepository.save(product);

            return ResponseEntity.ok("Product created successfully.");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    // --- Update Product Endpoint ---
    @PostMapping("/api/products/update")
    public ResponseEntity<?> updateProduct(
            @RequestParam("id") Long productId,
            @RequestParam("name") String name,
            @RequestParam("category") String category,
            @RequestParam("subCategory") String subCategory,
            @RequestParam("price") String priceStr,
            @RequestParam("stock") String stockStr,
            @RequestParam("discount") String discountStr,
            @RequestParam("description") String description,
            @RequestParam("attributes") String attributesJson,
            // FIXED: receive the "Listed as active" checkbox from the edit form
            @RequestParam(value = "active", required = false) String activeStr,
            @RequestParam(value = "infoImage", required = false) MultipartFile infoImage,
            @RequestParam(value = "productImages", required = false) List<MultipartFile> productImages,
            @RequestParam(value = "deleteImages", required = false) List<String> deleteImages,
            HttpSession session
    ) {
        try {
            Object userIdAttr = session.getAttribute("userId");
            if (userIdAttr == null) {
                return ResponseEntity.status(401).body("Unauthorized");
            }
            Long userId = Long.valueOf(userIdAttr.toString());

            User seller = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

            SellerProduct product = sellerProductRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found"));

            // Security check: Ensure user owns this product
            if (product.getSeller() != null && !product.getSeller().getId().equals(userId)) {
                return ResponseEntity.status(403).body("Unauthorized access to product");
            }

            // Update fields
            product.setName(name);
            product.setCategory(category);
            product.setSubCategory(subCategory);
            product.setPrice(Integer.parseInt(priceStr));
            product.setStock(Integer.parseInt(stockStr));
            product.setDiscount(Integer.parseInt(discountStr));
            product.setDescription(description);
            product.setAttributesJson(attributesJson);

            // FIXED: persist the "Listed as active" checkbox to the database
            if (activeStr != null) {
                product.setActive(Boolean.parseBoolean(activeStr));
            }

            // Handle info image update
            if (infoImage != null && !infoImage.isEmpty()) {
                // Delete old info image from S3 if it exists
                if (product.getInfoImageUrl() != null && !product.getInfoImageUrl().isEmpty()) {
                    String oldPath = product.getInfoImageUrl().replace(S3_BUCKET_URL, "");
                    s3Service.deleteFile(oldPath);
                }
                // Upload new info image
                String newInfoImageUrl = s3Service.uploadProductImage(infoImage, "info-" + name, userId);
                product.setInfoImageUrl(newInfoImageUrl);
            }

            // Handle product images update
            if (productImages != null && !productImages.isEmpty()) {
                // Get existing images
                List<String> existingImageUrls = new ArrayList<>();
                if (product.getImageUrlsJson() != null && !product.getImageUrlsJson().isEmpty()) {
                    try {
                        ObjectMapper mapper = new ObjectMapper();
                        existingImageUrls = mapper.readValue(product.getImageUrlsJson(), List.class);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }

                // Remove deleted images
                if (deleteImages != null && !deleteImages.isEmpty()) {
                    existingImageUrls.removeAll(deleteImages);
                    // Delete from S3
                    for (String url : deleteImages) {
                        String path = url.replace(S3_BUCKET_URL, "");
                        s3Service.deleteFile(path);
                    }
                }

                // Upload new images
                for (MultipartFile file : productImages) {
                    if (!file.isEmpty()) {
                        String url = s3Service.uploadProductImage(file, "product-" + name, userId);
                        existingImageUrls.add(url);
                    }
                }

                // Save updated image list
                ObjectMapper mapper = new ObjectMapper();
                product.setImageUrlsJson(mapper.writeValueAsString(existingImageUrls));
            }

            sellerProductRepository.save(product);

            return ResponseEntity.ok("Product updated successfully.");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    // --- NEW: Toggle Active/Inactive (pill button in the products table) ---
    @PostMapping("/api/products/toggleActive")
    public ResponseEntity<?> toggleActive(
            @RequestParam("id") Long productId,
            @RequestParam("active") boolean active,
            HttpSession session
    ) {
        try {
            Object userIdAttr = session.getAttribute("userId");
            if (userIdAttr == null) {
                return ResponseEntity.status(401).body("Unauthorized");
            }
            Long userId = Long.valueOf(userIdAttr.toString());

            SellerProduct product = sellerProductRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found"));

            // Security check: Ensure user owns this product
            if (product.getSeller() != null && !product.getSeller().getId().equals(userId)) {
                return ResponseEntity.status(403).body("Unauthorized access to product");
            }

            product.setActive(active);
            sellerProductRepository.save(product);

            return ResponseEntity.ok("ok");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }

    // --- Delete Product Endpoint ---
    @PostMapping("/api/products/delete")
    public ResponseEntity<?> deleteProduct(
            @RequestParam("id") Long productId,
            HttpSession session
    ) {
        try {
            Object userIdAttr = session.getAttribute("userId");
            if (userIdAttr == null) {
                return ResponseEntity.status(401).body("Unauthorized");
            }
            Long userId = Long.valueOf(userIdAttr.toString());

            User seller = userRepository.findById(userId)
                    .orElseThrow(() -> new RuntimeException("User not found with ID: " + userId));

            SellerProduct product = sellerProductRepository.findById(productId)
                    .orElseThrow(() -> new RuntimeException("Product not found"));

            // Security check: Ensure user owns this product
            if (product.getSeller() != null && !product.getSeller().getId().equals(userId)) {
                return ResponseEntity.status(403).body("Unauthorized access to product");
            }

            // Delete images from S3
            if (product.getInfoImageUrl() != null && !product.getInfoImageUrl().isEmpty()) {
                String path = product.getInfoImageUrl().replace(S3_BUCKET_URL, "");
                s3Service.deleteFile(path);
            }

            if (product.getImageUrlsJson() != null && !product.getImageUrlsJson().isEmpty()) {
                try {
                    ObjectMapper mapper = new ObjectMapper();
                    List<String> urls = mapper.readValue(product.getImageUrlsJson(), List.class);
                    for (String url : urls) {
                        String path = url.replace(S3_BUCKET_URL, "");
                        s3Service.deleteFile(path);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }

            // Delete product from database
            sellerProductRepository.delete(product);

            return ResponseEntity.ok("Product deleted successfully.");

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error: " + e.getMessage());
        }
    }
}