package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.Plan;
import com.fu.swp391.group1.smokingcessation.entity.PlanStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PlanRepository extends JpaRepository<Plan, Long> {
    Optional<Plan> findByAccountIdAndStatus(Long accountId, PlanStatus status);

    List<Plan> findByAccountId(Long accountId);

    List<Plan> findByCoachId(Long coachId);

    List<Plan> findByCoachIdAndStatus(Long coachId, PlanStatus status);

    List<Plan> findByStatus(PlanStatus status);

    List<Plan> findByAccountIdIn(List<Long> accountIds);
}