package com.fu.swp391.group1.smokingcessation.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.ConsultationSlot;
import java.time.format.DateTimeFormatter;
import org.springframework.stereotype.Service;

@Service
public class EmailService {
    @Autowired
    private JavaMailSender mailSender;
    public void sendSimpleMessage(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("namthse173516@fpt.edu.vn");
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);
        mailSender.send(message);
    }
    public void sendEmail(String to, String subject, String message) {
        SimpleMailMessage email = new SimpleMailMessage();
        email.setTo(to);
        email.setSubject(subject);
        email.setText(message);
        mailSender.send(email);
    }

    @Async
    public void sendBookingEmails(Account user, Account coach, String meetingLink, ConsultationSlot slot) {
        String timeStr = slot.getStartTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
        // Email cho user
        sendEmail(user.getEmail(), "Xác nhận lịch tư vấn",
                String.format("Chào %s,\n\nLịch tư vấn:\n⏰ %s\n👨‍⚕️ Coach: %s\n🎥 Link: %s\n\nTrân trọng,\nHệ thống cai thuốc lá",
                        user.getName(), timeStr, coach.getName(), meetingLink));
        // Email cho coach
        sendEmail(coach.getEmail(), "Lịch tư vấn mới",
                String.format("Chào Coach %s,\n\nLịch mới:\n⏰ %s\n👤 Khách: %s\n📧 Email: %s\n🎥 Link: %s\n\nTrân trọng,\nHệ thống",
                        coach.getName(), timeStr, user.getName(), user.getEmail(), meetingLink));
    }
}
