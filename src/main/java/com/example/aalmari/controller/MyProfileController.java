package com.example.aalmari.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MyProfileController {

    @GetMapping("/myprofile")
    public String showMyProfile() {
        return "myprofile";
    }

}
