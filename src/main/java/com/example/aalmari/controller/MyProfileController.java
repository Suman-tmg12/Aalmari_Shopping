package com.example.aalmari.controller;

import com.example.aalmari.model.User;
import com.example.aalmari.service.UserService;
import com.example.aalmari.service.impl.S3Service;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

@Controller
public class MyProfileController {

    @Autowired
    private UserService userService;

    @Autowired
    private S3Service s3Service;

    @GetMapping("/myprofile")
    public String showMyProfile(HttpSession session, Model model) {
        Long userId = (Long) session.getAttribute("userId");

        if (userId != null) {
            userService.findById(userId).ifPresent(user -> {
                String path = user.getProfilePicPath();
                if (path != null && !path.isEmpty()) {
                    model.addAttribute("profilePicUrl", s3Service.generateProfilePicUrl(path));
                }
            });
        }

        return "myprofile";
    }

    @PostMapping("/myprofile/update")
    public String updateProfile(@RequestParam("firstName") String firstName,
                                @RequestParam("lastName") String lastName,
                                @RequestParam("phone") String phone,
                                @RequestParam(value = "profilePic", required = false) MultipartFile profilePic,
                                HttpSession session) {

        Long userId = (Long) session.getAttribute("userId");
        if (userId == null) {
            return "redirect:/login";
        }

        User updated = userService.updateProfile(userId, firstName, lastName, phone, profilePic);

        // keep session text fields in sync so header/sidebar name update immediately
        session.setAttribute("userFirstName", updated.getFirstName());
        session.setAttribute("userLastName", updated.getLastName());
        session.setAttribute("userPhone", updated.getPhone());

        return "redirect:/myprofile?saved=true";
    }
}