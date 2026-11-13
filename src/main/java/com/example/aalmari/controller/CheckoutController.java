package com.example.aalmari.controller;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.dto.CheckoutForm;
import com.example.aalmari.model.Order;
import com.example.aalmari.service.CartService;
import com.example.aalmari.service.OrderService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

/** cart.jsp -> GET /checkout -> POST /checkout/place -> GET /checkout/success */
@Controller
public class CheckoutController {

    private final CartService cartService;
    private final OrderService orderService;

    public CheckoutController(CartService cartService, OrderService orderService) {
        this.cartService = cartService;
        this.orderService = orderService;
    }

    private Long currentUserId(HttpSession session) {
        Object v = session.getAttribute("userId");
        return (v instanceof Number n) ? n.longValue() : null;
    }

    /** "Go to Checkout" button on cart.jsp */
    @GetMapping("/checkout")
    public String showCheckout(HttpSession session, Model model) {
        Long userId = currentUserId(session);
        if (userId == null) return "redirect:/login";

        CartView cart = cartService.view(userId);
        if (cart.getItems().isEmpty()) return "redirect:/cart";

        model.addAttribute("cartItems", cart.getItems());
        model.addAttribute("subtotal", cart.getSubtotal());
        model.addAttribute("discountPercent", cart.getDiscountPercent());
        model.addAttribute("discountAmount", cart.getDiscountAmount());
        model.addAttribute("deliveryFee", cart.getDeliveryFee());
        model.addAttribute("total", cart.getTotal());
        model.addAttribute("prefill", orderService.checkoutPrefill(userId));
        return "checkout";
    }

    /** "Place order" button */
    @PostMapping("/checkout/place")
    public String place(@ModelAttribute CheckoutForm form,
                        HttpSession session,
                        RedirectAttributes redirect) {
        Long userId = currentUserId(session);
        if (userId == null) return "redirect:/login";

        String error = validate(form);
        if (error != null) {
            redirect.addFlashAttribute("checkoutError", error);
            return "redirect:/checkout";
        }

        // Only cash on delivery is built so far. eSewa, Khalti and card come next.
        if (!"COD".equals(form.getPaymentMethod())) {
            redirect.addFlashAttribute("checkoutError",
                    "Online payment is not available yet. Please choose Cash on delivery.");
            return "redirect:/checkout";
        }

        try {
            Order order = orderService.placeCodOrder(userId, form);
            return "redirect:/checkout/success?orderId=" + order.getId();
        } catch (IllegalStateException e) {
            redirect.addFlashAttribute("checkoutError", e.getMessage());
            return "redirect:/checkout";
        }
    }

    /** Order placed page */
    @GetMapping("/checkout/success")
    public String success(@RequestParam Long orderId, HttpSession session, Model model) {
        Long userId = currentUserId(session);
        if (userId == null) return "redirect:/login";

        Order order = orderService.findByIdAndUser(orderId, userId);
        if (order == null) return "redirect:/cart";

        model.addAttribute("order", order);
        return "order-success";
    }

    private String validate(CheckoutForm f) {
        if (blank(f.getFullName()) || blank(f.getProvince()) || blank(f.getCity()) || blank(f.getAddress())) {
            return "Fill in all the delivery address fields.";
        }
        if (f.getPhone() == null || !f.getPhone().trim().matches("9[678][0-9]{8}")) {
            return "Enter a valid 10-digit mobile number.";
        }
        String pm = f.getPaymentMethod();
        if (!("COD".equals(pm) || "ESEWA".equals(pm) || "KHALTI".equals(pm) || "CARD".equals(pm))) {
            return "Choose a payment method.";
        }
        return null;
    }

    private boolean blank(String s) { return s == null || s.trim().isEmpty(); }
}