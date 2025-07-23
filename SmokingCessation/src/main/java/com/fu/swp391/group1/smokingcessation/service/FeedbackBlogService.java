package com.fu.swp391.group1.smokingcessation.service;



import com.fu.swp391.group1.smokingcessation.entity.Blog;
import com.fu.swp391.group1.smokingcessation.entity.FeedbackBlog;
import com.fu.swp391.group1.smokingcessation.repository.BlogRepository;
import com.fu.swp391.group1.smokingcessation.repository.FeedbackBlogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;


@Service
public class FeedbackBlogService {

    @Autowired
    private FeedbackBlogRepository feedbackBlogRepository;

    @Autowired
    private BlogRepository blogRepository;


    public List<FeedbackBlog> getAllFeedbacks() {
        return feedbackBlogRepository.findAll();
    }

    public FeedbackBlog createFeedback(String information, int blogId) {
        Blog blog = blogRepository.findById(blogId).orElse(null);
        if (blog == null) return null;

        FeedbackBlog feedback = new FeedbackBlog();
        feedback.setBlog(blog);
        feedback.setInformation(information);
        return feedbackBlogRepository.save(feedback);
    }


    public boolean deleteFeedback(int feedbackId) {
        Optional<FeedbackBlog> optionalFeedback = feedbackBlogRepository.findById(feedbackId);
        if (optionalFeedback.isPresent()) {
            feedbackBlogRepository.deleteById(feedbackId);
            return true;
        }
        return false;
    }


    public long countFeedbacksToday() {
        return feedbackBlogRepository.countByCreatedDate(LocalDate.now());
    }

    public long countFeedbacksByDate(int day, int month, int year) {
        try {
            LocalDate date = LocalDate.of(year, month, day);
            return feedbackBlogRepository.countByCreatedDate(date);
        } catch (DateTimeException e) {
            throw new IllegalArgumentException("Ngày không hợp lệ: " + e.getMessage());
        }
    }



}
