package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.UserMedal;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface UserMedalRepository extends JpaRepository<UserMedal, Long> {
    List<UserMedal> findByAccount_Id(Long accountId);


}
