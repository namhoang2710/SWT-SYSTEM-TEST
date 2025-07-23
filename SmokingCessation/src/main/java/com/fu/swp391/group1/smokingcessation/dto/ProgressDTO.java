package com.fu.swp391.group1.smokingcessation.dto;

import com.fu.swp391.group1.smokingcessation.entity.ProgressTracking;
import java.math.BigDecimal;
import java.time.LocalDate;

public class ProgressDTO {
    private Long progressId;
    private Long planId;
    private String planTitle;
    private LocalDate date;
    private Integer cigarettesSmoked;
    private Integer cravingLevel;
    private Integer moodLevel;
    private String notes;
    private String coachFeedback;
    private SavingsDTO savings;  // Thông tin tiết kiệm

    // Savings info (chỉ khi có cải thiện)
    private BigDecimal dailySavings;
    private Integer cigarettesReduced;
    private String improvementMessage;

    // 🎉 Thông báo chúc mừng

    // Constructor từ ProgressTracking entity
    public ProgressDTO(ProgressTracking progress, String planTitle) {
        this.progressId = progress.getProgressId();
        this.planId = progress.getPlanId();
        this.planTitle = planTitle;
        this.date = progress.getDate();
        this.cigarettesSmoked = progress.getCigarettesSmoked();
        this.cravingLevel = progress.getCravingLevel();
        this.moodLevel = progress.getMoodLevel();
        this.notes = progress.getNotes();
        this.coachFeedback = progress.getCoachFeedback();
    }

    // Getters and Setters
    public Long getProgressId() { return progressId; }
    public Long getPlanId() { return planId; }
    public String getPlanTitle() { return planTitle; }
    public LocalDate getDate() { return date; }
    public Integer getCigarettesSmoked() { return cigarettesSmoked; }
    public Integer getCravingLevel() { return cravingLevel; }
    public Integer getMoodLevel() { return moodLevel; }
    public String getNotes() { return notes; }
    public String getCoachFeedback() { return coachFeedback; }

    public BigDecimal getDailySavings() { return dailySavings; }
    public void setDailySavings(BigDecimal dailySavings) { this.dailySavings = dailySavings; }

    public Integer getCigarettesReduced() { return cigarettesReduced; }
    public void setCigarettesReduced(Integer cigarettesReduced) { this.cigarettesReduced = cigarettesReduced; }

    public String getImprovementMessage() { return improvementMessage; }
    public void setImprovementMessage(String improvementMessage) { this.improvementMessage = improvementMessage; }
    public SavingsDTO getSavings() { return savings; }
    public void setSavings(SavingsDTO savings) { this.savings = savings; }
}