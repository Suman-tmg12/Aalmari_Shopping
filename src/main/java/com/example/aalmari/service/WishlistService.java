package com.example.aalmari.service;

import com.example.aalmari.dto.WishlistCard;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.model.WishlistItem;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.UserRepository;
import com.example.aalmari.repository.WishlistItemRepository;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class WishlistService {

    private static final int MAX_ITEMS = 200;
    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";

    private final WishlistItemRepository wishlistRepo;
    private final SellerProductRepository productRepo;
    private final UserRepository userRepo;
    private final FlashSaleService flashSaleService;
    private final ObjectMapper mapper = new ObjectMapper();

    public WishlistService(WishlistItemRepository wishlistRepo,
                           SellerProductRepository productRepo,
                           UserRepository userRepo,
                           FlashSaleService flashSaleService) {
        this.wishlistRepo = wishlistRepo;
        this.productRepo = productRepo;
        this.userRepo = userRepo;
        this.flashSaleService = flashSaleService;
    }

    /**
     * Adds a product. Safe to call twice (second call changes nothing).
     * Not @Transactional on purpose: if two clicks race and the unique key rejects the
     * second insert, we can swallow that error without poisoning an outer transaction.
     */
    public int add(Long userId, Long productId) {
        if (!wishlistRepo.existsByUser_IdAndProduct_Id(userId, productId)) {
            SellerProduct product = productRepo.findById(productId)
                    .filter(p -> Boolean.TRUE.equals(p.getActive()))
                    .orElseThrow(() -> new IllegalArgumentException("This product is not available."));

            if (wishlistRepo.countByUser_Id(userId) >= MAX_ITEMS) {
                throw new IllegalArgumentException("Your wishlist is full (max " + MAX_ITEMS + " items).");
            }

            WishlistItem item = new WishlistItem();
            item.setUser(userRepo.getReferenceById(userId));
            item.setProduct(product);
            try {
                wishlistRepo.save(item);
            } catch (DataIntegrityViolationException alreadySaved) {
                // double click / second tab: it is already in the wishlist, which is what we wanted
            }
        }
        return count(userId);
    }

    /** Removes a product. Safe to call when it is not in the wishlist. */
    @Transactional
    public int remove(Long userId, Long productId) {
        wishlistRepo.deleteByUserAndProduct(userId, productId);
        return count(userId);
    }

    @Transactional(readOnly = true)
    public int count(Long userId) {
        return (int) wishlistRepo.countByUser_Id(userId);
    }

    @Transactional(readOnly = true)
    public List<Long> productIds(Long userId) {
        return wishlistRepo.findProductIds(userId);
    }

    /** Cards for the My Profile page. Price = live product price, or the live flash price while a deal runs. */
    @Transactional(readOnly = true)
    public List<WishlistCard> cards(Long userId) {
        List<WishlistCard> out = new ArrayList<>();

        for (WishlistItem w : wishlistRepo.findAllForUser(userId)) {
            SellerProduct p = w.getProduct();

            int regular = p.getPrice() == null ? 0 : p.getPrice();
            int discount = p.getDiscount() == null ? 0 : p.getDiscount();
            int current = Math.max(0, (int) (regular * (100 - discount) / 100.0));   // same formula as ProductController
            int old = (discount > 0 && discount < 100) ? regular : 0;

            boolean active = Boolean.TRUE.equals(p.getActive());
            int stock = p.getStock() == null ? 0 : p.getStock();
            boolean available = active && stock > 0;

            WishlistCard c = new WishlistCard();
            c.setProductId(p.getId());
            c.setName(p.getName());
            c.setCategory(p.getCategory());
            c.setSubCategory(p.getSubCategory() == null ? "" : p.getSubCategory());
            c.setImageUrl(firstImage(p));
            c.setSold(p.getSold() == null ? 0 : p.getSold());
            c.setActive(active);
            c.setAvailable(available);
            c.setLink("/product/" + p.getId());

            // A running flash sale wins: show its price and open the flash page
            if (available) {
                Optional<FlashSaleService.Offer> offer = flashSaleService.offerFor(userId, p.getId());
                if (offer.isPresent()) {
                    FlashSaleService.Offer f = offer.get();
                    current = f.flashPrice();
                    old = f.regularPrice();
                    discount = old > 0 ? (int) Math.round(100.0 * (old - current) / old) : 0;
                    c.setFlash(true);
                    c.setLink("/flashsaleproduct?id=" + f.itemId());
                }
            }

            c.setPrice(current);
            c.setOldPrice(old);
            c.setDiscount(discount);
            out.add(c);
        }
        return out;
    }

    private String firstImage(SellerProduct p) {
        try {
            String json = p.getImageUrlsJson();
            if (json != null && !json.isEmpty() && !json.equals("[]")) {
                List<String> paths = mapper.readValue(json, new TypeReference<List<String>>() {});
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