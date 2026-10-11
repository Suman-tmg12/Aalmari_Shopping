package com.example.aalmari.controller;

import com.example.aalmari.dto.HeroSlide;
import com.example.aalmari.repository.HeroSlideRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.ArrayList;
import java.util.List;

@Controller
public class HomeController {

    @Autowired
    private HeroSlideRepository heroSlideRepository;

    @GetMapping("/")
    public String welcome(Model model) {
        // Fetch active slides from database
        List<HeroSlide> slides = new ArrayList<>();
        try {
            slides = heroSlideRepository.findAllActiveSlides();
            System.out.println("Fetched " + slides.size() + " slides from database.");
        } catch (Exception e) {
            System.err.println("Error fetching slides: " + e.getMessage());
            e.printStackTrace();
        }
        model.addAttribute("heroSlides", slides);

        return "welcome";
    }
}