package com.example.aalmari.controller;

import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.repository.SellerProductRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;

@Controller
public class ProductController {

    private final SellerProductRepository sellerProductRepository;
    private final ObjectMapper objectMapper;
    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";
    private static final int SIMILAR_LIMIT = 40;

    public ProductController(SellerProductRepository sellerProductRepository) {
        this.sellerProductRepository = sellerProductRepository;
        this.objectMapper = new ObjectMapper();
    }

    @GetMapping("/product/{id}")
    public String showProductDetail(@PathVariable Long id, Model model) {
        Optional<SellerProduct> productOpt = sellerProductRepository.findById(id);

        if (!productOpt.isPresent()) {
            return "redirect:/";
        }

        SellerProduct product = productOpt.get();

        if (!product.getActive()) {
            return "redirect:/";
        }

        // 1. Parse Attributes (Specs)
        Map<String, String> specs = new LinkedHashMap<>();
        if (product.getAttributesJson() != null &&
                !product.getAttributesJson().isEmpty() &&
                !product.getAttributesJson().equals("{}")) {
            try {
                specs = objectMapper.readValue(product.getAttributesJson(),
                        new TypeReference<LinkedHashMap<String, String>>(){});
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 2. Parse Gallery Images - REPLICATING WORKING LOGIC
        List<String> galleryImages = new ArrayList<>();
        if (product.getImageUrlsJson() != null &&
                !product.getImageUrlsJson().isEmpty() &&
                !product.getImageUrlsJson().equals("[]")) {
            try {
                List<String> paths = objectMapper.readValue(product.getImageUrlsJson(),
                        new TypeReference<List<String>>(){});
                for (String path : paths) {
                    if (path != null && !path.isEmpty()) {
                        String fullUrl = path;
                        // ONLY add S3 base if it's NOT already a full URL
                        if (!path.startsWith("http")) {
                            fullUrl = S3_BUCKET_URL + path;
                        }
                        galleryImages.add(fullUrl);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        // 3. Handle Main Image - REPLICATING WORKING LOGIC EXACTLY
        String mainImage = null;

        String infoImageUrl = product.getInfoImageUrl();
        if (infoImageUrl != null && !infoImageUrl.isEmpty()) {
            mainImage = infoImageUrl;
            // ONLY add S3 base if it's NOT already a full URL
            if (!mainImage.startsWith("http")) {
                mainImage = S3_BUCKET_URL + mainImage;
            }
        }

        // Fallback to gallery if no main image
        if (mainImage == null && !galleryImages.isEmpty()) {
            mainImage = galleryImages.get(0);
        }

        // Final fallback
        if (mainImage == null) {
            mainImage = "${pageContext.request.contextPath}/placeholder.jpg";
            System.err.println("WARNING: No image found for product ID: " + id);
        }

        // 4. Calculate Price
        int price = product.getPrice();
        int discount = product.getDiscount();

        if (price <= 0) {
            price = 0;
        }

        int currentPrice = (int) (price * (100 - discount) / 100.0);
        if (currentPrice < 0) {
            currentPrice = 0;
        }

        String currentPriceStr = "Rs " + currentPrice;
        String originalPriceStr = "";
        String discountStr = "";

        if (discount > 0 && discount < 100) {
            originalPriceStr = "Rs " + price;
            discountStr = "-" + discount + "%";
        }

        // 5. Similar products ("You May Also Like")
        List<SellerProduct> similarProducts = findSimilarProducts(product);

        // 6. Add to model
        model.addAttribute("product", product);
        model.addAttribute("specs", specs);
        model.addAttribute("galleryImages", galleryImages);
        model.addAttribute("mainImage", mainImage);
        model.addAttribute("currentPrice", currentPriceStr);
        model.addAttribute("originalPrice", originalPriceStr);
        model.addAttribute("discount", discountStr);
        model.addAttribute("similarProducts", similarProducts);

        return "productDetail";
    }

    /**
     * Same sub-category first, then the rest from the same category.
     * Never includes the current product, never includes duplicates.
     */
    private List<SellerProduct> findSimilarProducts(SellerProduct current) {
        List<SellerProduct> result = new ArrayList<>();
        Set<Long> seen = new HashSet<>();
        seen.add(current.getId());

        String sub = current.getSubCategory();
        if (sub != null && !sub.trim().isEmpty()) {
            for (SellerProduct p : sellerProductRepository
                    .findTop40ByActiveTrueAndSubCategoryIgnoreCaseAndIdNotOrderBySoldDescIdDesc(
                            sub, current.getId())) {
                if (result.size() < SIMILAR_LIMIT && seen.add(p.getId())) {
                    result.add(p);
                }
            }
        }

        String cat = current.getCategory();
        if (result.size() < SIMILAR_LIMIT && cat != null && !cat.trim().isEmpty()) {
            for (SellerProduct p : sellerProductRepository
                    .findTop40ByActiveTrueAndCategoryIgnoreCaseAndIdNotOrderBySoldDescIdDesc(
                            cat, current.getId())) {
                if (result.size() < SIMILAR_LIMIT && seen.add(p.getId())) {
                    result.add(p);
                }
            }
        }

        return result;
    }
}