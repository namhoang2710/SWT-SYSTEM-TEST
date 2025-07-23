package com.fu.swp391.group1.smokingcessation.dto;

public class CoachUserDTO {
    private Long userId;
    private String userName;
    private String userEmail;
    private Integer userAge;
    private String userGender;

    // Constructor
    public CoachUserDTO(Long userId, String userName, String userEmail, Integer userAge, String userGender) {
        this.userId = userId;
        this.userName = userName;
        this.userEmail = userEmail;
        this.userAge = userAge;
        this.userGender = userGender;
    }

    // Getters and Setters
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public Integer getUserAge() { return userAge; }
    public void setUserAge(Integer userAge) { this.userAge = userAge; }

    public String getUserGender() { return userGender; }
    public void setUserGender(String userGender) { this.userGender = userGender; }
}