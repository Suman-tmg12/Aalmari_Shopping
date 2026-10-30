package com.example.aalmari.repository;

import com.example.aalmari.model.SellerProduct;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SellerProductRepository extends JpaRepository<SellerProduct, Long> {

    Optional<SellerProduct> findBySku(String sku);

    // Category page: all sub-categories
    List<SellerProduct> findByActiveTrueAndCategoryIgnoreCaseOrderByIdDesc(String category);

    // Category page: one sub-category
    List<SellerProduct> findByActiveTrueAndCategoryIgnoreCaseAndSubCategoryIgnoreCaseOrderByIdDesc(
            String category, String subCategory);

    // Search page: matches name, category or sub-category
    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND (:q = ''
                  OR LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))
                  OR LOWER(p.category) LIKE LOWER(CONCAT('%', :q, '%'))
                  OR LOWER(p.subCategory) LIKE LOWER(CONCAT('%', :q, '%')))
           ORDER BY p.id DESC
           """)
    List<SellerProduct> searchActive(@Param("q") String q);

    // Store page: all active products of one seller (newest first)
    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true AND p.seller.id = :sellerId
           ORDER BY p.id DESC
           """)
    List<SellerProduct> findBySeller_IdAndActiveTrue(@Param("sellerId") Long sellerId);
}