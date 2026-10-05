package com.example.aalmari.controller;

import com.example.aalmari.model.User;
import com.example.aalmari.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import jakarta.servlet.http.HttpSession;

@Controller
public class AccountController {

    @Autowired
    private UserService userService;

    // ---------- SIGNUP ----------

    @GetMapping("/signin")
    public String showSignInPage() {
        return "auth/signin"; // -> /WEB-INF/views/signin.jsp
    }

    @PostMapping("/register")
    public String registerUser(
            @RequestParam String name,
            @RequestParam String email,
            @RequestParam String country,
            @RequestParam String phone,
            @RequestParam String password,
            @RequestParam(required = false) String terms,
            Model model) {

        if (name.isBlank() || email.isBlank() || country.isBlank()
                || phone.isBlank() || password.isBlank()) {
            model.addAttribute("error", "All fields are required.");
            return "auth/signin";
        }

        if (terms == null) {
            model.addAttribute("error", "You must accept the Terms of Service.");
            return "auth/signin";
        }

        if (password.length() < 8) {
            model.addAttribute("error", "Password must be at least 8 characters.");
            return "auth/signin";
        }

        if (userService.emailExists(email)) {
            model.addAttribute("error", "An account with this email already exists.");
            return "auth/signin";
        }

        userService.registerUser(name, email, country, phone, password);

        return "redirect:/login?registered=true";
    }

    // ---------- LOGIN ----------

    @GetMapping("/login")
    public String showLoginPage(
            @RequestParam(required = false) String registered,
            Model model) {

        if (registered != null) {
            model.addAttribute("success", "Account created successfully! Please log in.");
        }
        return "auth/login"; // -> /WEB-INF/views/login.jsp
    }

    @PostMapping("/login")
    public String loginUser(
            @RequestParam String email,
            @RequestParam String password,
            HttpSession session,
            Model model) {

        User user = userService.findByEmail(email).orElse(null);

        if (user == null || !userService.checkLogin(email, password)) {
            model.addAttribute("error", "Invalid email or password. Please try again.");
            return "auth/login";
        }

        session.setAttribute("userId", user.getId());
        session.setAttribute("userName", user.getName());
        session.setAttribute("userEmail", user.getEmail());

        return "redirect:/welcome";
    }

    // ---------- WELCOME ----------

    @GetMapping("/welcome")
    public String showWelcomePage(HttpSession session, Model model) {
        if (session.getAttribute("userId") == null) {
            return "redirect:/login";
        }
        model.addAttribute("userName", session.getAttribute("userName"));
        return "welcome"; // -> /WEB-INF/views/welcome.jsp
    }

    // ---------- LOGOUT ----------

    @GetMapping("/logout")
    public String logoutUser(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}