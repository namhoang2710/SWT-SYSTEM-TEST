package com.fu.swp391.group1.smokingcessation.dto;

import com.fu.swp391.group1.smokingcessation.entity.PlanStatus;
import jakarta.validation.constraints.*;
import java.time.LocalDate;

public class PlanUpdateRequest {

    @Size(max = 255, message = "Tiêu đề không được vượt quá 255 ký tự")
    private String title;

    private String description;

    @Future(message = "Ngày bắt đầu phải là trong tương lai")
    private LocalDate startDate;

    @Future(message = "Ngày mục tiêu phải là trong tương lai")
    private LocalDate goalDate;


    public PlanUpdateRequest() {}

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getGoalDate() { return goalDate; }
    public void setGoalDate(LocalDate goalDate) { this.goalDate = goalDate; }
}