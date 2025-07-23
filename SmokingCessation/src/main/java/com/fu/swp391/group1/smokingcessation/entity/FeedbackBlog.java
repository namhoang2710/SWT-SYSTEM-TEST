package com.fu.swp391.group1.smokingcessation.entity;


import jakarta.persistence.*;

import java.time.LocalDate;
import java.time.LocalTime;

@Entity
@Table(name = "FeedbackBlog")
public class FeedbackBlog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "BlogFeedbackID")
    private int feedbackBlogID;

    @ManyToOne()
    @JoinColumn(name = "blogID", nullable = false)
    private Blog blog;

    private String information;
    private LocalDate createdDate;
    private LocalTime createdTime;

    @PrePersist
    protected void onCreate() {
        this.createdDate = LocalDate.now();
        this.createdTime = LocalTime.now();
    }

    public FeedbackBlog() {}

    public FeedbackBlog(Blog blog, String information, LocalDate createdDate, LocalTime createdTime) {
        this.blog = blog;
        this.information = information;
        this.createdDate = createdDate;
        this.createdTime = createdTime;
    }

    public int getFeedbackBlogID() {
        return feedbackBlogID;
    }

    public void setFeedbackBlogID(int feedbackBlogID) {
        this.feedbackBlogID = feedbackBlogID;
    }

    public Blog getBlog() {
        return blog;
    }

    public void setBlog(Blog blog) {
        this.blog = blog;
    }

    public String getInformation() {
        return information;
    }

    public void setInformation(String information) {
        this.information = information;
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
