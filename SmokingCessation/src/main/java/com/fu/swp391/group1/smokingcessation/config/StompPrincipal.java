package com.fu.swp391.group1.smokingcessation.config;

import java.security.Principal;

public class StompPrincipal implements Principal {
    private final Long userId;
    private final String role;

    public StompPrincipal(Long userId, String role) {
        this.userId = userId;
        this.role   = role;
    }

    @Override
    public String getName() {
        return userId.toString();
    }

    public String getRole() {
        return role;
    }
}

