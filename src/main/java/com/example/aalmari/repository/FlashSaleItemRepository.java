package com.example.aalmari.repository;

import com.example.aalmari.model.FlashSaleItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface FlashSaleItemRepository extends JpaRepository<FlashSaleItem, Long> {

    /** Items already booked in a non-ended sale that overlaps [start, end). */
    @Query("""
           select i from FlashSaleItem i join fetch i.product
           where i.product.id in :pids
             and i.sale.endedEarly = false
             and i.sale.endTime > :now
             and i.sale.startTime < :end and i.sale.endTime > :start
             and i.sale.id <> :excludeId
           """)
    List<FlashSaleItem> findOverlapping(@Param("pids") List<Long> pids, @Param("start") long start,
                                        @Param("end") long end, @Param("now") long now,
                                        @Param("excludeId") Long excludeId);

    /** The sale running right now for a product (the overlap rule means at most one). */
    @Query("""
           select i from FlashSaleItem i join fetch i.sale join fetch i.product
           where i.product.id = :pid and i.sale.endedEarly = false
             and i.sale.startTime <= :now and i.sale.endTime > :now
           """)
    List<FlashSaleItem> findLive(@Param("pid") Long pid, @Param("now") long now);

    /** Every deal that is live right now and can still be bought (storefront pages). */
    @Query("""
           select i from FlashSaleItem i join fetch i.sale s join fetch i.product p
           where s.endedEarly = false and s.startTime <= :now and s.endTime > :now
             and p.active = true and p.stock > 0 and i.sold < i.qty
           order by s.endTime asc, i.id desc
           """)
    List<FlashSaleItem> findAllLive(@Param("now") long now);

    /** One item with its sale and product loaded (flash product page). */
    @Query("select i from FlashSaleItem i join fetch i.sale join fetch i.product where i.id = :id")
    Optional<FlashSaleItem> findWithAll(@Param("id") Long id);

    @Query("""
           select count(i) from FlashSaleItem i
           where i.product.id = :pid and i.sale.endedEarly = false and i.sale.endTime > :now
           """)
    long countOpen(@Param("pid") Long pid, @Param("now") long now);

    /** Atomic: only succeeds while sold + n <= qty, so it can never oversell. Returns 1 or 0. */
    @Modifying(clearAutomatically = true)
    @Query("update FlashSaleItem i set i.sold = i.sold + :n where i.id = :id and i.sold + :n <= i.qty")
    int claim(@Param("id") Long id, @Param("n") int n);

    void deleteByProduct_Id(Long productId);
}