package com.fu.swp391.group1.smokingcessation.dto;

import java.io.Serializable;

public class InformationPackageDTO implements Serializable {
    private String name;
    private Double price;
    private String description;
    private Integer numberOfConsultations;
    private Integer numberOfHealthCheckups;

    // Constructors
    public InformationPackageDTO() {
    }

    public InformationPackageDTO(Integer id, String name, Double price, String description,
                                Integer numberOfConsultations, Integer numberOfHealthCheckups) {
        this.name = name;
        this.price = price;
        this.description = description;
        this.numberOfConsultations = numberOfConsultations;
        this.numberOfHealthCheckups = numberOfHealthCheckups;
    }

    
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Double getPrice() {
        return price;
    }

    public void setPrice(Double price) {
        this.price = price;
    }


    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getNumberOfConsultations() {
        return numberOfConsultations;
    }

    public void setNumberOfConsultations(Integer numberOfConsultations) {
        this.numberOfConsultations = numberOfConsultations;
    }

    public Integer getNumberOfHealthCheckups() {
        return numberOfHealthCheckups;
    }

    public void setNumberOfHealthCheckups(Integer numberOfHealthCheckups) {
        this.numberOfHealthCheckups = numberOfHealthCheckups;
    }

   
}