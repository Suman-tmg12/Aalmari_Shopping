package com.example.aalmari.repository;

import com.example.aalmari.model.SellerDocumentation;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

public interface SellerDocumentationRepository extends JpaRepository<SellerDocumentation, Long> {
    Optional<SellerDocumentation> findByUserId(Long userId);
}