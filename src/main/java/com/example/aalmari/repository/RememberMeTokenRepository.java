package com.example.aalmari.repository;

import com.example.aalmari.model.RememberMeToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.Optional;

public interface RememberMeTokenRepository extends JpaRepository<RememberMeToken, Long> {
    Optional<RememberMeToken> findByTokenHashAndExpiresAtAfter(String tokenHash, LocalDateTime now);
    void deleteByUser_Id(Long userId);
}

