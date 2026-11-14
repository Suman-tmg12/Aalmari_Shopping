package com.example.aalmari.repository;

import com.example.aalmari.model.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {

    @Query("select i from OrderItem i join fetch i.order o " +
            "where i.seller.id = :sellerId order by o.id desc, i.id asc")
    List<OrderItem> findForSeller(@Param("sellerId") Long sellerId);
}