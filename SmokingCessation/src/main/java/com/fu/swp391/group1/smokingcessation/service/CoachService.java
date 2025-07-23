package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.dto.CoachUserDTO;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationBooking;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.CoachProfileRepository;
import com.fu.swp391.group1.smokingcessation.repository.ConsultationBookingRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class CoachService {

    @Autowired
    private AccountRepository accountRepository;
    @Autowired
    private CoachProfileRepository coachProfileRepository;
    @Autowired
    private ConsultationBookingRepository bookingRepository;
    @Autowired
    private AccountService accountService;
    @Autowired
    private MemberProfileService memberProfileService;

    public List<Account> getAllCoaches() {
        return accountRepository.findAll().stream()
                .filter(a -> "Coach".equalsIgnoreCase(a.getRole()))
                .collect(Collectors.toList());
    }

    @Transactional
    public Account addCoach(Account admin, Long accountId) {
        if (admin == null || !"Admin".equalsIgnoreCase(admin.getRole())) {
            throw new SecurityException("Admins only");
        }
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Account not found"));
        if (!"Member".equalsIgnoreCase(account.getRole())) {
            throw new IllegalStateException("Account must be a member");
        }
        account.setRole("Coach");
        return accountRepository.save(account);
    }

    @Transactional
    public void removeCoach(Account admin, Long accountId) {
        if (admin == null || !"Admin".equalsIgnoreCase(admin.getRole())) {
            throw new SecurityException("Admins only");
        }
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Account not found"));
        if (!"Coach".equalsIgnoreCase(account.getRole())) {
            throw new IllegalStateException("Account is not a coach");
        }
        account.setRole("Member");
        accountRepository.save(account);
    }

    public List<CoachUserDTO> getMyUsers(Long coachId) {
        List<MemberProfile> memberProfiles = memberProfileService.getMemberProfilesByCurrentCoachId(coachId);
        List<CoachUserDTO> users = new ArrayList<>();
        for (MemberProfile mp : memberProfiles) {
            Account user = mp.getAccount();
            CoachUserDTO userDTO = new CoachUserDTO(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getYearbirth(),
                user.getGender()
            );
            users.add(userDTO);
        }
        return users;
    }
    private boolean hasPermissionToViewUser(Long coachId, Long userId) {
        List<ConsultationBooking> bookings = bookingRepository.findBySlot_Coach_CoachId(coachId);
        return bookings.stream()
                .anyMatch(booking -> booking.getUser().getId().equals(userId));
    }

    public Map<String, Object> getUserProfile(Long coachId, Long userId) {

        CoachProfile coach = coachProfileRepository.findById(coachId)
                .orElseThrow(() -> new RuntimeException("Coach not found"));


        // if (!hasPermissionToViewUser(coachId, userId)) {
        //     throw new SecurityException("Coach không có quyền xem profile của user này");
        // }

        Account user = accountService.findById(userId);
        if (user == null) {
            throw new RuntimeException("User not found");
        }


        Optional<MemberProfile> memberProfileOpt = memberProfileService.getMPByAccountId(userId);


        Map<String, Object> response = new HashMap<>();
        response.put("account", user);
        response.put("memberProfile", memberProfileOpt.orElse(null));

        return response;
    }

}