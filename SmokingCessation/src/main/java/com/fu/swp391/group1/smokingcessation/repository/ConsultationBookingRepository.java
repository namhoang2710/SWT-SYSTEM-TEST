package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.ConsultationBooking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ConsultationBookingRepository extends JpaRepository<ConsultationBooking, Long> {
    List<ConsultationBooking> findBySlot_Coach_CoachId(Long coachId);
    boolean existsByUser_IdAndSlot_Coach_CoachId(Long userId, Long coachId);
    List<ConsultationBooking> findByUser_IdOrderByBookingTimeDesc(Long userId);
    Optional<ConsultationBooking> findBySlot_Id(Long slotId);
}