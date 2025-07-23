package com.fu.swp391.group1.smokingcessation.service;



import com.fu.swp391.group1.smokingcessation.config.StompPrincipal;
import com.fu.swp391.group1.smokingcessation.dto.ChatMessage;
import com.fu.swp391.group1.smokingcessation.dto.ChatResponse;
import com.fu.swp391.group1.smokingcessation.dto.ChatResponseDTO;
import com.fu.swp391.group1.smokingcessation.entity.Chat;
import com.fu.swp391.group1.smokingcessation.entity.ChatBox;
import com.fu.swp391.group1.smokingcessation.repository.ChatBoxRepository;
import com.fu.swp391.group1.smokingcessation.repository.ChatRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;


@Service
public class ChatService {

    @Autowired
    private ChatRepository chatRepository;

    @Autowired
    private ChatBoxRepository chatBoxRepository;

    public Chat sendMessage(Long chatBoxID, String message, Long accountIdFromToken) {
        Optional<ChatBox> chatBoxOpt = chatBoxRepository.findById(chatBoxID);
        if (chatBoxOpt.isEmpty()) {
            throw new RuntimeException("ChatBox not found with ID: " + chatBoxID);
        }

        ChatBox chatBox = chatBoxOpt.get();

        Chat chat = new Chat();
        chat.setChatBox(chatBox);
        chat.setMessage(message);
        chat.setSentDate(LocalDate.now());
        chat.setSentTime(LocalTime.now());
        chat.setCreatedbyID(accountIdFromToken);



        return chatRepository.save(chat);
    }


    public List<ChatResponseDTO> getAllMessagesByChatBoxId(Long chatBoxId) {
        ChatBox chatBox = chatBoxRepository.findById(chatBoxId)
                .orElseThrow(() -> new RuntimeException("ChatBox not found"));

        List<Chat> chats = chatRepository.findByChatBoxOrderByChatIDAsc(chatBox);
        return chats.stream()
                .map(chat -> new ChatResponseDTO(chat.getMessage(), chat.getSentDate(), chat.getSentTime()))
                .collect(Collectors.toList());
    }

    public void deleteChat(Long chatId, Long requesterId) {
        Chat chat = chatRepository.findById(chatId)
                .orElseThrow(() -> new RuntimeException("Chat not found"));

        if (!chat.getCreatedbyID().equals(requesterId)) {
            throw new RuntimeException("You are not authorized to delete this message");
        }

        chatRepository.delete(chat);
    }

//-----------------------------------------------------------------------------------------------------------------------------


    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    public void processMessage(ChatMessage chatMessage, Principal principal) {
        StompPrincipal user = (StompPrincipal) principal;
        Long userId = Long.valueOf(user.getName());
        String role = user.getRole();

        ChatBox box = chatBoxRepository.findById(chatMessage.getChatBoxId())
                .orElseThrow(() -> new RuntimeException("ChatBox not found: " + chatMessage.getChatBoxId()));

        String prefix = role.equalsIgnoreCase("Coach") ? "Coach: " : "Member: ";

        Chat chat = new Chat();
        chat.setChatBox(box);
        chat.setMessage(prefix + chatMessage.getContent());
        chat.setSentDate(LocalDate.now());
        chat.setSentTime(LocalTime.now());
        chat.setCreatedbyID(userId);
        Chat saved = chatRepository.save(chat);

        ChatResponse resp = new ChatResponse(
                saved.getMessage(), saved.getSentDate(), saved.getSentTime()
        );
        messagingTemplate.convertAndSend("/topic/chat." + box.getChatBoxID(), resp);
    }



}
