package com.example.aalmari.repository;

import com.example.aalmari.model.ProductReview;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ProductReviewRepository extends JpaRepository<ProductReview, Long> {

    Optional<ProductReview> findByUser_IdAndProduct_Id(Long userId, Long productId);

    @Query("select r from ProductReview r join fetch r.user u join fetch r.product p " +
            "where p.id = :productId order by r.createdAt desc")
    List<ProductReview> findForProductNewest(@Param("productId") Long productId);

    @Query("select coalesce(avg(r.rating), 0) from ProductReview r where r.product.id = :productId")
    double averageForProduct(@Param("productId") Long productId);

    long countByProduct_Id(Long productId);

    @Query("select r from ProductReview r join fetch r.user u join fetch r.product p " +
            "where p.seller.id = :sellerId order by r.createdAt desc")
    List<ProductReview> findForSellerNewest(@Param("sellerId") Long sellerId);

    @Query("select coalesce(avg(r.rating), 0) from ProductReview r where r.product.seller.id = :sellerId")
    double averageForSeller(@Param("sellerId") Long sellerId);

    @Query("select count(r) from ProductReview r where r.product.seller.id = :sellerId")
    long countForSeller(@Param("sellerId") Long sellerId);
}

