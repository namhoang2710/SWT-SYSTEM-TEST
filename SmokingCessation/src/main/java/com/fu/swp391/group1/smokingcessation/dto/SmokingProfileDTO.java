package com.fu.swp391.group1.smokingcessation.dto;

import java.time.LocalDate;

public class SmokingProfileDTO {
    private Long memberId;
    private String memberName;
    private Integer currentCigarettesPerDay;
    private Double currentCostPerPack;
    private Integer cigarettesPerPack;
    private String tobaccoCompany;
    private LocalDate lastLogDate;
    private String healthStatus;
    private Integer cravingLevel;

    // Constructors
    public SmokingProfileDTO() {}

    public SmokingProfileDTO(Long memberId, String memberName, Integer currentCigarettesPerDay,
                             Double currentCostPerPack, Integer cigarettesPerPack, String tobaccoCompany,
                             LocalDate lastLogDate, String healthStatus, Integer cravingLevel) {
        this.memberId = memberId;
        this.memberName = memberName;
        this.currentCigarettesPerDay = currentCigarettesPerDay;
        this.currentCostPerPack = currentCostPerPack;
        this.cigarettesPerPack = cigarettesPerPack;
        this.tobaccoCompany = tobaccoCompany;
        this.lastLogDate = lastLogDate;
        this.healthStatus = healthStatus;
        this.cravingLevel = cravingLevel;
    }

    // Getters and Setters
    public Long getMemberId() { return memberId; }
    public void setMemberId(Long memberId) { this.memberId = memberId; }

    public String getMemberName() { return memberName; }
    public void setMemberName(String memberName) { this.memberName = memberName; }

    public Integer getCurrentCigarettesPerDay() { return currentCigarettesPerDay; }
    public void setCurrentCigarettesPerDay(Integer currentCigarettesPerDay) {
        this.currentCigarettesPerDay = currentCigarettesPerDay;
    }

    public Double getCurrentCostPerPack() { return currentCostPerPack; }
    public void setCurrentCostPerPack(Double currentCostPerPack) {
        this.currentCostPerPack = currentCostPerPack;
    }

    public Integer getCigarettesPerPack() { return cigarettesPerPack; }
    public void setCigarettesPerPack(Integer cigarettesPerPack) {
        this.cigarettesPerPack = cigarettesPerPack;
    }

    public String getTobaccoCompany() { return tobaccoCompany; }
    public void setTobaccoCompany(String tobaccoCompany) { this.tobaccoCompany = tobaccoCompany; }

    public LocalDate getLastLogDate() { return lastLogDate; }
    public void setLastLogDate(LocalDate lastLogDate) { this.lastLogDate = lastLogDate; }

    public String getHealthStatus() { return healthStatus; }
    public void setHealthStatus(String healthStatus) { this.healthStatus = healthStatus; }

    public Integer getCravingLevel() { return cravingLevel; }
    public void setCravingLevel(Integer cravingLevel) { this.cravingLevel = cravingLevel; }
}
