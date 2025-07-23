package com.fu.swp391.group1.smokingcessation.dto;

import org.springframework.web.multipart.MultipartFile;

public class MedalCreationRequest {

    private String name;
    private String description;
    private String type;
    private MultipartFile image;

    public MedalCreationRequest() {
    }

    public MedalCreationRequest(String name, String description, String type , MultipartFile image) {
        this.name = name;
        this.description = description;
        this.type = type;
        this.image = image;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public MultipartFile getImage() {
        return image;
    }

    public void setImage(MultipartFile image) {
        this.image = image;
    }
}
