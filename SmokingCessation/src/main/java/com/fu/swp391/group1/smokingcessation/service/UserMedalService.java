package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.UserMedalCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.Medal;
import com.fu.swp391.group1.smokingcessation.entity.UserMedal;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.MedalRepository;
import com.fu.swp391.group1.smokingcessation.repository.UserMedalRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserMedalService {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private MedalRepository medalRepository;

    @Autowired
    private UserMedalRepository userMedalRepository;

    public UserMedal assignMedalToUser(UserMedalCreationRequest req) {
        Account account = accountRepository.findById(req.getAccountId())
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        Medal medal = medalRepository.findById(req.getMedalId())
                .orElseThrow(() -> new IllegalArgumentException("Medal not found"));

        UserMedal userMedal = new UserMedal();
        userMedal.setAccount(account);
        userMedal.setMedal(medal);
        userMedal.setMedalInfo(req.getMedalInfo());


        return userMedalRepository.save(userMedal);
    }


    public void deleteUserMedalById(int userMedalId) {
        if (!userMedalRepository.existsById((long) userMedalId)) {
            throw new IllegalArgumentException("UserMedal không tồn tại.");
        }
        userMedalRepository.deleteById((long) userMedalId);
    }

    public List<UserMedal> getMedalsByUserId(Long accountId) {
        return userMedalRepository.findByAccount_Id(accountId);
    }

    public List<UserMedal> getAllUserMedals() {
        return userMedalRepository.findAll();
    }


}

