package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.*;
import com.fu.swp391.group1.smokingcessation.entity.Plan;
import com.fu.swp391.group1.smokingcessation.entity.PlanStatus;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.repository.PlanRepository;
import com.fu.swp391.group1.smokingcessation.repository.MemberProfileRepository;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

@Service
public class PlanManagementService {

    @Autowired
    private PlanRepository planRepository;

    @Autowired
    private AccountService accountService;

    @Autowired
    private MemberProfileRepository memberProfileRepository;


    @Transactional
    public PlanDTO createPlan(Long accountId, PlanCreateRequest request, Long coachId) {
        if (coachId == null) {
            throw new IllegalArgumentException("Không tìm thấy Coach ID trong token");
        }


        Account member = accountService.findById(accountId);
        if (member == null || !"Member".equals(member.getRole())) {
            throw new IllegalArgumentException("Account không tồn tại hoặc không phải Member");
        }


        if (request.getGoalDate().isBefore(request.getStartDate())) {
            throw new IllegalArgumentException("Ngày mục tiêu phải sau ngày bắt đầu");
        }


        Plan plan = new Plan();
        plan.setAccountId(accountId);
        plan.setCoachId(coachId);
        plan.setTitle(request.getTitle());
        plan.setDescription(request.getDescription());
        plan.setStartDate(request.getStartDate());
        plan.setGoalDate(request.getGoalDate());
        plan.setStatus(PlanStatus.ACTIVE);

        Plan savedPlan = planRepository.save(plan);

        return new PlanDTO(savedPlan);
    }

    public List<PlanDTO> getMemberPlans(Long userId) {
        List<Plan> plans = planRepository.findByAccountId(userId);
        return plans.stream()
                .map(PlanDTO::new)
                .collect(Collectors.toList());
    }

    public List<PlanDTO> getCoachPlans(Long coachId, PlanStatus status) {
        List<Plan> plans;
        if (status != null) {
            plans = planRepository.findByCoachIdAndStatus(coachId, status);
        } else {
            plans = planRepository.findByCoachId(coachId);
        }

        return plans.stream()
                .map(PlanDTO::new)
                .collect(Collectors.toList());
    }

    public List<PlanDTO> getPlansOfCurrentCoach(Long coachId) {
        // Lấy tất cả user mà coach này là currentCoach
        List<MemberProfile> memberProfiles = memberProfileRepository.findByCurrentCoachId(coachId);
        List<Long> userIds = memberProfiles.stream().map(mp -> mp.getAccount().getId()).collect(Collectors.toList());
        // Lấy toàn bộ plan của các user này
        List<Plan> plans = userIds.isEmpty() ? List.of() : planRepository.findByAccountIdIn(userIds);
        return plans.stream().map(PlanDTO::new).collect(Collectors.toList());
    }

    @Transactional
    public PlanDTO updatePlan(Long planId, PlanUpdateRequest request, Long coachId) {
        Plan existingPlan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));

        // Lấy MemberProfile của user
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(existingPlan.getAccountId()).orElse(null);
        if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Chỉ coach hiện tại của user mới được sửa kế hoạch!");
        }
        // Validate goal date if provided
        if (request.getGoalDate() != null &&
                request.getGoalDate().isBefore(existingPlan.getStartDate())) {
            throw new IllegalArgumentException("Ngày mục tiêu phải sau ngày bắt đầu");
        }
        // Update fields
        if (request.getTitle() != null && !request.getTitle().trim().isEmpty()) {
            existingPlan.setTitle(request.getTitle());
        }
        if (request.getDescription() != null && !request.getDescription().trim().isEmpty()) {
            existingPlan.setDescription(request.getDescription());
        }
        if (request.getStartDate() != null) {
            existingPlan.setStartDate(request.getStartDate());
        }
        if (request.getGoalDate() != null) {
            existingPlan.setGoalDate(request.getGoalDate());
        }
        Plan updatedPlan = planRepository.save(existingPlan);
        return new PlanDTO(updatedPlan);
    }

    @Transactional
    public PlanDTO updatePlanStatus(Long planId, PlanStatus status, Long coachId) {
        Plan existingPlan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));
        // Lấy MemberProfile của user
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(existingPlan.getAccountId()).orElse(null);
        if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Chỉ coach hiện tại của user mới được sửa trạng thái kế hoạch!");
        }
        existingPlan.setStatus(status);
        Plan updatedPlan = planRepository.save(existingPlan);
        return new PlanDTO(updatedPlan);
    }
}