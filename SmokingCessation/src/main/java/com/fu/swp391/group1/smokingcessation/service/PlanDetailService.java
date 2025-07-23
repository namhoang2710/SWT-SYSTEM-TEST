package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.*;
import com.fu.swp391.group1.smokingcessation.entity.Plan;
import com.fu.swp391.group1.smokingcessation.entity.PlanDetail;
import com.fu.swp391.group1.smokingcessation.entity.PlanStatus;
import com.fu.swp391.group1.smokingcessation.repository.PlanDetailRepository;
import com.fu.swp391.group1.smokingcessation.repository.PlanRepository;
import com.fu.swp391.group1.smokingcessation.repository.MemberProfileRepository;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
public class PlanDetailService {

    @Autowired
    private PlanDetailRepository planDetailRepository;

    @Autowired
    private PlanRepository planRepository;

    @Autowired
    private MemberProfileRepository memberProfileRepository;

    @Transactional
    public PlanDetailDTO createWeek(Long planId, PlanDetailCreateRequest request, Long coachId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(plan.getAccountId()).orElse(null);
        if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Chỉ coach hiện tại của user mới được tạo tuần cho kế hoạch!");
        }
        if (plan.getStatus() != PlanStatus.ACTIVE) {
            throw new IllegalArgumentException("Chỉ có thể tạo tuần cho kế hoạch đang hoạt động");
        }
        if (request.getEndDate().isBefore(request.getStartDate())) {
            throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu");
        }
        Integer nextWeekNumber = getNextWeekNumber(planId);
        PlanDetail planDetail = new PlanDetail();
        planDetail.setPlanId(planId);
        planDetail.setWeekNumber(nextWeekNumber);
        planDetail.setStartDate(request.getStartDate());
        planDetail.setEndDate(request.getEndDate());
        planDetail.setTargetCigarettesPerDay(request.getTargetCigarettesPerDay());
        planDetail.setWeeklyContent(request.getWeeklyContent());
        PlanDetail savedPlanDetail = planDetailRepository.save(planDetail);
        return new PlanDetailDTO(savedPlanDetail);
    }

    public List<PlanDetailDTO> getWeeksByPlan(Long planId, Long coachId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(plan.getAccountId()).orElse(null);
        if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Chỉ coach hiện tại của user mới được xem tuần của kế hoạch!");
        }
        List<PlanDetail> planDetails = planDetailRepository.findByPlanIdOrderByWeekNumberAsc(planId);
        return planDetails.stream()
                .map(PlanDetailDTO::new)
                .collect(Collectors.toList());
    }

    public PlanDetailDTO getWeekById(Long planDetailId, Long coachId) {
        PlanDetail planDetail = planDetailRepository.findById(planDetailId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tuần!"));
        Plan plan = planRepository.findById(planDetail.getPlanId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(plan.getAccountId()).orElse(null);
        if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Chỉ coach hiện tại của user mới được xem tuần của kế hoạch!");
        }
        return new PlanDetailDTO(planDetail);
    }

    @Transactional
    public PlanDetailDTO updateWeek(Long planDetailId, PlanDetailUpdateRequest request, Long coachId) {
        PlanDetail planDetail = planDetailRepository.findById(planDetailId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tuần!"));
        Plan plan = planRepository.findById(planDetail.getPlanId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(plan.getAccountId()).orElse(null);
        if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Chỉ coach hiện tại của user mới được cập nhật tuần của kế hoạch!");
        }
        if (request.getStartDate() != null) {
            planDetail.setStartDate(request.getStartDate());
        }
        if (request.getEndDate() != null) {
            planDetail.setEndDate(request.getEndDate());
        }
        if (request.getTargetCigarettesPerDay() != null) {
            planDetail.setTargetCigarettesPerDay(request.getTargetCigarettesPerDay());
        }
        if (request.getWeeklyContent() != null && !request.getWeeklyContent().trim().isEmpty()) {
            planDetail.setWeeklyContent(request.getWeeklyContent());
        }
        if (planDetail.getStartDate() != null && planDetail.getEndDate() != null) {
            if (planDetail.getEndDate().isBefore(planDetail.getStartDate())) {
                throw new IllegalArgumentException("Ngày kết thúc phải sau ngày bắt đầu");
            }
        }
        PlanDetail updatedPlanDetail = planDetailRepository.save(planDetail);
        return new PlanDetailDTO(updatedPlanDetail);
    }

    @Transactional
    public void deleteWeek(Long planDetailId, Long coachId) {
        PlanDetail planDetail = planDetailRepository.findById(planDetailId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tuần!"));
        Plan plan = planRepository.findById(planDetail.getPlanId())
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));
        MemberProfile memberProfile = memberProfileRepository.findMPByAccount_Id(plan.getAccountId()).orElse(null);
        if (memberProfile == null || memberProfile.getCurrentCoachId() == null || !memberProfile.getCurrentCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Chỉ coach hiện tại của user mới được xóa tuần của kế hoạch!");
        }
        planDetailRepository.delete(planDetail);
    }



    public List<PlanDetailDTO> getWeeksByPlanForMember(Long planId, Long memberId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));

        if (!plan.getAccountId().equals(memberId)) {
            throw new IllegalArgumentException("Bạn chỉ có thể xem tuần của kế hoạch của mình");
        }

        List<PlanDetail> planDetails = planDetailRepository.findByPlanIdOrderByWeekNumberAsc(planId);
        return planDetails.stream()
                .map(PlanDetailDTO::new)
                .collect(Collectors.toList());
    }



    private Integer getNextWeekNumber(Long planId) {
        return planDetailRepository.findLastWeekByPlanId(planId)
                .map(lastWeek -> lastWeek.getWeekNumber() + 1)
                .orElse(1);
    }
}