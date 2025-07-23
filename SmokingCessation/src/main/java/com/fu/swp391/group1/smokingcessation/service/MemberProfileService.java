package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.CoachProfileCreationRequest;
import com.fu.swp391.group1.smokingcessation.dto.MemberProfileCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.MemberProfileRepository;

import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;


import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class MemberProfileService {

    @Autowired
    private MemberProfileRepository memberProfileRepository;

    @Autowired
    private AccountRepository accountRepository;

    public Page<MemberProfile> getAllMemberProfiles(Pageable pageable) {
        return memberProfileRepository.findAll(pageable);
    }

    public Optional<MemberProfile> getMPByAccountId(Long accountId) {
        return memberProfileRepository.findMPByAccount_Id(accountId);
    }

    public List<MemberProfile> getAllMemberProfiles() {
        return memberProfileRepository.findAll();
    }

    public List<MemberProfile> getMemberProfilesByCurrentCoachId(Long coachId) {
        return memberProfileRepository.findByCurrentCoachId(coachId);
    }


    public MemberProfile createMemberProfile(MemberProfileCreationRequest memberProfileCreationRequest, Long accountId) {
        var account = accountRepository.findById(accountId).orElseThrow(() -> new IllegalArgumentException("Account not found"));

        MemberProfile profile = new MemberProfile();
        profile.setStartDate(memberProfileCreationRequest.getStartDate());
        profile.setMotivation(memberProfileCreationRequest.getMotivation());
        profile.setAccount(account);

        return memberProfileRepository.save(profile);

    }

    public MemberProfile updateMemberProfile(Long accountId, MemberProfileCreationRequest req) {
        MemberProfile profile = memberProfileRepository.findMPByAccount_Id(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Profile not found"));

        profile.setStartDate(req.getStartDate());
        profile.setMotivation(req.getMotivation());
        return memberProfileRepository.save(profile);
    }

    @Transactional
    public void deleteMPByAccountId(Long accountId) {
        MemberProfile profile = memberProfileRepository.findMPByAccount_Id(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Profile not found"));

        profile.setStartDate(null);
        profile.setMotivation("");
        memberProfileRepository.save(profile);

    }

    public long countTodayMembers() {
        return memberProfileRepository.countByStartDate(LocalDate.now());
    }

    public Map<String, Object> countMembersByDayMonthYear(int day, int month, int year) {
        try {
            LocalDate date = LocalDate.of(year, month, day);
            long count = memberProfileRepository.countByStartDate(date);

            Map<String, Object> result = new HashMap<>();
            result.put("day", day);
            result.put("month", month);
            result.put("year", year);
            result.put("count", count);
            return result;
        } catch (DateTimeException e) {
            throw new IllegalArgumentException("Ngày không hợp lệ");
        }
    }



}
