package com.example.aalmari.util;

import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;

public final class PaginationSupport {
    private PaginationSupport() {}

    public static int page(int requestedPage) {
        return Math.max(1, requestedPage);
    }

    public static int size(int requestedSize, int minimum, int maximum, int defaultSize) {
        if (requestedSize <= 0) return defaultSize;
        return Math.max(minimum, Math.min(maximum, requestedSize));
    }

    public static Pageable pageable(int requestedPage, int pageSize, Sort sort) {
        return PageRequest.of(page(requestedPage) - 1, pageSize, sort);
    }

    public static int currentPage(int requestedPage, int totalPages) {
        int safePage = page(requestedPage);
        return totalPages == 0 ? 1 : Math.min(safePage, totalPages);
    }

    public static int totalPages(long totalItems, int pageSize) {
        if (totalItems <= 0 || pageSize <= 0) return 0;
        return (int) ((totalItems + pageSize - 1) / pageSize);
    }
}

