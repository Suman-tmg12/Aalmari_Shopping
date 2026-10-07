package com.example.aalmari.controller;

import com.example.aalmari.model.FlashProduct;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.*;

@Controller
public class FlashController {

    private final Map<String, FlashProduct> flashStore = new HashMap<>();

    public FlashController() {
        initFlashProducts();
    }

    private void initFlashProducts() {
        flashStore.put("himalaya-face-scrub", new FlashProduct(
                "himalaya-face-scrub", "Himalaya Face Scrub", "Beauty & Personal Care", "Skincare",
                "HimalayaFaceScrub.jpg", Arrays.asList("HimalayaFaceScrub.jpg"),
                "Rs.70", "Rs.150", "-53%", 4.6, 210,
                "Purifying Neem Face Scrub removes impurities and dead skin cells gently.",
                Arrays.asList("100g", "150g"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Brand", "Himalaya");
                    put("Skin Type", "All Skin Types");
                }},
                12, "04:15:30"
        ));

        flashStore.put("wireless-headphone", new FlashProduct(
                "wireless-headphone", "Wireless Headphone", "Electronics", "Audio",
                "Wireless_headPhone.jpg", Arrays.asList("Wireless_headPhone.jpg"),
                "Rs.70", "Rs.120", "-41%", 4.7, 340,
                "High-fidelity sound with deep bass and ergonomic wireless design.",
                Arrays.asList("Black", "White"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Connectivity", "Bluetooth 5.0");
                    put("Battery Life", "20 Hours");
                }},
                5, "02:45:10"
        ));

        flashStore.put("classic-black-shoes", new FlashProduct(
                "classic-black-shoes", "Classic Black Shoes", "Fashion", "Footwear",
                "ClassicBlackShoes.jpg", Arrays.asList("ClassicBlackShoes.jpg"),
                "Rs.90", "Rs.180", "-50%", 4.8, 510,
                "Elegant formal black leather shoes with durable rubber outer sole.",
                Arrays.asList("Black"), Arrays.asList("UK 7", "UK 8", "UK 9"),
                new LinkedHashMap<String, String>() {{
                    put("Material", "Genuine Leather");
                    put("Type", "Formal");
                }},
                8, "01:20:00"
        ));

        flashStore.put("smart-fitness-band", new FlashProduct(
                "smart-fitness-band", "Smart Fitness Band", "Electronics", "Wearables",
                "SmartFitnessBand.jpg", Arrays.asList("SmartFitnessBand.jpg"),
                "Rs.120", "Rs.240", "-50%", 4.5, 620,
                "Tracks heart rate, sleep cycles, workouts, and step counts in real time.",
                Arrays.asList("Black", "Red"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Display", "AMOLED");
                    put("Water Resistance", "5ATM");
                }},
                15, "05:00:00"
        ));

        flashStore.put("skin-care-set", new FlashProduct(
                "skin-care-set", "Skin Care Set", "Beauty & Personal Care", "Skincare",
                "skincare.jpg", Arrays.asList("skincare.jpg"),
                "Rs.150", "Rs.300", "-50%", 4.9, 180,
                "Complete hydrating daily regimen kit including cleanser, toner, and moisturizer.",
                Arrays.asList("Standard"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Items Included", "3 Products");
                }},
                3, "00:45:12"
        ));

        flashStore.put("healthy-food-pack", new FlashProduct(
                "healthy-food-pack", "Healthy Food Pack", "Groceries", "Organic",
                "Healthy.jpg", Arrays.asList("Healthy.jpg"),
                "Rs.300", "Rs.500", "-40%", 4.4, 95,
                "Assorted wholesome organic snacks rich in essential fiber and vitamins.",
                Arrays.asList("Pack of 1"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Weight", "1kg");
                }},
                20, "06:30:00"
        ));

        flashStore.put("unhealthy-foods", new FlashProduct(
                "unhealthy-foods", "Snack Combo Pack", "Groceries", "Snacks",
                "unhealthy-foods.jpg", Arrays.asList("unhealthy-foods.jpg"),
                "Rs.450", "Rs.500", "-10%", 4.2, 88,
                "Delicious variety party snack combo box.",
                Arrays.asList("Combo"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Servings", "4-6");
                }},
                7, "03:10:00"
        ));
    }

    @GetMapping("/flash")
    public String showFlashController(Model model) {
        model.addAttribute("flashProducts", flashStore.values());
        return "flash";
    }

    @GetMapping("/flashsaleproduct")
    public String showFlashSaleProduct(@RequestParam(value = "id", defaultValue = "himalaya-face-scrub") String id, Model model) {
        FlashProduct product = flashStore.get(id);

        if (product == null) {
            product = flashStore.get("himalaya-face-scrub");
        }

        model.addAttribute("product", product);
        return "flashsaleproduct";
    }
}