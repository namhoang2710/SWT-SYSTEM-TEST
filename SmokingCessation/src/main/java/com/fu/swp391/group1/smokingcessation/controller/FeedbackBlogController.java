package com.fu.swp391.group1.smokingcessation.controller;


import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.FeedbackBlogCreateDTO;
import com.fu.swp391.group1.smokingcessation.entity.FeedbackBlog;
import com.fu.swp391.group1.smokingcessation.service.FeedbackBlogService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api/feedbacks-blog")
public class FeedbackBlogController {

    @Autowired
    private FeedbackBlogService feedbackBlogService;

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
    public ResponseEntity<?> getAllFeedbacks(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if (!"Admin".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Only Admins can access all feedbacks");
        }

        List<FeedbackBlog> feedbacks = feedbackBlogService.getAllFeedbacks();
        return ResponseEntity.ok(feedbacks);
    }

    @PostMapping("/create/{blogId}")
    public ResponseEntity<?> createFeedback(@PathVariable int blogId, @RequestBody FeedbackBlogCreateDTO feedbackDTO, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        Long userId = jwtUtil.extractId(token);

        FeedbackBlog feedback = feedbackBlogService.createFeedback(feedbackDTO.getInformation(), blogId);
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

        boolean deleted = feedbackBlogService.deleteFeedback(feedbackId);
        if (deleted) {
            return ResponseEntity.ok("Feedback deleted successfully.");
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Feedback not found.");
        }
    }

    @GetMapping("/blog/count/today")
    public ResponseEntity<?> countFeedbacksToday() {
        long count = feedbackBlogService.countFeedbacksToday();
        return ResponseEntity.ok(Collections.singletonMap("count", count));
    }

    @GetMapping("/blog/count/by-date")
    public ResponseEntity<?> countFeedbacksByDate(@RequestParam("day") int day, @RequestParam("month") int month, @RequestParam("year") int year) {

        try {
            long count = feedbackBlogService.countFeedbacksByDate(day, month, year);
            return ResponseEntity.ok(Collections.singletonMap("count", count));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }









}
