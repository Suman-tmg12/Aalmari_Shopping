package com.example.aalmari.controller;

import com.example.aalmari.dto.HeroSlide;
import com.example.aalmari.model.SellerProduct;
import com.example.aalmari.repository.HeroSlideRepository;
import com.example.aalmari.repository.SellerProductRepository;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

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
    public String welcome(Model model) {
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

        // 2. Fetch Active Products (NEW Logic)
        List<SellerProduct> allProducts = sellerProductRepository.findAll();
        List<SellerProduct> activeProducts = allProducts.stream()
                .filter(SellerProduct::getActive)
                .collect(Collectors.toList());

        model.addAttribute("sellerProducts", activeProducts);

        return "welcome";
    }
}