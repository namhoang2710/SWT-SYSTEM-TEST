package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.FeedbackCoachCreateDTO;
import com.fu.swp391.group1.smokingcessation.dto.FeedbackCoachViewDTO;
import com.fu.swp391.group1.smokingcessation.entity.FeedbackCoach;
import com.fu.swp391.group1.smokingcessation.service.FeedbackCoachService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api/feedbacks-coach")
public class FeedbackCoachController {

    @Autowired
    private FeedbackCoachService feedbackCoachService;


    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }

    @GetMapping("/view/{coachId}")
    public ResponseEntity<?> getFeedbacksByCoach(@PathVariable Long coachId, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long userId = jwtUtil.extractId(token);
        String role = jwtUtil.extractRole(token);
        if (userId == null || role == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid token");
        }

        List<FeedbackCoachViewDTO> feedbacks = feedbackCoachService.getFeedbacksByCoach(coachId);
        return ResponseEntity.ok(feedbacks);
    }



    @PostMapping("/create/{coachId}")
    public ResponseEntity<?> createFeedback(@PathVariable Long coachId, @RequestBody FeedbackCoachCreateDTO dto, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if (!"Admin".equals(role) && !"Member".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
        }

        Long accountId = jwtUtil.extractId(token);
        FeedbackCoach feedback = feedbackCoachService.createFeedback(accountId, coachId, dto.getInformation());
        return ResponseEntity.ok(feedback);
    }


    @DeleteMapping("/delete/{feedbackId}")
    public ResponseEntity<?> deleteFeedback(@PathVariable int feedbackId, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if (!"Admin".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only admin can delete feedback");
        }

        boolean deleted = feedbackCoachService.deleteFeedback(feedbackId);
        if (deleted) {
            return ResponseEntity.ok("Feedback deleted successfully.");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Feedback not found.");
        }
    }


    @GetMapping("/coach/count/today")
    public ResponseEntity<?> countToday() {
        long count = feedbackCoachService.countCoachFeedbacksToday();
        return ResponseEntity.ok(Collections.singletonMap("count", count));
    }

    @GetMapping("/coach/count/by-date")
    public ResponseEntity<?> countByDate(@RequestParam("day") int day, @RequestParam("month") int month, @RequestParam("year") int year) {

        try {
            long count = feedbackCoachService.countCoachFeedbacksByDate(day, month, year);
            return ResponseEntity.ok(Collections.singletonMap("count", count));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}
