package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.FeedbackBlog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface FeedbackBlogRepository extends JpaRepository<FeedbackBlog, Integer> {
    List<FeedbackBlog> findAll();
    List<FeedbackBlog> findByBlog_BlogID(int blogId);
    long countByCreatedDate(LocalDate createdDate);

}
