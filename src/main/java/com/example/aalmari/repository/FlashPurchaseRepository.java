package com.example.aalmari.repository;

import com.example.aalmari.model.FlashPurchase;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface FlashPurchaseRepository extends JpaRepository<FlashPurchase, Long> {

    @Query("select coalesce(sum(p.qty), 0) from FlashPurchase p where p.userId = :uid and p.item.id = :iid")
    long bought(@Param("uid") Long uid, @Param("iid") Long itemId);

    @Modifying(clearAutomatically = true)
    @Query("delete from FlashPurchase p where p.item.id in (select i.id from FlashSaleItem i where i.sale.id = :saleId)")
    void deleteBySale(@Param("saleId") Long saleId);

    @Modifying(clearAutomatically = true)
    @Query("delete from FlashPurchase p where p.item.id in (select i.id from FlashSaleItem i where i.product.id = :pid)")
    void deleteByProduct(@Param("pid") Long productId);
}