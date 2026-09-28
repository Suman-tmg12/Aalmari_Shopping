package com.example.aalmari.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String showHomePage() {
        return "welcome";
    }

//    @GetMapping("/cart")
//    public String showCartPage() {
//        return "login";
//    }

//    @PostMapping("/login")
//    public String login(@RequestParam String username, @RequestParam String password, Model model) {
//        if ("admin".equals(username) && "admin123".equals(password)) {
//            model.addAttribute("username", username);
//            return "welcome";
//        } else {
//            model.addAttribute("error", "Invalid username or password");
//            return "login";
//        }
//    }

}
