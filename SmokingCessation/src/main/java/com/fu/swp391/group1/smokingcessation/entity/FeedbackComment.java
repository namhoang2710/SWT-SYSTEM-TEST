package com.fu.swp391.group1.smokingcessation.entity;


import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;

@Entity
@Table(name= "FeedbackComment")
public class FeedbackComment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "CommentFeedbackID")
    private int commentFeedbackID;

    @ManyToOne
    @JoinColumn(name= "commentID", nullable = false)
    private Comment comment;

    private String information;
    private LocalDateTime createdDate;
    private LocalDateTime createdTime;

    @PrePersist
    protected void onCreate() {
        this.createdDate = LocalDateTime.now();
        this.createdTime = LocalDateTime.now();
    }

    public FeedbackComment() {
    }

    public FeedbackComment(int commentFeedbackID, Comment comment, String information, LocalDateTime createdDate, LocalDateTime createdTime) {
        this.commentFeedbackID = commentFeedbackID;
        this.comment = comment;
        this.information = information;
        this.createdDate = createdDate;
        this.createdTime = createdTime;
    }

    public int getCommentFeedbackID() {
        return commentFeedbackID;
    }

    public void setCommentFeedbackID(int commentFeedbackID) {
        this.commentFeedbackID = commentFeedbackID;
    }

    public Comment getComment() {
        return comment;
    }

    public void setComment(Comment comment) {
        this.comment = comment;
    }

    public String getInformation() {
        return information;
    }

    public void setInformation(String information) {
        this.information = information;
    }

    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    public LocalDateTime getCreatedTime() {
        return createdTime;
    }

    public void setCreatedTime(LocalDateTime createdTime) {
        this.createdTime = createdTime;
    }
}
