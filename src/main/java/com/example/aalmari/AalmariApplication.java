package com.example.aalmari;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class AalmariApplication {
    public static void main(String[] args) {
        SpringApplication.run(AalmariApplication.class, args);
    }
}
