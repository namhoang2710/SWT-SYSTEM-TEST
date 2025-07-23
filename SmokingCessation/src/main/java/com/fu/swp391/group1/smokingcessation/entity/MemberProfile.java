package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDate;

@Data
@Entity
@Table(name = "MemberProfile")
public class MemberProfile {
    @Id
    @Column(name = "MemberID")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer memberId;


    @OneToOne
    @JoinColumn(name = "accountID", nullable = false)
    private Account account;

    @Column(name = "StartDate")
    private LocalDate startDate;

    

    @Column(name = "Motivation")
    private String motivation;

    @Column(name = "currentCoachId")
    private Long currentCoachId;

    public MemberProfile() {
    }

    public MemberProfile(Account account, LocalDate startDate, String motivation) {
        this.account = account;
        this.startDate = startDate;
        this.motivation = motivation;
    }

    public Integer getMemberId() {
        return memberId;
    }

    public void setMemberId(Integer memberId) {
        this.memberId = memberId;
    }


    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

   

    public String getMotivation() {
        return motivation;
    }

    public Long getCurrentCoachId() {
        return currentCoachId;
    }

    public void setCurrentCoachId(Long currentCoachId) {
        this.currentCoachId = currentCoachId;
    }
}