

package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.FeedbackCoachViewDTO;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.entity.FeedbackCoach;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.CoachProfileRepository;
import com.fu.swp391.group1.smokingcessation.repository.FeedbackCoachRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class FeedbackCoachService {

    @Autowired
    private FeedbackCoachRepository feedbackCoachRepository;

    @Autowired
    private CoachProfileRepository coachProfileRepository;

    @Autowired
    private AccountRepository accountRepository;

    public List<FeedbackCoachViewDTO> getFeedbacksByCoach(Long coachId) {
        List<FeedbackCoach> feedbacks = feedbackCoachRepository.findByCoach_CoachId(coachId);
        return feedbacks.stream().map(fb -> {
            Account acc = fb.getAccount();
            return new FeedbackCoachViewDTO(
                    fb.getCoachFeedbackID(),
                    fb.getInformation(),
                    fb.getCreatedDate(),
                    fb.getCreatedTime(),
                    acc.getId(),
                    acc.getName(),
                    acc.getImage()
            );
        }).collect(Collectors.toList());
    }



    public FeedbackCoach createFeedback(Long accountId, Long coachId, String information) {
        Account sender = accountRepository.findById(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Account not found"));

        CoachProfile coach = coachProfileRepository.findById(coachId)
                .orElseThrow(() -> new IllegalArgumentException("Coach not found"));

        FeedbackCoach feedback = new FeedbackCoach();
        feedback.setAccount(sender);
        feedback.setCoach(coach);
        feedback.setInformation(information);
        return feedbackCoachRepository.save(feedback);
    }


    public boolean deleteFeedback(int feedbackId) {
        Optional<FeedbackCoach> feedbackOpt = feedbackCoachRepository.findById(feedbackId);
        if (feedbackOpt.isPresent()) {
            feedbackCoachRepository.delete(feedbackOpt.get());
            return true;
        }
        return false;
    }

    public long countCoachFeedbacksToday() {
        return feedbackCoachRepository.countByCreatedDate(LocalDate.now());
    }

    public long countCoachFeedbacksByDate(int day, int month, int year) {
        try {
            LocalDate date = LocalDate.of(year, month, day);
            return feedbackCoachRepository.countByCreatedDate(date);
        } catch (DateTimeException e) {
            throw new IllegalArgumentException("Ngày không hợp lệ: " + e.getMessage());
        }
    }
}
