package com.example.aalmari.service;

import com.example.aalmari.model.RememberMeToken;
import com.example.aalmari.model.User;
import com.example.aalmari.repository.RememberMeTokenRepository;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Base64;
import java.util.Optional;

@Service
public class RememberMeService {

    public static final String COOKIE_NAME = "AALMARI_REMEMBER_ME";
    private static final int COOKIE_AGE_SECONDS = 30 * 24 * 60 * 60;

    private final RememberMeTokenRepository tokenRepository;
    private final SecureRandom secureRandom = new SecureRandom();

    public RememberMeService(RememberMeTokenRepository tokenRepository) {
        this.tokenRepository = tokenRepository;
    }

    @Transactional
    public void createToken(User user, HttpServletResponse response) {
        byte[] random = new byte[32];
        secureRandom.nextBytes(random);
        String rawToken = Base64.getUrlEncoder().withoutPadding().encodeToString(random);

        RememberMeToken stored = new RememberMeToken();
        stored.setUser(user);
        stored.setTokenHash(hash(rawToken));
        stored.setExpiresAt(LocalDateTime.now().plusDays(30));
        tokenRepository.save(stored);

        Cookie cookie = new Cookie(COOKIE_NAME, rawToken);
        cookie.setHttpOnly(true);
        cookie.setSecure(false); // Set true when HTTPS is enabled in production.
        cookie.setPath("/");
        cookie.setMaxAge(COOKIE_AGE_SECONDS);
        response.addCookie(cookie);
    }

    @Transactional
    public boolean restoreSession(HttpServletRequest request, HttpServletResponse response, HttpSession session) {
        if (session.getAttribute("userId") != null) return true;

        String rawToken = null;
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (COOKIE_NAME.equals(cookie.getName())) {
                    rawToken = cookie.getValue();
                    break;
                }
            }
        }
        if (rawToken == null || rawToken.isBlank()) return false;

        Optional<RememberMeToken> match = tokenRepository
                .findByTokenHashAndExpiresAtAfter(hash(rawToken), LocalDateTime.now());
        if (match.isEmpty()) {
            clearCookie(response);
            return false;
        }

        User user = match.get().getUser();
        if (user == null) {
            clearCookie(response);
            return false;
        }

        setSession(session, user);
        return true;
    }

    @Transactional
    public void revokeForUser(Long userId, HttpServletResponse response) {
        tokenRepository.deleteByUser_Id(userId);
        clearCookie(response);
    }

    public void clearCookie(HttpServletResponse response) {
        Cookie cookie = new Cookie(COOKIE_NAME, "");
        cookie.setHttpOnly(true);
        cookie.setSecure(false);
        cookie.setPath("/");
        cookie.setMaxAge(0);
        response.addCookie(cookie);
    }

    public void setSession(HttpSession session, User user) {
        session.setAttribute("userId", user.getId());
        session.setAttribute("userFirstName", user.getFirstName());
        session.setAttribute("userLastName", user.getLastName());
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userPhone", user.getPhone());
        session.setAttribute("userProfilePicPath", user.getProfilePicPath() == null ? "" : user.getProfilePicPath());
    }

    private String hash(String rawToken) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] bytes = digest.digest(rawToken.getBytes(StandardCharsets.UTF_8));
            StringBuilder hex = new StringBuilder(bytes.length * 2);
            for (byte b : bytes) hex.append(String.format("%02x", b));
            return hex.toString();
        } catch (Exception e) {
            throw new IllegalStateException("Could not secure remember-me token.", e);
        }
    }
}

