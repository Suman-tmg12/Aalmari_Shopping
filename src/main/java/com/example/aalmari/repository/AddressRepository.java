package com.example.aalmari.repository;

import com.example.aalmari.model.Address;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface AddressRepository extends JpaRepository<Address, Long> {

    /** Default address first, then newest. */
    List<Address> findByUser_IdOrderByDefaultAddressDescIdDesc(Long userId);

    Optional<Address> findByIdAndUser_Id(Long id, Long userId);

    long countByUser_Id(Long userId);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("update Address a set a.defaultAddress = false where a.user.id = :userId")
    void clearDefault(@Param("userId") Long userId);
}