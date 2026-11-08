package com.example.aalmari.controller;

import com.example.aalmari.service.CartService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/cart")
public class CartApiController {

    public record AddRequest(Long productId, Integer quantity) {}

    private final CartService cartService;

    public CartApiController(CartService cartService) {
        this.cartService = cartService;
    }

    /** The user always comes from the session, never from the request body. */
    private Long currentUserId(HttpSession session) {
        Object v = session.getAttribute("userId");
        return (v instanceof Number n) ? n.longValue() : null;
    }

    @PostMapping("/items")
    public ResponseEntity<?> add(@RequestBody AddRequest req, HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Please log in first."));
        }
        if (req == null || req.productId() == null) {
            return ResponseEntity.badRequest().body(Map.of("error", "productId is required."));
        }
        try {
            int qty = (req.quantity() == null) ? 1 : req.quantity();
            int count = cartService.add(userId, req.productId(), qty);
            return ResponseEntity.ok(Map.of("count", count));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("error", e.getMessage()));
        }
    }

    @GetMapping("/count")
    public ResponseEntity<?> count(HttpSession session) {
        Long userId = currentUserId(session);
        int count = (userId == null) ? 0 : cartService.count(userId);
        return ResponseEntity.ok(Map.of("count", count));
    }
}