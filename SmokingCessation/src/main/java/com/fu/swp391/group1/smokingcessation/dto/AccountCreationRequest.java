package com.fu.swp391.group1.smokingcessation.dto;

import org.springframework.web.multipart.MultipartFile;

public class AccountCreationRequest {

    private String email;
    private String password;
    private String name;
    private int yearbirth;
    private String gender;
    private String role;
    private String status;
    private MultipartFile image;

    public AccountCreationRequest() {
    }

    public AccountCreationRequest(String email, String password, String name, int yearbirth, String gender, String role, String status, MultipartFile image) {
        this.email = email;
        this.password = password;
        this.name = name;
        this.yearbirth = yearbirth;
        this.gender = gender;
        this.role = role;
        this.status = status;
        this.image = image;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getYearbirth() {
        return yearbirth;
    }

    public void setYearbirth(int yearbirth) {
        this.yearbirth = yearbirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public MultipartFile getImage() {
        return image;
    }

    public void setImage(MultipartFile image) {
        this.image = image;
    }

}
