package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.dto.SavingsDTO;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;
import com.fu.swp391.group1.smokingcessation.entity.ProgressTracking;
import com.fu.swp391.group1.smokingcessation.service.ProgressTrackingService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/progress")
public class ProgressTrackingController {

    @Autowired
    private ProgressTrackingService progressTrackingService;


    @PostMapping("/daily")
    @PreAuthorize("hasAuthority('Member')")
    public ResponseEntity<?> updateDailyProgress(
            @RequestParam Long planId,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam Integer cigarettesSmoked,
            @RequestParam(required = false) Integer cravingLevel,
            @RequestParam(required = false) Integer moodLevel,
            @RequestParam(required = false) Integer exerciseMinutes,
            @RequestParam(required = false) String notes,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            LocalDate progressDate = date != null ? date : LocalDate.now();

            ProgressTracking progress = progressTrackingService.updateDailyProgress(
                    planId,
                    userPrincipal.getUserId(),
                    progressDate,
                    cigarettesSmoked,
                    cravingLevel,
                    moodLevel,
                    exerciseMinutes,
                    notes
            );

            String message = "Bạn đã tiết kiệm được " + (progress.getMoneySave() != null ? progress.getMoneySave().toPlainString() : "0") + " đồng hôm nay!";
            Map<String, Object> response = new java.util.HashMap<>();
            response.put("progress", progress);
            response.put("message", message);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }


    @GetMapping("/plan/{planId}")
    @PreAuthorize("hasAuthority('Member') or hasAuthority('Coach')")
    public ResponseEntity<?> getProgressByPlan(
            @PathVariable Long planId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            List<ProgressTracking> progress = progressTrackingService.getProgressByPlan(
                    planId, userPrincipal.getUserId()
            );
            return ResponseEntity.ok(progress);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @PostMapping("/feedback/{progressId}")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> addCoachFeedback(
            @PathVariable Long progressId,
            @RequestParam String feedback) {

        try {
            ProgressTracking progress = progressTrackingService.addCoachFeedback(progressId, feedback);
            return ResponseEntity.ok(progress);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

    @GetMapping("/statistics/{planId}")
    @PreAuthorize("hasAuthority('Member') or hasAuthority('Coach')")
    public ResponseEntity<?> getProgressStatistics(@PathVariable Long planId) {
        try {
            Map<String, Object> stats = progressTrackingService.getProgressStatistics(planId);
            return ResponseEntity.ok(stats);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
