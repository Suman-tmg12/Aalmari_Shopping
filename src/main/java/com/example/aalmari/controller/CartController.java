package com.example.aalmari.controller;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.service.CartService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class CartController {

    private final CartService cartService;

    public CartController(CartService cartService) {
        this.cartService = cartService;
    }

    private Long currentUserId(HttpSession session) {
        Object v = session.getAttribute("userId");
        return (v instanceof Number n) ? n.longValue() : null;
    }

    @GetMapping("/cart")
    public String showCart(HttpSession session, Model model) {
        Long userId = currentUserId(session);
        if (userId == null) return "redirect:/login";

        CartView cart = cartService.view(userId);
        model.addAttribute("cartItems", cart.getItems());
        model.addAttribute("subtotal", cart.getSubtotal());
        model.addAttribute("discountPercent", cart.getDiscountPercent());
        model.addAttribute("discountAmount", cart.getDiscountAmount());
        model.addAttribute("deliveryFee", cart.getDeliveryFee());
        model.addAttribute("total", cart.getTotal());
        return "cart";
    }

    @PostMapping("/cart/update")
    public String update(@RequestParam Long itemId,
                         @RequestParam String action,
                         HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return "redirect:/login";
        cartService.changeQuantity(userId, itemId, "increase".equals(action));
        return "redirect:/cart";
    }

    @PostMapping("/cart/remove")
    public String remove(@RequestParam Long itemId, HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return "redirect:/login";
        cartService.remove(userId, itemId);
        return "redirect:/cart";
    }
}