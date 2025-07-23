package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationBooking;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationSlot;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.CoachProfileRepository;
import com.fu.swp391.group1.smokingcessation.repository.ConsultationBookingRepository;
import com.fu.swp391.group1.smokingcessation.repository.ConsultationSlotRepository;
import com.fu.swp391.group1.smokingcessation.repository.MemberProfileRepository;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.TemporalAdjusters;
import java.util.ArrayList;
import java.util.List;
import com.fu.swp391.group1.smokingcessation.service.EmailService;

@Service
public class ConsultationService {
    @Autowired
    private ConsultationSlotRepository slotRepository;
    @Autowired
    private AccountRepository accountRepository;
    @Autowired
    private JavaMailSender mailSender;
    @Autowired
    private ConsultationBookingRepository consultationBookingRepository;
    @Autowired
    private CoachProfileRepository coachProfileRepository;
    @Autowired
    private MemberProfileRepository memberProfileRepository;
    @Autowired
    private EmailService emailService;
    @Transactional
    public String bookConsultation(Long userId, Long slotId) {
        Account user = accountRepository.findById(userId).orElseThrow(() -> new RuntimeException("User not found"));
        if (user.getConsultations() <= 0) {
            return "Bạn không còn số lần tư vấn.";
        }
        ConsultationSlot slot = slotRepository.findByIdAndIsBookedFalse(slotId);
        if (slot == null) {
            return "Ca tư vấn đã được đặt.";
        }
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(userId).orElse(null);
        if (memberProfile != null) {
            Long newCoachId = slot.getCoach().getCoachId();
            if (memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(newCoachId)) {
                memberProfile.setCurrentCoachId(newCoachId);
                memberProfileRepository.save(memberProfile);
            }
        }
        String meetingLink = createMeetingLink(slot, user);
        slot.setBooked(true);
        slotRepository.save(slot);
        user.setConsultations(user.getConsultations() - 1);
        accountRepository.save(user);
        ConsultationBooking booking = new ConsultationBooking();
        booking.setUser(user);
        booking.setSlot(slot);
        booking.setBookingTime(LocalDateTime.now());
        booking.setGoogleMeetLink(meetingLink);
        slotRepository.save(slot);
        accountRepository.save(user);
        consultationBookingRepository.save(booking);
        emailService.sendBookingEmails(user, slot.getCoach().getAccount(), meetingLink, slot);
        return "Đặt lịch thành công!";
    }
    private String createMeetingLink(ConsultationSlot slot, Account user) {
        String roomId = String.format("SC%d%d%s",
                slot.getCoach().getCoachId(),
                user.getId(),
                slot.getStartTime().format(DateTimeFormatter.ofPattern("MMddHHmm"))
        );
        return "https://meet.jit.si/" + roomId;
    }

    public List<ConsultationSlot> getAvailableSlots(Long coachId) {
        CoachProfile coach = coachProfileRepository.findById(coachId)
                .orElseThrow(() -> new RuntimeException("Coach not found"));
        return slotRepository.findByCoach(coach);
    }

    public void addWeeklyConsultationSlots(Long coachId, String weekStartStr) {
        try {
            LocalDate weekStart;

            if (weekStartStr != null && !weekStartStr.isEmpty()) {
                weekStart = LocalDate.parse(weekStartStr);
            } else {
                weekStart = LocalDate.now().with(DayOfWeek.MONDAY);
            }
            if (weekStart.getDayOfWeek() != DayOfWeek.MONDAY) {
                weekStart = weekStart.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            }

            CoachProfile coach = coachProfileRepository.findById(coachId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Coach not found"));


            int[] timeSlots = {8, 10, 13, 15}; // 08:00, 10:00, 13:00, 15:00
            int createdSlotsCount = 0;


            for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
                LocalDate currentDate = weekStart.plusDays(dayOffset);


                for (int hour : timeSlots) {
                    LocalDateTime slotStartTime = LocalDateTime.of(currentDate, LocalTime.of(hour, 0));


                    boolean slotExists = isSlotExists(coach, slotStartTime);

                    if (!slotExists) {

                        createConsultationSlot(coach, currentDate, hour, 0);
                        createdSlotsCount++;
                    }
                }
            }

            if (createdSlotsCount == 0) {
                throw new IllegalArgumentException("Tuần này đã có đủ lịch!");
            }

        } catch (Exception e) {
            throw new IllegalArgumentException("Tạo lịch thất bại!");
        }
    }

    public void addWeeklyConsultationSlots(Long coachId) {
        addWeeklyConsultationSlots(coachId, null);
    }


    private boolean isSlotExists(CoachProfile coach, LocalDateTime slotStartTime) {
        // Tìm kiếm trong khoảng ±30 giây để tránh lỗi millisecond
        LocalDateTime searchStart = slotStartTime.minusSeconds(30);
        LocalDateTime searchEnd = slotStartTime.plusSeconds(30);

        List<ConsultationSlot> existingSlots = slotRepository.findByCoachAndStartTimeBetween(
                coach,
                searchStart,
                searchEnd
        );

        return !existingSlots.isEmpty();
    }
    public void deleteUnbookedSlotsForWeek(Long coachId, String weekStartStr) {
        try {
            LocalDate weekStart;

            if (weekStartStr != null && !weekStartStr.isEmpty()) {
                weekStart = LocalDate.parse(weekStartStr);
            } else {
                weekStart = LocalDate.now().with(DayOfWeek.MONDAY);
            }

            if (weekStart.getDayOfWeek() != DayOfWeek.MONDAY) {
                // Tìm Monday của tuần chứa ngày này
                weekStart = weekStart.with(TemporalAdjusters.previousOrSame(DayOfWeek.MONDAY));
            }
            LocalDate endOfWeek = weekStart.plusDays(6);

            CoachProfile coach = coachProfileRepository.findById(coachId)
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Coach not found"));
            // Tìm tất cả slots trong tuần này
            List<ConsultationSlot> weekSlots = slotRepository.findByCoachAndStartTimeBetween(
                    coach,
                    weekStart.atStartOfDay(),
                    endOfWeek.atTime(23, 59, 59)
            );
            List<ConsultationSlot> unbookedSlots = new ArrayList<>();
            for (ConsultationSlot slot : weekSlots) {
                if (!slot.isBooked()) {
                    unbookedSlots.add(slot);
                }
            }
            if (unbookedSlots.isEmpty()) {
                throw new IllegalArgumentException("Không có ca trống nào để xóa trong tuần này!");
            }
            slotRepository.deleteAll(unbookedSlots);
        } catch (Exception e) {
            String weekDisplay = weekStartStr != null ? weekStartStr : "hiện tại";
            throw new IllegalArgumentException("Lỗi khi xóa ca trống trong tuần " + weekDisplay + ": " + e.getMessage());
        }
    }
    private void createConsultationSlot(CoachProfile coach, LocalDate date, int hour, int minute) {
        LocalTime startTime = LocalTime.of(hour, minute);
        LocalTime endTime = startTime.plusHours(1);
        LocalDateTime startDateTime = LocalDateTime.of(date, startTime);
        LocalDateTime endDateTime = LocalDateTime.of(date, endTime);
        ConsultationSlot slot = new ConsultationSlot();
        slot.setCoach(coach);
        slot.setStartTime(startDateTime);
        slot.setEndTime(endDateTime);
        slot.setBooked(false);
        slotRepository.save(slot);
    }
    public void deleteAllConsultationSlotsByCoachId(Long coachId) {
        CoachProfile coach = coachProfileRepository.findById(coachId)
                .orElseThrow(() -> new IllegalArgumentException("Coach not found with ID: " + coachId));
        slotRepository.deleteByCoach(coach);
    }
    public List<ConsultationSlot> getCoachSchedule(Long coachId) {
        CoachProfile coach = coachProfileRepository.findById(coachId)
                .orElseThrow(() -> new RuntimeException("Coach not found"));
        return slotRepository.findByCoach(coach);
    }
    public List<ConsultationBooking> getUserBookingHistory(Long userId) {
        return consultationBookingRepository.findByUser_IdOrderByBookingTimeDesc(userId);
    }
    public ConsultationBooking getSlotBookingInfo(Long slotId) {
        return consultationBookingRepository.findBySlot_Id(slotId).orElse(null);
    }
}
