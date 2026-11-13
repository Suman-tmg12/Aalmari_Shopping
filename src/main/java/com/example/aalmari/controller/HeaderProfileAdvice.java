package com.example.aalmari.controller;

import com.example.aalmari.model.User;
import com.example.aalmari.service.UserService;
import com.example.aalmari.service.impl.S3Service;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * Adds "headerPicUrl" to the model of every page, so header.jsp can show the
 * logged-in user's profile picture on any page (home, cart, flash sale, ...).
 *
 * Only the picture PATH is kept in the session ("userProfilePicPath"). The URL is
 * generated fresh on each page view, so a time-limited S3 link never goes stale.
 */
@ControllerAdvice
public class HeaderProfileAdvice {

    @Autowired
    private UserService userService;

    @Autowired
    private S3Service s3Service;

    @ModelAttribute("headerPicUrl")
    public String headerPicUrl(HttpSession session, HttpServletRequest request) {
        // skip JSON/API calls (e.g. /api/cart/count): they don't render the header
        if (request.getRequestURI().contains("/api/")) return null;

        Object uid = session.getAttribute("userId");
        if (!(uid instanceof Number)) return null;

        String path;
        Object cached = session.getAttribute("userProfilePicPath");
        if (cached == null) {
            // Session from before this change: load once from the DB, then cache it
            path = userService.findById(((Number) uid).longValue())
                    .map(User::getProfilePicPath)
                    .orElse("");
            if (path == null) path = "";
            session.setAttribute("userProfilePicPath", path);
        } else {
            path = cached.toString();
        }

        if (path.isEmpty()) return null;

        try {
            return s3Service.generateProfilePicUrl(path);
        } catch (Exception e) {
            return null;   // header falls back to the default account icon
        }
    }
}