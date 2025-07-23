package com.fu.swp391.group1.smokingcessation.dto;

import lombok.Data;

import java.time.LocalDate;
import java.time.LocalTime;


@Data
public class ChatRequestDTO {

    private String message;
//    private LocalDate sentDate;
//    private LocalTime sentTime;
//    private Long chatBoxID;

    public ChatRequestDTO() {
    }

    public ChatRequestDTO(String message/*, LocalDate sentDate, LocalTime sentTime, Long chatBoxID*/) {
        this.message = message;
//        this.sentDate = sentDate;
//        this.sentTime = sentTime;
//        this.chatBoxID = chatBoxID;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

//    public LocalDate getSentDate() {
//        return sentDate;
//    }
//
//    public void setSentDate(LocalDate sentDate) {
//        this.sentDate = sentDate;
//    }
//
//    public LocalTime getSentTime() {
//        return sentTime;
//    }
//
//    public void setSentTime(LocalTime sentTime) {
//        this.sentTime = sentTime;
//    }
//
//    public Long getChatBoxID() {
//        return chatBoxID;
//    }
//
//    public void setChatBoxID(Long chatBoxID) {
//        this.chatBoxID = chatBoxID;
//    }
}
