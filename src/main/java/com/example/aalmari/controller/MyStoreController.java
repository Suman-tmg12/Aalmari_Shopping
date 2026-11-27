package com.example.aalmari.controller;

import com.example.aalmari.model.SellerDocumentation;
import com.example.aalmari.model.StoreFollow;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.ProductReviewRepository;
import com.example.aalmari.repository.SellerDocumentationRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.StoreFollowRepository;
import com.example.aalmari.repository.UserRepository;
import jakarta.servlet.http.HttpSession;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;
import java.util.Optional;

@Controller
public class MyStoreController {

    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";

    private final SellerDocumentationRepository storeRepository;
    private final SellerProductRepository productRepository;
    private final StoreFollowRepository followRepository;
    private final UserRepository userRepository;
    private final ProductReviewRepository reviewRepository;

    public MyStoreController(SellerDocumentationRepository storeRepository,
                             SellerProductRepository productRepository,
                             StoreFollowRepository followRepository,
                             UserRepository userRepository,
                             ProductReviewRepository reviewRepository) {
        this.storeRepository = storeRepository;
        this.productRepository = productRepository;
        this.followRepository = followRepository;
        this.userRepository = userRepository;
        this.reviewRepository = reviewRepository;
    }

    @GetMapping("/mystore")
    public String showMyStore(HttpSession session, Model model) {
        Object id = session.getAttribute("userId");
        if (id instanceof Number number) {
            Optional<SellerDocumentation> ownStore = storeRepository.findByUserId(number.longValue());
            if (ownStore.isPresent()) {
                return "redirect:/store/" + number.longValue();
            }
        }
        model.addAttribute("sellerProducts", java.util.List.of());
        model.addAttribute("storeReviews", java.util.List.of());
        model.addAttribute("storeRating", 0.0);
        model.addAttribute("storeReviewCount", 0L);
        model.addAttribute("followerCount", 0L);
        model.addAttribute("isFollowing", false);
        model.addAttribute("currentPage", 1);
        model.addAttribute("totalPages", 0);
        model.addAttribute("totalProducts", 0L);
        model.addAttribute("pageSize", 12);
        model.addAttribute("sort", "best");
        return "mystore";
    }

    @GetMapping("/store/{sellerId}")
    public String showStore(@PathVariable Long sellerId,
                            @RequestParam(name = "page", defaultValue = "1") int page,
                            @RequestParam(name = "size", defaultValue = "12") int size,
                            @RequestParam(name = "sort", defaultValue = "best") String sort,
                            Model model, HttpSession session) {

        Optional<SellerDocumentation> storeOpt = storeRepository.findByUserId(sellerId);
        if (storeOpt.isEmpty()) return "redirect:/";

        SellerDocumentation store = storeOpt.get();
        if (!"approved".equalsIgnoreCase(store.getStatus())) {
            return "redirect:/";
        }

        long followerCount = followRepository.countBySeller_Id(sellerId);
        boolean isFollowing = false;
        Object viewer = session.getAttribute("userId");
        if (viewer instanceof Number number) {
            isFollowing = followRepository.findByFollower_IdAndSeller_Id(number.longValue(), sellerId).isPresent();
        }

        int requestedPage = Math.max(1, page);
        int pageSize = Math.max(6, Math.min(48, size));
        Sort sortSpec = switch (sort) {
            case "low-high" -> Sort.by(Sort.Order.asc("price"), Sort.Order.desc("id"));
            case "high-low" -> Sort.by(Sort.Order.desc("price"), Sort.Order.desc("id"));
            case "popular" -> Sort.by(Sort.Order.desc("sold"), Sort.Order.desc("id"));
            default -> Sort.by(Sort.Order.desc("id"));
        };
        Page<com.example.aalmari.model.SellerProduct> productsPage = productRepository.pageStoreProducts(
                sellerId, PageRequest.of(requestedPage - 1, pageSize, sortSpec));
        int totalPages = productsPage.getTotalPages();
        int currentPage = totalPages == 0 ? 1 : Math.min(requestedPage, totalPages);
        if (currentPage != requestedPage && totalPages > 0) {
            productsPage = productRepository.pageStoreProducts(
                    sellerId, PageRequest.of(currentPage - 1, pageSize, sortSpec));
        }

        model.addAttribute("store", store);
        model.addAttribute("logoUrl", toUrl(store.getStoreLogoPath()));
        model.addAttribute("bannerUrl", toUrl(store.getStoreBannerPath()));
        model.addAttribute("sellerProducts", productsPage.getContent());
        model.addAttribute("storeReviews", reviewRepository.findForSellerNewest(sellerId));
        model.addAttribute("storeRating", reviewRepository.averageForSeller(sellerId));
        model.addAttribute("storeReviewCount", reviewRepository.countForSeller(sellerId));
        model.addAttribute("followerCount", followerCount);
        model.addAttribute("isFollowing", isFollowing);
        model.addAttribute("sellerId", sellerId);
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", productsPage.getTotalPages());
        model.addAttribute("totalProducts", productsPage.getTotalElements());
        model.addAttribute("pageSize", pageSize);
        model.addAttribute("sort", sort);
        return "mystore";
    }

    @PostMapping("/api/store/{sellerId}/follow")
    public ResponseEntity<?> toggleFollow(@PathVariable Long sellerId, HttpSession session) {
        Object viewer = session.getAttribute("userId");
        if (!(viewer instanceof Number number)) {
            return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));
        }
        Long followerId = number.longValue();
        if (followerId.equals(sellerId)) {
            return ResponseEntity.badRequest().body(Map.of("error", "You cannot follow your own store."));
        }

        Optional<User> followerOpt = userRepository.findById(followerId);
        Optional<User> sellerOpt = userRepository.findById(sellerId);
        if (followerOpt.isEmpty() || sellerOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Store or account not found."));
        }

        Optional<StoreFollow> existing = followRepository.findByFollower_IdAndSeller_Id(followerId, sellerId);
        boolean following;
        if (existing.isPresent()) {
            followRepository.delete(existing.get());
            following = false;
        } else {
            StoreFollow follow = new StoreFollow();
            follow.setFollower(followerOpt.get());
            follow.setSeller(sellerOpt.get());
            followRepository.save(follow);
            following = true;
        }
        long followers = followRepository.countBySeller_Id(sellerId);
        return ResponseEntity.ok(Map.of("following", following, "followers", followers));
    }

    private String toUrl(String path) {
        if (path == null || path.isEmpty()) return null;
        return path.startsWith("http") ? path : S3_BUCKET_URL + path;
    }
}