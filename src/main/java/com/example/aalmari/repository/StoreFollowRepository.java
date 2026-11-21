package com.example.aalmari.repository;

import com.example.aalmari.model.StoreFollow;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface StoreFollowRepository extends JpaRepository<StoreFollow, Long> {
    long countBySeller_Id(Long sellerId);
    Optional<StoreFollow> findByFollower_IdAndSeller_Id(Long followerId, Long sellerId);
}

