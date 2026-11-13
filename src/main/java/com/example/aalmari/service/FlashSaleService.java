package com.example.aalmari.service;

import com.example.aalmari.dto.FlashDeal;
import com.example.aalmari.model.FlashPurchase;
import com.example.aalmari.model.FlashSale;
import com.example.aalmari.model.FlashSaleItem;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.repository.FlashPurchaseRepository;
import com.example.aalmari.repository.FlashSaleItemRepository;
import com.example.aalmari.repository.FlashSaleRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.jsoup.Jsoup;
import org.jsoup.safety.Safelist;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FlashSaleService {

    public static final int MIN_DISC = 10, MAX_DISC = 90, MAX_ITEMS = 20;
    public static final long MIN_LEAD = 15 * 60_000L, MIN_DUR = 3_600_000L, MAX_DUR = 72 * 3_600_000L;

    private static final String S3_BUCKET_URL = "https://sellerimages123.s3.ap-southeast-2.amazonaws.com/";

    public record ItemReq(Long productId, Integer discount, Integer qty, Integer limit) {}
    public record SaveReq(Long id, String name, Long start, Long end, List<ItemReq> items) {}
    /** What a customer can get right now: flash price and the most units they may still buy at it. */
    public record Offer(Long itemId, int flashPrice, int regularPrice, int maxQty) {}

    private final FlashSaleRepository saleRepo;
    private final FlashSaleItemRepository itemRepo;
    private final FlashPurchaseRepository purchaseRepo;
    private final SellerProductRepository productRepo;
    private final UserRepository userRepo;
    private final ObjectMapper mapper = new ObjectMapper();

    public FlashSaleService(FlashSaleRepository saleRepo, FlashSaleItemRepository itemRepo,
                            FlashPurchaseRepository purchaseRepo, SellerProductRepository productRepo,
                            UserRepository userRepo) {
        this.saleRepo = saleRepo;
        this.itemRepo = itemRepo;
        this.purchaseRepo = purchaseRepo;
        this.productRepo = productRepo;
        this.userRepo = userRepo;
    }

    private static IllegalArgumentException bad(String m) { return new IllegalArgumentException(m); }
    private static int price(int regular, int disc) { return (int) Math.round(regular * (100 - disc) / 100.0); }

    private static String status(FlashSale s, long now) {
        if (s.isEndedEarly() || now >= s.getEndTime()) return "ended";
        return now < s.getStartTime() ? "scheduled" : "live";
    }

    private FlashSale mine(Long sellerId, Long id) {
        return saleRepo.findByIdAndSeller_Id(id, sellerId)
                .orElseThrow(() -> new SecurityException("Flash sale not found."));
    }

    /* ====================================================================== */
    /*  Seller dashboard                                                      */
    /* ====================================================================== */

    /** JSON read by SellerDashboard.js (#flashData). */
    @Transactional(readOnly = true)
    public String sellerJson(Long sellerId) {
        List<Map<String, Object>> out = new ArrayList<>();
        for (FlashSale s : saleRepo.findBySeller_IdOrderByStartTimeDesc(sellerId)) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", s.getId());
            m.put("name", s.getName());
            m.put("start", s.getStartTime());
            m.put("end", s.getEndTime());
            m.put("endedEarly", s.isEndedEarly());
            m.put("items", s.getItems().stream().map(i -> {
                Map<String, Object> o = new LinkedHashMap<>();
                o.put("pid", i.getProduct().getId());
                o.put("name", i.getProduct().getName());
                o.put("price", i.getRegularPrice());
                o.put("disc", i.getDiscount());
                o.put("qty", i.getQty());
                o.put("limit", i.getLimitPerCustomer());
                o.put("sold", i.getSold());
                return o;
            }).collect(Collectors.toList()));
            out.add(m);
        }
        try {
            return mapper.writeValueAsString(out);
        } catch (JsonProcessingException e) {
            return "[]";
        }
    }

    /* ---------- create / edit ---------- */
    @Transactional
    public Long save(Long sellerId, SaveReq r) {
        long now = System.currentTimeMillis();
        if (r == null || r.name() == null || r.name().isBlank()) throw bad("Campaign name is required.");
        String name = r.name().trim();
        if (name.length() > 60) throw bad("Campaign name is too long (max 60).");
        if (r.start() == null || r.end() == null) throw bad("Choose a valid start and end time.");
        long start = r.start(), end = r.end();
        if (end - start < MIN_DUR) throw bad("Sale must run for at least 1 hour.");
        if (end - start > MAX_DUR) throw bad("Sale can run for at most 72 hours.");

        boolean isNew = r.id() == null;
        FlashSale sale;
        if (isNew) {
            if (start < now + MIN_LEAD) throw bad("Sale must start at least 15 minutes from now.");
            sale = new FlashSale();
            sale.setSeller(userRepo.getReferenceById(sellerId));
        } else {
            sale = mine(sellerId, r.id());
            if (!"scheduled".equals(status(sale, now))) throw bad("Only scheduled sales can be edited.");
            if (start != sale.getStartTime() && start < now + MIN_LEAD)
                throw bad("Sale must start at least 15 minutes from now.");
        }

        List<ItemReq> reqs = r.items();
        if (reqs == null || reqs.isEmpty()) throw bad("Select at least one product.");
        if (reqs.size() > MAX_ITEMS) throw bad("You can add up to " + MAX_ITEMS + " products per sale.");

        List<Long> pids = new ArrayList<>();
        for (ItemReq q : reqs) {
            if (q == null || q.productId() == null) throw bad("Invalid product.");
            if (pids.contains(q.productId())) throw bad("A product can only be added once per sale.");
            pids.add(q.productId());
        }
        Map<Long, SellerProduct> prods = productRepo.findAllById(pids).stream()
                .collect(Collectors.toMap(SellerProduct::getId, p -> p));

        List<FlashSaleItem> built = new ArrayList<>();
        for (ItemReq q : reqs) {
            SellerProduct p = prods.get(q.productId());
            if (p == null || p.getSeller() == null || !p.getSeller().getId().equals(sellerId))
                throw bad("Product not found.");
            int stock = p.getStock() == null ? 0 : p.getStock();
            if (!Boolean.TRUE.equals(p.getActive())) throw bad(p.getName() + ": product is not active.");
            if (stock < 1) throw bad(p.getName() + ": product is out of stock.");

            int disc = q.discount() == null ? 0 : q.discount();
            int qty = q.qty() == null ? 0 : q.qty();
            int lim = q.limit() == null ? 0 : q.limit();
            if (disc < MIN_DISC || disc > MAX_DISC)
                throw bad(p.getName() + ": discount must be " + MIN_DISC + "-" + MAX_DISC + "%.");
            if (qty < 1 || qty > stock)
                throw bad(p.getName() + ": flash quantity must be 1-" + stock + " (current stock).");
            if (lim < 1 || lim > qty)
                throw bad(p.getName() + ": limit per customer must be 1-" + qty + ".");

            int regular = p.getPrice();
            int flash = price(regular, disc);
            int current = (p.getDiscount() != null && p.getDiscount() > 0) ? price(regular, p.getDiscount()) : regular;
            if (flash >= current)
                throw bad(p.getName() + " already sells at Rs " + current + ". The flash price must be lower than that.");

            FlashSaleItem it = new FlashSaleItem();
            it.setSale(sale);
            it.setProduct(p);
            it.setRegularPrice(regular);
            it.setDiscount(disc);
            it.setFlashPrice(flash);
            it.setQty(qty);
            it.setLimitPerCustomer(lim);
            it.setSold(0);
            built.add(it);
        }

        Long exclude = isNew ? -1L : sale.getId();
        List<FlashSaleItem> clash = itemRepo.findOverlapping(pids, start, end, now, exclude);
        if (!clash.isEmpty()) {
            String names = clash.stream().map(i -> i.getProduct().getName()).distinct().collect(Collectors.joining(", "));
            throw bad("Already in another sale during this time: " + names + ".");
        }

        sale.setName(name);
        sale.setStartTime(start);
        sale.setEndTime(end);
        sale.getItems().clear();
        sale.getItems().addAll(built);
        return saleRepo.save(sale).getId();
    }

    @Transactional
    public void end(Long sellerId, Long id) {
        FlashSale s = mine(sellerId, id);
        if (!"live".equals(status(s, System.currentTimeMillis()))) throw bad("Only live sales can be ended.");
        s.setEndedEarly(true);
    }

    @Transactional
    public void delete(Long sellerId, Long id) {
        FlashSale s = mine(sellerId, id);
        if ("live".equals(status(s, System.currentTimeMillis()))) throw bad("End the sale before deleting it.");
        purchaseRepo.deleteBySale(id);
        saleRepo.delete(s);
    }

    /** Called before a product is deleted: blocks if it is in an open sale, otherwise cleans up history. */
    @Transactional
    public void detachProduct(Long productId) {
        if (itemRepo.countOpen(productId, System.currentTimeMillis()) > 0)
            throw bad("This product is in a live or scheduled flash sale. End or delete that sale first.");
        purchaseRepo.deleteByProduct(productId);
        itemRepo.deleteByProduct_Id(productId);
        saleRepo.deleteEmpty();
    }

    /* ====================================================================== */
    /*  Customer side: cart and checkout                                      */
    /* ====================================================================== */

    /** Flash offer for this customer on this product right now, if any. userId may be null (anonymous). */
    @Transactional(readOnly = true)
    public Optional<Offer> offerFor(Long userId, Long productId) {
        List<FlashSaleItem> live = itemRepo.findLive(productId, System.currentTimeMillis());
        if (live.isEmpty()) return Optional.empty();
        FlashSaleItem i = live.get(0);
        SellerProduct p = i.getProduct();
        if (!Boolean.TRUE.equals(p.getActive())) return Optional.empty();

        int left = i.getQty() - i.getSold();
        int mine = userId == null ? 0 : (int) Math.min(Integer.MAX_VALUE, purchaseRepo.bought(userId, i.getId()));
        int max = Math.min(Math.min(left, i.getLimitPerCustomer() - mine), p.getStock() == null ? 0 : p.getStock());
        if (max < 1) return Optional.empty();           // sold out or limit reached -> regular price
        return Optional.of(new Offer(i.getId(), i.getFlashPrice(), i.getRegularPrice(), max));
    }

    /**
     * Call this when an order is placed. Returns the flash unit price if the flash sale applied,
     * or empty if the customer should pay the normal price. Throws if qty exceeds what is allowed.
     */
    @Transactional
    public Optional<Integer> claim(Long userId, Long productId, int qty) {
        Optional<Offer> o = offerFor(userId, productId);
        if (o.isEmpty()) return Optional.empty();
        Offer offer = o.get();
        if (qty > offer.maxQty())
            throw bad("Flash sale allows at most " + offer.maxQty() + " unit(s) for you.");
        if (itemRepo.claim(offer.itemId(), qty) != 1)
            throw new IllegalStateException("Sorry, this flash deal just sold out.");
        FlashPurchase fp = new FlashPurchase();
        fp.setItem(itemRepo.getReferenceById(offer.itemId()));
        fp.setUserId(userId);
        fp.setQty(qty);
        purchaseRepo.save(fp);
        return Optional.of(offer.flashPrice());
    }

    /* ====================================================================== */
    /*  Storefront pages: home, /flash, /flashsaleproduct                     */
    /* ====================================================================== */

    /** Live deals, soonest-ending first. category/sub may be null; limit <= 0 means no limit. */
    @Transactional(readOnly = true)
    public List<FlashDeal> liveDeals(String category, String sub, int limit) {
        List<FlashDeal> out = new ArrayList<>();
        for (FlashSaleItem i : itemRepo.findAllLive(System.currentTimeMillis())) {
            SellerProduct p = i.getProduct();
            if (category != null && !category.isBlank() && !category.equalsIgnoreCase(p.getCategory())) continue;
            if (sub != null && !sub.isBlank() && !sub.equalsIgnoreCase(p.getSubCategory())) continue;
            out.add(toDeal(i));
            if (limit > 0 && out.size() >= limit) break;
        }
        return out;
    }

    /** One live deal by flash-item id (empty if it is not live any more). */
    @Transactional(readOnly = true)
    public Optional<FlashDeal> liveDeal(Long itemId) {
        long now = System.currentTimeMillis();
        return itemRepo.findWithAll(itemId).filter(i -> {
            FlashSale s = i.getSale();
            SellerProduct p = i.getProduct();
            int stock = p.getStock() == null ? 0 : p.getStock();
            return !s.isEndedEarly() && s.getStartTime() <= now && now < s.getEndTime()
                    && Boolean.TRUE.equals(p.getActive()) && stock > 0 && i.getSold() < i.getQty();
        }).map(this::toDeal);
    }

    private FlashDeal toDeal(FlashSaleItem i) {
        SellerProduct p = i.getProduct();
        FlashDeal d = new FlashDeal();
        d.setItemId(i.getId());
        d.setProductId(p.getId());
        d.setTitle(p.getName());
        d.setCategory(p.getCategory());
        d.setSubCategory(p.getSubCategory() == null ? "" : p.getSubCategory());
        d.setRegularPrice(i.getRegularPrice());
        d.setFlashPrice(i.getFlashPrice());
        d.setDiscountPercent(i.getDiscount());
        d.setQty(i.getQty());
        d.setSold(i.getSold());
        int stock = p.getStock() == null ? 0 : p.getStock();
        d.setStockLeft(Math.max(0, Math.min(i.getQty() - i.getSold(), stock)));
        d.setLimitPerCustomer(i.getLimitPerCustomer());
        d.setEndTime(i.getSale().getEndTime());

        List<String> imgs = new ArrayList<>();
        try {
            String json = p.getImageUrlsJson();
            if (json != null && !json.isBlank() && !json.equals("[]")) {
                for (String path : mapper.readValue(json, new TypeReference<List<String>>() {})) {
                    if (path != null && !path.isEmpty()) imgs.add(s3Url(path));
                }
            }
        } catch (Exception ignored) { }
        if (imgs.isEmpty() && p.getInfoImageUrl() != null && !p.getInfoImageUrl().isEmpty()) {
            imgs.add(s3Url(p.getInfoImageUrl()));
        }
        d.setGalleryImages(imgs);
        d.setMainImage(imgs.isEmpty() ? "" : imgs.get(0));

        // The description is rich text typed by the seller: sanitize before it is printed on a public page
        String desc = p.getDescription() == null ? "" : p.getDescription();
        d.setDescriptionHtml(Jsoup.clean(desc, Safelist.basic().addEnforcedAttribute("a", "rel", "nofollow noopener")));

        try {
            String attrs = p.getAttributesJson();
            if (attrs != null && !attrs.isBlank()) {
                Map<String, String> m = mapper.readValue(attrs, new TypeReference<Map<String, String>>() {});
                m.forEach((k, v) -> {
                    if (v != null && !v.isBlank()) d.getSpecs().put(k, v);
                });
            }
        } catch (Exception ignored) { }
        return d;
    }

    private static String s3Url(String path) {
        return path.startsWith("http") ? path : S3_BUCKET_URL + path;
    }
}