package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "PlanDetail")
@Getter
@Setter
public class PlanDetail {
    @Id
    @Column(name = "PlanDetailID")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long planDetailId;

    @Column(name = "PlanID")
    private Long planId;

    @Column(name = "WeekNumber")
    private Integer weekNumber;

    @Column(name = "StartDate")
    private LocalDate startDate;

    @Column(name = "EndDate")
    private LocalDate endDate;

    @Column(name = "TargetCigarettesPerDay")
    private Integer targetCigarettesPerDay;

    @Column(name = "WeeklyContent", columnDefinition = "TEXT")
    private String weeklyContent;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;


    public PlanDetail() {
        this.createdAt = LocalDateTime.now();
    }

    public PlanDetail(Long planId, Integer weekNumber, LocalDate startDate, LocalDate endDate,
                      Integer targetCigarettesPerDay, String weeklyContent) {
        this();
        this.planId = planId;
        this.weekNumber = weekNumber;
        this.startDate = startDate;
        this.endDate = endDate;
        this.targetCigarettesPerDay = targetCigarettesPerDay;
        this.weeklyContent = weeklyContent;
    }


}