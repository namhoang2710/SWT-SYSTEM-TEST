package com.fu.swp391.group1.smokingcessation.dto;

public class FeedbackBlogCreateDTO {

    private String information;

    public FeedbackBlogCreateDTO() {
    }

    public FeedbackBlogCreateDTO(String information) {
        this.information = information;
    }

    public String getInformation() {
        return information;
    }

    public void setInformation(String information) {
        this.information = information;
    }
}
