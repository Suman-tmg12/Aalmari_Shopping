package com.example.aalmari.config;

import com.example.aalmari.service.RememberMeService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Component
public class RememberMeConfig implements WebMvcConfigurer {

    private final RememberMeService rememberMeService;

    public RememberMeConfig(RememberMeService rememberMeService) {
        this.rememberMeService = rememberMeService;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new HandlerInterceptor() {
            @Override
            public boolean preHandle(@NonNull HttpServletRequest request,
                                     @NonNull HttpServletResponse response,
                                     @NonNull Object handler) {
                rememberMeService.restoreSession(request, response, request.getSession(true));
                return true;
            }
        }).addPathPatterns("/**");
    }
}

