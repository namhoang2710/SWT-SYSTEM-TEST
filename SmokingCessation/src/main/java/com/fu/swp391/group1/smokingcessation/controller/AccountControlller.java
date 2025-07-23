package com.fu.swp391.group1.smokingcessation.controller;

import com.cloudinary.Cloudinary;
import com.fu.swp391.group1.smokingcessation.config.CloudinaryConfig;
import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.AccountRegisterDTO;
import com.fu.swp391.group1.smokingcessation.dto.AccountUpdateDTO;
import com.fu.swp391.group1.smokingcessation.dto.ErrorResponse;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.Login;
import com.fu.swp391.group1.smokingcessation.service.AccountService;
import com.fu.swp391.group1.smokingcessation.service.TokenBlacklistService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;



import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/account")
public class AccountControlller {
    @Autowired
    private AccountService accountService;
    @Autowired
    private JwtUtil jwtUtil;
    @Autowired
    private PasswordEncoder passwordEncoder;
    @Autowired
    private TokenBlacklistService tokenBlacklistService;
    @Autowired
    private Cloudinary cloudinary;


    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody AccountRegisterDTO accountRegisterDTO) {
        try {
        Account account = new Account();
        account.setEmail(accountRegisterDTO.getEmail());
        account.setPassword(accountRegisterDTO.getPassword());
        account.setName(accountRegisterDTO.getName());
        account.setYearbirth(accountRegisterDTO.getYearbirth());
        account.setGender(accountRegisterDTO.getGender());
        Account registeredAccount = accountService.Register(account);
        return ResponseEntity.ok("Registration successful! Please check your email to verify your account.");
        } catch (IllegalArgumentException e) {
            throw e;
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Lỗi server: " + e.getMessage());
        }
    }
    @GetMapping("/verify")
    public ResponseEntity<?> verifyAccount(@RequestParam("code") String code) {
        boolean verified = accountService.verify(code);
        if (verified) {
            return ResponseEntity.ok(Map.of("message", "Account verified successfully!"));
        } else {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(Map.of("message", "Invalid or expired verification code."));
        }
    }


    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Login loginDTO) {
        try {
            String token = accountService.login(loginDTO.getEmail(), loginDTO.getPassword());
            Map<String, String> response = new HashMap<>();
            response.put("token", token);
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            ErrorResponse errorResponse = new ErrorResponse("Authentication error", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
        }
    }


    @GetMapping("/profile")
    public ResponseEntity<?> getUserProfile(@AuthenticationPrincipal UserPrincipal userPrincipal) {
        Long userId = userPrincipal.getUserId();

        Account account = accountService.findById(userId);
        if (account == null) {
            return ResponseEntity.status(404).body("User not found");
        }

        return ResponseEntity.ok(account);
    }



    //xong
    @PutMapping(value = "/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateProfile(@PathVariable Long id,
                                           @ModelAttribute AccountUpdateDTO accountUpdateDTO,
                                           Authentication authentication) {
        UserPrincipal userPrincipal = (UserPrincipal) authentication.getPrincipal();
        Long currentUserId = userPrincipal.getUserId();

        if (!currentUserId.equals(id)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Access denied");
        }

        try {
            Account accountToUpdate = new Account();
            accountToUpdate.setId(id);
            accountToUpdate.setName(accountUpdateDTO.getName());
            accountToUpdate.setYearbirth(accountUpdateDTO.getYearbirth() != null ? accountUpdateDTO.getYearbirth() : 0);
            accountToUpdate.setGender(accountUpdateDTO.getGender());
            accountToUpdate.setPassword(accountUpdateDTO.getPassword());
            Account updatedAccount = accountService.update(accountToUpdate, accountUpdateDTO.getImage());
            if (updatedAccount != null) {
                return ResponseEntity.ok(updatedAccount);
            } else {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
            }
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Update failed: " + e.getMessage());
        }
    }


    @GetMapping("/all")
    public List<Account> findAllAccounts() {
        return accountService.findAllAccounts();
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(@AuthenticationPrincipal UserPrincipal userPrincipal,
                                    HttpServletRequest request) {
        try {
            String authHeader = request.getHeader("Authorization");
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                String token = authHeader.substring(7);
                tokenBlacklistService.blacklistToken(token);
            }

            Map<String, String> response = new HashMap<>();
            response.put("message", "Logout successful");
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Logout error: " + e.getMessage());
        }
    }
    
    
    @DeleteMapping("/Ban/{accountId}")
    public ResponseEntity<?> BanAccount(@PathVariable Long accountId, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if ("Admin".equals(role)) {
            accountService.BanAccount(accountId);
            return ResponseEntity.ok("Account banned successfully");

        }

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Chỉ Admin mới có quyền khóa tài khoản");

    }

    @DeleteMapping("/Unban/{accountId}")
    public ResponseEntity<?> UnbanAccount(@PathVariable Long accountId, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        String role = jwtUtil.extractRole(token);
        if ("Admin".equals(role)) {
            accountService.UnbanAccount(accountId);
            return ResponseEntity.ok("Account unbanned successfully");

        }
        
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Chỉ Admin mới có quyền khóa tài khoản");
    }

    private String extractToken(jakarta.servlet.http.HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }
    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        if (email == null || email.isBlank()) {
            return ResponseEntity.badRequest().body("Email không được để trống");
        }
        try {
            accountService.requestPasswordReset(email);
            return ResponseEntity.ok("Liên kết đặt lại mật khẩu đã được gửi tới email.");
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi server");
        }
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        String token = request.get("token");
        String newPassword = request.get("newPassword");
        if (token == null || newPassword == null || token.isBlank() || newPassword.isBlank()) {
            return ResponseEntity.badRequest().body("Token và mật khẩu mới không được để trống");
        }
        try {
            boolean success = accountService.resetPassword(token, newPassword);
            if (success) {
                return ResponseEntity.ok("Đặt lại mật khẩu thành công");
            }
            return ResponseEntity.badRequest().body("Token không hợp lệ hoặc đã hết hạn");
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Lỗi server");
        }
    }
}