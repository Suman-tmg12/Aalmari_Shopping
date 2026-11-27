package com.example.aalmari.repository;

import com.example.aalmari.model.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByIdAndUser_Id(Long id, Long userId);

    List<Order> findByUser_IdOrderByIdDesc(Long userId);

    List<Order> findTop20ByUser_IdOrderByIdDesc(Long userId);

    Optional<Order> findByTransactionUuid(String transactionUuid);

    List<Order> findByStatusAndPaymentMethod(String status, String paymentMethod);

    Page<Order> findByUser_Id(Long userId, Pageable pageable);

    @org.springframework.data.jpa.repository.Query("""
           SELECT o FROM ShopOrder o
           WHERE o.user.id = :userId
             AND (:status = 'all'
                  OR (:status = 'processing' AND o.status IN ('PLACED', 'PENDING_PAYMENT'))
                  OR (:status = 'shipped' AND o.status = 'SHIPPED')
                  OR (:status = 'delivered' AND o.status = 'DELIVERED')
                  OR (:status = 'cancelled' AND o.status = 'CANCELLED'))
           ORDER BY o.id DESC
           """)
    Page<Order> findByUserAndStatus(@org.springframework.data.repository.query.Param("userId") Long userId,
                                    @org.springframework.data.repository.query.Param("status") String status,
                                    Pageable pageable);

    Page<Order> findByStatus(String status, Pageable pageable);
}