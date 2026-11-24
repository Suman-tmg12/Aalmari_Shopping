package com.example.aalmari.controller;

import com.example.aalmari.model.ProductReview;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.OrderItemRepository;
import com.example.aalmari.repository.ProductReviewRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.UserRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

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
    private final ProductReviewRepository reviewRepository;
    private final OrderItemRepository orderItemRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper;
    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";
    private static final int SIMILAR_LIMIT = 40;

    public ProductController(SellerProductRepository sellerProductRepository,
                              ProductReviewRepository reviewRepository,
                              OrderItemRepository orderItemRepository,
                              UserRepository userRepository) {
        this.sellerProductRepository = sellerProductRepository;
        this.reviewRepository = reviewRepository;
        this.orderItemRepository = orderItemRepository;
        this.userRepository = userRepository;
        this.objectMapper = new ObjectMapper();
    }

    @GetMapping("/product/{id}")
    public String showProductDetail(@PathVariable Long id, Model model, HttpSession session) {
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

        // 6. Review summary data
        List<ProductReview> reviews = reviewRepository.findForProductNewest(id);
        double averageRating = reviewRepository.averageForProduct(id);
        long reviewCount = reviewRepository.countByProduct_Id(id);

        // 7. Session eligibility and existing review
        boolean canReview = false;
        ProductReview existingReview = null;
        boolean isOwnProduct = false;
        Object userIdValue = session.getAttribute("userId");
        if (userIdValue instanceof Number number) {
            Long userId = number.longValue();
            isOwnProduct = product.getSeller() != null
                    && product.getSeller().getId() != null
                    && product.getSeller().getId().equals(userId);
            canReview = orderItemRepository.existsDeliveredPurchase(userId, id);
            existingReview = reviewRepository.findByUser_IdAndProduct_Id(userId, id).orElse(null);
        }

        // 8. Add to model
        model.addAttribute("product", product);
        model.addAttribute("specs", specs);
        model.addAttribute("galleryImages", galleryImages);
        model.addAttribute("mainImage", mainImage);
        model.addAttribute("currentPrice", currentPriceStr);
        model.addAttribute("originalPrice", originalPriceStr);
        model.addAttribute("discount", discountStr);
        model.addAttribute("similarProducts", similarProducts);
        model.addAttribute("reviews", reviews);
        model.addAttribute("reviewCount", reviewCount);
        model.addAttribute("averageRating", averageRating);
        model.addAttribute("canReview", canReview);
        model.addAttribute("existingReview", existingReview);
        model.addAttribute("isOwnProduct", isOwnProduct);

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

    public record ReviewRequest(Integer rating, String comment) {}

    @PostMapping("/api/products/{id}/reviews")
    public ResponseEntity<?> submitReview(@PathVariable Long id,
                                          @RequestBody ReviewRequest request,
                                          HttpSession session) {
        Object userIdValue = session.getAttribute("userId");
        if (!(userIdValue instanceof Number number)) {
            return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));
        }

        Optional<SellerProduct> productOpt = sellerProductRepository.findById(id);
        if (productOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Product not found."));
        }

        Long userId = number.longValue();
        if (!orderItemRepository.existsDeliveredPurchase(userId, id)) {
            return ResponseEntity.status(403).body(Map.of("error", "Only customers with a delivered purchase can review this product."));
        }

        int rating = request.rating() == null ? 0 : request.rating();
        if (rating < 1 || rating > 5) {
            return ResponseEntity.badRequest().body(Map.of("error", "Rating must be between 1 and 5."));
        }

        String comment = request.comment() == null ? "" : request.comment().trim();
        if (comment.length() > 1000) {
            return ResponseEntity.badRequest().body(Map.of("error", "Review is too long."));
        }

        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isEmpty()) {
            return ResponseEntity.status(401).body(Map.of("error", "Session user is invalid."));
        }

        ProductReview review = reviewRepository.findByUser_IdAndProduct_Id(userId, id).orElse(new ProductReview());
        review.setUser(userOpt.get());
        review.setProduct(productOpt.get());
        review.setRating(rating);
        review.setComment(comment);
        review.setVerifiedPurchase(true);
        review.setUpdatedAt(java.time.LocalDateTime.now());
        reviewRepository.save(review);

        double average = reviewRepository.averageForProduct(id);
        long count = reviewRepository.countByProduct_Id(id);
        return ResponseEntity.ok(Map.of(
                "success", true,
                "average", average,
                "count", count
        ));
    }
}