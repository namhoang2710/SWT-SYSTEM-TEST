package com.fu.swp391.group1.smokingcessation.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class CorsConfig {

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                registry.addMapping("/**")
                        .allowedOriginPatterns("http://localhost:*", "http://127.0.0.1:*") // Dùng allowedOriginPatterns thay vì allowedOrigins
                        .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD","PATCH")
                        .allowedHeaders("*")
                        .exposedHeaders("Authorization")
                        .allowCredentials(true) // Đổi thành true
                        .maxAge(3600);
            }
        };
    }
}
