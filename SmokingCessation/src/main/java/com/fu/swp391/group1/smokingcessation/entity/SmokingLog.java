package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "SmokingLog")
public class SmokingLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "SmokingLogID")
    private Integer id;

    @Column(name = "MemberID")
    private Integer memberId;

    @Column(name = "Date")
    private LocalDate date;

    @Column(name = "Cigarettes")
    private Integer cigarettes;
    
    @Column(name = "Tobaccocompany")
    private String tobaccoCompany;

    @Column(name = "NumberOfCigarettes")
    private Integer numberOfCigarettes;

    @Column(name = "Cost")
    private Double cost;

    @Column(name = "HealthStatus")
    private String healthStatus;

    @Column(name = "CravingLevel")
    private Integer cravingLevel;

    @Column(name = "Notes")
    private String notes;

    // Getters and setters
    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Integer getMemberId() {
        return memberId;
    }

    public void setMemberId(Integer memberId) {
        this.memberId = memberId;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public Integer getCigarettes() {
        return cigarettes;
    }

    public void setCigarettes(Integer cigarettes) {
        this.cigarettes = cigarettes;
    }

    public String getTobaccoCompany() {
        return tobaccoCompany;
    }
    public void setTobaccoCompany(String tobaccoCompany) {
        this.tobaccoCompany = tobaccoCompany;
    }

    public Integer getNumberOfCigarettes() {
        return numberOfCigarettes;
    }   
    public void setNumberOfCigarettes(Integer numberOfCigarettes) {
        this.numberOfCigarettes = numberOfCigarettes;
    }
    public Double getCost() {
        return cost;
    }

    public void setCost(Double cost) {
        this.cost = cost;
    }

    public String getHealthStatus() {
        return healthStatus;
    }

    public void setHealthStatus(String healthStatus) {
        this.healthStatus = healthStatus;
    }

    public Integer getCravingLevel() {
        return cravingLevel;
    }

    public void setCravingLevel(Integer cravingLevel) {
        this.cravingLevel = cravingLevel;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }
}