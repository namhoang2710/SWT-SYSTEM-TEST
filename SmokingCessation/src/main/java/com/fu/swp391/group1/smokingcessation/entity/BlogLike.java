package com.fu.swp391.group1.smokingcessation.entity;


import jakarta.persistence.*;

@Entity
@Table(name = "Bloglike", uniqueConstraints = {@UniqueConstraint(columnNames = {"AccountID", "BlogID"})})
public class BlogLike {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "AccountID", nullable = false)
    private Account account;

    @ManyToOne
    @JoinColumn(name = "BlogID", nullable = false)
    private Blog blog;

    public BlogLike() {
    }

    public BlogLike(Account account, Blog blog) {
        this.account = account;
        this.blog = blog;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public Blog getBlog() {
        return blog;
    }

    public void setBlog(Blog blog) {
        this.blog = blog;
    }
}
