package com.example.aalmari.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LegalController {

    @GetMapping("/legal")
    public String legal(@RequestParam(value = "document", defaultValue = "terms") String document,
                        Model model) {
        String normalized = document == null ? "terms" : document.trim().toLowerCase();
        if (!normalized.matches("terms|privacy|returns|seller")) {
            normalized = "terms";
        }

        model.addAttribute("document", normalized);
        model.addAttribute("pageTitle", switch (normalized) {
            case "privacy" -> "Privacy Policy";
            case "returns" -> "Return & Refund Policy";
            case "seller" -> "Seller Terms of Service";
            default -> "Terms of Service";
        });
        return "legal";
    }
}

