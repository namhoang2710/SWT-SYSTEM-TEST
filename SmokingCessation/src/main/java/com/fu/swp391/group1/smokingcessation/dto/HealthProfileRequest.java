package com.fu.swp391.group1.smokingcessation.dto;

import jakarta.validation.constraints.*;
import java.math.BigDecimal;
import java.time.LocalDate;

public class HealthProfileRequest {

    // Member ID sẽ được truyền qua URL parameter, không cần trong request body

    private LocalDate startDate;

    private String healthInfo;

    @DecimalMin(value = "1000.0", message = "Dung tích phổi phải >= 1000ml")
    @DecimalMax(value = "8000.0", message = "Dung tích phổi phải <= 8000ml")
    private BigDecimal lungCapacity;

    @Min(value = 40, message = "Nhịp tim phải >= 40 bpm")
    @Max(value = 200, message = "Nhịp tim phải <= 200 bpm")
    private Integer heartRate;

    @Pattern(regexp = "^\\d{2,3}/\\d{2,3}$", message = "Huyết áp phải có format XXX/XX (VD: 120/80)")
    private String bloodPressure;

    @Size(max = 2000, message = "Ghi chú không được quá 2000 ký tự")
    private String coachNotes;

    // Constructors
    public HealthProfileRequest() {}

    public HealthProfileRequest(BigDecimal lungCapacity, Integer heartRate,
                                String bloodPressure, String coachNotes) {
        this.lungCapacity = lungCapacity;
        this.heartRate = heartRate;
        this.bloodPressure = bloodPressure;
        this.coachNotes = coachNotes;
        this.startDate = LocalDate.now();
    }

    // Getters and Setters

    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }

    public String getHealthInfo() { return healthInfo; }
    public void setHealthInfo(String healthInfo) { this.healthInfo = healthInfo; }

    public BigDecimal getLungCapacity() { return lungCapacity; }
    public void setLungCapacity(BigDecimal lungCapacity) { this.lungCapacity = lungCapacity; }

    public Integer getHeartRate() { return heartRate; }
    public void setHeartRate(Integer heartRate) { this.heartRate = heartRate; }

    public String getBloodPressure() { return bloodPressure; }
    public void setBloodPressure(String bloodPressure) { this.bloodPressure = bloodPressure; }

    public String getCoachNotes() { return coachNotes; }
    public void setCoachNotes(String coachNotes) { this.coachNotes = coachNotes; }
}