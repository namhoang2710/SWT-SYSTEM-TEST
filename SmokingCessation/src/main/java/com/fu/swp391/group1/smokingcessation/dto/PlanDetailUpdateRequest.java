package com.fu.swp391.group1.smokingcessation.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

public class PlanDetailUpdateRequest {

    private LocalDate startDate;
    private LocalDate endDate;

    @Min(value = 0, message = "Mục tiêu điếu/ngày phải >= 0")
    private Integer targetCigarettesPerDay;

    private String weeklyContent;

    // Constructors
    public PlanDetailUpdateRequest() {}

    // Getters and Setters
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }

    public Integer getTargetCigarettesPerDay() { return targetCigarettesPerDay; }
    public void setTargetCigarettesPerDay(Integer targetCigarettesPerDay) {
        this.targetCigarettesPerDay = targetCigarettesPerDay;
    }

    public String getWeeklyContent() { return weeklyContent; }
    public void setWeeklyContent(String weeklyContent) { this.weeklyContent = weeklyContent; }
}