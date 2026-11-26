package com.example.aalmari.repository;

import com.example.aalmari.model.CustomerNotification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface CustomerNotificationRepository extends JpaRepository<CustomerNotification, Long> {
    List<CustomerNotification> findTop20ByUser_IdAndAudienceOrderByCreatedAtDesc(Long userId, String audience);
    long countByUser_IdAndAudienceAndReadAtIsNull(Long userId, String audience);
    Optional<CustomerNotification> findByIdAndUser_IdAndAudience(Long id, Long userId, String audience);
    boolean existsByUser_IdAndOrderIdAndAudience(Long userId, Long orderId, String audience);

    @Modifying
    @Query("update CustomerNotification n set n.readAt = :readAt " +
            "where n.user.id = :userId and n.audience = :audience and n.readAt is null")
    int markAllRead(@Param("userId") Long userId, @Param("audience") String audience,
                    @Param("readAt") java.time.LocalDateTime readAt);
}
