package com.example.aalmari.repository;

import com.example.aalmari.model.SellerProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SellerProductRepository extends JpaRepository<SellerProduct, Long> {
    Optional<SellerProduct> findBySku(String sku);
    // Add other query methods if needed
}