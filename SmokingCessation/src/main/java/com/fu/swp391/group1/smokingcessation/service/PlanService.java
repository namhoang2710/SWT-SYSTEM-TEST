package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.entity.*;
import com.fu.swp391.group1.smokingcessation.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class PlanService {

    @Autowired
    private PlanRepository planRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private CoachProfileRepository coachProfileRepository;

    public List<Plan> getPlansByMemberId(Long memberId) {
        return planRepository.findByAccountId(memberId);
    }


    public List<Plan> getPlansByCoachId(Long coachId) {
        return planRepository.findByCoachId(coachId);
    }


    public List<Plan> getPlansByAccountIds(List<Long> accountIds) {
        return planRepository.findByAccountIdIn(accountIds);
    }


    @Transactional
    public Plan updatePlan(Long planId, String title, String description, PlanStatus status) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));

        if (title != null && !title.trim().isEmpty()) {
            plan.setTitle(title);
        }
        if (description != null && !description.trim().isEmpty()) {
            plan.setDescription(description);
        }
        if (status != null) {
            plan.setStatus(status);
        }

        return planRepository.save(plan);
    }


    public Plan getPlanById(Long planId) {
        return planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));
    }
}