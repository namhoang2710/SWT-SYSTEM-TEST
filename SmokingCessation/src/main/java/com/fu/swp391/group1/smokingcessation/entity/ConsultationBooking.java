package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "consultation_booking")
public class ConsultationBooking {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private Account user;  // Liên kết với Account (tài khoản người dùng)

    @ManyToOne
    @JoinColumn(name = "slot_id", nullable = false)
    private ConsultationSlot slot;  // Liên kết với ConsultationSlot (ca tư vấn)

    @Column(name = "booking_time", nullable = false)  // Thêm name = "booking_time"
    private LocalDateTime bookingTime;  // Thời gian người dùng đặt lịch

    @Column(name = "google_meet_link", nullable = false)  // Thêm name = "google_meet_link"
    private String googleMeetLink;  // Link Google Meet cho cuộc họp
}
