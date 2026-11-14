package com.example.aalmari.controller;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.dto.CheckoutForm;
import com.example.aalmari.model.Order;
import com.example.aalmari.service.AddressService;
import com.example.aalmari.service.CartService;
import com.example.aalmari.service.OrderService;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.Map;

/** cart.jsp -> GET /checkout -> POST /checkout/place -> GET /checkout/success */
@Controller
public class CheckoutController {

    private final CartService cartService;
    private final OrderService orderService;
    private final AddressService addressService;

    public CheckoutController(CartService cartService,
                              OrderService orderService,
                              AddressService addressService) {
        this.cartService = cartService;
        this.orderService = orderService;
        this.addressService = addressService;
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
        // saved addresses as JSON for checkout.jsp ("<" escaped so it is safe inside <script>)
        model.addAttribute("addressesJson", addressService.listJson(userId).replace("<", "\\u003c"));
        return "checkout";
    }

    /* ====================================================================== */
    /*  Address book (called with fetch() from checkout.jsp)                  */
    /* ====================================================================== */

    @PostMapping("/checkout/address/save")
    @ResponseBody
    public ResponseEntity<?> saveAddress(@RequestParam(value = "id", required = false) Long id,
                                         @RequestParam("label") String label,
                                         @RequestParam("fullName") String fullName,
                                         @RequestParam("phone") String phone,
                                         @RequestParam("province") String province,
                                         @RequestParam("city") String city,
                                         @RequestParam("address") String address,
                                         @RequestParam(value = "landmark", required = false) String landmark,
                                         @RequestParam(value = "makeDefault", defaultValue = "false") boolean makeDefault,
                                         HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return ResponseEntity.status(401).body("Please log in again.");
        try {
            Long savedId = addressService.save(userId, id, label, fullName, phone,
                    province, city, address, landmark, makeDefault);
            return ResponseEntity.ok(Map.of("id", savedId, "addresses", addressService.list(userId)));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Could not save the address. Please try again.");
        }
    }

    @PostMapping("/checkout/address/delete")
    @ResponseBody
    public ResponseEntity<?> deleteAddress(@RequestParam("id") Long id, HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return ResponseEntity.status(401).body("Please log in again.");
        try {
            addressService.delete(userId, id);
            return ResponseEntity.ok(Map.of("addresses", addressService.list(userId)));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Could not delete the address. Please try again.");
        }
    }

    @PostMapping("/checkout/address/default")
    @ResponseBody
    public ResponseEntity<?> defaultAddress(@RequestParam("id") Long id, HttpSession session) {
        Long userId = currentUserId(session);
        if (userId == null) return ResponseEntity.status(401).body("Please log in again.");
        try {
            addressService.setDefault(userId, id);
            return ResponseEntity.ok(Map.of("addresses", addressService.list(userId)));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Could not update the address. Please try again.");
        }
    }

    /* ====================================================================== */
    /*  Place order                                                           */
    /* ====================================================================== */

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
        if (f.getAddressId() == null) {
            return "Choose a delivery address.";
        }
        String pm = f.getPaymentMethod();
        if (!("COD".equals(pm) || "ESEWA".equals(pm) || "KHALTI".equals(pm) || "CARD".equals(pm))) {
            return "Choose a payment method.";
        }
        return null;
    }
}