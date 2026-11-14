package com.example.aalmari.service;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.dto.CheckoutForm;
import com.example.aalmari.dto.OrderCard;
import com.example.aalmari.dto.OrderLineCard;
import com.example.aalmari.model.Address;
import com.example.aalmari.model.Order;
import com.example.aalmari.model.OrderItem;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.AddressRepository;
import com.example.aalmari.repository.CartItemRepository;
import com.example.aalmari.repository.OrderItemRepository;
import com.example.aalmari.repository.OrderRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import com.example.aalmari.dto.SellerFinance;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.Comparator;
import java.util.HashSet;
import java.util.Set;

@Service
public class OrderService {

    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";
    private static final String PLACEHOLDER_IMG = "/placeholder.jpg";
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("MMM d, yyyy", Locale.ENGLISH);
    /** Platform commission taken from every delivered line. */
    public static final double COMMISSION_RATE = 0.10;

    /** Label, pill colour and filter group for one stored status. */
    private record StatusInfo(String label, String pillClass, String group) {}

    /** One product line of an order, as the seller sees it (serialized to JSON). */
    public static class SellerLineRow {
        public String name;
        public String img;
        public int qty;
        public long unit;
        public long line;
    }

    /** One order as the seller sees it: only this seller's lines (serialized to JSON). */
    public static class SellerOrderRow {
        public String ref;
        public String date;
        public String cust;
        public String phone;
        public String address;
        public String note;
        public String payment;
        public String status;                    // pending, confirmed, shipped, delivered, cancelled
        public long total;                       // sum of this seller's lines only
        public List<SellerLineRow> items = new ArrayList<>();
    }

    private final OrderRepository orderRepository;
    private final OrderItemRepository orderItemRepository;
    private final CartService cartService;
    private final CartItemRepository cartItemRepository;
    private final SellerProductRepository productRepository;
    private final UserRepository userRepository;
    private final FlashSaleService flashSaleService;
    private final AddressRepository addressRepository;
    private final ObjectMapper mapper = new ObjectMapper();

    public OrderService(OrderRepository orderRepository,
                        OrderItemRepository orderItemRepository,
                        CartService cartService,
                        CartItemRepository cartItemRepository,
                        SellerProductRepository productRepository,
                        UserRepository userRepository,
                        FlashSaleService flashSaleService,
                        AddressRepository addressRepository) {
        this.orderRepository = orderRepository;
        this.orderItemRepository = orderItemRepository;
        this.cartService = cartService;
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
        this.flashSaleService = flashSaleService;
        this.addressRepository = addressRepository;
    }

    /** Name and phone to pre-fill the checkout address form (keys: fullName, phone). */
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

        // The chosen saved address must belong to this customer.
        if (f.getAddressId() == null) {
            throw new IllegalStateException("Please choose a delivery address.");
        }
        Address addr = addressRepository.findByIdAndUser_Id(f.getAddressId(), userId)
                .orElseThrow(() -> new IllegalStateException("Please choose a delivery address."));

        Order order = new Order();
        order.setUser(user);
        order.setStatus("PLACED");
        order.setPaymentMethod("COD");
        order.setPaymentStatus("UNPAID");
        order.setSubtotal(cart.getSubtotal());
        order.setDiscountAmount(cart.getDiscountAmount());
        order.setDeliveryFee(cart.getDeliveryFee());
        order.setTotal(cart.getTotal());

        // The order keeps its own copy, so editing or deleting the saved address never changes it.
        order.setReceiverName(addr.getReceiverName());
        order.setReceiverPhone(addr.getPhone());
        order.setProvince(addr.getProvince());
        order.setCity(addr.getCity());
        order.setAddress(addr.getStreet());
        order.setLandmark(blankToNull(addr.getLandmark()));
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
            item.setSeller(p.getSeller());                 // the seller who owns this product
            item.setStatus("PENDING");                     // each seller moves their own lines
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

    /* ====================================================================== */
    /*  Seller dashboard: orders that contain this seller's products          */
    /* ====================================================================== */

    /**
     * JSON read by SellerDashboard.js (#orderData). Newest order first. Each order lists
     * only the lines that belong to this seller, and its total covers only those lines.
     * The status is the status of this seller's lines.
     */
    @Transactional(readOnly = true)
    public String sellerOrdersJson(Long sellerId) {
        Map<Long, SellerOrderRow> byOrder = new LinkedHashMap<>();

        for (OrderItem i : orderItemRepository.findForSeller(sellerId)) {
            Order o = i.getOrder();
            SellerOrderRow row = byOrder.get(o.getId());

            if (row == null) {
                row = new SellerOrderRow();
                row.ref = o.getOrderNumber() != null ? o.getOrderNumber() : "AAL-" + o.getId();
                row.date = o.getCreatedAt().format(DATE_FMT);
                row.cust = nz(o.getReceiverName());
                row.phone = nz(o.getReceiverPhone());

                String addr = nz(o.getAddress()) + ", " + nz(o.getCity()) + ", " + nz(o.getProvince());
                if (!nz(o.getLandmark()).isEmpty()) {
                    addr += " (near " + o.getLandmark() + ")";
                }
                row.address = addr;
                row.note = nz(o.getNote());
                row.payment = paymentLabel(o.getPaymentMethod());
                row.status = i.getStatus().toLowerCase();   // pending, confirmed, shipped, delivered, cancelled
                byOrder.put(o.getId(), row);
            }

            SellerLineRow l = new SellerLineRow();
            l.name = i.getName();
            l.img = imageSrc(i.getImageUrl());
            l.qty = i.getQuantity();
            l.unit = i.getUnitPrice();
            l.line = i.getLineTotal();
            row.items.add(l);
            row.total += i.getLineTotal();
        }

        try {
            return mapper.writeValueAsString(byOrder.values());
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    /**
     * The seller moves all of their lines in one order.
     * action: confirm, ship, deliver, cancel.
     */
    @Transactional
    public void updateSellerOrderStatus(Long sellerId, String ref, String action) {
        List<OrderItem> items = orderItemRepository.findForSellerByRef(ref, sellerId);
        if (items.isEmpty()) {
            throw new SecurityException("Order not found.");
        }
        String current = items.get(0).getStatus();

        String target = switch (action == null ? "" : action) {
            case "confirm" -> "CONFIRMED";
            case "ship"    -> "SHIPPED";
            case "deliver" -> "DELIVERED";
            case "cancel"  -> "CANCELLED";
            default -> throw new IllegalArgumentException("Unknown action.");
        };

        boolean allowed = switch (target) {
            case "CONFIRMED" -> current.equals("PENDING");
            case "SHIPPED"   -> current.equals("CONFIRMED");
            case "DELIVERED" -> current.equals("SHIPPED");
            case "CANCELLED" -> current.equals("PENDING") || current.equals("CONFIRMED");
            default -> false;
        };
        if (!allowed) {
            throw new IllegalArgumentException("This order is " + current.toLowerCase()
                    + " and cannot be changed that way.");
        }

        for (OrderItem i : items) {
            i.setStatus(target);
            if (target.equals("DELIVERED")) {
                i.setDeliveredAt(LocalDateTime.now());
            }
            if (target.equals("CANCELLED")) {
                // put the stock back (flash-sale units stay claimed)
                productRepository.findById(i.getProductId()).ifPresent(p -> {
                    p.setStock((p.getStock() == null ? 0 : p.getStock()) + i.getQuantity());
                    p.setSold(Math.max(0, (p.getSold() == null ? 0 : p.getSold()) - i.getQuantity()));
                    productRepository.save(p);
                });
            }
        }
        rollUpOrderStatus(items.get(0).getOrder());
    }

    /** Revenue, orders, product earnings and payouts for the last 6 months (delivered lines only). */
    @Transactional(readOnly = true)
    public SellerFinance sellerFinance(Long sellerId) {
        LocalDate today = LocalDate.now();
        SellerFinance f = SellerFinance.blank(today, COMMISSION_RATE);

        YearMonth cur = YearMonth.from(today);
        YearMonth first = cur.minusMonths(SellerFinance.MONTHS - 1);

        List<Set<Long>> orderIds = new ArrayList<>();
        for (int k = 0; k < SellerFinance.MONTHS; k++) orderIds.add(new HashSet<>());
        Map<Long, SellerFinance.Earn> byProduct = new LinkedHashMap<>();

        for (OrderItem i : orderItemRepository.findDeliveredForSeller(sellerId)) {
            LocalDateTime when = i.getDeliveredAt() != null ? i.getDeliveredAt() : i.getOrder().getCreatedAt();
            YearMonth ym = YearMonth.from(when);
            if (ym.isBefore(first) || ym.isAfter(cur)) continue;

            int idx = (int) ChronoUnit.MONTHS.between(first, ym);
            f.gross[idx] += i.getLineTotal();
            orderIds.get(idx).add(i.getOrder().getId());

            SellerFinance.Earn e = byProduct.computeIfAbsent(i.getProductId(), pid -> {
                SellerFinance.Earn x = new SellerFinance.Earn();
                x.name = i.getName();
                return x;
            });
            e.amount += i.getLineTotal();
        }

        for (int k = 0; k < SellerFinance.MONTHS; k++) f.orders[k] = orderIds.get(k).size();

        // product-wise earnings, net of commission, best first
        for (SellerFinance.Earn e : byProduct.values()) {
            e.amount = e.amount - Math.round(e.amount * COMMISSION_RATE);
            f.earnings.add(e);
        }
        f.earnings.sort(Comparator.comparingLong((SellerFinance.Earn e) -> e.amount).reversed());
        if (f.earnings.size() > 6) f.earnings = new ArrayList<>(f.earnings.subList(0, 6));

        // payouts: one per finished month that had sales, newest first
        for (int k = SellerFinance.MONTHS - 2; k >= 0 && f.payouts.size() < 5; k--) {
            if (f.gross[k] <= 0) continue;
            YearMonth ym = cur.minusMonths(SellerFinance.MONTHS - 1 - k);
            LocalDate payDay = SellerFinance.payoutDate(ym);

            SellerFinance.Payout p = new SellerFinance.Payout();
            p.period = SellerFinance.periodLabel(ym);
            p.ref = "PAY-" + String.format("%d%02d", ym.getYear(), ym.getMonthValue());
            p.date = payDay.format(java.time.format.DateTimeFormatter.ofPattern("MMM d", Locale.ENGLISH));
            p.net = f.gross[k] - Math.round(f.gross[k] * COMMISSION_RATE);
            p.paid = !today.isBefore(payDay);
            f.payouts.add(p);
        }
        return f;
    }

    /** Customer-facing order status, worked out from all items (every seller). */
    private void rollUpOrderStatus(Order o) {
        int active = 0, delivered = 0;
        boolean anyShipped = false;

        for (OrderItem i : o.getItems()) {
            String s = i.getStatus();
            if (s.equals("CANCELLED")) continue;
            active++;
            if (s.equals("DELIVERED")) delivered++;
            if (s.equals("SHIPPED") || s.equals("DELIVERED")) anyShipped = true;
        }

        if (active == 0) {
            o.setStatus("CANCELLED");
        } else if (delivered == active) {
            o.setStatus("DELIVERED");
            if ("COD".equals(o.getPaymentMethod())) {
                o.setPaymentStatus("PAID");   // cash was collected on delivery
            }
        } else if (anyShipped) {
            o.setStatus("SHIPPED");
        } else {
            o.setStatus("PLACED");
        }
    }

    /* ====================================================================== */
    /*  Helpers for the customer's My Orders page                             */
    /* ====================================================================== */

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