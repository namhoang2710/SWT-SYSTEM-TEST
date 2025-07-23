package com.fu.swp391.group1.smokingcessation.dto;

public class ChatBoxRequestDTO {
    private Long memberID;
    private String nameChatBox;

    public ChatBoxRequestDTO() {
    }

    public ChatBoxRequestDTO(Long memberID, String nameChatBox) {
        this.memberID = memberID;
        this.nameChatBox = nameChatBox;
    }

    public Long getMemberID() {
        return memberID;
    }

    public void setMemberID(Long memberID) {
        this.memberID = memberID;
    }

    public String getNameChatBox() {
        return nameChatBox;
    }
    public void setNameChatBox(String nameChatBox) {
        this.nameChatBox = nameChatBox;
    }
}
