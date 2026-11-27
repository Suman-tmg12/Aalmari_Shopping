package com.example.aalmari.controller;

import com.example.aalmari.dto.HeroSlide;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.repository.HeroSlideRepository;
import com.example.aalmari.repository.SellerProductRepository;
import com.example.aalmari.util.PaginationSupport;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Controller
public class HomeController {

    private final HeroSlideRepository heroSlideRepository;
    private final SellerProductRepository sellerProductRepository;

    public HomeController(HeroSlideRepository heroSlideRepository,
                          SellerProductRepository sellerProductRepository) {
        this.heroSlideRepository = heroSlideRepository;
        this.sellerProductRepository = sellerProductRepository;
    }

    @GetMapping("/")
    public String welcome(Model model,
                          @RequestParam(name = "page", defaultValue = "1") int page,
                          @RequestParam(name = "size", defaultValue = "12") int size) {
        // 1. Fetch Hero Slides (Your existing logic)
        List<HeroSlide> slides = new ArrayList<>();
        try {
            slides = heroSlideRepository.findAllActiveSlides();
            System.out.println("Fetched " + slides.size() + " slides from database.");
        } catch (Exception e) {
            System.err.println("Error fetching slides: " + e.getMessage());
            e.printStackTrace();
        }
        model.addAttribute("heroSlides", slides);

        // 2. Fetch products from approved sellers only with pagination
        int requestedPage = PaginationSupport.page(page);
        int pageSize = PaginationSupport.size(size, 6, 48, 12);
        Page<SellerProduct> activeProductsPage = sellerProductRepository.findAllPublicActivePaged(
                PageRequest.of(requestedPage - 1, pageSize, Sort.by(Sort.Order.desc("id"))));
        int totalPages = activeProductsPage.getTotalPages();
        int currentPage = totalPages == 0 ? 1 : Math.min(requestedPage, totalPages);
        if (currentPage != requestedPage && totalPages > 0) {
            activeProductsPage = sellerProductRepository.findAllPublicActivePaged(
                    PageRequest.of(currentPage - 1, pageSize, Sort.by(Sort.Order.desc("id"))));
        }

        List<SellerProduct> activeProducts = activeProductsPage.getContent();

        model.addAttribute("sellerProducts", activeProducts);
        model.addAttribute("currentPage", currentPage);
        model.addAttribute("totalPages", totalPages);
        model.addAttribute("totalItems", activeProductsPage.getTotalElements());
        model.addAttribute("pageSize", pageSize);

        return "welcome";
    }
}