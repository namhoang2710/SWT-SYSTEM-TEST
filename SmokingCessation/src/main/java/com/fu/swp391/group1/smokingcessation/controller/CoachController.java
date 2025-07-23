package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;
import com.fu.swp391.group1.smokingcessation.service.CoachService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/coach")
public class CoachController {
    @Autowired
    private CoachService coachService;

    @GetMapping("/my-users")
    public ResponseEntity<?> getMyUsers(@AuthenticationPrincipal UserPrincipal userPrincipal) {

        Long coachId = userPrincipal.getCoachId();

        return ResponseEntity.ok(coachService.getMyUsers(coachId));
    }
    @GetMapping("/user/{userId}/profile")
    public ResponseEntity<?> getUserProfile(@PathVariable Long userId,
                                            @AuthenticationPrincipal UserPrincipal userPrincipal) {
        Long coachId = userPrincipal.getCoachId();

        return ResponseEntity.ok(coachService.getUserProfile(coachId, userId));
    }
}

