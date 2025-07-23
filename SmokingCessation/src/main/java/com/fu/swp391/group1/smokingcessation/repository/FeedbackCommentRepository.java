package com.fu.swp391.group1.smokingcessation.repository;


import com.fu.swp391.group1.smokingcessation.entity.FeedbackComment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;


import java.time.LocalDate;
import java.util.List;

public interface FeedbackCommentRepository extends JpaRepository<FeedbackComment, Integer> {
    List<FeedbackComment> findAll();
    @Query("SELECT COUNT(f) FROM FeedbackComment f WHERE DATE(f.createdDate) = :date")
    long countByDate(@Param("date") LocalDate date);

}
