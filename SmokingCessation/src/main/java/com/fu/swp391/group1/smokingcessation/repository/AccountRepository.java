package com.fu.swp391.group1.smokingcessation.repository;

   import com.fu.swp391.group1.smokingcessation.entity.Account;
   import org.springframework.data.jpa.repository.JpaRepository;
   import org.springframework.stereotype.Repository;


import java.util.List;

public interface AccountRepository extends JpaRepository<Account, Long> {
    Account findByEmail(String email);
    Account findByVerificationCode(String verificationCode);
    Account findByResetPasswordToken(String resetPasswordToken);
    boolean existsByEmail(String email);

}
