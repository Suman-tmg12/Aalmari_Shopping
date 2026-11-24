package com.example.aalmari.service;

import com.example.aalmari.dto.AdminSalesSummaryResponse;
import com.example.aalmari.repository.OrderItemRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Service
public class AdminSalesService {

    private static final DateTimeFormatter MONTH_LABEL = DateTimeFormatter.ofPattern("MMM yyyy");

    private final OrderItemRepository orderItemRepository;

    public AdminSalesService(OrderItemRepository orderItemRepository) {
        this.orderItemRepository = orderItemRepository;
    }

    public AdminSalesSummaryResponse getSummary() {
        List<Object[]> deliveredSales = orderItemRepository.findDeliveredSalesData();
        Map<YearMonth, Long> monthlyTotals = new HashMap<>();
        Set<Long> deliveredOrderIds = new HashSet<>();
        long grossSales = 0;

        for (Object[] row : deliveredSales) {
            long lineTotal = ((Number) row[0]).longValue();
            LocalDateTime soldAt = (LocalDateTime) row[1];
            Long orderId = ((Number) row[2]).longValue();

            grossSales += lineTotal;
            deliveredOrderIds.add(orderId);
            YearMonth month = YearMonth.from(soldAt);
            monthlyTotals.merge(month, lineTotal, Long::sum);
        }

        YearMonth currentMonth = YearMonth.from(LocalDate.now());
        List<AdminSalesSummaryResponse.MonthlySales> months = new ArrayList<>(6);
        for (int offset = 5; offset >= 0; offset--) {
            YearMonth month = currentMonth.minusMonths(offset);
            months.add(new AdminSalesSummaryResponse.MonthlySales(
                    month.format(MONTH_LABEL),
                    monthlyTotals.getOrDefault(month, 0L)
            ));
        }

        return new AdminSalesSummaryResponse("NPR", grossSales, deliveredOrderIds.size(), months);
    }
}
