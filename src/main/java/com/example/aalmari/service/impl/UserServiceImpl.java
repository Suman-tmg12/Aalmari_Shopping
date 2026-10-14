package com.example.aalmari.service.impl;

import com.example.aalmari.model.User;
import com.example.aalmari.repository.UserRepository;
import com.example.aalmari.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Optional;

@Service
public class UserServiceImpl implements UserService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private S3Service s3Service;

    @Override
    public boolean emailExists(String email) {
        return userRepository.existsByEmail(email);
    }

    @Override
    public User registerUser(String firstName, String lastName, String email, String country,
                             String phone, String rawPassword) {

        User user = new User();
        user.setFirstName(firstName);
        user.setLastName(lastName);
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

    @Override
    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    @Override
    public User updateProfile(Long userId, String firstName, String lastName, String phone, MultipartFile profilePic) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found with id: " + userId));

        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setPhone(phone);

        if (profilePic != null && !profilePic.isEmpty()) {
            String key = s3Service.uploadProfilePic(profilePic, userId);
            user.setProfilePicPath(key);
        }

        return userRepository.save(user);
    }
}