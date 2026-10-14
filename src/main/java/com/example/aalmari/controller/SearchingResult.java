package com.example.aalmari.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SearchingResult {

    @GetMapping("/searchingresult")
    public String showSearchingResult() {
        return "searchingresult";
    }
}
