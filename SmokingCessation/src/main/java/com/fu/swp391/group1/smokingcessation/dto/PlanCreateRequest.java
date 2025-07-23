package com.fu.swp391.group1.smokingcessation.dto;

import jakarta.validation.constraints.*;
import java.time.LocalDate;

public class PlanCreateRequest {



    @NotBlank(message = "Tiêu đề kế hoạch không được để trống")
    @Size(max = 255, message = "Tiêu đề không được vượt quá 255 ký tự")
    private String title;

    @NotBlank(message = "Mô tả kế hoạch không được để trống")
    private String description;

    @NotNull(message = "Ngày bắt đầu không được để trống")
    @Future(message = "Ngày bắt đầu phải là trong tương lai")
    private LocalDate startDate;

    @NotNull(message = "Ngày mục tiêu không được để trống")
    @Future(message = "Ngày mục tiêu phải là trong tương lai")
    private LocalDate goalDate;


    public PlanCreateRequest() {}

    public PlanCreateRequest( String title, String description,
                             LocalDate startDate, LocalDate goalDate) {

        this.title = title;
        this.description = description;
        this.startDate = startDate;
        this.goalDate = goalDate;
    }



    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public LocalDate getGoalDate() { return goalDate; }
    public void setGoalDate(LocalDate goalDate) { this.goalDate = goalDate; }
}