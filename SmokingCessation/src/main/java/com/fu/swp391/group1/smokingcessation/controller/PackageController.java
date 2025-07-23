package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.PurchaseRequestDTO;
import com.fu.swp391.group1.smokingcessation.dto.PurchaseResponseDTO;
import com.fu.swp391.group1.smokingcessation.dto.SmokingLogDto;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.SmokingLog;
import com.fu.swp391.group1.smokingcessation.service.PackageService;
import org.springframework.http.MediaType;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;


import java.util.List;

import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/packages")
public class PackageController {
    @Autowired
    private PackageService packageService;

    @Autowired
    private JwtUtil jwtUtil;

   

    @PostMapping("/buy")
public ResponseEntity<?> buyPackage(
    @AuthenticationPrincipal UserPrincipal userPrincipal,
    @RequestHeader("Package-Id") Integer packageId
    ) {

    Long accountId = userPrincipal.getUserId();


    PurchaseResponseDTO response = packageService.purchasePackage(accountId, packageId);
    if (response == null) {
    return ResponseEntity.ok("Purchase failed");
    }

    return ResponseEntity.ok(response);
}


    // @DeleteMapping("/{packageId}/cancel")
    // public ResponseEntity<?> cancelPackage(@PathVariable Integer packageId, @RequestHeader("Authorization") String authHeader) {
    //     Long accountId = getAccountId(authHeader);
    //     if (accountId == null || packageId == null || packageId <= 0) {
    //         return ResponseEntity.badRequest().body("Invalid input");
    //     }
    //     return packageService.cancelPackage(accountId, packageId) ?
    //             ResponseEntity.ok("Package canceled") : ResponseEntity.badRequest().body("Cancellation failed");
    // }
    @GetMapping("/list")
    public ResponseEntity<?> getPurchasedPackages(@AuthenticationPrincipal UserPrincipal userPrincipal  ){
    Long accountId = userPrincipal.getUserId();
    {
        Map<String, Object> purchasedPackages = packageService.getPurchasedPackagesByAccountId(accountId);
        return ResponseEntity.ok(purchasedPackages);
    }
}

    @PostMapping("/smoking-log")
    public ResponseEntity<?> logSmokingStatus(
        @AuthenticationPrincipal UserPrincipal userPrincipal,
        @RequestBody SmokingLogDto smokingLogDto
    ) {
        if (smokingLogDto.getCigarettes() == null || smokingLogDto.getCigarettes() < 0 ||
            smokingLogDto.getCost() == null || smokingLogDto.getCost() < 0 ||
            smokingLogDto.getHealthStatus() == null || smokingLogDto.getHealthStatus().isEmpty()) {
            return ResponseEntity.badRequest().body("Invalid smoking log data");
        }
        Long accountId = userPrincipal.getUserId();
        if (accountId == null) return ResponseEntity.badRequest().body("Invalid input");
        
        SmokingLog savedLog = packageService.logSmokingStatus(accountId, smokingLogDto);
        return savedLog != null 
            ? ResponseEntity.ok(savedLog) 
            : ResponseEntity.badRequest().body("Log failed");
    }


    @GetMapping("/smoking-logs/list")

    public ResponseEntity<?> getSmokingLogs(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        Long accountId = userPrincipal.getUserId();
        String role = userPrincipal.getRole();
        List<SmokingLog> logs = packageService.getSmokingLogs(accountId, role);
        return ResponseEntity.ok(logs);
    }

    @PutMapping(value = "/smoking-log/{logId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateSmokingLog(
        @AuthenticationPrincipal UserPrincipal userPrincipal,
        @PathVariable Integer logId,
        @ModelAttribute SmokingLogDto smokingLogDto
    ) {
        Long accountId = userPrincipal.getUserId();
        SmokingLog updatedLog = packageService.updateSmokingLog(accountId, logId, smokingLogDto);
        return updatedLog != null ? ResponseEntity.ok(updatedLog) : ResponseEntity.badRequest().body("Update failed");
    }
}