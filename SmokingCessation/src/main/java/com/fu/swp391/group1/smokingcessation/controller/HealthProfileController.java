package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.dto.ErrorResponse;
import com.fu.swp391.group1.smokingcessation.dto.HealthProfileRequest;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;
import com.fu.swp391.group1.smokingcessation.entity.HealthProfile;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import com.fu.swp391.group1.smokingcessation.repository.ConsultationBookingRepository;
import com.fu.swp391.group1.smokingcessation.repository.MemberProfileRepository;
import com.fu.swp391.group1.smokingcessation.service.HealthProfileService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/health-profile")
@PreAuthorize("hasAuthority('Coach')")
public class HealthProfileController {

    @Autowired
    private HealthProfileService healthProfileService;

    @Autowired
    private ConsultationBookingRepository consultationBookingRepository;

    @Autowired
    private MemberProfileRepository memberProfileRepository;

    @PostMapping("/account/{accountId}/create")
    public ResponseEntity<?> createHealthProfile(
            @PathVariable Integer accountId,
            @Valid @RequestBody HealthProfileRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            Integer coachId = userPrincipal.getCoachId().intValue();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }
            MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(accountId.longValue()).orElse(null);
            if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(userPrincipal.getCoachId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Chỉ coach hiện tại của user mới được tạo health profile cho user này"));
            }
            HealthProfile healthProfile = healthProfileService.createHealthProfile(accountId, request, coachId);
            return ResponseEntity.ok(healthProfile);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi tạo health profile"));
        }
    }
    @PutMapping("/update/{healthProfileId}")
    public ResponseEntity<?> updateHealthProfile(
            @PathVariable Integer healthProfileId,
            @Valid @RequestBody HealthProfileRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            Integer coachId = userPrincipal.getCoachId().intValue();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }
            HealthProfile existingProfile = healthProfileService.getHealthProfileById(healthProfileId);
            MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(existingProfile.getAccountId().longValue()).orElse(null);
            if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(userPrincipal.getCoachId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Chỉ coach hiện tại của user mới được sửa health profile cho user này"));
            }
            HealthProfile updatedProfile = healthProfileService.updateHealthProfile(healthProfileId, request, coachId);
            return ResponseEntity.ok(updatedProfile);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("NOT_FOUND", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi cập nhật health profile"));
        }
    }
    @GetMapping("/account/{accountId}/history")
    public ResponseEntity<?> getAccountHealthHistory(
            @PathVariable Integer accountId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(accountId.longValue()).orElse(null);
            if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(userPrincipal.getCoachId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Chỉ coach hiện tại của user mới được xem health profile của user này"));
            }
            List<HealthProfile> healthHistory = healthProfileService.getAccountHealthHistory(accountId);
            return ResponseEntity.ok(healthHistory);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy health history"));
        }
    }

    @DeleteMapping("/delete/{healthProfileId}")
    public ResponseEntity<?> deleteHealthProfile(
            @PathVariable Integer healthProfileId,  // ✅ Integer thay vì Long
            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            healthProfileService.deleteHealthProfile(healthProfileId);
            return ResponseEntity.ok("Health profile đã được xóa thành công");

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi xóa health profile"));
        }
    }
}