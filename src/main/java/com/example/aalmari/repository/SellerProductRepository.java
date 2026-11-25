package com.example.aalmari.repository;

import com.example.aalmari.model.SellerProduct;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SellerProductRepository extends JpaRepository<SellerProduct, Long> {

    Optional<SellerProduct> findBySku(String sku);

    // Keep every storefront query restricted to products explicitly approved by an admin.
    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND LOWER(p.category) = LOWER(:category)
           ORDER BY p.id DESC
           """)
    List<SellerProduct> findByActiveTrueAndCategoryIgnoreCaseOrderByIdDesc(@Param("category") String category);

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND LOWER(p.category) = LOWER(:category)
             AND LOWER(p.subCategory) = LOWER(:subCategory)
           ORDER BY p.id DESC
           """)
    List<SellerProduct> findByActiveTrueAndCategoryIgnoreCaseAndSubCategoryIgnoreCaseOrderByIdDesc(
            @Param("category") String category, @Param("subCategory") String subCategory);

    // Search page: matches name, category or sub-category
    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND (:q = ''
                  OR LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))
                  OR LOWER(p.category) LIKE LOWER(CONCAT('%', :q, '%'))
                  OR LOWER(p.subCategory) LIKE LOWER(CONCAT('%', :q, '%')))
           ORDER BY p.id DESC
           """)
    List<SellerProduct> searchActive(@Param("q") String q);

    // Search suggestions (autocomplete): active product names only.
    // Names that START with the query rank first, then names that merely contain it.
    // The caller must escape %, _ and ! in :q using '!' (see SearchSuggestController).
    @Query("""
           SELECT p.name FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%')) ESCAPE '!'
           ORDER BY CASE WHEN LOWER(p.name) LIKE LOWER(CONCAT(:q, '%')) ESCAPE '!'
                         THEN 0 ELSE 1 END,
                    p.name
           """)
    List<String> suggestNames(@Param("q") String q, Pageable pageable);

    // Public store page: only active, approved products of one seller (newest first).
    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.seller.id = :sellerId
           ORDER BY p.id DESC
           """)
    List<SellerProduct> findBySeller_IdAndActiveTrue(@Param("sellerId") Long sellerId);

    // ---------- "You May Also Like" ----------
    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND LOWER(p.subCategory) = LOWER(:subCategory) AND p.id <> :id
           ORDER BY p.sold DESC, p.id DESC
           """)
    List<SellerProduct> findTop40ByActiveTrueAndSubCategoryIgnoreCaseAndIdNotOrderBySoldDescIdDesc(
            @Param("subCategory") String subCategory, @Param("id") Long id);

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND LOWER(p.category) = LOWER(:category) AND p.id <> :id
           ORDER BY p.sold DESC, p.id DESC
           """)
    List<SellerProduct> findTop40ByActiveTrueAndCategoryIgnoreCaseAndIdNotOrderBySoldDescIdDesc(
            @Param("category") String category, @Param("id") Long id);

    // Public storefront: product must be active and its seller application must be approved.
    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
           ORDER BY p.id DESC
           """)
    List<SellerProduct> findAllPublicActive();

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.id = :id AND p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
           """)
    Optional<SellerProduct> findPublicActiveById(@Param("id") Long id);

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
             AND (:q = ''
                  OR LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%'))
                  OR LOWER(p.category) LIKE LOWER(CONCAT('%', :q, '%'))
                  OR LOWER(p.subCategory) LIKE LOWER(CONCAT('%', :q, '%')))
           ORDER BY p.id DESC
           """)
    List<SellerProduct> searchPublicActive(@Param("q") String q);

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
             AND LOWER(p.category) = LOWER(:category)
           ORDER BY p.id DESC
           """)
    List<SellerProduct> findPublicActiveByCategory(@Param("category") String category);

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
             AND LOWER(p.category) = LOWER(:category)
             AND LOWER(p.subCategory) = LOWER(:subCategory)
           ORDER BY p.id DESC
           """)
    List<SellerProduct> findPublicActiveByCategoryAndSubCategory(
            @Param("category") String category, @Param("subCategory") String subCategory);

    @Query("""
           SELECT p.name FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
             AND LOWER(p.name) LIKE LOWER(CONCAT('%', :q, '%')) ESCAPE '!'
           ORDER BY CASE WHEN LOWER(p.name) LIKE LOWER(CONCAT(:q, '%')) ESCAPE '!'
                         THEN 0 ELSE 1 END,
                    p.name
           """)
    List<String> suggestPublicNames(@Param("q") String q, Pageable pageable);

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.id <> :id
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
             AND LOWER(p.subCategory) = LOWER(:subCategory)
           ORDER BY p.sold DESC, p.id DESC
           """)
    List<SellerProduct> findPublicSimilarBySubCategory(
            @Param("subCategory") String subCategory,
            @Param("id") Long id,
            Pageable pageable);

    @Query("""
           SELECT p FROM SellerProduct p
           WHERE p.active = true
             AND p.approvalStatus = com.example.aalmari.model.ProductApprovalStatus.APPROVED
             AND p.id <> :id
             AND p.seller.id IN (
                 SELECT sd.userId FROM SellerDocumentation sd
                 WHERE LOWER(sd.status) = 'approved'
             )
             AND LOWER(p.category) = LOWER(:category)
           ORDER BY p.sold DESC, p.id DESC
           """)
    List<SellerProduct> findPublicSimilarByCategory(
            @Param("category") String category,
            @Param("id") Long id,
            Pageable pageable);
}