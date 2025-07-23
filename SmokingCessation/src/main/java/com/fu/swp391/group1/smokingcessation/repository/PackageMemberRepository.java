package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.PackageMember;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PackageMemberRepository extends JpaRepository<PackageMember, Integer> {
    List<PackageMember> findByAccountId(Long accountId);
}