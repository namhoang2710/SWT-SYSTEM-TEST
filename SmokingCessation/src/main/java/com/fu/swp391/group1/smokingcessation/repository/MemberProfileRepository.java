package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface MemberProfileRepository extends JpaRepository<MemberProfile, Integer> {
    MemberProfile findByAccountId(Long accountId);
    Optional<MemberProfile> findMPByAccount_Id(Long accountId);
    Page<MemberProfile> findAll(Pageable pageable);
    List<MemberProfile> findByCurrentCoachId(Long currentCoachId);
    long countByStartDate(LocalDate date);
}