package com.fu.swp391.group1.smokingcessation.entity;


import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "Chat")
public class Chat {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long chatID;

    private String message;
    private LocalDate sentDate;
    private LocalTime sentTime;

    @Column(name = "CreatedbyID")
    private Long createdbyID;


    @ManyToOne(fetch =  FetchType.LAZY)
    @JoinColumn(name = "chatBoxID", nullable = false)
    private ChatBox chatBox;

    public Chat() {
    }

    public Chat(Long chatID, String message, LocalDate sentDate, LocalTime sentTime, Long createdbyID, ChatBox chatBox) {
        this.chatID = chatID;
        this.message = message;
        this.sentDate = sentDate;
        this.sentTime = sentTime;
        this.createdbyID = createdbyID;
        this.chatBox = chatBox;
    }

    public Long getChatID() {
        return chatID;
    }

    public void setChatID(Long chatID) {
        this.chatID = chatID;
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

    public Long getCreatedbyID() {
        return createdbyID;
    }

    public void setCreatedbyID(Long createdbyID) {
        this.createdbyID = createdbyID;
    }

    public ChatBox getChatBox() {
        return chatBox;
    }

    public void setChatBox(ChatBox chatBox) {
        this.chatBox = chatBox;
    }
}
