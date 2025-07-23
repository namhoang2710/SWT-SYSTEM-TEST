package com.fu.swp391.group1.smokingcessation.controller;


import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.FeedbackCommentCreateDTO;
import com.fu.swp391.group1.smokingcessation.entity.FeedbackComment;
import com.fu.swp391.group1.smokingcessation.service.FeedbackCommentService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api/feedbacks-comment")
public class FeedbackCommentController {

    @Autowired
    private FeedbackCommentService feedbackCommentService;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authHeader = request.getHeader("Authorization");
        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            return authHeader.substring(7);
        }
        return null;
    }

    @GetMapping("/admin/all")
    public ResponseEntity<?> getAllFeedbacksComment(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if (!"Admin".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only Admins can access all feedbacks");
        }

        List<FeedbackComment>  feedbackComments = feedbackCommentService.getAllFeedbacksComment();
        return ResponseEntity.ok(feedbackComments);
    }

    @PostMapping("/create/{commentId}")
    public ResponseEntity<?> createFeedback(@PathVariable int commentId, @RequestBody FeedbackCommentCreateDTO feedbackDTO, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        Long userId = jwtUtil.extractId(token);

        FeedbackComment feedback = feedbackCommentService.craeteFeedbackComment(feedbackDTO.getInformation(), commentId);
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
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only Admins can delete feedbacks");
        }

        boolean deleted = feedbackCommentService.deleteFeedbackComment(feedbackId);
        if (deleted) {
            return ResponseEntity.ok("Feedback deleted successfully.");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Feedback comment not found.");
        }
    }

    @GetMapping("/count/today")
    public ResponseEntity<?> countToday() {
        long count = feedbackCommentService.countToday();
        return ResponseEntity.ok(Collections.singletonMap("count", count));
    }

    @GetMapping("/count/by-date")
    public ResponseEntity<?> countByDate(@RequestParam("day") int day, @RequestParam("month") int month, @RequestParam("year") int year) {
        try {
            long count = feedbackCommentService.countByDate(day, month, year);
            return ResponseEntity.ok(Collections.singletonMap("count", count));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }

}
