package com.fu.swp391.group1.smokingcessation.controller;


import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.CommentResponseDTO;
import com.fu.swp391.group1.smokingcessation.entity.Comment;
import com.fu.swp391.group1.smokingcessation.repository.CommentRepository;
import com.fu.swp391.group1.smokingcessation.service.CommentService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Collections;
import java.util.List;

@RestController
@RequestMapping("/api")
public class CommentController {

    @Autowired
    private CommentService commentService;

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }

    @GetMapping("/comments/all")
    public List<Comment> getAllComments() {
        return commentService.getAllComments();
    }



    @GetMapping("/comments/{blogId}")
    public ResponseEntity<?> getCommentsByBlogId(@PathVariable("blogId") int blogId) {
        List<CommentResponseDTO> commentDTOs = commentService.getCommentsByBlogId(blogId);
        return ResponseEntity.ok(commentDTOs);
    }




//    @PostMapping(value = "/comments/create/{blogId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
//    public ResponseEntity<?> createComment(@PathVariable int blogId,@RequestParam("content") String content,HttpServletRequest request) {
//        String token = extractToken(request);
//        if (token == null) {
//            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
//        }
//
//        String role = jwtUtil.extractRole(token);
//        Long userId = jwtUtil.extractId(token);
//
//        if (!"Member".equals(role) && !"Admin".equals(role)) {
//            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
//        }
//
//        return ResponseEntity.ok(commentService.createComment(comment, userId, blogId));
//    }

    @PostMapping("/comments/create/{blogId}")
    public ResponseEntity<?> createComment(@PathVariable int blogId,@RequestParam("content") String content,HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long userId = jwtUtil.extractId(token);
        String role = jwtUtil.extractRole(token);

        if (!"Member".equalsIgnoreCase(role) && !"Admin".equalsIgnoreCase(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
        }

        return ResponseEntity.ok(commentService.createComment(content, userId, blogId));
    }


    @DeleteMapping("/comments/delete/{id}")
    public ResponseEntity<?> deleteComment(@PathVariable int id, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        Long userId = jwtUtil.extractId(token);

        Comment comment = commentService.getCommentById(id);
        if ("Admin".equals(role) || comment.getAccount().getId().equals(userId)) {
            commentService.deleteComment(id);
            return ResponseEntity.ok("Comment deleted");
        }

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
    }

    @PutMapping("/comments/update/{id}")
    public ResponseEntity<?> updateComment(@PathVariable int id, @RequestParam("content") String newComment, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        Long userId = jwtUtil.extractId(token);

        Comment existingComment = commentService.getCommentById(id);
        if (existingComment == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Comment not found");
        }

        if ("Admin".equals(role) || existingComment.getAccount().getId().equals(userId)) {
            return ResponseEntity.ok(commentService.updateComment(id, newComment));
        }

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
    }

    @GetMapping("/comment/count/today")
    public ResponseEntity<?> countCommentsToday() {
        long count = commentService.countCommentsToday();
        return ResponseEntity.ok(Collections.singletonMap("count", count));
    }

    @GetMapping("/comment/count/by-date")
    public ResponseEntity<?> countCommentsByDate(@RequestParam("day") int day, @RequestParam("month") int month, @RequestParam("year") int year) {
        try {
            long count = commentService.countCommentsByDate(day, month, year);
            return ResponseEntity.ok(Collections.singletonMap("count", count));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }



}
