package com.fu.swp391.group1.smokingcessation.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public class SavingsDTO {
    private Long planId;
    private String planTitle;
    private LocalDate fromDate;
    private LocalDate toDate;
    private BigDecimal totalSavings;
    private Integer daysTracked;
    private Integer smokeFreeDays;
    private Integer totalCigarettesReduced;
    private Integer baselineCigarettes;        // Từ SmokingLog
    private Integer actualCigarettes;          // Từ ProgressTracking
    private Integer cigarettesReduced;         // baselineCigarettes - actualCigarettes
    private BigDecimal costPerCigarette;       // Từ SmokingLog
    private BigDecimal dailySavings;           // cigarettesReduced * costPerCigarette
    private String improvementMessage;         // Thông báo động viên


    // Constructor
    public SavingsDTO(Long planId, String planTitle, LocalDate fromDate, LocalDate toDate) {
        this.planId = planId;
        this.planTitle = planTitle;
        this.fromDate = fromDate;
        this.toDate = toDate;
    }

    // Getters and Setters
    public Long getPlanId() { return planId; }
    public String getPlanTitle() { return planTitle; }
    public LocalDate getFromDate() { return fromDate; }
    public LocalDate getToDate() { return toDate; }

    public BigDecimal getTotalSavings() { return totalSavings; }
    public void setTotalSavings(BigDecimal totalSavings) { this.totalSavings = totalSavings; }

    public Integer getDaysTracked() { return daysTracked; }
    public void setDaysTracked(Integer daysTracked) { this.daysTracked = daysTracked; }

    public Integer getSmokeFreeDays() { return smokeFreeDays; }
    public void setSmokeFreeDays(Integer smokeFreeDays) { this.smokeFreeDays = smokeFreeDays; }

    public Integer getTotalCigarettesReduced() { return totalCigarettesReduced; }
    public void setTotalCigarettesReduced(Integer totalCigarettesReduced) {
        this.totalCigarettesReduced = totalCigarettesReduced;
    }
    public Integer getBaselineCigarettes() { return baselineCigarettes; }
    public void setBaselineCigarettes(Integer baselineCigarettes) { this.baselineCigarettes = baselineCigarettes; }

    public Integer getActualCigarettes() { return actualCigarettes; }
    public void setActualCigarettes(Integer actualCigarettes) { this.actualCigarettes = actualCigarettes; }

    public Integer getCigarettesReduced() { return cigarettesReduced; }
    public void setCigarettesReduced(Integer cigarettesReduced) { this.cigarettesReduced = cigarettesReduced; }

    public BigDecimal getCostPerCigarette() { return costPerCigarette; }
    public void setCostPerCigarette(BigDecimal costPerCigarette) { this.costPerCigarette = costPerCigarette; }

    public BigDecimal getDailySavings() { return dailySavings; }
    public void setDailySavings(BigDecimal dailySavings) { this.dailySavings = dailySavings; }

    public String getImprovementMessage() { return improvementMessage; }
    public void setImprovementMessage(String improvementMessage) { this.improvementMessage = improvementMessage; }
}
