package com.fu.swp391.group1.smokingcessation.dto;
import lombok.Data;


@Data
public class SmokingLogDto {
    private Integer cigarettes;
    private String tobaccoCompany;          
    private Integer numberOfCigarettes;
    private Double cost;
    private String healthStatus;
    private Integer cravingLevel;
    private String notes;
}
