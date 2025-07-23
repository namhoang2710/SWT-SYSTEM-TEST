package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.UserMedalCreationRequest;
import com.fu.swp391.group1.smokingcessation.entity.UserMedal;
import com.fu.swp391.group1.smokingcessation.service.UserMedalService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api")
public class UserMedalController {

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private UserMedalService userMedalService;

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }

    @PostMapping("/coach/medal/assign")
    public ResponseEntity<?> assignMedalToUser(@RequestParam("accountId") Long accountId, @RequestParam("medalId") int medalId, @RequestParam(value = "medalInfo", required = false) String medalInfo, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if (!"Coach".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Chỉ có Coach mới được sử dụng");
        }

        try {
            UserMedalCreationRequest req = new UserMedalCreationRequest(accountId, medalId, medalInfo);
            return ResponseEntity.ok(userMedalService.assignMedalToUser(req));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }


    @DeleteMapping("/coach/medal/delete/{userMedalId}")
    public ResponseEntity<?> deleteUserMedal(@PathVariable int userMedalId, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if (!"Coach".equals(role) && !"Admin".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Chỉ có Coach hoặc Admin mới được sử dụng");
        }

        try {
            userMedalService.deleteUserMedalById(userMedalId);
            return ResponseEntity.ok("Xóa huy chương thành công.");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(e.getMessage());
        }
    }

    @GetMapping("/coach/medal/user/{accountId}")
    public ResponseEntity<?> getMedalsByUser(@PathVariable Long accountId) {
        try {
            List<UserMedal> userMedals = userMedalService.getMedalsByUserId(accountId);
            return ResponseEntity.ok(userMedals);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Không thể xem huy chương của người dùng.");
        }
    }

    @GetMapping("/admin/medal/all")
    public ResponseEntity<?> getAllUserMedals(HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if (!"Admin".equals(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Chỉ có Admin mới được sử dụng");
        }

        try {
            return ResponseEntity.ok(userMedalService.getAllUserMedals());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Không thể xem danh sách UserMedal.");
        }
    }



}
