package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.dto.*;
import com.fu.swp391.group1.smokingcessation.entity.Plan;
import com.fu.swp391.group1.smokingcessation.entity.PlanStatus;
import com.fu.swp391.group1.smokingcessation.service.PlanManagementService;
import com.fu.swp391.group1.smokingcessation.service.PlanService;
import com.fu.swp391.group1.smokingcessation.repository.MemberProfileRepository;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/plans")
public class PlanManagementController {

    @Autowired
    private PlanManagementService planManagementService;

    @Autowired
    private PlanService planService;

    @Autowired
    private MemberProfileRepository memberProfileRepository;

    @PostMapping("/account/{accountId}/create")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> createPlanForAccount(
            @PathVariable Long accountId,
            @Valid @RequestBody PlanCreateRequest request,  
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }


            PlanDTO planDTO = planManagementService.createPlan(accountId, request, coachId);
            return ResponseEntity.status(HttpStatus.CREATED).body(planDTO);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi tạo kế hoạch: " + e.getMessage()));
        }
    }

    @GetMapping("/coach/my-plans")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> getMyCoachPlans(
            @RequestParam(required = false) PlanStatus status,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }
            // Lấy toàn bộ plan của các user mà coach này là currentCoach
            List<PlanDTO> plans = planManagementService.getPlansOfCurrentCoach(coachId);
            // Nếu có filter status thì lọc ở đây
            if (status != null) {
                plans = plans.stream().filter(p -> p.getStatus() == status).collect(Collectors.toList());
            }
            return ResponseEntity.ok(plans);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy danh sách kế hoạch"));
        }
    }

    @PutMapping("/{planId}")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> updatePlan(
            @PathVariable Long planId,
            @Valid @RequestBody PlanUpdateRequest request,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            PlanDTO updatedPlan = planManagementService.updatePlan(planId, request, coachId);
            return ResponseEntity.ok(updatedPlan);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi cập nhật kế hoạch"));
        }
    }

    @PatchMapping("/{planId}/status")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> updatePlanStatus(
            @PathVariable Long planId,
            @RequestParam PlanStatus status,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            PlanDTO updatedPlan = planManagementService.updatePlanStatus(planId, status, coachId);
            return ResponseEntity.ok(updatedPlan);

        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(new ErrorResponse("VALIDATION_ERROR", e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi cập nhật trạng thái"));
        }
    }


    @GetMapping("/account/{accountId}/plans")
    @PreAuthorize("hasAuthority('Coach')")
    public ResponseEntity<?> getAccountPlans(
            @PathVariable Long accountId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(accountId).orElse(null);
            if (memberProfile == null || memberProfile.getCurrentCoachId() == null ||
                !memberProfile.getCurrentCoachId().equals(userPrincipal.getCoachId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Chỉ coach hiện tại của user mới được xem toàn bộ plan của user này"));
            }
            List<Plan> plans = planService.getPlansByMemberId(accountId);
            List<PlanDTO> planDTOs = plans.stream()
                    .map(PlanDTO::new)
                    .collect(Collectors.toList());

            return ResponseEntity.ok(planDTOs);
        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("ERROR", e.getMessage()));
        }
    }


    @GetMapping("/member/my-plans")
    @PreAuthorize("hasAuthority('Member')")
    public ResponseEntity<?> getMyMemberPlans(
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Long userId = userPrincipal.getUserId();
            List<Plan> plans = planService.getPlansByMemberId(userId);
            List<PlanDTO> planDTOs = plans.stream()
                    .map(PlanDTO::new)
                    .collect(Collectors.toList());
            return ResponseEntity.ok(planDTOs);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy danh sách kế hoạch"));
        }
    }


    @GetMapping("/{planId}")
    @PreAuthorize("hasAuthority('Member') or hasAuthority('Coach')")
    public ResponseEntity<?> getPlanById(
            @PathVariable Long planId,
            @AuthenticationPrincipal UserPrincipal userPrincipal) {

        try {
            Plan plan = planService.getPlanById(planId);
            String userRole = userPrincipal.getRole();
            if ("Member".equals(userRole) && !plan.getAccountId().equals(userPrincipal.getUserId())) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Chỉ xem được plan của mình"));
            }
            if ("Coach".equals(userRole)) {
                MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(plan.getAccountId()).orElse(null);
                if (memberProfile == null || memberProfile.getCurrentCoachId() == null ||
                    !memberProfile.getCurrentCoachId().equals(userPrincipal.getCoachId())) {
                    return ResponseEntity.status(HttpStatus.FORBIDDEN)
                            .body(new ErrorResponse("FORBIDDEN", "Chỉ coach hiện tại của user mới được xem toàn bộ plan của user này"));
                }
            }
            return ResponseEntity.ok(new PlanDTO(plan));

        } catch (Exception e) {
            return ResponseEntity.badRequest()
                    .body(new ErrorResponse("ERROR", e.getMessage()));
        }
    }
}