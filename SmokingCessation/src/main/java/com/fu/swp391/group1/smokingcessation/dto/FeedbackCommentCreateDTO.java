package com.fu.swp391.group1.smokingcessation.dto;

public class FeedbackCommentCreateDTO {

    private String information;

    public FeedbackCommentCreateDTO() {
    }

    public FeedbackCommentCreateDTO(String information) {
        this.information = information;
    }

    public String getInformation() {
        return information;
    }

    public void setInformation(String information) {
        this.information = information;
    }
}
