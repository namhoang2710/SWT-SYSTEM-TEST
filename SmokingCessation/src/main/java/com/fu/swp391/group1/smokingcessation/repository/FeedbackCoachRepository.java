package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.FeedbackCoach;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface FeedbackCoachRepository extends JpaRepository<FeedbackCoach, Integer> {
    List<FeedbackCoach> findByCoach_CoachId(Long coachId);
    long countByCreatedDate(LocalDate createdDate);
}

