package com.example.aalmari.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CartController {

    @GetMapping("/cart")
    public String showCartPage() {
        return "cart"; // -> /WEB-INF/views/cart.jsp
    }
}