package com.example.aalmari.controller;


import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class FlashController {
    @GetMapping("/flash")
    public String showFlashController() {
        return "flash";
    }
}
