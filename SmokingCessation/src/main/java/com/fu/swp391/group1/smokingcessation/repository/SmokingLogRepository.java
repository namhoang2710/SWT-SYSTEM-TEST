package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.SmokingLog;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface SmokingLogRepository extends JpaRepository<SmokingLog, Integer> {
    List<SmokingLog> findByMemberId(Integer memberId);
    @Query("SELECT sl FROM SmokingLog sl WHERE sl.memberId = :memberId ORDER BY sl.date DESC LIMIT 1")
    Optional<SmokingLog> findLatestByMemberId(@Param("memberId") Integer memberId);


}
