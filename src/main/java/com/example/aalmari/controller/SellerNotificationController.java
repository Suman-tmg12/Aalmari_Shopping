package com.example.aalmari.controller;

import com.example.aalmari.service.CustomerNotificationService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/seller-notifications")
public class SellerNotificationController {
    private final CustomerNotificationService notificationService;

    public SellerNotificationController(CustomerNotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public ResponseEntity<?> feed(HttpSession session) {
        Long sellerId = currentSellerId(session);
        if (sellerId == null) return ResponseEntity.status(401).body("Please sign in as a seller.");
        return ResponseEntity.ok(notificationService.feed(sellerId, "SELLER"));
    }

    @PostMapping("/{notificationId}/read")
    public ResponseEntity<?> markRead(@PathVariable Long notificationId, HttpSession session) {
        Long sellerId = currentSellerId(session);
        if (sellerId == null) return ResponseEntity.status(401).body("Please sign in as a seller.");
        if (!notificationService.markRead(sellerId, "SELLER", notificationId)) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/read-all")
    public ResponseEntity<?> markAllRead(HttpSession session) {
        Long sellerId = currentSellerId(session);
        if (sellerId == null) return ResponseEntity.status(401).body("Please sign in as a seller.");
        notificationService.markAllRead(sellerId, "SELLER");
        return ResponseEntity.noContent().build();
    }

    private Long currentSellerId(HttpSession session) {
        Object value = session.getAttribute("userId");
        return value instanceof Number number ? number.longValue() : null;
    }
}
