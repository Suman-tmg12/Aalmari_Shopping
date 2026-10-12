package com.example.aalmari.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CartController {

    @GetMapping("/cart")
    public String showCartPage(HttpSession session) {

        Object userIdAttr = session.getAttribute("userId");
        if(userIdAttr == null) {
            return "redirect:/login";
        }

        return "cart"; // -> /WEB-INF/views/cart.jsp
    }
}