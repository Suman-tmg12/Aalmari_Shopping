package com.example.aalmari.controller;

import com.example.aalmari.model.Product;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.*;

@Controller
public class ProductController {

    private final Map<String, Product> productStore = new HashMap<>();

    public ProductController() {
        initProducts();
    }

    private void initProducts() {
        productStore.put("hair-spray", new Product(
                "hair-spray", "Hair Spray", "Beauty & Personal Care", "Haircare",
                "hairSpray.jpg", Arrays.asList("hairSpray.jpg"),
                "Rs.70", "Rs.150", "-53%", 4.5, 452,
                "Keep your hair styled and looking fresh all day with long-lasting strong hold.",
                Arrays.asList("Default"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Volume", "250ml");
                    put("Hold Level", "Extra Strong");
                }}
        ));

        productStore.put("olipop-cherry", new Product(
                "olipop-cherry", "OLIPOP Cherry Vanilla", "Groceries", "Beverages",
                "olipop.jpg", Arrays.asList("olipop.jpg"),
                "Rs.120", "Rs.180", "-33%", 4.8, 320,
                "A refreshing soda with plant-based ingredients, prebiotics, and low sugar.",
                Arrays.asList("Cherry"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Volume", "355ml");
                    put("Sugar", "2g");
                }}
        ));

        productStore.put("nike-shoes", new Product(
                "nike-shoes", "Nike Dunk Low Blue", "Fashion", "Footwear",
                "nikeShoe.jpg", Arrays.asList("nikeShoe.jpg"),
                "Rs.200", "Rs.350", "-43%", 4.9, 810,
                "Classic blue and white leather retro sneakers with rubber outsole.",
                Arrays.asList("Blue/White", "Black/White"), Arrays.asList("UK 7", "UK 8", "UK 9", "UK 10"),
                new LinkedHashMap<String, String>() {{
                    put("Material", "Leather");
                    put("Closure", "Lace-Up");
                }}
        ));

        productStore.put("black-glasses", new Product(
                "black-glasses", "Black Glasses", "Fashion", "Accessories",
                "BlackGlass.jpg", Arrays.asList("BlackGlass.jpg"),
                "Rs.90", "Rs.150", "-40%", 4.6, 230,
                "Sleek UV400 protected dark sunglasses with durable frame.",
                Arrays.asList("Black"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Protection", "100% UV400");
                }}
        ));

        productStore.put("white-spray", new Product(
                "white-spray", "White Spray", "Beauty & Personal Care", "Bodycare",
                "WhiteSpray.jpg", Arrays.asList("WhiteSpray.jpg"),
                "Rs.80", "Rs.130", "-38%", 4.4, 180,
                "Multi-purpose refreshing spray for everyday freshness.",
                Arrays.asList("White"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Volume", "200ml");
                }}
        ));

        productStore.put("falcon-spray", new Product(
                "falcon-spray", "Falcon Spray", "Beauty & Personal Care", "Fragrance",
                "FalconSpray.jpg", Arrays.asList("FalconSpray.jpg"),
                "Rs.110", "Rs.200", "-45%", 4.7, 560,
                "Premium long-lasting fragrance spray designed for all-day protection.",
                Arrays.asList("Falcon"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Scent Profile", "Woody & Fresh");
                }}
        ));

        productStore.put("iphone-15-pro", new Product(
                "iphone-15-pro", "iPhone 15 Pro", "Electronics", "Mobile Phones",
                "iphone15pro.jpg", Arrays.asList("iphone15pro.jpg"),
                "Rs.1500", "Rs.1800", "-17%", 4.9, 1240,
                "Titanium design with A17 Pro chip and 48MP camera system.",
                Arrays.asList("Natural Titanium", "Blue Titanium"), Arrays.asList("128GB", "256GB"),
                new LinkedHashMap<String, String>() {{
                    put("Processor", "A17 Pro");
                }}
        ));

        productStore.put("macbook-pro-m3", new Product(
                "macbook-pro-m3", "MacBook Pro M3", "Electronics", "Laptops",
                "MacBookProm3.jpg", Arrays.asList("MacBookProm3.jpg"),
                "Rs.2200", "Rs.2500", "-12%", 5.0, 970,
                "Supercharged by M3 chip with Liquid Retina XDR display.",
                Arrays.asList("Space Black", "Silver"), Arrays.asList("512GB", "1TB"),
                new LinkedHashMap<String, String>() {{
                    put("Chip", "Apple M3");
                }}
        ));

        productStore.put("airpods-pro", new Product(
                "airpods-pro", "AirPods Pro", "Electronics", "Audio",
                "Airpods.jpg", Arrays.asList("Airpods.jpg"),
                "Rs.250", "Rs.350", "-28%", 4.8, 1520,
                "Active Noise Cancellation and Personalized Spatial Audio.",
                Arrays.asList("White"), Collections.emptyList(),
                new LinkedHashMap<String, String>() {{
                    put("Connectivity", "Bluetooth 5.3");
                }}
        ));
    }

    @GetMapping("/product")
    public String showProductDetail(@RequestParam(value = "id", defaultValue = "hair-spray") String id, Model model) {
        Product product = productStore.get(id);

        if (product == null) {
            product = productStore.get("hair-spray");
        }

        model.addAttribute("product", product);
        return "product";
    }
}