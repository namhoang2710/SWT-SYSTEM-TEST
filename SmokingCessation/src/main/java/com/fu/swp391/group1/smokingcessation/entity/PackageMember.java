package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "PackageMember")
public class PackageMember {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "PackageID")
    private Integer id;

    @Column(name = "AccountID")
    private Long accountId;

    @Column(name = "InfoPackageID")
    private Integer infoPackageId;

    @Column(name = "Name")
    private String name;

    @Column(name = "Price")
    private Double price;

    @Column(name = "PurchaseDate")
    private LocalDateTime purchaseDate;
}