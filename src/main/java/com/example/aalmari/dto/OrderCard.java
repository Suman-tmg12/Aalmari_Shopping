package com.example.aalmari.dto;

import java.util.List;

/** One order as the My Profile page shows it. All text is ready to print. */
public class OrderCard {

    private final String orderNumber;
    private final String statusLabel;
    /** CSS pill class, e.g. pill-amber. */
    private final String statusClass;
    /** processing, shipped, delivered or cancelled: used by the filter tabs. */
    private final String statusGroup;
    private final String dateLabel;
    private final String totalLabel;
    private final String paymentLabel;
    private final String shippingAddress;
    private final int itemCount;
    private final List<OrderLineCard> lines;

    public OrderCard(String orderNumber, String statusLabel, String statusClass, String statusGroup,
                     String dateLabel, String totalLabel, String paymentLabel, String shippingAddress,
                     int itemCount, List<OrderLineCard> lines) {
        this.orderNumber = orderNumber;
        this.statusLabel = statusLabel;
        this.statusClass = statusClass;
        this.statusGroup = statusGroup;
        this.dateLabel = dateLabel;
        this.totalLabel = totalLabel;
        this.paymentLabel = paymentLabel;
        this.shippingAddress = shippingAddress;
        this.itemCount = itemCount;
        this.lines = List.copyOf(lines);
    }

    public String getOrderNumber() { return orderNumber; }
    public String getStatusLabel() { return statusLabel; }
    public String getStatusClass() { return statusClass; }
    public String getStatusGroup() { return statusGroup; }
    public String getDateLabel() { return dateLabel; }
    public String getTotalLabel() { return totalLabel; }
    public String getPaymentLabel() { return paymentLabel; }
    public String getShippingAddress() { return shippingAddress; }
    public int getItemCount() { return itemCount; }
    public List<OrderLineCard> getLines() { return lines; }
}