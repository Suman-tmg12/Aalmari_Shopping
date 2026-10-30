package com.example.aalmari.controller;

import com.example.aalmari.model.SellerDocumentation;
import com.example.aalmari.repository.SellerDocumentationRepository;
import com.example.aalmari.repository.SellerProductRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.Optional;

@Controller
public class MyStoreController {

    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";

    private final SellerDocumentationRepository storeRepository;
    private final SellerProductRepository productRepository;

    public MyStoreController(SellerDocumentationRepository storeRepository,
                             SellerProductRepository productRepository) {
        this.storeRepository = storeRepository;
        this.productRepository = productRepository;
    }

    // Existing page (placeholder/demo content), unchanged behaviour
    @GetMapping("/mystore")
    public String showMyStore() {
        return "mystore";
    }

    // Public store page for a specific seller (opened from "Go to Store")
    @GetMapping("/store/{sellerId}")
    public String showStore(@PathVariable Long sellerId, Model model) {
        Optional<SellerDocumentation> storeOpt = storeRepository.findByUserId(sellerId);
        if (storeOpt.isEmpty()) {
            return "redirect:/";
        }
        SellerDocumentation store = storeOpt.get();

        // Optional: only show approved stores publicly (adjust the status value to yours)
        // if (!"approved".equalsIgnoreCase(store.getStatus())) return "redirect:/";

        model.addAttribute("store", store);
        model.addAttribute("logoUrl", toUrl(store.getStoreLogoPath()));
        model.addAttribute("bannerUrl", toUrl(store.getStoreBannerPath()));
        // mystore.jsp reads this attribute name
        model.addAttribute("sellerProducts",
                productRepository.findBySeller_IdAndActiveTrue(sellerId));

        return "mystore";
    }

    private String toUrl(String path) {
        if (path == null || path.isEmpty()) return null;
        return path.startsWith("http") ? path : S3_BUCKET_URL + path;
    }
}