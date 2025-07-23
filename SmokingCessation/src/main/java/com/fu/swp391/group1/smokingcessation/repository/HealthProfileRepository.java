package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.HealthProfile;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface HealthProfileRepository extends JpaRepository<HealthProfile, Integer> {


    List<HealthProfile> findByAccountIdOrderByStartDateDesc(Integer accountId);
    @Query("SELECT COUNT(hp) > 0 FROM HealthProfile hp WHERE hp.accountId = :accountId AND hp.coachId = :coachId")
    boolean existsByAccountIdAndCoachId(@Param("accountId") Integer accountId, @Param("coachId") Integer coachId);

}