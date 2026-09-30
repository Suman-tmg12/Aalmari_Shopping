package com.example.aalmari.service;

import com.example.aalmari.model.User;

import java.util.Optional;

public interface UserService {
    boolean emailExists(String email);
    User registerUser(String name, String email, String country, String phone, String rawPassword);
    boolean checkLogin(String email, String rawPassword);
    Optional<User> findByEmail(String email);
}