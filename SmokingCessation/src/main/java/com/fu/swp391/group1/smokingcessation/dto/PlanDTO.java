package com.fu.swp391.group1.smokingcessation.dto;

import com.fu.swp391.group1.smokingcessation.entity.Plan;
import com.fu.swp391.group1.smokingcessation.entity.PlanStatus;
import java.time.LocalDate;

public class PlanDTO {
    private Long planId;
    private String title;
    private String description;
    private Long accountId;
    private String accountName;
    private Long coachId;
    private String coachName;
    private LocalDate startDate;
    private LocalDate goalDate;
    private PlanStatus status;

    public PlanDTO(Plan plan) {
        this.planId = plan.getPlanId();
        this.title = plan.getTitle();
        this.description = plan.getDescription();
        this.accountId = plan.getAccountId();
        this.coachId = plan.getCoachId();
        this.startDate = plan.getStartDate();
        this.goalDate = plan.getGoalDate();
        this.status = plan.getStatus();

        // Account name nếu có
        if (plan.getAccount() != null) {
            this.accountName = plan.getAccount().getName();
        }

        // Coach name nếu có
        if (plan.getCoachProfile() != null && plan.getCoachProfile().getAccount() != null) {
            this.coachName = plan.getCoachProfile().getAccount().getName();
        }
    }


    public Long getPlanId() { return planId; }
    public String getTitle() { return title; }
    public String getDescription() { return description; }
    public Long getAccountId() { return accountId; }
    public String getAccountName() { return accountName; }
    public Long getCoachId() { return coachId; }
    public String getCoachName() { return coachName; }
    public LocalDate getStartDate() { return startDate; }
    public LocalDate getGoalDate() { return goalDate; }
    public PlanStatus getStatus() { return status; }
}