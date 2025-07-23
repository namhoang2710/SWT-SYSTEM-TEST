package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.Blog;
import com.fu.swp391.group1.smokingcessation.entity.Comment;
import com.mysql.cj.jdbc.Blob;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Integer> {
    List<Comment> findAll();
    void deleteByBlog(Blog blog);
    List<Comment> findByBlog_BlogID(int blogId);
    long countByCreatedDate(LocalDate createdDate);
}
