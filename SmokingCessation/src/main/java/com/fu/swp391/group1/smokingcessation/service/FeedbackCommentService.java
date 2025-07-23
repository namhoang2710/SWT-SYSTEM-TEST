package com.fu.swp391.group1.smokingcessation.service;


import com.fu.swp391.group1.smokingcessation.entity.Comment;
import com.fu.swp391.group1.smokingcessation.entity.FeedbackComment;
import com.fu.swp391.group1.smokingcessation.repository.CommentRepository;
import com.fu.swp391.group1.smokingcessation.repository.FeedbackCommentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.DateTimeException;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
public class FeedbackCommentService {

    @Autowired
    private FeedbackCommentRepository feedbackCommentRepository;

    @Autowired
    private CommentRepository commentRepository;

    public List<FeedbackComment> getAllFeedbacksComment() {
        return feedbackCommentRepository.findAll();
    }

    public FeedbackComment craeteFeedbackComment(String information, int commentId ) {
        Comment comment = commentRepository.findById(commentId).orElse(null);
        if (comment == null) return null;

        FeedbackComment feedbackComment = new FeedbackComment();
        feedbackComment.setComment(comment);
        feedbackComment.setInformation(information);
        return feedbackCommentRepository.save(feedbackComment);
    }


    public boolean deleteFeedbackComment(int feedbackId) {
        Optional<FeedbackComment> optionalFeedbackComment = feedbackCommentRepository.findById(feedbackId);
        if (optionalFeedbackComment.isPresent()) {
            feedbackCommentRepository.deleteById(feedbackId);
            return true;
        }
        return false;
    }

    public long countToday() {
        return feedbackCommentRepository.countByDate(LocalDate.now());
    }

    public long countByDate(int day, int month, int year) {
        try {
            LocalDate date = LocalDate.of(year, month, day);
            return feedbackCommentRepository.countByDate(date);
        } catch (DateTimeException e) {
            throw new IllegalArgumentException("Ngày không hợp lệ: " + e.getMessage());
        }
    }









}
