package com.fu.swp391.group1.smokingcessation.entity;


import jakarta.persistence.*;

import java.time.LocalDate;

@Entity
@Table(name = "UserMedal")
public class UserMedal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int UserMedalID;

    @ManyToOne
    @JoinColumn(name = "MedalID", nullable = false)
    private Medal medal;

    @ManyToOne
    @JoinColumn(name = "AccountID", nullable = false)
    private Account account;

    @Column(name = "MedalDate")
    private LocalDate createdDate;


    private String medalInfo;

    @PrePersist
    protected void onCreate() {
        this.createdDate = LocalDate.now();
    }

    public UserMedal() {
    }

    public UserMedal(int userMedalID, Medal medal, Account account, String medalInfo) {
        UserMedalID = userMedalID;
        this.medal = medal;
        this.account = account;
        this.medalInfo = medalInfo;
    }

    public int getUserMedalID() {
        return UserMedalID;
    }

    public void setUserMedalID(int userMedalID) {
        UserMedalID = userMedalID;
    }

    public Medal getMedal() {
        return medal;
    }

    public void setMedal(Medal medal) {
        this.medal = medal;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public LocalDate getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDate createdDate) {
        this.createdDate = createdDate;
    }

    public String getMedalInfo() {
        return medalInfo;
    }

    public void setMedalInfo(String medalInfo) {
        this.medalInfo = medalInfo;
    }
}
