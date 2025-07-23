package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.PlanDetail;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface PlanDetailRepository extends JpaRepository<PlanDetail, Long> {

    // Tìm tất cả weeks của một plan
    List<PlanDetail> findByPlanIdOrderByWeekNumberAsc(Long planId);

    // Tìm week cụ thể trong plan
    Optional<PlanDetail> findByPlanIdAndWeekNumber(Long planId, Integer weekNumber);

    // Tìm week hiện tại (đang trong khoảng thời gian)
    @Query("SELECT pd FROM PlanDetail pd WHERE pd.planId = :planId " +
            "AND :currentDate BETWEEN pd.startDate AND pd.endDate")
    Optional<PlanDetail> findCurrentWeek(@Param("planId") Long planId,
                                         @Param("currentDate") LocalDate currentDate);

    // Tìm week tiếp theo
    @Query("SELECT pd FROM PlanDetail pd WHERE pd.planId = :planId " +
            "AND pd.startDate > :currentDate ORDER BY pd.startDate ASC LIMIT 1")
    Optional<PlanDetail> findNextWeek(@Param("planId") Long planId,
                                      @Param("currentDate") LocalDate currentDate);

    // Tìm week theo date range
    @Query("SELECT pd FROM PlanDetail pd WHERE pd.planId = :planId " +
            "AND pd.startDate <= :endDate AND pd.endDate >= :startDate " +
            "ORDER BY pd.weekNumber ASC")
    List<PlanDetail> findByPlanIdAndDateRange(@Param("planId") Long planId,
                                              @Param("startDate") LocalDate startDate,
                                              @Param("endDate") LocalDate endDate);

    // Đếm số weeks trong plan
    @Query("SELECT COUNT(pd) FROM PlanDetail pd WHERE pd.planId = :planId")
    Long countWeeksByPlanId(@Param("planId") Long planId);

    // Tìm week cuối cùng của plan
    @Query("SELECT pd FROM PlanDetail pd WHERE pd.planId = :planId " +
            "ORDER BY pd.weekNumber DESC LIMIT 1")
    Optional<PlanDetail> findLastWeekByPlanId(@Param("planId") Long planId);

    // Tìm week đầu tiên của plan
    @Query("SELECT pd FROM PlanDetail pd WHERE pd.planId = :planId " +
            "ORDER BY pd.weekNumber ASC LIMIT 1")
    Optional<PlanDetail> findFirstWeekByPlanId(@Param("planId") Long planId);

    // Xóa tất cả weeks của plan
    void deleteByPlanId(Long planId);

    // Check xem week number đã tồn tại chưa
    boolean existsByPlanIdAndWeekNumber(Long planId, Integer weekNumber);

    // Tìm weeks theo target cigarettes range
    @Query("SELECT pd FROM PlanDetail pd WHERE pd.planId = :planId " +
            "AND pd.targetCigarettesPerDay BETWEEN :minTarget AND :maxTarget " +
            "ORDER BY pd.weekNumber ASC")
    List<PlanDetail> findByTargetCigarettesRange(@Param("planId") Long planId,
                                                 @Param("minTarget") Integer minTarget,
                                                @Param("maxTarget") Integer maxTarget);
}