package com.fu.swp391.group1.smokingcessation.entity;


import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "FeedbackCoach")
public class FeedbackCoach {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CoachFeedbackID")
    private int coachFeedbackID;

    @ManyToOne
    @JoinColumn(name = "AccountID", nullable = false)
    private Account account;

    @ManyToOne
    @JoinColumn(name = "CoachID", nullable = false)
    private CoachProfile coach;


    private String information;

    private LocalDate createdDate;
    private LocalTime createdTime;

    @PrePersist
    protected void onCreate() {
        this.createdDate = LocalDate.now();
        this.createdTime = LocalTime.now();
    }

    public FeedbackCoach() {}

    public FeedbackCoach(Account account, CoachProfile coach, String information, LocalDate createdDate, LocalTime createdTime) {
        this.account = account;
        this.coach = coach;
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

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
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

    public CoachProfile getCoach() {
        return coach;
    }

    public void setCoach(CoachProfile coach) {
        this.coach = coach;
    }


}
