package com.fu.swp391.group1.smokingcessation.service;


import com.fu.swp391.group1.smokingcessation.dto.CommentResponseDTO;
import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.Blog;
import com.fu.swp391.group1.smokingcessation.entity.Comment;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.BlogRepository;
import com.fu.swp391.group1.smokingcessation.repository.CommentRepository;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class CommentService {

    @Autowired
    private CommentRepository commentRepository;

    @Autowired
    private AccountRepository accountRepository;

    @Autowired
    private BlogRepository blogRepository;

    @Autowired
    private BlogService blogService;

    @Autowired
    private AccountService accountService;

    public List<Comment> getAllComments() {
        return commentRepository.findAll();
    }



    public List<CommentResponseDTO> getCommentsByBlogId(int blogId) {
        List<Comment> comments = commentRepository.findByBlog_BlogID(blogId);
        return comments.stream()
                .map(c -> new CommentResponseDTO(
                        c.getCommentID(),
                        c.getAccount().getId(),
                        c.getContent(),
                        c.getAccount().getName(),
                        c.getAccount().getImage(),
                        c.getCreatedDate(),
                        c.getCreatedTime()
                ))
                .collect(Collectors.toList());
    }




    public Comment getCommentById(int id) {
        return commentRepository.findById(id).orElse(null);
    }


    public Comment createComment(String content, Long userId, int blogId) {
        Account account = accountRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("Account not found"));
        Blog blog = blogRepository.findById(blogId)
                .orElseThrow(() -> new RuntimeException("Blog not found"));

        Comment comment = new Comment();
        comment.setAccount(account);
        comment.setBlog(blog);
        comment.setContent(content);

        return commentRepository.save(comment);
    }


    public void deleteComment(int id) {
        commentRepository.deleteById(id);
    }

    public Comment updateComment(int id, String newComment) {
        Comment comment = commentRepository.findById(id).orElse(null);
        if (comment != null) {
            comment.setContent(newComment);
            return commentRepository.save(comment);
        }
        return null;
    }

    public long countCommentsToday() {
        return commentRepository.countByCreatedDate(LocalDate.now());
    }

    public long countCommentsByDate(int day, int month, int year) {
        try {
            LocalDate date = LocalDate.of(year, month, day);
            return commentRepository.countByCreatedDate(date);
        } catch (DateTimeException e) {
            throw new IllegalArgumentException("Ngày không hợp lệ: " + e.getMessage());
        }
    }






}
