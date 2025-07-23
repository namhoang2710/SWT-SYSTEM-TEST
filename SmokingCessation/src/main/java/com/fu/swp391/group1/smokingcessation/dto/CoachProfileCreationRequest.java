package com.fu.swp391.group1.smokingcessation.dto;

import org.springframework.web.multipart.MultipartFile;

public class CoachProfileCreationRequest {

    private Long accountId;
    private String specialty;
    private String experience;
    private MultipartFile image;

    public CoachProfileCreationRequest() {}

    public CoachProfileCreationRequest(Long accountId, String specialty, String experience, MultipartFile image) {
        this.accountId = accountId;
        this.specialty = specialty;
        this.experience = experience;
        this.image = image;
    }

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public String getSpecialty() {
        return specialty;
    }

    public void setSpecialty(String specialty) {
        this.specialty = specialty;
    }

    public String getExperience() {
        return experience;
    }

    public void setExperience(String experience) {
        this.experience = experience;
    }

    public MultipartFile getImage() {
        return image;
    }

    public void setImage(MultipartFile image) {
        this.image = image;
    }
}
