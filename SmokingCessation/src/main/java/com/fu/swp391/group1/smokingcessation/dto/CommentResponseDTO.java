package com.fu.swp391.group1.smokingcessation.dto;


import java.time.LocalDate;
import java.time.LocalTime;


public class CommentResponseDTO {

    private int commentId;
    private Long accountId;
    private String content;
    private String commenterName;
    private String commenterImage;
    private LocalDate createdDate;
    private LocalTime createdTime;

    public CommentResponseDTO() {
    }

    public CommentResponseDTO(int commentId, Long accountId, String content, String commenterName, String commenterImage, LocalDate createdDate, LocalTime createdTime) {
        this.commentId = commentId;
        this.accountId = accountId;
        this.content = content;
        this.commenterName = commenterName;
        this.commenterImage = commenterImage;
        this.createdDate = createdDate;
        this.createdTime = createdTime;
    }

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public int getCommentId() {
        return commentId;
    }

    public void setCommentId(int commentId) {
        this.commentId = commentId;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getCommenterName() {
        return commenterName;
    }

    public void setCommenterName(String commenterName) {
        this.commenterName = commenterName;
    }

    public String getCommenterImage() {
        return commenterImage;
    }

    public void setCommenterImage(String commenterImage) {
        this.commenterImage = commenterImage;
    }

    public LocalDate getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDate createdDate) {
        this.createdDate = createdDate;
    }

    public LocalTime getCreatedTime() {
        return createdTime;
    }

    public void setCreatedTime(LocalTime createdTime) {
        this.createdTime = createdTime;
    }
}
