package com.fu.swp391.group1.smokingcessation.controller;


import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.BlogCreationRequest;
import com.fu.swp391.group1.smokingcessation.dto.BlogResponseDTO;
import com.fu.swp391.group1.smokingcessation.entity.Blog;
import com.fu.swp391.group1.smokingcessation.repository.BlogRepository;
import com.fu.swp391.group1.smokingcessation.service.BlogService;
import jakarta.servlet.http.HttpServletRequest;

import java.util.Collections;
import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api")
public class BlogController {

    @Autowired
    private BlogService blogService;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }
//xong
    @GetMapping("/blogs/all")
    public ResponseEntity<?> getAllBlogs(HttpServletRequest request) {
        String token = extractToken(request);
        Long userId = null;

        if (token != null) {
            userId = jwtUtil.extractId(token);
        }

        List<BlogResponseDTO> result = blogService.getAllBlogs(userId);
        return ResponseEntity.ok(result);
    }




    //xong
    @GetMapping("/blogs/{id}")
    public ResponseEntity<?> getBlogById(@PathVariable Integer id, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null || !"Admin".equals(jwtUtil.extractRole(token))) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Access denied");
        }
        return ResponseEntity.ok(blogService.getBlogById(id));
    }

//xong
    @GetMapping("/blogs/my")
    public ResponseEntity<?> getMyBlogs(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
        }
        Long userId = jwtUtil.extractId(token);
        return ResponseEntity.ok(blogService.findByAccountId(userId));
    }

//xong
    @PutMapping(value = "/blogs/update/{id}", consumes = "multipart/form-data")
    public ResponseEntity<?> updateBlog(@PathVariable int id, @ModelAttribute BlogCreationRequest blogCreationRequest, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        Long userId = jwtUtil.extractId(token);

        Blog blog = blogService.getBlogById(id);
        if ("Admin".equals(role) || (blog.getAccount().getId().equals(userId) && "Member".equals(role)) || (blog.getAccount().getId().equals(userId) && "Coach".equals(role))) {
            return ResponseEntity.ok(blogService.updateBlog(id, blogCreationRequest));
        }

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
    }

    @DeleteMapping("/blogs/delete/{id}")
    public ResponseEntity<?> deleteBlog(@PathVariable int id, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        Long userId = jwtUtil.extractId(token);

        Blog blog = blogService.getBlogById(id);
        if ("Admin".equals(role) || (blog.getAccount().getId().equals(userId) && "Member".equals(role)) || (blog.getAccount().getId().equals(userId) && "Coach".equals(role))) {
            blogService.deleteBlog(id);
            return ResponseEntity.ok("Blog deleted");
        }

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
    }
//xong



    @PostMapping(value = "/blogs/create", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createBlog(@ModelAttribute BlogCreationRequest blogCreationRequest,HttpServletRequest request) {

        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long userId = jwtUtil.extractId(token);
        blogCreationRequest.setAccountID(userId);
        Blog blog = blogService.createBlog(blogCreationRequest, userId);

        return ResponseEntity.status(HttpStatus.CREATED).body(blog);
    }



    @PutMapping("/blogs/like/{id}")
    public ResponseEntity<?> blogLike(@PathVariable int id, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long userId = jwtUtil.extractId(token);
        Map<String, Object> result = blogService.blogLike(id, userId);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/blog/count/today")
    public ResponseEntity<?> countBlogsToday() {
        long count = blogService.countBlogsToday();
        return ResponseEntity.ok(Collections.singletonMap("count", count));
    }

    @GetMapping("/blog/count/by-date")
    public ResponseEntity<?> countBlogsByDate(@RequestParam("day") int day, @RequestParam("month") int month, @RequestParam("year") int year) {

        try {
            long count = blogService.countBlogsByDate(day, month, year);
            return ResponseEntity.ok(Collections.singletonMap("count", count));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }







}
