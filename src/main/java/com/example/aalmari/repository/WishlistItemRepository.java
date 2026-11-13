package com.example.aalmari.repository;

import com.example.aalmari.model.WishlistItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface WishlistItemRepository extends JpaRepository<WishlistItem, Long> {

    boolean existsByUser_IdAndProduct_Id(Long userId, Long productId);

    long countByUser_Id(Long userId);

    /** Only the product ids: used by the pages to fill the hearts. */
    @Query("select w.product.id from WishlistItem w where w.user.id = :uid order by w.id desc")
    List<Long> findProductIds(@Param("uid") Long userId);

    /** Whole wishlist with the products loaded, newest first (My Profile page). */
    @Query("select w from WishlistItem w join fetch w.product p where w.user.id = :uid order by w.id desc")
    List<WishlistItem> findAllForUser(@Param("uid") Long userId);

    /** Idempotent remove: deleting something that is not there is fine. */
    @Modifying
    @Query("delete from WishlistItem w where w.user.id = :uid and w.product.id = :pid")
    int deleteByUserAndProduct(@Param("uid") Long userId, @Param("pid") Long productId);
}