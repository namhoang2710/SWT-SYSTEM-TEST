package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.ErrorResponse;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationBooking;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationSlot;
import com.fu.swp391.group1.smokingcessation.service.ConsultationService;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import jakarta.servlet.http.HttpServletRequest;

import java.util.List;
@Transactional
@RestController
@RequestMapping("/api/Booking")
@PreAuthorize("hasAuthority('Coach')")
public class BookingController {
    @Autowired
    private ConsultationService consultationService;
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private HttpServletRequest request;
    @GetMapping("/available")
    public List<ConsultationSlot> getAvailableSlots(@RequestParam Long coachId) {
        return consultationService.getAvailableSlots(coachId);
    }

    @PostMapping("/addWeeklySlots")
    public ResponseEntity<?> addWeeklySlots(@RequestParam Long coachId,@RequestParam(required = false) String weekStart) {
        try {
            consultationService.addWeeklyConsultationSlots(coachId,weekStart);
            String message = weekStart != null
                    ? "Các ca tư vấn cho tuần " + weekStart + " đã được tạo!"
                    : "Các ca tư vấn cho tuần hiện tại đã được tạo!";

            return new ResponseEntity<>(message, HttpStatus.OK);
        } catch (IllegalArgumentException ex) {
            ErrorResponse errorResponse = new ErrorResponse("IllegalArgumentException", ex.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);

        }
    }
    @DeleteMapping("/deleteUnbookedSlotsForWeek")
    public ResponseEntity<?> deleteUnbookedSlotsForWeek(@RequestParam Long coachId,
                                                        @RequestParam(required = false) String weekStart) {
        try {
            consultationService.deleteUnbookedSlotsForWeek(coachId, weekStart);
            String message = weekStart != null
                    ? "Đã xóa các ca trống trong tuần " + weekStart + "!"
                    : "Đã xóa các ca trống trong tuần hiện tại!";

            return new ResponseEntity<>(message, HttpStatus.OK);
        } catch (IllegalArgumentException ex) {
            ErrorResponse errorResponse = new ErrorResponse("IllegalArgumentException", ex.getMessage());
            return new ResponseEntity<>(errorResponse, HttpStatus.BAD_REQUEST);
        }
    }
    @GetMapping("/coach-schedule")
    public ResponseEntity<?> getCoachSchedule(@RequestParam Long coachId, @AuthenticationPrincipal UserPrincipal userPrincipal) {
        if (!coachId.equals(userPrincipal.getCoachId())) {
            return ResponseEntity.status(403).body("Bạn không có quyền xem lịch của coach khác.");
        }
        return ResponseEntity.ok(consultationService.getCoachSchedule(coachId));
    }
    @GetMapping("/slot/{slotId}/booking-info")
    public ResponseEntity<?> getSlotBookingInfo(@PathVariable Long slotId,
                                                @AuthenticationPrincipal UserPrincipal userPrincipal) {
        try {
            Long coachId = userPrincipal.getCoachId();
            if (coachId == null) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Không tìm thấy Coach ID trong token"));
            }

            ConsultationBooking booking = consultationService.getSlotBookingInfo(slotId);

            if (booking == null) {
                return ResponseEntity.ok("Slot này chưa có ai booking");
            }

            // Kiểm tra slot có thuộc về coach này không
            if (!booking.getSlot().getCoach().getCoachId().equals(coachId)) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body(new ErrorResponse("FORBIDDEN", "Bạn chỉ có thể xem booking info của slot thuộc về mình"));
            }

            return ResponseEntity.ok(booking);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ErrorResponse("INTERNAL_ERROR", "Lỗi khi lấy thông tin booking"));
        }
    }

}
