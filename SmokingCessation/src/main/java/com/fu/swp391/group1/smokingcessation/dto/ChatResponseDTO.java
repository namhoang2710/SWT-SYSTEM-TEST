package com.fu.swp391.group1.smokingcessation.dto;

import java.time.LocalDate;
import java.time.LocalTime;

public class ChatResponseDTO {

    private String message;
    private LocalDate sentDate;
    private LocalTime sentTime;

    public ChatResponseDTO() {
    }

    public ChatResponseDTO(String message, LocalDate sentDate, LocalTime sentTime) {
        this.message = message;
        this.sentDate = sentDate;
        this.sentTime = sentTime;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public LocalDate getSentDate() {
        return sentDate;
    }

    public void setSentDate(LocalDate sentDate) {
        this.sentDate = sentDate;
    }

    public LocalTime getSentTime() {
        return sentTime;
    }

    public void setSentTime(LocalTime sentTime) {
        this.sentTime = sentTime;
    }
}
