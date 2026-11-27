package com.example.aalmari.controller;

import com.example.aalmari.dto.OrderCard;
import com.example.aalmari.dto.WishlistCard;
import com.example.aalmari.model.User;
import com.example.aalmari.service.OrderService;
import com.example.aalmari.service.UserService;
import com.example.aalmari.service.WishlistService;
import com.example.aalmari.service.impl.S3Service;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@Controller
public class MyProfileController {

    @Autowired
    private UserService userService;

    @Autowired
    private S3Service s3Service;

    @Autowired
    private WishlistService wishlistService;

    @Autowired
    private OrderService orderService;

    @GetMapping("/myprofile")
    public String showMyProfile(HttpSession session, Model model,
                                @RequestParam(name = "wishlistPage", defaultValue = "1") int wishlistPage,
                                @RequestParam(name = "orderPage", defaultValue = "1") int orderPage,
                                @RequestParam(name = "orderStatus", defaultValue = "all") String orderStatus,
                                @RequestParam(name = "size", defaultValue = "12") int size) {
        Object sessionUserId = session.getAttribute("userId");
        Long userId = sessionUserId instanceof Number n ? n.longValue() : null;
        if (userId == null) {
            return "redirect:/login";
        }

        // Safe defaults so the page shows 0 and empty lists instead of blanks
        model.addAttribute("orders", List.of());
        model.addAttribute("recentOrders", List.of());
        model.addAttribute("orderCount", 0);
        model.addAttribute("activeOrderCount", 0);
        model.addAttribute("wishlistItems", List.of());
        model.addAttribute("wishlistCount", 0);
        model.addAttribute("wishlistSaleCount", 0);

        if (userId != null) {
            userService.findById(userId).ifPresent(user -> {
                String path = user.getProfilePicPath();
                if (path != null && !path.isEmpty()) {
                    model.addAttribute("profilePicUrl", s3Service.generateProfilePicUrl(path));
                }
            });

            int pageSize = Math.max(6, Math.min(48, size));

            var wishlistItemsPage = wishlistService.pageItems(
                    userId,
                    PageRequest.of(Math.max(1, wishlistPage) - 1, pageSize, Sort.by(Sort.Order.desc("id"))));
            int wishlistTotalPages = wishlistItemsPage.getTotalPages();
            int wishlistCurrentPage = wishlistTotalPages == 0 ? 1
                    : Math.min(Math.max(1, wishlistPage), wishlistTotalPages);
            if (wishlistCurrentPage != Math.max(1, wishlistPage) && wishlistTotalPages > 0) {
                wishlistItemsPage = wishlistService.pageItems(
                        userId,
                        PageRequest.of(wishlistCurrentPage - 1, pageSize, Sort.by(Sort.Order.desc("id"))));
            }

            List<WishlistCard> wishlist = wishlistService.cards(wishlistItemsPage.getContent());
            model.addAttribute("wishlistItems", wishlist);
            model.addAttribute("wishlistCount", wishlistService.count(userId));
            model.addAttribute("wishlistSaleCount", wishlist.stream().filter(WishlistCard::isOnSale).count());
            model.addAttribute("wishlistCurrentPage", wishlistCurrentPage);
            model.addAttribute("wishlistTotalPages", wishlistItemsPage.getTotalPages());

            Page<OrderCard> ordersPage = orderService.listForUser(
                    userId, orderStatus,
                    PageRequest.of(Math.max(1, orderPage) - 1, pageSize, Sort.by(Sort.Order.desc("id"))));
            int orderTotalPages = ordersPage.getTotalPages();
            int orderCurrentPage = orderTotalPages == 0 ? 1
                    : Math.min(Math.max(1, orderPage), orderTotalPages);
            if (orderCurrentPage != Math.max(1, orderPage) && orderTotalPages > 0) {
                ordersPage = orderService.listForUser(
                        userId,
                        orderStatus,
                        PageRequest.of(orderCurrentPage - 1, pageSize, Sort.by(Sort.Order.desc("id"))));
            }

            List<OrderCard> orders = ordersPage.getContent();
            long active = orders.stream()
                    .filter(o -> "processing".equals(o.getStatusGroup()) || "shipped".equals(o.getStatusGroup()))
                    .count();

            model.addAttribute("orders", orders);
            model.addAttribute("recentOrders", orders.stream().limit(3).toList());
            model.addAttribute("orderCount", ordersPage.getTotalElements());
            model.addAttribute("activeOrderCount", active);
            model.addAttribute("orderCurrentPage", orderCurrentPage);
            model.addAttribute("orderTotalPages", ordersPage.getTotalPages());
            model.addAttribute("profilePageSize", pageSize);
        }

        return "myprofile";
    }

    @PostMapping("/myprofile/update")
    public String updateProfile(@RequestParam("firstName") String firstName,
                                @RequestParam("lastName") String lastName,
                                @RequestParam("phone") String phone,
                                @RequestParam(value = "profilePic", required = false) MultipartFile profilePic,
                                HttpSession session) {

        Object sessionUserId = session.getAttribute("userId");
        Long userId = sessionUserId instanceof Number n ? n.longValue() : null;
        if (userId == null) {
            return "redirect:/login";
        }

        User updated = userService.updateProfile(userId, firstName, lastName, phone, profilePic);

        // Keep session text fields in sync so the header and sidebar update immediately
        session.setAttribute("userFirstName", updated.getFirstName());
        session.setAttribute("userLastName", updated.getLastName());
        session.setAttribute("userPhone", updated.getPhone());
        session.setAttribute("userProfilePicPath",
                updated.getProfilePicPath() == null ? "" : updated.getProfilePicPath());

        return "redirect:/myprofile?saved=true";
    }

    @PostMapping("/myprofile/remove-avatar")
    public String removeProfilePic(HttpSession session) {
        Object sessionUserId = session.getAttribute("userId");
        Long userId = sessionUserId instanceof Number n ? n.longValue() : null;
        if (userId == null) return "redirect:/login";

        userService.removeProfilePic(userId);
        session.setAttribute("userProfilePicPath", "");
        return "redirect:/myprofile?tab=settings&avatar=removed";
    }

    @PostMapping("/myprofile/password")
    @ResponseBody
    public ResponseEntity<Map<String, String>> changePassword(
            @RequestParam(required = false) String currentPassword,
            @RequestParam(required = false) String newPassword,
            HttpSession session) {
        Object sessionUserId = session.getAttribute("userId");
        Long userId = sessionUserId instanceof Number n ? n.longValue() : null;
        if (userId == null) {
            return ResponseEntity.status(401).body(Map.of("message", "Please sign in again."));
        }
        if (currentPassword == null || currentPassword.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "Enter your current password."));
        }
        if (newPassword == null || newPassword.length() < 8) {
            return ResponseEntity.badRequest().body(Map.of("message", "New password must be at least 8 characters."));
        }
        if (currentPassword.equals(newPassword)) {
            return ResponseEntity.badRequest().body(Map.of("message", "Choose a password you have not used for this account."));
        }

        try {
            if (!userService.changePassword(userId, currentPassword, newPassword)) {
                return ResponseEntity.badRequest().body(Map.of("message", "Current password is incorrect."));
            }
            return ResponseEntity.ok(Map.of("message", "Password updated successfully."));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(Map.of("message", e.getMessage()));
        }
    }
}