package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.CreateCoachRequestDTO;
import com.fu.swp391.group1.smokingcessation.dto.InformationPackageDTO;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.service.AccountService;
import com.fu.swp391.group1.smokingcessation.service.CoachService;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import lombok.Data;

@RestController
@RequestMapping("/api/admin/coaches")
public class AdminCoachController { 

    @Autowired
    private AccountService accountService;

    
    @Autowired
    private CoachService coachService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private AccountRepository accountRepository;

    

    @GetMapping("/all")
    public ResponseEntity<List<Account>> getAllCoaches() {
        return ResponseEntity.ok(coachService.getAllCoaches());
    }


    @PostMapping("/{accountId}")
    public ResponseEntity<Account> addCoach(
        @PathVariable Long accountId,
        @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        Long currentUserId = userPrincipal.getUserId();
        Account account = accountRepository.findById(currentUserId).orElse(null);
        if (account == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        try {
            return ResponseEntity.ok(coachService.addCoach(account, accountId));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
    }


    @DeleteMapping("/{accountId}")
public ResponseEntity<Void> removeCoach(
    @PathVariable Long accountId,
    @AuthenticationPrincipal UserPrincipal userPrincipal
) {
    Long currentUserId = userPrincipal.getUserId();
    Account account = accountRepository.findById(currentUserId).orElse(null);
    if (account == null) {
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
    }

    try {
        coachService.removeCoach(account, accountId);
        return ResponseEntity.ok().build();
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }
}
@PostMapping("/create")
    public ResponseEntity<?> createCoachByAdmin(
            @RequestBody CreateCoachRequestDTO request,
            @AuthenticationPrincipal UserPrincipal userPrincipal
    ) {
        Long currentUserId = userPrincipal.getUserId();
        Account admin = accountRepository.findById(currentUserId).orElse(null);

        if (admin == null || !"Admin".equalsIgnoreCase(admin.getRole())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Chỉ Admin mới có quyền tạo Coach!");
        }

        try {
            Account newCoach = accountService.createCoachAccountByAdmin(
                    request.getName(),
                    request.getEmail(),
                    request.getYearbirth(),
                    request.getGender()
            );
            return ResponseEntity.ok(newCoach);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }


}