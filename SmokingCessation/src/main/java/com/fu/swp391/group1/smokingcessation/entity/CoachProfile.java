package com.fu.swp391.group1.smokingcessation.entity;


import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

@Entity
@Table(name = "CoachProfile")
public class CoachProfile {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long coachId;


    @OneToOne
    @JoinColumn(name = "accountID", nullable = false)
    private Account account;

    private String specialty;
    private String experience;
    private String image;

    public CoachProfile() {
    }

    public CoachProfile(Account account, String specialty, String experience, String image) {
        this.account = account;
        this.specialty = specialty;
        this.experience = experience;
        this.image = image;
    }

    public Long getCoachId() {
        return coachId;
    }

    public void setCoachId(Long coachId) {
        this.coachId = coachId;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public String getSpecialty() {
        return specialty;
    }

    public void setSpecialty(String specialty) {
        this.specialty = specialty;
    }

    public String getExperience() {
        return experience;
    }

    public void setExperience(String experience) {
        this.experience = experience;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }
}
