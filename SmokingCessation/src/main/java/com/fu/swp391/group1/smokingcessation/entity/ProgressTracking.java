package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "ProgressTracking")
@Getter
@Setter
public class ProgressTracking {
    @Id
    @Column(name = "ProgressID")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long progressId;

    @Column(name = "PlanID")
    private Long planId;

    @Column(name = "AccountID")
    private Long accountId;

    @Column(name = "Date")
    private LocalDate date;

    @Column(name = "CigarettesSmoked")
    private Integer cigarettesSmoked;

    @Column(name = "CravingLevel")
    private Integer cravingLevel;

    @Column(name = "MoodLevel")
    private Integer moodLevel;

    @Column(name = "ExerciseMinutes")
    private Integer exerciseMinutes;

    @Column(name = "Notes")
    private String notes;

    @Column(name = "CoachFeedback")
    private String coachFeedback;

    @Column(name = "CreatedAt")
    private LocalDateTime createdAt;

    @Column(name = "money_save")
    private BigDecimal moneySave;

    // Relationships
    @ManyToOne
    @JoinColumn(name = "PlanID", insertable = false, updatable = false)
    private Plan plan;

    @ManyToOne
    @JoinColumn(name = "AccountID", insertable = false, updatable = false)
    private Account account;

    public ProgressTracking() {
    }

    public ProgressTracking(Long progressId, Long planId, Long accountId, LocalDate date,
                            Integer cigarettesSmoked, Integer cravingLevel, Integer moodLevel,
                            Integer exerciseMinutes, String notes, String coachFeedback,
                            LocalDateTime createdAt, Plan plan, Account account) {
        this.progressId = progressId;
        this.planId = planId;
        this.accountId = accountId;
        this.date = date;
        this.cigarettesSmoked = cigarettesSmoked;
        this.cravingLevel = cravingLevel;
        this.moodLevel = moodLevel;
        this.exerciseMinutes = exerciseMinutes;
        this.notes = notes;
        this.coachFeedback = coachFeedback;
        this.createdAt = createdAt;
        this.plan = plan;
        this.account = account;
    }

    public BigDecimal getMoneySave() {
        return moneySave;
    }
    public void setMoneySave(BigDecimal moneySave) {
        this.moneySave = moneySave;
    }

}