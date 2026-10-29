package com.example.aalmari.controller;

import com.example.aalmari.repository.SellerProductRepository;
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
                                   Model model) {
        String query = q.trim();
        if (query.length() > 100) query = query.substring(0, 100);

        model.addAttribute("searchProducts", sellerProductRepository.searchActive(query));
        return "searchResult";
    }
}