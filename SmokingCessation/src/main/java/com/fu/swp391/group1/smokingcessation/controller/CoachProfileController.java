package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.CoachProfileCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.CoachProfile;
import com.fu.swp391.group1.smokingcessation.service.CoachProfileService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/coach/profile")
public class CoachProfileController {

    @Autowired
    private CoachProfileService coachProfileService;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }

    @GetMapping("/all")
    public List<CoachProfile> getAll() {
        return coachProfileService.getAllCoachProfiles();
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMyProfile(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long userId = jwtUtil.extractId(token);
        return ResponseEntity.ok(coachProfileService.getByAccountId(userId));
    }

    @PostMapping(value = "/create", consumes = "multipart/form-data")
    public ResponseEntity<?> createCoachProfile(@ModelAttribute CoachProfileCreationRequest coachProfileCreationRequest, HttpServletRequest request) {
        String token = extractToken(request);
        Long userId = jwtUtil.extractId(token);
        if (coachProfileService.getByAccountId(userId).isPresent()) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Profile already exists.");
        }

        coachProfileCreationRequest.setAccountId(userId);
        return ResponseEntity.status(HttpStatus.CREATED).body(coachProfileService.createCoachProfile(coachProfileCreationRequest, userId));
    }

    @PutMapping(value = "/update", consumes = "multipart/form-data")
    public ResponseEntity<?> updateCoachProfile(@ModelAttribute CoachProfileCreationRequest req, HttpServletRequest request) {
        String token = extractToken(request);
        Long accountId = jwtUtil.extractId(token);

        Optional<CoachProfile> existingProfile = coachProfileService.getByAccountId(accountId);
        if (existingProfile.isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Profile not found.");
        }

        return ResponseEntity.ok(coachProfileService.updateCoachProfile(accountId, req));
    }

    @DeleteMapping("/delete")
    public ResponseEntity<?> deleteMyCoachProfile(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }
        Long accountId = jwtUtil.extractId(token);

        if (coachProfileService.getByAccountId(accountId).isEmpty()) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Profile not found.");
        }

        coachProfileService.deleteByAccountId(accountId);
        return ResponseEntity.ok("Profile deleted.");
    }











}
