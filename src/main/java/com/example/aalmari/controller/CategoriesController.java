package com.example.aalmari.controller;

import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.repository.SellerProductRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class CategoriesController {

    private static final List<String> CATEGORIES = List.of(
            "Electronics", "Fashion", "Beauty & Personal Care", "Home & Living", "Groceries",
            "Sports & Fitness", "Books & Stationery", "Automotive", "Toys & Games", "Health & Wellness");

    private final SellerProductRepository sellerProductRepository;

    public CategoriesController(SellerProductRepository sellerProductRepository) {
        this.sellerProductRepository = sellerProductRepository;
    }

    @GetMapping("/category")
    public String showCategory(@RequestParam(name = "name", defaultValue = "Electronics") String name,
                               @RequestParam(name = "sub", required = false) String sub,
                               Model model) {

        String category = CATEGORIES.contains(name) ? name : "Electronics";
        boolean hasSub = sub != null && !sub.isBlank();

        List<SellerProduct> products = hasSub
                ? sellerProductRepository
                .findByActiveTrueAndCategoryIgnoreCaseAndSubCategoryIgnoreCaseOrderByIdDesc(category, sub.trim())
                : sellerProductRepository
                .findByActiveTrueAndCategoryIgnoreCaseOrderByIdDesc(category);

        model.addAttribute("sellerProducts", products);
        return "categories";
    }
}