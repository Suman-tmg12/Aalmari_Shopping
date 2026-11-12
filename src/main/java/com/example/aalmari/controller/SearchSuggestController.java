package com.example.aalmari.controller;

import com.example.aalmari.repository.SellerProductRepository;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.stream.Collectors;

@RestController
public class SearchSuggestController {

    private static final int MIN_LEN = 2;
    private static final int MAX_LEN = 60;
    private static final int LIMIT = 8;

    private final SellerProductRepository repo;

    public SearchSuggestController(SellerProductRepository repo) {
        this.repo = repo;
    }

    @GetMapping("/api/search/suggest")
    public ResponseEntity<List<String>> suggest(
            @RequestParam(name = "q", defaultValue = "") String q) {

        q = q.trim();
        if (q.length() < MIN_LEN || q.length() > MAX_LEN) {
            return ResponseEntity.ok(List.of());
        }

        // Escape LIKE wildcards so users can't inject % or _ (matches ESCAPE '!')
        String safe = q.replace("!", "!!").replace("%", "!%").replace("_", "!_");

        // Fetch extra rows, then de-duplicate names in Java
        List<String> rows = repo.suggestNames(safe, PageRequest.of(0, LIMIT * 3));
        List<String> result = new LinkedHashSet<>(rows).stream()
                .limit(LIMIT)
                .collect(Collectors.toList());

        return ResponseEntity.ok()
                .cacheControl(CacheControl.maxAge(Duration.ofSeconds(30)).cachePrivate())
                .body(result);
    }
}