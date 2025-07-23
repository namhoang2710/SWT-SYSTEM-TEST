package com.fu.swp391.group1.smokingcessation.controller;


import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.MemberProfileCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import com.fu.swp391.group1.smokingcessation.service.MemberProfileService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/member/profile")
public class MemberProfileController {

    @Autowired
    private MemberProfileService memberProfileService;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(jakarta.servlet.http.HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }

    @GetMapping("/all")
    public ResponseEntity<?> getAll(@RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "10") int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<MemberProfile> result = memberProfileService.getAllMemberProfiles(pageable);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMyProfile(jakarta.servlet.http.HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long userId = jwtUtil.extractId(token);
        return ResponseEntity.ok(memberProfileService.getMPByAccountId(userId));
    }

    @PostMapping("/create")
    public ResponseEntity<?> createMemberProfile(@RequestBody MemberProfileCreationRequest memberProfileCreationRequest, jakarta.servlet.http.HttpServletRequest request) {
        String token = extractToken(request);
        Long userId = jwtUtil.extractId(token);
        if (memberProfileService.getMPByAccountId(userId).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Profile already exists.");
        }

        memberProfileCreationRequest.setAccountId(userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(memberProfileService.createMemberProfile(memberProfileCreationRequest, userId));
    }

    @PutMapping("/update")
    public ResponseEntity<?> updateMemberProfile(@RequestBody MemberProfileCreationRequest req, jakarta.servlet.http.HttpServletRequest request) {
        String token = extractToken(request);
        Long accountId = jwtUtil.extractId(token);

        Optional<MemberProfile> existingProfile = memberProfileService.getMPByAccountId(accountId);
        if (existingProfile.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Profile not found.");
        }

        return ResponseEntity.ok(memberProfileService.updateMemberProfile(accountId, req));
    }

    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteMyMemberProfile(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long accountId = jwtUtil.extractId(token);

        if (memberProfileService.getMPByAccountId(accountId).isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Profile not found.");
        }

        memberProfileService.deleteMPByAccountId(accountId);
        return ResponseEntity.ok("Profile deleted.");
    }

    @GetMapping("/admin/today")
    public ResponseEntity<Long> countMembersCreatedToday() {
        long count = memberProfileService.countTodayMembers();
        return ResponseEntity.ok(count);
    }

    @GetMapping("/members/by-date")
    public ResponseEntity<?> countMembersByDayMonthYear(@RequestParam("day") int day, @RequestParam("month") int month, @RequestParam("year") int year) {
        try {
            Map<String, Object> result = memberProfileService.countMembersByDayMonthYear(day, month, year);
            return ResponseEntity.ok(result);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }



}
