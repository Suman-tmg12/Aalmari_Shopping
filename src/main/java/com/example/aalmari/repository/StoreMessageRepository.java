package com.example.aalmari.repository;

import com.example.aalmari.model.StoreMessage;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface StoreMessageRepository extends JpaRepository<StoreMessage, Long> {

    @Query("select m from StoreMessage m join fetch m.customer c join fetch m.seller s join fetch m.product p " +
            "where s.id = :sellerId order by m.createdAt desc")
    List<StoreMessage> findForSellerNewest(@Param("sellerId") Long sellerId);

    @Query("select m from StoreMessage m join fetch m.customer c join fetch m.seller s join fetch m.product p " +
            "where s.id = :sellerId and c.id = :customerId and p.id = :productId order by m.createdAt asc")
    List<StoreMessage> findThread(@Param("sellerId") Long sellerId,
                                  @Param("customerId") Long customerId,
                                  @Param("productId") Long productId);

    @Query("select m from StoreMessage m join fetch m.customer c join fetch m.seller s join fetch m.product p " +
            "where c.id = :customerId and p.id = :productId order by m.createdAt asc")
    List<StoreMessage> findCustomerThread(@Param("customerId") Long customerId,
                                          @Param("productId") Long productId);

    long countBySeller_IdAndUnreadForSellerTrue(Long sellerId);

    long countByCustomer_IdAndUnreadForCustomerTrue(Long customerId);
}

