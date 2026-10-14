package com.example.aalmari.service;

import com.example.aalmari.model.User;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

public interface UserService {
    boolean emailExists(String email);
    User registerUser(String firstName, String lastName, String email, String country, String phone, String rawPassword);
    boolean checkLogin(String email, String rawPassword);
    Optional<User> findByEmail(String email);
    Optional<User> findById(Long id);
    User updateProfile(Long userId, String firstName, String lastName, String phone, MultipartFile profilePic);
}