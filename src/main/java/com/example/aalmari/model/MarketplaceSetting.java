package com.example.aalmari.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "marketplace_settings")
public class MarketplaceSetting {

    public static final String PLATFORM_NAME_KEY = "platformName";
    public static final String DEFAULT_PLATFORM_NAME = "Aalmari Multi-Vendor Online";

    @Id
    @Column(name = "setting_key", length = 64)
    private String key;

    @Column(name = "setting_value", nullable = false, length = 80)
    private String value;

    protected MarketplaceSetting() {
    }

    public String getValue() {
        return value;
    }
}
