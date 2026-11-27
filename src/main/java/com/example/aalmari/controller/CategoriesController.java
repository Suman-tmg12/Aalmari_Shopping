package com.example.aalmari.controller;

import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.repository.SellerProductRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
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
                               @RequestParam(name = "page", defaultValue = "1") int page,
                               @RequestParam(name = "size", defaultValue = "12") int size,
                               @RequestParam(name = "sort", defaultValue = "best") String sort,
                               Model model) {

        String category = CATEGORIES.contains(name) ? name : "Electronics";
        boolean hasSub = sub != null && !sub.isBlank();

        int requestedPage = Math.max(1, page);
        int pageSize = Math.max(6, Math.min(48, size));
        Sort sortSpec = switch (sort) {
            case "low-high" -> Sort.by(Sort.Order.asc("price"), Sort.Order.desc("id"));
            case "high-low" -> Sort.by(Sort.Order.desc("price"), Sort.Order.desc("id"));
            case "popular" -> Sort.by(Sort.Order.desc("sold"), Sort.Order.desc("id"));
            default -> Sort.by(Sort.Order.desc("id"));
        };

        Pageable pageable = PageRequest.of(requestedPage - 1, pageSize, sortSpec);
        Page<SellerProduct> productsPage;
        if (sort.equals("low-high")) {
            productsPage = hasSub
                    ? sellerProductRepository.pagePublicActiveByCategoryAndSubCategoryPriceAsc(category, sub.trim(), pageable)
                    : sellerProductRepository.pagePublicActiveByCategoryPriceAsc(category, pageable);
        } else if (sort.equals("high-low")) {
            productsPage = hasSub
                    ? sellerProductRepository.pagePublicActiveByCategoryAndSubCategoryPriceDesc(category, sub.trim(), pageable)
                    : sellerProductRepository.pagePublicActiveByCategoryPriceDesc(category, pageable);
        } else {
            productsPage = hasSub
                    ? sellerProductRepository.pagePublicActiveByCategoryAndSubCategory(category, sub.trim(), pageable)
                    : sellerProductRepository.pagePublicActiveByCategory(category, pageable);
        }

        int totalPages = productsPage.getTotalPages();
        int currentPage = totalPages == 0 ? 1 : Math.min(requestedPage, totalPages);
        if (currentPage != requestedPage && totalPages > 0) {
            pageable = PageRequest.of(currentPage - 1, pageSize, sortSpec);
            if (sort.equals("low-high")) {
                productsPage = hasSub
                        ? sellerProductRepository.pagePublicActiveByCategoryAndSubCategoryPriceAsc(category, sub.trim(), pageable)
                        : sellerProductRepository.pagePublicActiveByCategoryPriceAsc(category, pageable);
            } else if (sort.equals("high-low")) {
                productsPage = hasSub
                        ? sellerProductRepository.pagePublicActiveByCategoryAndSubCategoryPriceDesc(category, sub.trim(), pageable)
                        : sellerProductRepository.pagePublicActiveByCategoryPriceDesc(category, pageable);
            } else {
                productsPage = hasSub
                        ? sellerProductRepository.pagePublicActiveByCategoryAndSubCategory(category, sub.trim(), pageable)
                        : sellerProductRepository.pagePublicActiveByCategory(category, pageable);
            }
        }

        model.addAttribute("sellerProducts", productsPage.getContent());
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", productsPage.getTotalPages());
        model.addAttribute("totalItems", productsPage.getTotalElements());
        model.addAttribute("pageSize", pageSize);
        model.addAttribute("sort", sort);
        model.addAttribute("categoryName", category);
        model.addAttribute("subCategoryName", sub);
        return "categories";
    }
}