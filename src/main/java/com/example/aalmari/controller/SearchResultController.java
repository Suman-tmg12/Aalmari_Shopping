package com.example.aalmari.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SearchResultController {

    @GetMapping("/searchResult")
    public String showSearchResult() {
        return "searchResult";
    }
}