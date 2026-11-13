package com.example.aalmari.dto;

/** One product line inside an order card. Prices are already formatted for display. */
public class OrderLineCard {

    private final String name;
    private final String imageSrc;
    private final int quantity;
    private final String unitPriceLabel;
    private final String lineTotalLabel;

    public OrderLineCard(String name, String imageSrc, int quantity,
                         String unitPriceLabel, String lineTotalLabel) {
        this.name = name;
        this.imageSrc = imageSrc;
        this.quantity = quantity;
        this.unitPriceLabel = unitPriceLabel;
        this.lineTotalLabel = lineTotalLabel;
    }

    public String getName() { return name; }
    public String getImageSrc() { return imageSrc; }
    public int getQuantity() { return quantity; }
    public String getUnitPriceLabel() { return unitPriceLabel; }
    public String getLineTotalLabel() { return lineTotalLabel; }
}