package com.example.aalmari.repository;

import com.example.aalmari.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, Long> {

    Optional<Order> findByIdAndUser_Id(Long id, Long userId);

    List<Order> findByUser_IdOrderByIdDesc(Long userId);
}