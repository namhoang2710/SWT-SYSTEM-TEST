package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.Chat;

import com.fu.swp391.group1.smokingcessation.entity.ChatBox;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;


public interface ChatRepository extends JpaRepository<Chat, Long> {
    List<Chat> findByChatBoxOrderByChatIDAsc(ChatBox chatBox);
    Optional<Chat> findById(Long id);

    @Modifying
    @Transactional
    @Query("DELETE FROM Chat c WHERE c.chatBox.chatBoxID = :chatBoxId")
    int deleteByChatBoxId(@Param("chatBoxId") Long chatBoxId);

}
