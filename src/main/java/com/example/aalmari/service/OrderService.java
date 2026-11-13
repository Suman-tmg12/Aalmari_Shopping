package com.example.aalmari.service;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.dto.CheckoutForm;
import com.example.aalmari.model.Order;
import com.example.aalmari.model.OrderItem;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.CartItemRepository;
import com.example.aalmari.repository.OrderRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.Map;

@Service
public class OrderService {

    private final OrderRepository orderRepository;
    private final CartService cartService;
    private final CartItemRepository cartItemRepository;
    private final SellerProductRepository productRepository;
    private final UserRepository userRepository;

    public OrderService(OrderRepository orderRepository,
                        CartService cartService,
                        CartItemRepository cartItemRepository,
                        SellerProductRepository productRepository,
                        UserRepository userRepository) {
        this.orderRepository = orderRepository;
        this.cartService = cartService;
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

    /** Name and phone to pre-fill the checkout form (keys: fullName, phone). */
    @Transactional(readOnly = true)
    public Map<String, String> checkoutPrefill(Long userId) {
        Map<String, String> m = new HashMap<>();
        userRepository.findById(userId).ifPresent(u -> {
            m.put("fullName", (nz(u.getFirstName()) + " " + nz(u.getLastName())).trim());
            String digits = nz(u.getPhone()).replaceAll("\\D", "");
            m.put("phone", digits.length() > 10 ? digits.substring(digits.length() - 10) : digits);
        });
        return m;
    }

    /**
     * Cash on delivery: creates the order, takes the stock, and empties the cart, all in one
     * transaction. Prices come from CartService.view(), which reads the live product rows and the
     * live flash sale, so nothing the browser sends can change the amount.
     *
     * Throws IllegalStateException with a message that is safe to show to the customer.
     */
    @Transactional
    public Order placeCodOrder(Long userId, CheckoutForm f) {
        CartView cart = cartService.view(userId);
        if (cart.getItems().isEmpty()) {
            throw new IllegalStateException("Your cart is empty.");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalStateException("Please log in again."));

        Order order = new Order();
        order.setUser(user);
        order.setStatus("PLACED");
        order.setPaymentMethod("COD");
        order.setPaymentStatus("UNPAID");
        order.setSubtotal(cart.getSubtotal());
        order.setDiscountAmount(cart.getDiscountAmount());
        order.setDeliveryFee(cart.getDeliveryFee());
        order.setTotal(cart.getTotal());
        order.setReceiverName(f.getFullName().trim());
        order.setReceiverPhone(f.getPhone().trim());
        order.setProvince(f.getProvince().trim());
        order.setCity(f.getCity().trim());
        order.setAddress(f.getAddress().trim());
        order.setLandmark(blankToNull(f.getLandmark()));
        order.setNote(blankToNull(f.getOrderNote()));

        for (CartView.Line line : cart.getItems()) {
            SellerProduct p = productRepository.findById(line.getProductId())
                    .filter(x -> Boolean.TRUE.equals(x.getActive()))
                    .orElseThrow(() -> new IllegalStateException(
                            line.getName() + " is no longer available. Remove it from your cart."));

            int stock = p.getStock() == null ? 0 : p.getStock();
            if (stock < line.getQuantity()) {
                throw new IllegalStateException(stock == 0
                        ? line.getName() + " is out of stock."
                        : "Only " + stock + " of " + line.getName() + " left in stock.");
            }
            p.setStock(stock - line.getQuantity());
            p.setSold((p.getSold() == null ? 0 : p.getSold()) + line.getQuantity());
            productRepository.save(p);

            OrderItem item = new OrderItem();
            item.setProductId(line.getProductId());
            item.setName(line.getName());
            item.setImageUrl(line.getImageUrl());
            item.setUnitPrice(line.getUnitPrice());
            item.setOriginalPrice(line.getOriginalPrice());
            item.setQuantity(line.getQuantity());
            item.setLineTotal(line.getLineTotal());
            order.addItem(item);

            // TODO (flash sale): if this line was bought at a flash price, save a FlashPurchase
            // and reduce the flash stock here. Needs FlashSaleService, see the notes.
        }

        orderRepository.save(order);                                   // gets the id
        order.setOrderNumber(String.format("AAL-%06d", order.getId())); // e.g. AAL-000042

        cartItemRepository.deleteAll(cartItemRepository.findByUser_IdOrderByIdDesc(userId));
        return order;
    }

    /** Returns the order only if it belongs to this user, with its items loaded. */
    @Transactional(readOnly = true)
    public Order findByIdAndUser(Long orderId, Long userId) {
        Order o = orderRepository.findByIdAndUser_Id(orderId, userId).orElse(null);
        if (o != null) {
            o.getItems().size(); // load the lazy list while the session is open
        }
        return o;
    }

    private static String nz(String s) { return s == null ? "" : s; }

    private static String blankToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
}