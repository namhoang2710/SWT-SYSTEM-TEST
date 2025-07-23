package com.fu.swp391.group1.smokingcessation.dto;

import jakarta.persistence.Column;

import java.time.LocalDate;

public class MemberProfileCreationRequest {

    private Long accountId;
    private LocalDate startDate;
    private String motivation;

    public MemberProfileCreationRequest() {
    }

    public MemberProfileCreationRequest(Long accountId, LocalDate startDate, String motivation) {
        this.accountId = accountId;
        this.startDate = startDate;
        this.motivation = motivation;
    }

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
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
}
