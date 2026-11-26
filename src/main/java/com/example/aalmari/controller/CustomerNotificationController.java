package com.example.aalmari.controller;

import com.example.aalmari.service.CustomerNotificationService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/customer-notifications")
public class CustomerNotificationController {
    private final CustomerNotificationService notificationService;

    public CustomerNotificationController(CustomerNotificationService notificationService) {
        this.notificationService = notificationService;
    }

    @GetMapping
    public ResponseEntity<?> feed(HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return ResponseEntity.status(401).body("Please sign in to view notifications.");
        return ResponseEntity.ok(notificationService.feed(userId, "CUSTOMER"));
    }

    @PostMapping("/{notificationId}/read")
    public ResponseEntity<?> markRead(@PathVariable Long notificationId, HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return ResponseEntity.status(401).body("Please sign in to view notifications.");
        if (!notificationService.markRead(userId, "CUSTOMER", notificationId)) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/read-all")
    public ResponseEntity<?> markAllRead(HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return ResponseEntity.status(401).body("Please sign in to view notifications.");
        notificationService.markAllRead(userId, "CUSTOMER");
        return ResponseEntity.noContent().build();
    }

    private Long currentUserId(HttpSession session) {
        Object value = session.getAttribute("userId");
        return value instanceof Number number ? number.longValue() : null;
    }
}
