package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;

@Entity
@Table(name= "Medal")
public class Medal {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name= "MedalID")
    private int medalID;

    private String name;
    private String description;
    private String type;
    private String image;

    public Medal() {
    }

    public Medal(int medalID, String name, String description, String type, String image) {
        this.medalID = medalID;
        this.name = name;
        this.description = description;
        this.type = type;
        this.image = image;
    }

    public int getMedalID() {
        return medalID;
    }

    public void setMedalID(int medalID) {
        this.medalID = medalID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }
}
