package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "InformationPackage")
public class InformationPackage {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "InfoPackageID")
    private Integer id;

    @Column(name = "Name")
    private String name;

    @Column(name = "Price")
    private Double price;

    @Column(name = "Description")
    private String description;

    @Column(name = "NumberOfConsultations", nullable = false)
    private Integer numberOfConsultations = 0;

    @Column(name = "NumberOfHealthCheckups", nullable = false)
    private Integer numberOfHealthCheckups = 0;
}