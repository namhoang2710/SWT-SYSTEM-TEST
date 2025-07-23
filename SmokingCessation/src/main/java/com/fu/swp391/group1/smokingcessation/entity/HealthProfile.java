package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@Entity
@Table(name = "HealthProfile")
public class HealthProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "HealthProfileID")
    private Integer healthProfileId;

    /**
     * ✅ CHỈ DÙNG: AccountID thôi
     */
    @Column(name = "AccountID", nullable = false)
    private Integer accountId;

    @Column(name = "CoachID")
    private Integer coachId;

    @Column(name = "StartDate")
    private LocalDate startDate;

    @Column(name = "HealthInfo", columnDefinition = "TEXT")
    private String healthInfo;

    @Column(name = "LungCapacity", precision = 7, scale = 2)
    private BigDecimal lungCapacity;

    @Column(name = "HeartRate")
    private Integer heartRate;

    @Column(name = "BloodPressure", length = 10)
    private String bloodPressure;

    @Column(name = "HealthScore", precision = 5, scale = 2)
    private BigDecimal healthScore;

    @Column(name = "CoachNotes", columnDefinition = "TEXT")
    private String coachNotes;
}