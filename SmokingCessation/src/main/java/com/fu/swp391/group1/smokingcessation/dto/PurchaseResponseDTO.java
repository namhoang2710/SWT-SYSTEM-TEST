package com.fu.swp391.group1.smokingcessation.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class PurchaseResponseDTO {
    private Integer packageId;
    private String packageName;
    private Double price;
    private Long accountId;
    private String message;
    private LocalDateTime purchaseDate;
}