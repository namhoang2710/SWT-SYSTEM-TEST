package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface ConsultationSlotRepository extends JpaRepository<ConsultationSlot, Long> {
    List<ConsultationSlot> findByCoachAndIsBookedFalse(CoachProfile coach);
    ConsultationSlot findByIdAndIsBookedFalse(Long id);
    List<ConsultationSlot> findByCoachAndStartTimeBetween(CoachProfile coach, LocalDateTime startTime, LocalDateTime endTime);
    void deleteByCoach(CoachProfile coach);
    List<ConsultationSlot> findByCoach(CoachProfile coach);
}