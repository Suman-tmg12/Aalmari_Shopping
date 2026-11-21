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
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;

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
        return "mystore";
    }

    @GetMapping("/store/{sellerId}")
    public String showStore(@PathVariable Long sellerId, Model model, HttpSession session) {
        Optional<SellerDocumentation> storeOpt = storeRepository.findByUserId(sellerId);
        if (storeOpt.isEmpty()) return "redirect:/";

        SellerDocumentation store = storeOpt.get();
        long followerCount = followRepository.countBySeller_Id(sellerId);
        boolean isFollowing = false;
        Object viewer = session.getAttribute("userId");
        if (viewer instanceof Number number) {
            isFollowing = followRepository.findByFollower_IdAndSeller_Id(number.longValue(), sellerId).isPresent();
        }

        model.addAttribute("store", store);
        model.addAttribute("logoUrl", toUrl(store.getStoreLogoPath()));
        model.addAttribute("bannerUrl", toUrl(store.getStoreBannerPath()));
        model.addAttribute("sellerProducts", productRepository.findBySeller_IdAndActiveTrue(sellerId));
        model.addAttribute("storeReviews", reviewRepository.findForSellerNewest(sellerId));
        model.addAttribute("storeRating", reviewRepository.averageForSeller(sellerId));
        model.addAttribute("storeReviewCount", reviewRepository.countForSeller(sellerId));
        model.addAttribute("followerCount", followerCount);
        model.addAttribute("isFollowing", isFollowing);
        model.addAttribute("sellerId", sellerId);
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