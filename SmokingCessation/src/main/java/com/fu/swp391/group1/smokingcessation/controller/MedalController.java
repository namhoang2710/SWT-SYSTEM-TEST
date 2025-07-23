package com.fu.swp391.group1.smokingcessation.controller;


import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.MedalCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.Blog;
import com.fu.swp391.group1.smokingcessation.entity.Medal;
import com.fu.swp391.group1.smokingcessation.service.MedalService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class MedalController {

    @Autowired
    private MedalService medalService;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }

    @GetMapping("/medal/all")
    public List<Medal> getAllMedal() {
        return medalService.getAllMedal();
    }

    @PostMapping(value = "/medal/admin/create", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createMedal(@ModelAttribute MedalCreationRequest medalCreationRequest, HttpServletRequest request) {

        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Medal medal = medalService.createMedal(medalCreationRequest);

        return ResponseEntity.status(HttpStatus.CREATED).body(medal);
    }


    @DeleteMapping("/medal/admin/delete/{id}")
    public ResponseEntity<?> deleteMedal(@PathVariable int id, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        medalService.deleteMedal(id);
        return ResponseEntity.ok("Medal deleted");
    }

    @PutMapping(value = "/medal/admin/update/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateMedal(@PathVariable int id, @ModelAttribute MedalCreationRequest medalCreationRequest, HttpServletRequest request) {

        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Medal updatedMedal = medalService.updateMedal(id, medalCreationRequest);
        return ResponseEntity.ok(updatedMedal);
    }


}

