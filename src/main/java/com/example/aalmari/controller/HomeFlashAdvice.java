package com.example.aalmari.controller;

import com.example.aalmari.dto.FlashDeal;
import com.example.aalmari.service.FlashSaleService;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

import java.util.List;

@ControllerAdvice(assignableTypes = HomeController.class)
public class HomeFlashAdvice {

    private final FlashSaleService flashSaleService;

    public HomeFlashAdvice(FlashSaleService flashSaleService) {
        this.flashSaleService = flashSaleService;
    }

    @ModelAttribute("homeFlashDeals")
    public List<FlashDeal> homeFlashDeals() {
        return flashSaleService.liveDeals(null, null, 5);
    }
}