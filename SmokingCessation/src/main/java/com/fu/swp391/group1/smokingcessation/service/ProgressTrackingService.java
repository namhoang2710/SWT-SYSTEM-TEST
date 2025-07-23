package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.ProgressDTO;
import com.fu.swp391.group1.smokingcessation.dto.SavingsDTO;
import com.fu.swp391.group1.smokingcessation.entity.*;
import com.fu.swp391.group1.smokingcessation.repository.*;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Service
public class ProgressTrackingService {

    @Autowired
    private ProgressTrackingRepository progressTrackingRepository;

    @Autowired
    private PlanRepository planRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private SmokingLogRepository smokingLogRepository;

    @Autowired
    private MemberProfileRepository memberProfileRepository;

    @Transactional
    public ProgressTracking updateDailyProgress(Long planId, Long accountId, LocalDate date,
                                                Integer cigarettesSmoked, Integer cravingLevel,
                                                Integer moodLevel, Integer exerciseMinutes, String notes) {

        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));

        if (plan.getStatus() != PlanStatus.ACTIVE) {
            throw new IllegalArgumentException("Kế hoạch không còn hoạt động!");
        }


        if (!plan.getAccountId().equals(accountId)) {
            throw new IllegalArgumentException("Bạn không có quyền cập nhật kế hoạch này!");
        }


        Optional<ProgressTracking> existingProgress = progressTrackingRepository
                .findByPlanIdAndAccountIdAndDate(planId, accountId, date);

        ProgressTracking progress;
        if (existingProgress.isPresent()) {

            progress = existingProgress.get();
        } else {

            progress = new ProgressTracking();
            progress.setPlanId(planId);
            progress.setAccountId(accountId);
            progress.setDate(date);
            progress.setCreatedAt(LocalDateTime.now());
        }


        progress.setCigarettesSmoked(cigarettesSmoked != null ? cigarettesSmoked : 0);
        progress.setCravingLevel(cravingLevel);
        progress.setMoodLevel(moodLevel);
        progress.setExerciseMinutes(exerciseMinutes != null ? exerciseMinutes : 0);
        progress.setNotes(notes);

        // Tính số tiền tiết kiệm
        BaselineData baseline = getBaselineFromSmokingLog(accountId, planId);
        BigDecimal moneySave = BigDecimal.ZERO;
        if (baseline != null && cigarettesSmoked != null) {
            int reduced = Math.max(0, baseline.baselineCigarettes - cigarettesSmoked);
            moneySave = baseline.costPerCigarette.multiply(BigDecimal.valueOf(reduced));
        }
        progress.setMoneySave(moneySave);

        return progressTrackingRepository.save(progress);
    }


    public List<ProgressTracking> getProgressByPlan(Long planId, Long accountId) {
        return progressTrackingRepository.findByPlanIdAndAccountId(planId, accountId);
    }



    @Transactional
    public ProgressTracking addCoachFeedback(Long progressId, String feedback) {
        ProgressTracking progress = progressTrackingRepository.findById(progressId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tiến độ!"));

        progress.setCoachFeedback(feedback);
        return progressTrackingRepository.save(progress);
    }
    public Map<String, Object> getProgressStatistics(Long planId) {
        Plan plan = planRepository.findById(planId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy kế hoạch!"));

        LocalDate startDate = plan.getStartDate();
        LocalDate endDate = LocalDate.now();

        Map<String, Object> stats = new HashMap<>();

        Long totalEntries = progressTrackingRepository.countProgressInPeriod(planId, startDate, endDate);
        stats.put("totalEntries", totalEntries);

        Double avgCigarettes = progressTrackingRepository.getAverageCigarettesInPeriod(planId, startDate, endDate);
        stats.put("avgCigarettes", avgCigarettes);

        Long smokeFreeDays = progressTrackingRepository.countSmokeFreeDays(planId, startDate, endDate);
        stats.put("smokeFreeDays", smokeFreeDays);

        try {
            BaselineData baseline = getBaselineFromSmokingLog(plan.getAccountId(), planId);
            if (baseline != null && avgCigarettes != null) {
                double reductionPercentage = ((baseline.baselineCigarettes - avgCigarettes)
                        / baseline.baselineCigarettes) * 100;
                stats.put("reductionPercentage", Math.max(0, reductionPercentage));
                stats.put("baselineCigarettes", baseline.baselineCigarettes);
            }
        } catch (Exception e) {

        }

        return stats;
    }





    public SavingsDTO calculateDailySavings(Long planId, Long accountId, LocalDate date, Integer cigarettesSmoked) {
        try {

            BaselineData baseline = getBaselineFromSmokingLog(accountId, planId);

            if (baseline == null) {
                return createDefaultSavings(date, cigarettesSmoked);
            }


            Integer cigarettesReduced = Math.max(0, baseline.baselineCigarettes - cigarettesSmoked);
            BigDecimal dailySavings = baseline.costPerCigarette.multiply(BigDecimal.valueOf(cigarettesReduced));


            BigDecimal totalSavings = calculateTotalSavingsToDate(planId, accountId, date, baseline);


            String message = generateImprovementMessage(cigarettesReduced, dailySavings);

            SavingsDTO savingsDTO = new SavingsDTO(planId, "", date, date);
            savingsDTO.setBaselineCigarettes(baseline.baselineCigarettes);
            savingsDTO.setActualCigarettes(cigarettesSmoked);
            savingsDTO.setCigarettesReduced(cigarettesReduced);
            savingsDTO.setCostPerCigarette(baseline.costPerCigarette);
            savingsDTO.setDailySavings(dailySavings);
            savingsDTO.setTotalSavings(totalSavings);
            savingsDTO.setImprovementMessage(message);

            return savingsDTO;

        } catch (Exception e) {
            return createDefaultSavings(date, cigarettesSmoked);
        }
    }

    private BaselineData getBaselineFromSmokingLog(Long accountId, Long planId) {
        try {


            Optional<Plan> planOpt = planRepository.findById(planId);
            if (planOpt.isEmpty()) {
                return null;
            }
            Plan plan = planOpt.get();

            Optional<MemberProfile> memberProfileOpt = memberProfileRepository.findMPByAccount_Id(accountId);
            if (memberProfileOpt.isEmpty()) {
                return null;
            }
            Integer memberId = memberProfileOpt.get().getMemberId();

            Optional<SmokingLog> latestLogOpt = smokingLogRepository.findLatestByMemberId(memberId);
            if (latestLogOpt.isEmpty()) {
                return null;
            }

            SmokingLog log = latestLogOpt.get();
            return createBaselineFromLog(log);

        } catch (Exception e) {
            return null;
        }
    }

    private BaselineData createBaselineFromLog(SmokingLog log) {


        Integer baselineCigarettes = log.getCigarettes();
        Double cost = log.getCost();
        Integer numberOfCigarettes = log.getNumberOfCigarettes() != null ? log.getNumberOfCigarettes() : 20;



        BigDecimal costPerCigarette = BigDecimal.valueOf(cost)
                .divide(BigDecimal.valueOf(numberOfCigarettes), 2, RoundingMode.HALF_UP);



        return new BaselineData(baselineCigarettes, costPerCigarette);
    }

    private BigDecimal calculateTotalSavingsToDate(Long planId, Long accountId, LocalDate currentDate, BaselineData baseline) {
        try {
            Optional<Plan> planOpt = planRepository.findById(planId);
            if (planOpt.isEmpty()) {
                return BigDecimal.ZERO;
            }
            Plan plan = planOpt.get();

            List<ProgressTracking> progressList = progressTrackingRepository.findByPlanIdAndDateRange(
                    planId, plan.getStartDate(), currentDate
            );

            BigDecimal totalSavings = BigDecimal.ZERO;
            for (ProgressTracking progress : progressList) {
                Integer cigarettesReduced = Math.max(0, baseline.baselineCigarettes - progress.getCigarettesSmoked());
                BigDecimal dailySavings = baseline.costPerCigarette.multiply(BigDecimal.valueOf(cigarettesReduced));
                totalSavings = totalSavings.add(dailySavings);
            }

            return totalSavings;
        } catch (Exception e) {
            return BigDecimal.ZERO;
        }
    }
    private String generateImprovementMessage(Integer cigarettesReduced, BigDecimal dailySavings) {
        if (cigarettesReduced <= 0) {
            return "Hôm nay chưa cải thiện, hãy cố gắng hơn ngày mai! 💪";
        } else if (cigarettesReduced <= 5) {
            return String.format("Tốt lắm! Bạn đã giảm được %d điếu và tiết kiệm %,.0fđ! 👍",
                    cigarettesReduced, dailySavings);
        } else if (cigarettesReduced <= 10) {
            return String.format("Xuất sắc! Bạn đã giảm được %d điếu và tiết kiệm %,.0fđ! 🎉",
                    cigarettesReduced, dailySavings);
        } else {
            return String.format("Tuyệt vời! Bạn đã giảm được %d điếu và tiết kiệm %,.0fđ! Tiếp tục nhé! 🏆",
                    cigarettesReduced, dailySavings);
        }
    }


    private SavingsDTO createDefaultSavings(LocalDate date, Integer cigarettesSmoked) {
        Integer defaultBaseline = 20;
        BigDecimal defaultCostPerCigarette = BigDecimal.valueOf(2500);
        Integer cigarettesReduced = Math.max(0, defaultBaseline - cigarettesSmoked);
        BigDecimal dailySavings = defaultCostPerCigarette.multiply(BigDecimal.valueOf(cigarettesReduced));

        SavingsDTO savingsDTO = new SavingsDTO(null, "", date, date);
        savingsDTO.setBaselineCigarettes(defaultBaseline);
        savingsDTO.setActualCigarettes(cigarettesSmoked);
        savingsDTO.setCigarettesReduced(cigarettesReduced);
        savingsDTO.setCostPerCigarette(defaultCostPerCigarette);
        savingsDTO.setDailySavings(dailySavings);
        savingsDTO.setTotalSavings(dailySavings);
        savingsDTO.setImprovementMessage("Dữ liệu baseline chưa có, sử dụng ước tính: 20 điếu/ngày, 2,500đ/điếu");

        return savingsDTO;
    }


    public ProgressDTO getProgressWithSavings(Long progressId) {
        ProgressTracking progress = progressTrackingRepository.findById(progressId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tiến độ!"));
        String planTitle = "";
        if (progress.getPlan() != null) {
            planTitle = progress.getPlan().getTitle();
        }
        ProgressDTO progressDTO = new ProgressDTO(progress, planTitle);

        SavingsDTO savings = calculateDailySavings(
                progress.getPlanId(),
                progress.getAccountId(),
                progress.getDate(),
                progress.getCigarettesSmoked()
        );
        progressDTO.setSavings(savings);

        return progressDTO;
    }

   
    private static class BaselineData {
        Integer baselineCigarettes;
        BigDecimal costPerCigarette;

        BaselineData(Integer baselineCigarettes, BigDecimal costPerCigarette) {
            this.baselineCigarettes = baselineCigarettes;
            this.costPerCigarette = costPerCigarette;
        }
    }


}