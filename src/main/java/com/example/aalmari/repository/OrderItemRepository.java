package com.example.aalmari.repository;

import com.example.aalmari.model.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    /** All lines that belong to this seller, newest order first. */
    @Query("select i from OrderItem i join fetch i.order o " +
            "where i.seller.id = :sellerId order by o.id desc, i.id asc")
    List<OrderItem> findForSeller(@Param("sellerId") Long sellerId);

    /** This seller's lines inside one order, found by order number (e.g. AAL-000042). */
    @Query("select i from OrderItem i join fetch i.order o " +
            "where o.orderNumber = :ref and i.seller.id = :sellerId")
    List<OrderItem> findForSellerByRef(@Param("ref") String ref, @Param("sellerId") Long sellerId);
}