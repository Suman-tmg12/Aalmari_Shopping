package com.example.aalmari.service;

import com.example.aalmari.dto.CartView;
import com.example.aalmari.model.CartItem;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.CartItemRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.UserRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
public class CartService {

    private static final int MAX_QTY_PER_ITEM = 10;   // same limit as the product page
    private static final long DELIVERY_FEE = 0;       // change when you add delivery pricing
    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";

    private final CartItemRepository cartItemRepository;
    private final SellerProductRepository productRepository;
    private final UserRepository userRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public CartService(CartItemRepository cartItemRepository,
                       SellerProductRepository productRepository,
                       UserRepository userRepository) {
        this.cartItemRepository = cartItemRepository;
        this.productRepository = productRepository;
        this.userRepository = userRepository;
    }

    /** Adds a product (or increases its quantity). Returns the new total item count. */
    @Transactional
    public int add(Long userId, Long productId, int qty) {
        if (qty < 1) qty = 1;

        SellerProduct product = productRepository.findById(productId)
                .filter(p -> Boolean.TRUE.equals(p.getActive()))
                .orElseThrow(() -> new IllegalArgumentException("This product is not available."));

        int stock = product.getStock() == null ? 0 : product.getStock();
        if (stock < 1) {
            throw new IllegalArgumentException("This product is out of stock.");
        }
        int limit = Math.min(MAX_QTY_PER_ITEM, stock);

        CartItem item = cartItemRepository.findByUser_IdAndProduct_Id(userId, productId).orElse(null);
        if (item == null) {
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new IllegalArgumentException("User not found."));
            item = new CartItem();
            item.setUser(user);
            item.setProduct(product);
            item.setQuantity(0);
        }
        item.setQuantity(Math.min(limit, item.getQuantity() + qty));
        cartItemRepository.save(item);

        return cartItemRepository.countItems(userId);
    }

    @Transactional
    public void changeQuantity(Long userId, Long itemId, boolean increase) {
        cartItemRepository.findByIdAndUser_Id(itemId, userId).ifPresent(item -> {
            int stock = item.getProduct().getStock() == null ? 0 : item.getProduct().getStock();
            int limit = Math.max(1, Math.min(MAX_QTY_PER_ITEM, stock));
            int q = item.getQuantity() + (increase ? 1 : -1);
            item.setQuantity(Math.max(1, Math.min(limit, q)));
            cartItemRepository.save(item);
        });
    }

    @Transactional
    public void remove(Long userId, Long itemId) {
        cartItemRepository.findByIdAndUser_Id(itemId, userId)
                .ifPresent(cartItemRepository::delete);
    }

    @Transactional(readOnly = true)
    public int count(Long userId) {
        return cartItemRepository.countItems(userId);
    }

    /** Builds everything cart.jsp shows. Prices always come from the live product row. */
    @Transactional(readOnly = true)
    public CartView view(Long userId) {
        CartView view = new CartView();
        List<CartView.Line> lines = new ArrayList<>();
        long subtotal = 0;
        long payable = 0;

        for (CartItem item : cartItemRepository.findByUser_IdOrderByIdDesc(userId)) {
            SellerProduct p = item.getProduct();
            long price = p.getPrice() == null ? 0 : p.getPrice();
            int discount = p.getDiscount() == null ? 0 : p.getDiscount();
            long unit = (long) (price * (100 - discount) / 100.0);   // same formula as ProductController
            int qty = item.getQuantity();

            CartView.Line line = new CartView.Line();
            line.setId(item.getId());
            line.setProductId(p.getId());
            line.setName(p.getName());
            line.setImageUrl(firstImage(p));
            line.setUnitPrice(unit);
            line.setOriginalPrice(price);
            line.setQuantity(qty);
            line.setLineTotal(unit * qty);
            lines.add(line);

            subtotal += price * qty;
            payable += unit * qty;
        }

        long discountAmount = subtotal - payable;
        view.setItems(lines);
        view.setSubtotal(subtotal);
        view.setDiscountAmount(discountAmount);
        view.setDiscountPercent(subtotal > 0 ? Math.round(discountAmount * 100.0 / subtotal) : 0);
        view.setDeliveryFee(lines.isEmpty() ? 0 : DELIVERY_FEE);
        view.setTotal(payable + view.getDeliveryFee());
        return view;
    }

    private String firstImage(SellerProduct p) {
        try {
            String json = p.getImageUrlsJson();
            if (json != null && !json.isEmpty() && !json.equals("[]")) {
                List<String> paths = objectMapper.readValue(json, new TypeReference<List<String>>() {});
                for (String path : paths) {
                    if (path != null && !path.isEmpty()) return toUrl(path);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return toUrl(p.getInfoImageUrl());
    }

    private String toUrl(String path) {
        if (path == null || path.isEmpty()) return null;
        return path.startsWith("http") ? path : S3_BUCKET_URL + path;
    }
}