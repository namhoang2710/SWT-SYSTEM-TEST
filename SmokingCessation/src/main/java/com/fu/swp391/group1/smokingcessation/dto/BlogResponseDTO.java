package com.fu.swp391.group1.smokingcessation.dto;

import com.fu.swp391.group1.smokingcessation.entity.Account;


import java.time.LocalDate;
import java.time.LocalTime;

public class BlogResponseDTO {

    private int blogID;
    private String title;
    private String content;
    private LocalDate createdDate;
    private LocalTime createdTime;
    private String image;
    private int likes;
    private boolean liked;

    private Account account;


    public BlogResponseDTO() {
    }

    public BlogResponseDTO(int blogID, String title, String content, LocalDate createdDate, LocalTime createdTime, String image, int likes, boolean liked, Account account) {
        this.blogID = blogID;
        this.title = title;
        this.content = content;
        this.createdDate = createdDate;
        this.createdTime = createdTime;
        this.image = image;
        this.likes = likes;
        this.liked = liked;
        this.account = account;
    }

    public int getBlogID() {
        return blogID;
    }

    public void setBlogID(int blogID) {
        this.blogID = blogID;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
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

    public String getImage() {
        return image;
    }

    public void setImage(String image) {
        this.image = image;
    }

    public int getLikes() {
        return likes;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    public boolean isLiked() {
        return liked;
    }

    public void setLiked(boolean liked) {
        this.liked = liked;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }
}
