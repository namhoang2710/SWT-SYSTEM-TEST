package com.fu.swp391.group1.smokingcessation.dto;

public class UserMedalCreationRequest {

    private Long accountId;
    private int medalId;
    private String medalInfo;

    public UserMedalCreationRequest() {
    }

    public UserMedalCreationRequest(Long accountId, int medalId, String medalInfo) {
        this.accountId = accountId;
        this.medalId = medalId;
        this.medalInfo = medalInfo;
    }

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public int getMedalId() {
        return medalId;
    }

    public void setMedalId(int medalId) {
        this.medalId = medalId;
    }

    public String getMedalInfo() {
        return medalInfo;
    }

    public void setMedalInfo(String medalInfo) {
        this.medalInfo = medalInfo;
    }
}
