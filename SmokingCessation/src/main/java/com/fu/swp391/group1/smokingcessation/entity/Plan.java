package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Data
@Entity
@Table(name = "Plans")
@Getter
@Setter
public class Plan {
    @Id
    @Column(name = "PlanID")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long planId;

    @Column(name = "Title")
    private String title;

    @Column(name = "Description")
    private String description;

    @Column(name = "AccountID")
    private Long accountId;

    @Column(name = "CoachID")
    private Long coachId;

    @Column(name = "StartDate")
    private LocalDate startDate;

    @Column(name = "GoalDate")
    private LocalDate goalDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "Status")
    private PlanStatus status;

    // Relationships
    @ManyToOne
    @JoinColumn(name = "AccountID", insertable = false, updatable = false)
    private Account account;

    @ManyToOne
    @JoinColumn(name = "CoachID", insertable = false, updatable = false)
    private CoachProfile coachProfile;


    public Plan() {
    }

    public Plan(Long planId, String title, String description, Long accountId, Long coachId,
                LocalDate startDate, LocalDate goalDate, PlanStatus status,
                Account account, CoachProfile coachProfile) {
        this.planId = planId;
        this.title = title;
        this.description = description;
        this.accountId = accountId;
        this.coachId = coachId;
        this.startDate = startDate;
        this.goalDate = goalDate;
        this.status = status;
        this.account = account;
        this.coachProfile = coachProfile;
    }
}