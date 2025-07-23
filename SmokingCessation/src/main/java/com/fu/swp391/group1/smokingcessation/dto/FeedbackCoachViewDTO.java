package com.fu.swp391.group1.smokingcessation.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class FeedbackCoachViewDTO {
    private int coachFeedbackID;
    private String information;
    private LocalDate createdDate;
    private LocalTime createdTime;

    //account post
    private Long id;
    private String name;
    private String image;


    public FeedbackCoachViewDTO() {
    }

    public FeedbackCoachViewDTO(int coachFeedbackID, String information, LocalDate createdDate, LocalTime createdTime, Long id, String name, String image) {
        this.coachFeedbackID = coachFeedbackID;
        this.information = information;
        this.createdDate = createdDate;
        this.createdTime = createdTime;
        this.id = id;
        this.name = name;
        this.image = image;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalTime getCreatedTime() {
        return createdTime;
    }

    public void setCreatedTime(LocalTime createdTime) {
        this.createdTime = createdTime;
    }

    public LocalDate getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDate createdDate) {
        this.createdDate = createdDate;
    }

    public String getInformation() {
        return information;
    }

    public void setInformation(String information) {
        this.information = information;
    }

    public int getCoachFeedbackID() {
        return coachFeedbackID;
    }

    public void setCoachFeedbackID(int coachFeedbackID) {
        this.coachFeedbackID = coachFeedbackID;
    }
}
