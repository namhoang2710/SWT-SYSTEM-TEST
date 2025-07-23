package com.fu.swp391.group1.smokingcessation.dto;

import org.springframework.web.multipart.MultipartFile;



public class BlogCreationRequest {

    private String title;
    private String content;
    private Long accountID;
    private MultipartFile image;


    public BlogCreationRequest() {
    }

    public BlogCreationRequest(String title, String content, Long accountID, MultipartFile image  ) {
        this.title = title;
        this.content = content;
        this.accountID = accountID;
        this.image = image;

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

    public Long getAccountID() {
        return accountID;
    }

    public void setAccountID(Long accountID) {
        this.accountID = accountID;
    }


    public MultipartFile getImage() {
        return image;
    }

    public void setImage(MultipartFile image) {
        this.image = image;
    }
}