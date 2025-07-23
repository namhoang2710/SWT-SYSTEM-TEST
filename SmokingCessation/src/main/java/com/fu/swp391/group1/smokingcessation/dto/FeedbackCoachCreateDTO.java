package com.fu.swp391.group1.smokingcessation.dto;

public class FeedbackCoachCreateDTO {
    private String information;

    public FeedbackCoachCreateDTO() {
    }

    public FeedbackCoachCreateDTO(String information) {
        this.information = information;
    }

    public String getInformation() {
        return information;
    }

    public void setInformation(String information) {
        this.information = information;
    }
}
