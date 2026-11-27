package com.example.aalmari.controller;

import com.example.aalmari.repository.SellerProductRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class SearchResultController {

    private final SellerProductRepository sellerProductRepository;

    public SearchResultController(SellerProductRepository sellerProductRepository) {
        this.sellerProductRepository = sellerProductRepository;
    }

    @GetMapping("/searchResult")
    public String showSearchResult(@RequestParam(name = "q", required = false, defaultValue = "") String q,
                                   @RequestParam(name = "cat", required = false) String category,
                                   @RequestParam(name = "page", defaultValue = "1") int page,
                                   @RequestParam(name = "size", defaultValue = "12") int size,
                                   @RequestParam(name = "sort", defaultValue = "best") String sort,
                                   Model model) {
        String query = q.trim();
        if (query.length() > 100) query = query.substring(0, 100);

        int requestedPage = Math.max(1, page);
        int pageSize = Math.max(6, Math.min(48, size));
        Sort sortSpec = switch (sort) {
            case "low-high" -> Sort.by(Sort.Order.asc("price"), Sort.Order.desc("id"));
            case "high-low" -> Sort.by(Sort.Order.desc("price"), Sort.Order.desc("id"));
            case "popular" -> Sort.by(Sort.Order.desc("sold"), Sort.Order.desc("id"));
            default -> Sort.by(Sort.Order.desc("id"));
        };

        Page<com.example.aalmari.model.SellerProduct> resultPage = sellerProductRepository.pageSearchPublicActive(
                query, category, PageRequest.of(requestedPage - 1, pageSize, sortSpec));
        int totalPages = resultPage.getTotalPages();
        int currentPage = totalPages == 0 ? 1 : Math.min(requestedPage, totalPages);
        if (currentPage != requestedPage && totalPages > 0) {
            resultPage = sellerProductRepository.pageSearchPublicActive(
                    query, category, PageRequest.of(currentPage - 1, pageSize, sortSpec));
        }

        model.addAttribute("searchProducts", resultPage.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", resultPage.getTotalPages());
        model.addAttribute("totalItems", resultPage.getTotalElements());
        model.addAttribute("pageSize", pageSize);
        model.addAttribute("sort", sort);
        model.addAttribute("searchCategory", category);
        return "searchResult";
    }
}