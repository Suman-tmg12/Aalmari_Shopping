package com.example.aalmari.controller;

import com.example.aalmari.service.WishlistService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/wishlist")
public class WishlistApiController {

    private final WishlistService wishlistService;

    public WishlistApiController(WishlistService wishlistService) {
        this.wishlistService = wishlistService;
    }

    /** The user always comes from the session, never from the request. */
    private Long currentUserId(HttpSession session) {
        Object v = session.getAttribute("userId");
        return (v instanceof Number n) ? n.longValue() : null;
    }

    private ResponseEntity<?> loginRequired() {
        return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));
    }

    /** Ids of every wishlisted product: the pages use this to fill the hearts. Guests get an empty list. */
    @GetMapping("/ids")
    public ResponseEntity<?> ids(HttpSession session) {
        Long userId = currentUserId(session);
        List<Long> ids = (userId == null) ? List.of() : wishlistService.productIds(userId);
        return ResponseEntity.ok(Map.of("ids", ids, "count", ids.size()));
    }

    /** Add (idempotent). */
    @PutMapping("/items/{productId}")
    public ResponseEntity<?> add(@PathVariable Long productId, HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return loginRequired();
        try {
            int count = wishlistService.add(userId, productId);
            return ResponseEntity.ok(Map.of("wished", true, "count", count));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    /** Remove (idempotent). */
    @DeleteMapping("/items/{productId}")
    public ResponseEntity<?> remove(@PathVariable Long productId, HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return loginRequired();
        int count = wishlistService.remove(userId, productId);
        return ResponseEntity.ok(Map.of("wished", false, "count", count));
    }
}