package com.fu.swp391.group1.smokingcessation.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class FeedbackCoachDTO {

    private int coachFeedbackID;
    private int accountID;
    private String information;
    private LocalDate createdDate;
    private LocalTime createdTime;

    public FeedbackCoachDTO() {
    }

    public FeedbackCoachDTO(int coachFeedbackID, int accountID, String information, LocalDate createdDate, LocalTime createdTime) {
        this.coachFeedbackID = coachFeedbackID;
        this.accountID = accountID;
        this.information = information;
        this.createdDate = createdDate;
        this.createdTime = createdTime;
    }

    public int getCoachFeedbackID() {
        return coachFeedbackID;
    }

    public void setCoachFeedbackID(int coachFeedbackID) {
        this.coachFeedbackID = coachFeedbackID;
    }

    public int getAccountID() {
        return accountID;
    }

    public void setAccountID(int accountID) {
        this.accountID = accountID;
    }

    public String getInformation() {
        return information;
    }

    public void setInformation(String information) {
        this.information = information;
    }

    public LocalDate getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDate createdDate) {
        this.createdDate = createdDate;
    }

    public LocalTime getCreatedTime() {
        return createdTime;
    }

    public void setCreatedTime(LocalTime createdTime) {
        this.createdTime = createdTime;
    }
}
