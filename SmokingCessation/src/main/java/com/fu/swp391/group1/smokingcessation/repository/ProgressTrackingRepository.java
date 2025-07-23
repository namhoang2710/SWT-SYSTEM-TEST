package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.ProgressTracking;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface ProgressTrackingRepository extends JpaRepository<ProgressTracking, Long> {
    List<ProgressTracking> findByPlanIdAndAccountId(Long planId, Long accountId);
    List<ProgressTracking> findByPlanId(Long planId);
    List<ProgressTracking> findByAccountId(Long accountId);
    @Query("SELECT pt FROM ProgressTracking pt WHERE pt.planId = :planId AND pt.date BETWEEN :startDate AND :endDate ORDER BY pt.date DESC")
    List<ProgressTracking> findByPlanIdAndDateRange(@Param("planId") Long planId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    @Query("SELECT pt FROM ProgressTracking pt WHERE pt.accountId = :accountId AND pt.date BETWEEN :startDate AND :endDate ORDER BY pt.date DESC")
    List<ProgressTracking> findByAccountIdAndDateRange(@Param("accountId") Long accountId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    Optional<ProgressTracking> findByPlanIdAndAccountIdAndDate(Long planId, Long accountId, LocalDate date);
    boolean existsByPlanIdAndAccountIdAndDate(Long planId, Long accountId, LocalDate date);
    @Query("SELECT pt FROM ProgressTracking pt WHERE pt.accountId = :accountId ORDER BY pt.date DESC, pt.createdAt DESC")
    Optional<ProgressTracking> findLatestByAccountId(@Param("accountId") Long accountId);
    @Query("SELECT pt FROM ProgressTracking pt WHERE pt.planId IN :planIds AND (pt.coachFeedback IS NULL OR pt.coachFeedback = '') ORDER BY pt.date DESC")
    List<ProgressTracking> findProgressNeedingFeedback(@Param("planIds") List<Long> planIds);
    @Query("SELECT AVG(pt.cigarettesSmoked) FROM ProgressTracking pt WHERE pt.planId = :planId AND pt.date BETWEEN :startDate AND :endDate")
    Double getAverageCigarettesInPeriod(@Param("planId") Long planId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    @Query("SELECT COUNT(pt) FROM ProgressTracking pt WHERE pt.planId = :planId AND pt.date BETWEEN :startDate AND :endDate")
    Long countProgressInPeriod(@Param("planId") Long planId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    @Query("SELECT COUNT(pt) FROM ProgressTracking pt WHERE pt.planId = :planId AND pt.cigarettesSmoked = 0 AND pt.date BETWEEN :startDate AND :endDate")
    Long countSmokeFreeDays(@Param("planId") Long planId, @Param("startDate") LocalDate startDate, @Param("endDate") LocalDate endDate);
    @Query("SELECT WEEK(pt.date) as week, AVG(pt.cigarettesSmoked) as avgCigarettes, AVG(pt.cravingLevel) as avgCraving " +
            "FROM ProgressTracking pt WHERE pt.planId = :planId AND YEAR(pt.date) = :year " +
            "GROUP BY WEEK(pt.date) ORDER BY WEEK(pt.date)")
    List<Object[]> getWeeklyProgressSummary(@Param("planId") Long planId, @Param("year") int year);
}