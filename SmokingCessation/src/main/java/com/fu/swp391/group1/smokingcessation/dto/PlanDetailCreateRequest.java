package com.fu.swp391.group1.smokingcessation.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

public class PlanDetailCreateRequest {

    @NotNull(message = "Ngày bắt đầu không được để trống")
    private LocalDate startDate;

    @NotNull(message = "Ngày kết thúc không được để trống")
    private LocalDate endDate;

    @NotNull(message = "Mục tiêu điếu/ngày không được để trống")
    @Min(value = 0, message = "Mục tiêu điếu/ngày phải >= 0")
    private Integer targetCigarettesPerDay;

    @NotBlank(message = "Nội dung tuần không được để trống")
    private String weeklyContent;

    // Constructors
    public PlanDetailCreateRequest() {}

    public PlanDetailCreateRequest(LocalDate startDate, LocalDate endDate,
                                   Integer targetCigarettesPerDay, String weeklyContent) {
        this.startDate = startDate;
        this.endDate = endDate;
        this.targetCigarettesPerDay = targetCigarettesPerDay;
        this.weeklyContent = weeklyContent;
    }

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