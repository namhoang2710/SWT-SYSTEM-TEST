package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.entity.ChatBox;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ChatBoxRepository extends JpaRepository<ChatBox, Long> {
    List<ChatBox> findByCoachID(Long coachID);
    List<ChatBox> findByMemberID(Long memberID);
    Optional<ChatBox> findByCoachIDAndMemberID(Long coachID, Long memberID);

}
