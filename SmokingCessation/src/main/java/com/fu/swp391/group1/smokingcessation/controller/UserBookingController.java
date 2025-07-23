package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.dto.ErrorResponse;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationBooking;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationSlot;
import com.fu.swp391.group1.smokingcessation.entity.HealthProfile;
import com.fu.swp391.group1.smokingcessation.service.ConsultationService;
import com.fu.swp391.group1.smokingcessation.service.HealthProfileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/user/consultation")
@PreAuthorize("hasAuthority('Member')")
public class UserBookingController {

    @Autowired
    private ConsultationService consultationService;
    @Autowired
    private HealthProfileService healthProfileService;

    @GetMapping("/coach-slots/{coachId}")
    public List<ConsultationSlot> getCoachAvailableSlots(@PathVariable Long coachId) {
        return consultationService.getAvailableSlots(coachId);
    }

    @GetMapping("/coach-schedule/{coachId}")
    public List<ConsultationSlot> getCoachSchedule(@PathVariable Long coachId) {
        return consultationService.getCoachSchedule(coachId);
    }

    @PostMapping("/book")
    public String bookConsultation(@RequestParam Long slotId, Authentication authentication) {
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        Long userId = userPrincipal.getUserId();

        return consultationService.bookConsultation(userId, slotId);
    }
    @GetMapping("/my-history")
    @PreAuthorize("hasAuthority('Member')")
    public ResponseEntity<?> getMyHealthHistory(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            Integer accountId = userPrincipal.getUserId().intValue(); // Member chỉ xem của chính mình

            List<HealthProfile> healthHistory = healthProfileService.getAccountHealthHistory(accountId);
            return ResponseEntity.ok(healthHistory);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy health history"));
        }
    }
    @GetMapping("/my-bookings")
    public ResponseEntity<?> getMyBookingHistory(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            Long userId = userPrincipal.getUserId();
            List<ConsultationBooking> bookingHistory = consultationService.getUserBookingHistory(userId);
            return ResponseEntity.ok(bookingHistory);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy lịch sử booking"));
        }
    }
}
