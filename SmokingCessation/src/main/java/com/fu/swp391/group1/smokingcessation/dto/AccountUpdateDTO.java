package com.fu.swp391.group1.smokingcessation.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.*;
import org.springframework.web.multipart.MultipartFile;

public class AccountUpdateDTO {

    private String name;
    @Schema(hidden = true)
    private String email;
    private Integer yearbirth;

    private String gender;

    private MultipartFile image;

    private String password;

    public AccountUpdateDTO() {
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public Integer getYearbirth() {
        return yearbirth;
    }

    public void setYearbirth(Integer yearbirth) {
        this.yearbirth = yearbirth;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public MultipartFile getImage() {
        return image;
    }

    public void setImage(MultipartFile image) {
        this.image = image;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}