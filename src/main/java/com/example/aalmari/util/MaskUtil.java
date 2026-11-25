package com.example.aalmari.util;

public final class MaskUtil {

    private MaskUtil() {}

    public static String maskAccountNumber(String accountNumber) {
        if (accountNumber == null || accountNumber.isBlank()) {
            return "";
        }

        String value = accountNumber.trim();
        if (value.length() <= 4) {
            return "*".repeat(value.length());
        }

        return "*".repeat(value.length() - 4) + value.substring(value.length() - 4);
    }
}
