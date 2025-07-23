package com.fu.swp391.group1.smokingcessation.dto;

public class ChatMessage {
    private Long chatBoxId;
    private String content;

    public ChatMessage() {
    }

    public ChatMessage(Long chatBoxId, String content) {
        this.chatBoxId = chatBoxId;
        this.content = content;
    }

    public Long getChatBoxId() {
        return chatBoxId;
    }

    public void setChatBoxId(Long chatBoxId) {
        this.chatBoxId = chatBoxId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
