package com.example.aalmari.controller;

import com.example.aalmari.dto.FlashDeal;
import com.example.aalmari.service.FlashSaleService;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Optional;

@Controller
public class FlashController {

    private final FlashSaleService flashSaleService;

    public FlashController(FlashSaleService flashSaleService) {
        this.flashSaleService = flashSaleService;
    }

    /** /flash  or  /flash?name=Electronics&sub=Mobiles */
    @GetMapping("/flash")
    public String showFlashController(@RequestParam(value = "name", required = false) String name,
                                      @RequestParam(value = "sub", required = false) String sub,
                                      @RequestParam(name = "page", defaultValue = "1") int page,
                                      @RequestParam(name = "size", defaultValue = "12") int size,
                                      @RequestParam(name = "sort", defaultValue = "best") String sort,
                                      Model model) {
        List<FlashDeal> deals = flashSaleService.liveDeals(name, sub, 0);

        String normalizedSort = switch (sort) {
            case "low-high", "high-low", "popular", "newest" -> sort;
            default -> "best";
        };
        switch (normalizedSort) {
            case "low-high" -> deals.sort(java.util.Comparator.comparingInt(FlashDeal::getFlashPrice)
                    .thenComparing(java.util.Comparator.comparingLong(FlashDeal::getItemId).reversed()));
            case "high-low" -> deals.sort(java.util.Comparator.comparingInt(FlashDeal::getFlashPrice).reversed()
                    .thenComparing(java.util.Comparator.comparingLong(FlashDeal::getItemId).reversed()));
            case "popular" -> deals.sort(java.util.Comparator.comparingInt(FlashDeal::getSold).reversed()
                    .thenComparing(java.util.Comparator.comparingLong(FlashDeal::getItemId).reversed()));
            case "newest" -> deals.sort(java.util.Comparator.comparingLong(FlashDeal::getEndTime).reversed()
                    .thenComparing(java.util.Comparator.comparingLong(FlashDeal::getItemId).reversed()));
            default -> deals.sort(java.util.Comparator.comparingLong(FlashDeal::getItemId).reversed());
        }

        int pageSize = Math.max(6, Math.min(48, size));
        int requestedPage = Math.max(1, page);
        int totalPages = deals.isEmpty() ? 0 : (deals.size() + pageSize - 1) / pageSize;
        int currentPage = totalPages == 0 ? 1 : Math.min(requestedPage, totalPages);
        int start = (currentPage - 1) * pageSize;
        int end = Math.min(start + pageSize, deals.size());
        List<FlashDeal> pageDeals = start >= deals.size() ? List.of() : new java.util.ArrayList<>(deals.subList(start, end));

        model.addAttribute("flashDeals", pageDeals);
        model.addAttribute("flashCurrentPage", currentPage);
        model.addAttribute("flashTotalPages", totalPages);
        model.addAttribute("flashTotalItems", deals.size());
        model.addAttribute("flashPageSize", pageSize);
        model.addAttribute("flashSort", normalizedSort);
        return "flash";
    }

    /** /flashsaleproduct?id=<flash item id> */
    @GetMapping("/flashsaleproduct")
    public String showFlashSaleProduct(@RequestParam(value = "id", required = false) Long id,
                                       @RequestParam(name = "page", defaultValue = "1") int page,
                                       @RequestParam(name = "size", defaultValue = "8") int size,
                                       Model model, HttpSession session) {
        if (id == null) return "redirect:/flash";
        Optional<FlashDeal> deal = flashSaleService.liveDeal(id);
        if (deal.isEmpty()) return "redirect:/flash";      // sale ended, sold out, or bad id

        // Other live flash deals, paginated on the server.
        List<FlashDeal> allRelated = flashSaleService.liveDeals(null, null, 0);
        allRelated.removeIf(d -> id.equals(d.getItemId()));
        allRelated.sort(java.util.Comparator
                .comparingLong(FlashDeal::getEndTime)
                .thenComparing(java.util.Comparator.comparingLong(FlashDeal::getItemId).reversed()));
        int pageSize = Math.max(4, Math.min(24, size));
        int requestedPage = Math.max(1, page);
        int totalPages = allRelated.isEmpty() ? 0 : (allRelated.size() + pageSize - 1) / pageSize;
        int currentPage = totalPages == 0 ? 1 : Math.min(requestedPage, totalPages);
        int start = (currentPage - 1) * pageSize;
        int end = Math.min(start + pageSize, allRelated.size());
        List<FlashDeal> related = start >= allRelated.size()
                ? List.of()
                : new java.util.ArrayList<>(allRelated.subList(start, end));

        model.addAttribute("product", deal.get());
        model.addAttribute("relatedFlashDeals", related);
        model.addAttribute("relatedCurrentPage", currentPage);
        model.addAttribute("relatedTotalPages", totalPages);
        model.addAttribute("relatedPageSize", pageSize);

        // Check if the logged-in user owns the viewed flash sale product
        Object userIdValue = session.getAttribute("userId");
        boolean isOwner = false;
        if (userIdValue instanceof Number number) {
            isOwner = deal.get().getSellerId() != null
                    && deal.get().getSellerId().equals(number.longValue());
        }
        model.addAttribute("isOwner", isOwner);

        return "flashsaleproduct";
    }
}