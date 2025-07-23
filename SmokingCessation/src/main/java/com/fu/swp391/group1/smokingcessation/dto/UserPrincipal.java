package com.fu.swp391.group1.smokingcessation.dto;



public class UserPrincipal {
    private String username;
    private Long userId;
    private Long coachId;
    private String role;

    public UserPrincipal(String username, Long userId,Long coachId, String role) {
        this.username = username;
        this.userId = userId;
        this.coachId = coachId;
        this.role = role;
    }
    
    public String getUsername() {
        return username;
    }
    public Long getUserId() {
        return userId;
    }
    public Long getCoachId() {return coachId;
    }
    public String getRole() {
        return role;
    }

}