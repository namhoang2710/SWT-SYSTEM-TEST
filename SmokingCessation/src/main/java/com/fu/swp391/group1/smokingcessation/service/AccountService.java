package com.fu.swp391.group1.smokingcessation.service;

import com.cloudinary.Cloudinary;
import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.MemberProfile;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
public class AccountService {

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private EmailService emailService;

    @Autowired
    private JwtUtil jwtUtil;

    @Autowired
    private CloudinaryImageService cloudinaryImageService;

    @Autowired
    private Cloudinary cloudinary;

    @Autowired
    private CoachProfileService coachProfileService; 

    public Account  Register (Account account){
        if (accountRepository.existsByEmail(account.getEmail())) {
            throw new IllegalArgumentException("Email đã tồn tại!");
        }
        account.setPassword(passwordEncoder.encode(account.getPassword()));
        account.setRole("Member");
        account.setStatus("Pending");
        account.setVerificationCode(generateVerificationCode());
        account.setImage(account.getImage());
        accountRepository.save(account);
        sendVerificationEmail(account);
        return account;
    }
    public Account createCoachAccountByAdmin(String name, String email, int yearbirth, String gender) {
        if (accountRepository.existsByEmail(email)) {
            throw new IllegalArgumentException("Email đã tồn tại!");
        }

        String rawPassword = UUID.randomUUID().toString().substring(0, 8);
        String encodedPassword = passwordEncoder.encode(rawPassword);

        Account account = new Account();
        account.setName(name);
        account.setEmail(email);
        account.setPassword(encodedPassword);
        account.setRole("Coach");
        account.setStatus("Active");
        account.setYearbirth(yearbirth);
        account.setGender(gender);
        accountRepository.save(account);

        if (account.getRole().equalsIgnoreCase("COACH")) {
        coachProfileService.createEmptyProfileForCoach(account);
}

        sendCoachAccountEmail(account, rawPassword);
        return account;
    }

    private void sendCoachAccountEmail(Account account, String rawPassword) {
        String subject = "Tài khoản Coach đã được tạo";
        String message = "Xin chào " + account.getName() + ",\n\n"
                + "Tài khoản Coach của bạn đã được tạo bởi quản trị viên.\n\n"
                + "Email: " + account.getEmail() + "\n"
                + "Mật khẩu: " + rawPassword + "\n\n"
                + "Vui lòng đăng nhập và đổi mật khẩu ngay sau khi sử dụng.\n\n"
                + "Trân trọng.";
        emailService.sendSimpleMessage(account.getEmail(), subject, message);
    }


    private String generateVerificationCode() {
        return UUID.randomUUID().toString();
    }

    private void sendVerificationEmail(Account account) {
        String subject = "Please verify your registration";
        String verifyUrl = "http://localhost:5173/verify?code=" + account.getVerificationCode();
        String mobileVerifyUrl = "smokingcessation://verification?code=" + account.getVerificationCode();
        String message = "Dear " + account.getName() + ",\n\n"
                + "Please click one of the links below to verify your registration:\n\n"
                + "For web browser:\n"
                + verifyUrl + "\n\n"
                + "For mobile app:\n"
                + mobileVerifyUrl + "\n\n"
                + "Thank you!";
        emailService.sendSimpleMessage(account.getEmail(), subject, message);
    }

    public boolean verify(String code) {
        Account account = accountRepository.findByVerificationCode(code);
        if (account == null || "Active".equals(account.getStatus())) {
            return false;
        }
        account.setStatus("Active");
        account.setVerificationCode(null);
        accountRepository.save(account);
        return true;
    }

    public String login(String email, String password) {
        Account account = accountRepository.findByEmail(email);
        if (account != null && passwordEncoder.matches(password, account.getPassword())) {
            Long coachId = null;
            if (account.getCoachProfile() != null) {
                coachId = account.getCoachProfile().getCoachId();
            }
            return jwtUtil.generateToken(account.getEmail(), account.getRole(), account.getId(), coachId);
        }
        throw new IllegalArgumentException("Email hoặc mật khẩu không chính xác!");
    }

    public Account findByEmail(String email) {
        return accountRepository.findByEmail(email);
    }

    public Account findById(Long id) {
        return accountRepository.findById(id).orElse(null);
    }




public Account update(Account account, MultipartFile imageFile) {
    Account existingAccount = findById(account.getId());
    if (existingAccount != null) {

        if (account.getName() != null && !account.getName().trim().isEmpty()) {
            existingAccount.setName(account.getName());
        }
        if (account.getYearbirth() > 1000) {
            existingAccount.setYearbirth(account.getYearbirth());
        }
        if (account.getGender() != null && !account.getGender().trim().isEmpty()) {
            existingAccount.setGender(account.getGender());
        }
        if (imageFile != null && !imageFile.isEmpty()) {
            String oldImageUrl = existingAccount.getImage();
            if (oldImageUrl != null && oldImageUrl.startsWith("http")) {
                try {
                    String publicId = extractPublicId(oldImageUrl);
                    if (publicId != null) {
                        cloudinary.uploader().destroy(publicId, Map.of());
                    }
                } catch (IOException e) {
                    throw new RuntimeException("Không thể xoá ảnh cũ: " + e.getMessage(), e);
                }
            }
            try {
                Map uploadResult = cloudinary.uploader().upload(imageFile.getBytes(), Map.of("resource_type", "auto"));
                String newImageUrl = (String) uploadResult.get("secure_url");
                existingAccount.setImage(newImageUrl);
            } catch (IOException e) {
                throw new RuntimeException("Lỗi khi upload ảnh đại diện mới: " + e.getMessage(), e);
            }
        }
        if (account.getPassword() != null && !account.getPassword().isEmpty()) {
            existingAccount.setPassword(passwordEncoder.encode(account.getPassword()));
        }
        return accountRepository.save(existingAccount);
    }
    return null;
}
    private String extractPublicId(String imageUrl) {
        int lastSlash = imageUrl.lastIndexOf('/');
        int dot = imageUrl.lastIndexOf('.');
        if (lastSlash != -1 && dot != -1 && dot > lastSlash) {
            return imageUrl.substring(lastSlash + 1, dot);
        }
        return null;
    }

    @Transactional
    public void BanAccount(Long accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản với ID: " + accountId));
        account.setStatus("Ban");
        accountRepository.save(account);
    }

    @Transactional
    public void UnbanAccount(Long accountId) {
        Account account = accountRepository.findById(accountId)
                .orElseThrow(() -> new IllegalArgumentException("Không tìm thấy tài khoản với ID: " + accountId));
        account.setStatus("Active");
        accountRepository.save(account);
    }

    public List<Account> findAllAccounts() {
        return accountRepository.findAll();
    }

    public void requestPasswordReset(String email) {
        Account account = accountRepository.findByEmail(email);
        if (account == null) {
            throw new IllegalArgumentException("Email không tồn tại!");
        }

        String resetToken = UUID.randomUUID().toString();
        account.setResetPasswordToken(resetToken);
        account.setResetPasswordTokenExpiry(LocalDateTime.now().plusHours(24)); // Token hết hạn sau 24 giờ
        accountRepository.save(account);
        sendPasswordResetEmail(account);
    }

    private void sendPasswordResetEmail(Account account) {
        String subject = "Đặt lại mật khẩu";
        String resetUrl = "https://http://localhost:5173/reset-password?token=" + account.getResetPasswordToken();
        String mobileResetUrl = "smokingcessation://reset-password?token=" + account.getResetPasswordToken();
        String message = "Kính gửi " + account.getName() + ",\n\n"
                + "Vui lòng nhấp vào một trong các liên kết dưới đây để đặt lại mật khẩu của bạn:\n\n"
                + "Dành cho trình duyệt web:\n"
                + resetUrl + "\n\n"
                + "Dành cho ứng dụng di động:\n"
                + mobileResetUrl + "\n\n"
                + "Liên kết này sẽ hết hạn sau 24 giờ. Vui lòng đặt lại mật khẩu sớm.\n\n"
                + "Cảm ơn bạn!";
        emailService.sendSimpleMessage(account.getEmail(), subject, message);
    }

    public boolean resetPassword(String token, String newPassword) {
        Account account = accountRepository.findByResetPasswordToken(token);
        if (account == null || account.getResetPasswordTokenExpiry() == null 
                || account.getResetPasswordTokenExpiry().isBefore(LocalDateTime.now())) {
            return false; 
        }

        account.setPassword(passwordEncoder.encode(newPassword));
        account.setResetPasswordToken(null);
        account.setResetPasswordTokenExpiry(null);
        accountRepository.save(account);
        return true;
    }
}