package com.example.aalmari.service.impl;

import com.example.aalmari.model.User;
import com.example.aalmari.repository.UserRepository;
import com.example.aalmari.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Override
    public boolean emailExists(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public User registerUser(String name, String email, String country,
                             String phone, String rawPassword) {

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setCountry(country);
        user.setPhone(phone);
        user.setPassword(passwordEncoder.encode(rawPassword));

        return userRepository.save(user);
    }

    @Override
    public boolean checkLogin(String email, String rawPassword) {
        return userRepository.findByEmail(email)
                .map(user -> passwordEncoder.matches(rawPassword, user.getPassword()))
                .orElse(false);
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
}
