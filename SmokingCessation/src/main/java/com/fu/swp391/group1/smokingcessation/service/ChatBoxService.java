package com.fu.swp391.group1.smokingcessation.service;

import com.fu.swp391.group1.smokingcessation.entity.Account;
import com.fu.swp391.group1.smokingcessation.entity.ChatBox;
import com.fu.swp391.group1.smokingcessation.repository.AccountRepository;
import com.fu.swp391.group1.smokingcessation.repository.ChatBoxRepository;
import com.fu.swp391.group1.smokingcessation.repository.ChatRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ChatBoxService {

    @Autowired
    private ChatBoxRepository chatBoxRepository;

    @Autowired
    private ChatRepository chatRepository;

    @Autowired
    private AccountRepository AccountRepository;
    
    public ResponseEntity<?> createChatBox(Long coachID, Long memberID, String nameChatBox) {
        Optional<ChatBox> existingBox = chatBoxRepository.findByCoachIDAndMemberID(coachID, memberID);
        if (existingBox.isPresent()) {
            return ResponseEntity.badRequest().body("Box chat đã tồn tại");
        }
        Account coach = AccountRepository.findById(coachID)
                .orElseThrow(() -> new IllegalArgumentException("Coach not found"));
        Account member = AccountRepository.findById(memberID)
                .orElseThrow(() -> new IllegalArgumentException("Member not found"));

        ChatBox box = new ChatBox();
        box.setCoachID(coachID);
        box.setMemberID(memberID);
        box.setCreatedAt(LocalDateTime.now());
        box.setNameChatBox(nameChatBox);
        box.setNameCoach(coach.getName());
        box.setNameMember(member.getName());

        ChatBox saved = chatBoxRepository.save(box);
        return ResponseEntity.ok(saved);
    }


    public List<ChatBox> getChatBoxesByCoachId(Long coachId) {
        return chatBoxRepository.findByCoachID(coachId);
    }

    public List<ChatBox> getChatBoxesByMemberId(Long memberId) {
        return chatBoxRepository.findByMemberID(memberId);
    }

    public List<ChatBox> getAllChatBoxes() {
        return chatBoxRepository.findAll();
    }

    @Transactional
    public boolean deleteChatBoxIfOwner(Long chatBoxId, Long coachAccountId) {
        return chatBoxRepository.findById(chatBoxId).filter(box -> box.getCoachID().equals(coachAccountId)).map(box -> {
            chatRepository.deleteByChatBoxId(chatBoxId);
            chatBoxRepository.delete(box);
            return true;
        }).orElse(false);
    }

    @Transactional
    public boolean deleteById(Long chatBoxId) {
        if (!chatBoxRepository.existsById(chatBoxId)) {
            return false;
        }
        chatRepository.deleteByChatBoxId(chatBoxId);
        chatBoxRepository.deleteById(chatBoxId);
        return true;
    }

}
