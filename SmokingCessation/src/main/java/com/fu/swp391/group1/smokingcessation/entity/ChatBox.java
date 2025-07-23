package com.fu.swp391.group1.smokingcessation.entity;


import jakarta.persistence.*;
import java.time.LocalDateTime;


@Entity
@Table(name = "ChatBox")
public class ChatBox {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long chatBoxID;

    private Long coachID;
    private Long memberID;
    private LocalDateTime createdAt;
    private String nameChatBox;
    private String nameCoach;
    private String nameMember;

    public ChatBox() {
    }

    public ChatBox(Long chatBoxID, Long coachID, Long memberID, LocalDateTime createdAt, String nameChatBox, String nameCoach, String nameMember) {
        this.chatBoxID = chatBoxID;
        this.coachID = coachID;
        this.memberID = memberID;
        this.createdAt = createdAt;
        this.nameChatBox = nameChatBox;
        this.nameCoach = nameCoach;
        this.nameMember = nameMember;
    }

    public Long getChatBoxID() {
        return chatBoxID;
    }

    public void setChatBoxID(Long chatBoxID) {
        this.chatBoxID = chatBoxID;
    }

    public Long getCoachID() {
        return coachID;
    }

    public void setCoachID(Long coachID) {
        this.coachID = coachID;
    }

    public Long getMemberID() {
        return memberID;
    }

    public void setMemberID(Long memberID) {
        this.memberID = memberID;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public String getNameChatBox() {
        return nameChatBox;
    }

    public void setNameChatBox(String nameChatBox) {
        this.nameChatBox = nameChatBox;
    }

    public String getNameCoach() {
        return nameCoach;
    }

    public void setNameCoach(String nameCoach) {
        this.nameCoach = nameCoach;
    }

    public String getNameMember() {
        return nameMember;
    }

    public void setNameMember(String nameMember) {
        this.nameMember = nameMember;
    }
}
