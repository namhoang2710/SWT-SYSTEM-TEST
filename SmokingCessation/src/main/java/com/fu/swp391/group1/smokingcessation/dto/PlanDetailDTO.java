package com.fu.swp391.group1.smokingcessation.dto;

import com.fu.swp391.group1.smokingcessation.entity.PlanDetail;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class PlanDetailDTO {
    private Long planDetailId;
    private Long planId;
    private Integer weekNumber;
    private LocalDate startDate;
    private LocalDate endDate;
    private Integer targetCigarettesPerDay;
    private String weeklyContent;
    private LocalDateTime createdAt;

    // Constructor từ Entity
    public PlanDetailDTO(PlanDetail planDetail) {
        this.planDetailId = planDetail.getPlanDetailId();
        this.planId = planDetail.getPlanId();
        this.weekNumber = planDetail.getWeekNumber();
        this.startDate = planDetail.getStartDate();
        this.endDate = planDetail.getEndDate();
        this.targetCigarettesPerDay = planDetail.getTargetCigarettesPerDay();
        this.weeklyContent = planDetail.getWeeklyContent();
        this.createdAt = planDetail.getCreatedAt();
    }  // ← THÊM DẤU } NÀY

    // Getters
    public Long getPlanDetailId() { return planDetailId; }
    public Long getPlanId() { return planId; }
    public Integer getWeekNumber() { return weekNumber; }
    public LocalDate getStartDate() { return startDate; }
    public LocalDate getEndDate() { return endDate; }
    public Integer getTargetCigarettesPerDay() { return targetCigarettesPerDay; }
    public String getWeeklyContent() { return weeklyContent; }
    public LocalDateTime getCreatedAt() { return createdAt; }
}