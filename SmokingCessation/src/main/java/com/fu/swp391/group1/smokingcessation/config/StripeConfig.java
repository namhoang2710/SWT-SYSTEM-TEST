package com.fu.swp391.group1.smokingcessation.config;

import com.stripe.Stripe;

import jakarta.annotation.PostConstruct;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

@Configuration
public class StripeConfig {

    @Value("${stripe.api.key}")
    private String secretKey;

    @Value("${stripe.publishable.key}")
    private String publishableKey;

    @PostConstruct
        public void init() {
        if (secretKey != null && !secretKey.isEmpty()) {
            Stripe.apiKey = secretKey; 
        } else {
            throw new IllegalStateException("Stripe API key is not configured.");
        }
    }

    public String getPublishableKey() {
        return publishableKey;
    }
}