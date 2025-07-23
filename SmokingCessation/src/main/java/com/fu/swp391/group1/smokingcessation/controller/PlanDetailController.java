package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.dto.*;
import com.fu.swp391.group1.smokingcessation.service.PlanDetailService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/plans")
public class PlanDetailController {

    @Autowired
    private PlanDetailService planDetailService;




    @PostMapping("/{planId}/weeks")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> createWeek(
            @PathVariable Long planId,
            @Valid @RequestBody PlanDetailCreateRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            PlanDetailDTO planDetailDTO = planDetailService.createWeek(planId, request, coachId);
            return ResponseEntity.status(HttpStatus.CREATED).body(planDetailDTO);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi tạo tuần: " + e.getMessage()));
        }
    }


    @GetMapping("/{planId}/weeks")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> getWeeksByPlan(
            @PathVariable Long planId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            List<PlanDetailDTO> weeks = planDetailService.getWeeksByPlan(planId, coachId);
            return ResponseEntity.ok(weeks);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy danh sách tuần"));
        }
    }


    @GetMapping("/weeks/{planDetailId}")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> getWeekById(
            @PathVariable Long planDetailId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            PlanDetailDTO week = planDetailService.getWeekById(planDetailId, coachId);
            return ResponseEntity.ok(week);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy thông tin tuần"));
        }
    }


    @PutMapping("/weeks/{planDetailId}")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> updateWeek(
            @PathVariable Long planDetailId,
            @Valid @RequestBody PlanDetailUpdateRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            PlanDetailDTO updatedWeek = planDetailService.updateWeek(planDetailId, request, coachId);
            return ResponseEntity.ok(updatedWeek);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi cập nhật tuần"));
        }
    }


    @DeleteMapping("/weeks/{planDetailId}")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> deleteWeek(
            @PathVariable Long planDetailId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            planDetailService.deleteWeek(planDetailId, coachId);

            // Simple success response
            return ResponseEntity.ok().body(new SimpleResponse("SUCCESS", "Xóa tuần thành công"));

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi xóa tuần"));
        }
    }

    @GetMapping("/{planId}/weeks/member")
    @PreAuthorize("hasAuthority('Member')")
    public ResponseEntity<?> getWeeksByPlanForMember(
            @PathVariable Long planId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long memberId = userPrincipal.getUserId();
            List<PlanDetailDTO> weeks = planDetailService.getWeeksByPlanForMember(planId, memberId);
            return ResponseEntity.ok(weeks);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy danh sách tuần"));
        }
    }
}

class SimpleResponse {
    private String status;
    private String message;

    public SimpleResponse(String status, String message) {
        this.status = status;
        this.message = message;
    }

    public String getStatus() { return status; }
    public String getMessage() { return message; }
}