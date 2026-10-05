package com.example.aalmari.controller;

import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

@Controller
public class SellerController {

    // Shows the Seller registration / intro page
    @GetMapping("/seller")
    public String sellerController(HttpSession session) {
        if (session.getAttribute("userId") == null) {
            return "redirect:/login";
        }
        return "SellerPage/seller"; // -> /WEB-INF/views/SellerPage/seller.jsp
    }

    // Handles the POST request when submitting the seller form
    @PostMapping("/SellerDashboard")
    public String handleSellerSubmit(HttpSession session) {
        if (session.getAttribute("userId") == null) {
            return "redirect:/login";
        }
        // TODO: Process seller form data here (e.g., save seller details to DB)

        return "SellerPage/SellerDashboard"; // -> /WEB-INF/views/SellerPage/sellerDashboard.jsp
    }

    // Displays the Seller Dashboard page directly via GET
    @GetMapping("/SellerDashboard")
    public String showSellerDashboard(HttpSession session) {
        if (session.getAttribute("userId") == null) {
            return "redirect:/login";
        }
        return "SellerPage/SellerDashboard"; // -> /WEB-INF/views/SellerPage/sellerDashboard.jsp
    }
}