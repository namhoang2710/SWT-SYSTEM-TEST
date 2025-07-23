package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationBooking;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface CoachProfileRepository extends JpaRepository<CoachProfile, Long> {
    Optional<CoachProfile> findByAccount_Id(Long accountId);
    Optional<CoachProfile> findByAccount(Account account);

}
