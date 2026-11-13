package com.example.aalmari.controller;

import com.example.aalmari.dto.FlashDeal;
import com.example.aalmari.service.FlashSaleService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;
import java.util.Optional;

@Controller
public class FlashController {

    private final FlashSaleService flashSaleService;

    public FlashController(FlashSaleService flashSaleService) {
        this.flashSaleService = flashSaleService;
    }

    /** /flash  or  /flash?name=Electronics&sub=Mobiles */
    @GetMapping("/flash")
    public String showFlashController(@RequestParam(value = "name", required = false) String name,
                                      @RequestParam(value = "sub", required = false) String sub,
                                      Model model) {
        List<FlashDeal> deals = flashSaleService.liveDeals(name, sub, 0);
        model.addAttribute("flashDeals", deals);
        return "flash";
    }

    /** /flashsaleproduct?id=<flash item id> */
    @GetMapping("/flashsaleproduct")
    public String showFlashSaleProduct(@RequestParam(value = "id", required = false) Long id, Model model) {
        if (id == null) return "redirect:/flash";
        Optional<FlashDeal> deal = flashSaleService.liveDeal(id);
        if (deal.isEmpty()) return "redirect:/flash";      // sale ended, sold out, or bad id

        // Other live flash deals (all live ones, minus the one being viewed)
        List<FlashDeal> related = flashSaleService.liveDeals(null, null, 0);
        related.removeIf(d -> id.equals(d.getItemId()));

        model.addAttribute("product", deal.get());
        model.addAttribute("relatedFlashDeals", related);
        return "flashsaleproduct";
    }
}