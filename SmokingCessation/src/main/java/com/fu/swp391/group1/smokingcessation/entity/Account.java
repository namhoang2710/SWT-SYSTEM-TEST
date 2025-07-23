package com.fu.swp391.group1.smokingcessation.entity;


import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import jakarta.validation.constraints.*;
import lombok.Data;
import lombok.Getter;
import lombok.Setter;

@Data
@Entity
@Table(name = "Account")
@Getter
@Setter
public class Account {
    @Id
    @Column(name = "AccountID")
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Email(message = "Invalid email")
    @NotBlank(message = "Email cannot be empty")
    @Column(name = "Email", unique = true)
    private String email;

    @NotBlank(message = "Password cannot be empty")
    @Size(min = 6, message = "Password must be at least 6 characters")
    @Column(name = "Password")
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;

    @NotBlank(message = "Name cannot be empty")
    @Column(name = "Name")
    private String name;

    @Column(name = "YearBirth")
    private Integer yearbirth;

    @NotBlank(message = "Gender cannot be empty")
    @Column(name = "Gender")
    private String gender;

    public Account() {
    }

    @Column(name = "Role")
    private String role;



    @Column(name = "Status")
    private String status;

    @Column(name = "Image")
    private String image;

    @Column(name = "verification_code")
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String verificationCode;

    @Column(name = "Consultations", nullable = false)
    private Integer consultations = 0;

    @Column(name = "HealthCheckups", nullable = false)
    private Integer healthCheckups = 0;
    @JsonIgnore
    @OneToOne(mappedBy = "account")
    private CoachProfile coachProfile;

    @Column(name = "reset_password_token")
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String resetPasswordToken;

    @Column(name = "reset_password_token_expiry")
    private LocalDateTime resetPasswordTokenExpiry;

    public Account(Long id, String email, String password, String name, Integer yearbirth, String gender, String role, String status, String image, String verificationCode, Integer consultations, Integer healthCheckups, CoachProfile coachProfile,
                    String resetPasswordToken, LocalDateTime resetPasswordTokenExpiry) {
        this.id = id;
        this.email = email;
        this.password = password;
        this.name = name;
        this.yearbirth = yearbirth;
        this.gender = gender;
        this.role = role;
        this.status = status;
        this.image = image;
        this.verificationCode = verificationCode;
        this.consultations = consultations;
        this.healthCheckups = healthCheckups;
        this.coachProfile = coachProfile;
        this.resetPasswordToken = resetPasswordToken;
        this.resetPasswordTokenExpiry = resetPasswordTokenExpiry;
    }

    public Integer getYearbirth() {
        return yearbirth;
    }

    public void setYearbirth(Integer yearbirth) {
        this.yearbirth = yearbirth;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getVerificationCode() {
        return verificationCode;
    }

    public void setVerificationCode(String verificationCode) {
        this.verificationCode = verificationCode;
    }

    public Integer getConsultations() {
        return consultations;
    }

    public void setConsultations(Integer consultations) {
        this.consultations = consultations;
    }

    public Integer getHealthCheckups() {
        return healthCheckups;
    }

    public void setHealthCheckups(Integer healthCheckups) {
        this.healthCheckups = healthCheckups;
    }

    public CoachProfile getCoachProfile() {
        return coachProfile;
    }

    public void setCoachProfile(CoachProfile coachProfile) {
        this.coachProfile = coachProfile;
    }
    public String getResetPasswordToken() {
        return resetPasswordToken;
    }
    public void setResetPasswordToken(String resetPasswordToken) {
        this.resetPasswordToken = resetPasswordToken;
    }
    public LocalDateTime getResetPasswordTokenExpiry() {
        return resetPasswordTokenExpiry;
    }
    public void setResetPasswordTokenExpiry(LocalDateTime resetPasswordTokenExpiry) {
        this.resetPasswordTokenExpiry = resetPasswordTokenExpiry;
}
}