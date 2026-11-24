package com.example.aalmari.dto;

import java.util.List;

public record AdminSalesSummaryResponse(
        String currency,
        long grossSales,
        long deliveredOrderCount,
        List<MonthlySales> monthlySales
) {
    public record MonthlySales(String month, long grossSales) {}
}
