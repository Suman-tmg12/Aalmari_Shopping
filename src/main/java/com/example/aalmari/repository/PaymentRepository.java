package com.example.aalmari.repository;

import com.example.aalmari.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PaymentRepository extends JpaRepository<Payment, Long> {
    Optional<Payment> findByTransactionUuid(String transactionUuid);
}

