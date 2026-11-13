package com.example.aalmari.service;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.dto.CheckoutForm;
import com.example.aalmari.dto.OrderCard;
import com.example.aalmari.dto.OrderLineCard;
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

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

@Service
public class OrderService {

    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";
    private static final String PLACEHOLDER_IMG = "/placeholder.jpg";
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("MMM d, yyyy", Locale.ENGLISH);

    /** Label, pill colour and filter group for one stored status. */
    private record StatusInfo(String label, String pillClass, String group) {}

    private final OrderRepository orderRepository;
    private final CartService cartService;
    private final CartItemRepository cartItemRepository;
    private final SellerProductRepository productRepository;
    private final UserRepository userRepository;
    private final FlashSaleService flashSaleService;

    public OrderService(OrderRepository orderRepository,
                        CartService cartService,
                        CartItemRepository cartItemRepository,
                        SellerProductRepository productRepository,
                        UserRepository userRepository,
                        FlashSaleService flashSaleService) {
        this.orderRepository = orderRepository;
        this.cartService = cartService;
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
        this.flashSaleService = flashSaleService;
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
     * Cash on delivery: claims flash units, takes stock, creates the order and empties the cart,
     * all in one transaction. Any exception rolls back everything.
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

            // Claims flash units and enforces the per-customer limit; throws if the deal sold out.
            long unitPrice = line.getUnitPrice();
            Optional<Integer> flashPrice =
                    flashSaleService.claim(userId, line.getProductId(), line.getQuantity());
            if (flashPrice.isPresent() && flashPrice.get() != unitPrice) {
                throw new IllegalStateException(
                        "The price of " + line.getName() + " has changed. Please review your cart.");
            }

            p.setStock(stock - line.getQuantity());
            p.setSold((p.getSold() == null ? 0 : p.getSold()) + line.getQuantity());
            productRepository.save(p);

            OrderItem item = new OrderItem();
            item.setProductId(line.getProductId());
            item.setName(line.getName());
            item.setImageUrl(line.getImageUrl());
            item.setUnitPrice(unitPrice);
            item.setOriginalPrice(line.getOriginalPrice());
            item.setQuantity(line.getQuantity());
            item.setLineTotal(unitPrice * line.getQuantity());
            order.addItem(item);
        }

        orderRepository.save(order);                                    // assigns the id
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

    /** The user's orders, newest first, ready for the My Profile page. */
    @Transactional(readOnly = true)
    public List<OrderCard> listForUser(Long userId) {
        List<OrderCard> out = new ArrayList<>();
        for (Order o : orderRepository.findByUser_IdOrderByIdDesc(userId)) {
            out.add(toCard(o));
        }
        return out;
    }

    private OrderCard toCard(Order o) {
        StatusInfo st = statusInfo(o.getStatus());

        List<OrderLineCard> lines = new ArrayList<>();
        for (OrderItem i : o.getItems()) {
            lines.add(new OrderLineCard(
                    i.getName(),
                    imageSrc(i.getImageUrl()),
                    i.getQuantity(),
                    rs(i.getUnitPrice()),
                    rs(i.getLineTotal())));
        }

        String shipping = nz(o.getReceiverName()) + ", " + nz(o.getAddress()) + ", " + nz(o.getCity());
        if (!nz(o.getProvince()).isEmpty()) {
            shipping += ", " + o.getProvince();
        }

        String number = o.getOrderNumber() != null ? o.getOrderNumber() : "AAL-" + o.getId();

        return new OrderCard(
                number,
                st.label(),
                st.pillClass(),
                st.group(),
                o.getCreatedAt().format(DATE_FMT),
                rs(o.getTotal()),
                paymentLabel(o.getPaymentMethod()),
                shipping,
                lines.size(),
                lines);
    }

    /** PLACED shows as Processing; PENDING_PAYMENT as Awaiting payment, under the Processing tab. */
    private static StatusInfo statusInfo(String status) {
        if (status == null) return new StatusInfo("Processing", "pill-amber", "processing");
        return switch (status) {
            case "PENDING_PAYMENT" -> new StatusInfo("Awaiting payment", "pill-amber", "processing");
            case "SHIPPED"         -> new StatusInfo("Shipped", "pill-sky", "shipped");
            case "DELIVERED"       -> new StatusInfo("Delivered", "pill-green", "delivered");
            case "CANCELLED"       -> new StatusInfo("Cancelled", "pill-rose", "cancelled");
            default                -> new StatusInfo("Processing", "pill-amber", "processing");
        };
    }

    private static String paymentLabel(String method) {
        if (method == null) return "";
        return switch (method) {
            case "COD"    -> "Cash on delivery";
            case "ESEWA"  -> "eSewa";
            case "KHALTI" -> "Khalti";
            case "CARD"   -> "Card";
            default       -> method;
        };
    }

    /** Whole rupees, e.g. "Rs. 1,250". */
    private static String rs(long amount) {
        return String.format(Locale.US, "Rs. %,d", amount);
    }

    /** Cart stores either a full URL or a bare S3 key. */
    private static String imageSrc(String path) {
        if (path == null || path.isEmpty()) return PLACEHOLDER_IMG;
        return path.startsWith("http") ? path : S3_BUCKET_URL + path;
    }

    private static String nz(String s) { return s == null ? "" : s; }

    private static String blankToNull(String s) {
        return (s == null || s.trim().isEmpty()) ? null : s.trim();
    }
}