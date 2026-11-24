package com.example.aalmari.repository;

import com.example.aalmari.model.PayoutSettlement;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PayoutSettlementRepository extends JpaRepository<PayoutSettlement, Long> {
    Optional<PayoutSettlement> findBySellerIdAndPeriod(Long sellerId, String period);
}

