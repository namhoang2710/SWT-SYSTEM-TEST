package com.fu.swp391.group1.smokingcessation.entity;

import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "Comment")
public class Comment {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int commentID;

    @ManyToOne()
    @JoinColumn(name = "blogID", nullable = false)
    private Blog blog;

    @ManyToOne()
    @JoinColumn(name = "accountID", nullable = false)
    private Account account;

    private String content;
    private LocalDate createdDate;
    private LocalTime createdTime;


    public Comment() {
    }

    public Comment(Blog blog, Account account, String content, LocalDate createdDate, LocalTime createdTime) {
        this.blog = blog;
        this.account = account;
        this.content = content;
        this.createdDate = createdDate;
        this.createdTime = createdTime;
    }

    @PrePersist
    protected void onCreate() {
        this.createdDate = LocalDate.now();
        this.createdTime = LocalTime.now();
    }

    public int getCommentID() {
        return commentID;
    }

    public void setCommentID(int commentID) {
        this.commentID = commentID;
    }

    public Blog getBlog() {
        return blog;
    }

    public void setBlog(Blog blog) {
        this.blog = blog;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public LocalTime getCreatedTime() {
        return createdTime;
    }

    public void setCreatedTime(LocalTime createdTime) {
        this.createdTime = createdTime;
    }

    public LocalDate getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(LocalDate createdDate) {
        this.createdDate = createdDate;
    }
}
