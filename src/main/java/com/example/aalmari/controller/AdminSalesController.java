package com.example.aalmari.controller;

import com.example.aalmari.dto.AdminSalesSummaryResponse;
import com.example.aalmari.service.AdminSalesService;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/admin/sales")
@CrossOrigin(origins = {"http://localhost:8000", "http://127.0.0.1:8000"})
public class AdminSalesController {

    private final AdminSalesService adminSalesService;

    public AdminSalesController(AdminSalesService adminSalesService) {
        this.adminSalesService = adminSalesService;
    }

    @GetMapping("/summary")
    public AdminSalesSummaryResponse getSalesSummary() {
        return adminSalesService.getSummary();
    }
}
