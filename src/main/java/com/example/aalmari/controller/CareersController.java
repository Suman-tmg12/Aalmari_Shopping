package com.example.aalmari.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class CareersController {
    @GetMapping("/Careers")
    public String showCareersController() {
        return "Careers";
    }

}
