package com.example.aalmari.repository;

import com.example.aalmari.model.FlashSale;
import org.springframework.data.jpa.repository.*;
import java.util.List;
import java.util.Optional;

public interface FlashSaleRepository extends JpaRepository<FlashSale, Long> {
    List<FlashSale> findBySeller_IdOrderByStartTimeDesc(Long sellerId);
    Optional<FlashSale> findByIdAndSeller_Id(Long id, Long sellerId);

    @Modifying(clearAutomatically = true)
    @Query("delete from FlashSale s where not exists (select 1 from FlashSaleItem i where i.sale = s)")
    void deleteEmpty();
}