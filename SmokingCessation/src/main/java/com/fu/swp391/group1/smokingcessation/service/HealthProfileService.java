package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.HealthProfileRequest;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.HealthProfile;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.HealthProfileRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class HealthProfileService {

    @Autowired
    private HealthProfileRepository healthProfileRepository;
    @Autowired
    private AccountRepository accountRepository;

    @Transactional
    public HealthProfile createHealthProfile(Integer accountId, HealthProfileRequest request, Integer coachId) {
        Account user = accountRepository.findById(accountId.longValue())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        if (user.getHealthCheckups() <= 0) {
            throw new IllegalArgumentException("User không còn số lần kiểm tra sức khỏe");
        }
        HealthProfile healthProfile = new HealthProfile();
        healthProfile.setAccountId(accountId);
        healthProfile.setCoachId(coachId);
        healthProfile.setStartDate(request.getStartDate() != null ? request.getStartDate() : LocalDate.now());
        healthProfile.setHealthInfo(request.getHealthInfo());
        healthProfile.setLungCapacity(request.getLungCapacity());
        healthProfile.setHeartRate(request.getHeartRate());
        healthProfile.setBloodPressure(request.getBloodPressure());
        healthProfile.setCoachNotes(request.getCoachNotes());
        BigDecimal healthScore = calculateHealthScore(
                request.getLungCapacity(),
                request.getHeartRate(),
                request.getBloodPressure()
        );
        healthProfile.setHealthScore(healthScore);
        user.setHealthCheckups(user.getHealthCheckups() - 1);
        accountRepository.save(user);

        return healthProfileRepository.save(healthProfile);
    }
    @Transactional
    public HealthProfile updateHealthProfile(Integer healthProfileId, HealthProfileRequest request, Integer coachId) {
        HealthProfile existingProfile = healthProfileRepository.findById(healthProfileId)
                .orElseThrow(() -> new IllegalArgumentException("Health Profile không tìm thấy"));
        if (!existingProfile.getCoachId().equals(coachId)) {
            throw new IllegalArgumentException("Bạn không có quyền cập nhật health profile này");
        }

        existingProfile.setHealthInfo(request.getHealthInfo());
        existingProfile.setLungCapacity(request.getLungCapacity());
        existingProfile.setHeartRate(request.getHeartRate());
        existingProfile.setBloodPressure(request.getBloodPressure());
        existingProfile.setCoachNotes(request.getCoachNotes());

        BigDecimal healthScore = calculateHealthScore(
                request.getLungCapacity(),
                request.getHeartRate(),
                request.getBloodPressure()
        );
        existingProfile.setHealthScore(healthScore);

        return healthProfileRepository.save(existingProfile);
    }

    public List<HealthProfile> getAccountHealthHistory(Integer accountId) {
        return healthProfileRepository.findByAccountIdOrderByStartDateDesc(accountId);
    }
    public boolean canCoachAccessAccount(Integer coachId, Integer accountId) {
        return healthProfileRepository.existsByAccountIdAndCoachId(accountId, coachId);
    }
    @Transactional
    public void deleteHealthProfile(Integer healthProfileId) {
        healthProfileRepository.deleteById(healthProfileId);
    }
    public HealthProfile getHealthProfileById(Integer healthProfileId) {
        return healthProfileRepository.findById(healthProfileId)
                .orElseThrow(() -> new IllegalArgumentException("Health Profile không tìm thấy"));
    }
    private BigDecimal calculateHealthScore(BigDecimal lungCapacity, Integer heartRate, String bloodPressure) {
        double totalScore = 0.0;
        int validMetrics = 0;
        if (lungCapacity != null && lungCapacity.compareTo(BigDecimal.ZERO) > 0) {
            double lungScore = Math.min(100, Math.max(0,
                    ((lungCapacity.doubleValue() - 2000) / 2500) * 100
            ));
            totalScore += lungScore;
            validMetrics++;
        }
        if (heartRate != null && heartRate > 0) {
            double heartScore;
            if (heartRate >= 60 && heartRate <= 80) {
                heartScore = 100;
            } else if (heartRate >= 50 && heartRate <= 100) {
                heartScore = Math.max(60, 100 - Math.abs(heartRate - 70));
            } else {
                heartScore = Math.max(20, 80 - Math.abs(heartRate - 70));
            }
            totalScore += heartScore;
            validMetrics++;
        }
        if (bloodPressure != null && bloodPressure.contains("/")) {
            try {
                String[] parts = bloodPressure.split("/");
                int systolic = Integer.parseInt(parts[0].trim());
                int diastolic = Integer.parseInt(parts[1].trim());

                double bpScore;
                if (systolic <= 120 && diastolic <= 80) {
                    bpScore = 100;
                } else if (systolic <= 130 && diastolic <= 85) {
                    bpScore = 85;
                } else if (systolic <= 140 && diastolic <= 90) {
                    bpScore = 70;
                } else if (systolic <= 160 && diastolic <= 100) {
                    bpScore = 50;
                } else {
                    bpScore = 30;
                }
                totalScore += bpScore;
                validMetrics++;
            } catch (NumberFormatException e) {
            }
        }
        if (validMetrics > 0) {
            double averageScore = totalScore / validMetrics;
            return BigDecimal.valueOf(Math.round(averageScore * 100.0) / 100.0);
        }

        return BigDecimal.ZERO;
    }
}