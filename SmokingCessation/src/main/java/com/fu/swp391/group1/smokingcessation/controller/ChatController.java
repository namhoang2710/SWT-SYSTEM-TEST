package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.ChatMessage;
import com.fu.swp391.group1.smokingcessation.dto.ChatRequestDTO;
import com.fu.swp391.group1.smokingcessation.dto.ChatResponseDTO;
import com.fu.swp391.group1.smokingcessation.entity.Chat;
import com.fu.swp391.group1.smokingcessation.service.ChatService;
import jakarta.servlet.http.HttpServletRequest;
import org.apache.catalina.connector.Request;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/chats")
public class ChatController {

    @Autowired
    private ChatService chatService;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }

    @PostMapping("/{chatboxId}")
    public ResponseEntity<Chat> sendMessage(@PathVariable("chatboxId") Long chatBoxID, @RequestBody ChatRequestDTO request, HttpServletRequest httpRequest) {

        String token = extractToken(httpRequest);
        if (token == null || jwtUtil.extractUsername(token) == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        String role = jwtUtil.extractRole(token);
        String finalMessage = (role.equalsIgnoreCase("Coach") ? "Coach: " : "Member: ") + request.getMessage();
        Long accountId = jwtUtil.extractId(token);

        Chat savedChat = chatService.sendMessage(chatBoxID, finalMessage, accountId);
        return ResponseEntity.ok(savedChat);
    }


    @GetMapping("/{chatBoxId}")
    public ResponseEntity<List<ChatResponseDTO>> getMessagesByChatBox(@PathVariable Long chatBoxId) {
        List<ChatResponseDTO> messages = chatService.getAllMessagesByChatBoxId(chatBoxId);
        return ResponseEntity.ok(messages);
    }

    @DeleteMapping("/{chatId}")
    public ResponseEntity<String> deleteChat(@PathVariable Long chatId, HttpServletRequest request) {
        String token = extractToken(request);
        Long accountId = jwtUtil.extractId(token);

        chatService.deleteChat(chatId, accountId);
        return ResponseEntity.ok("Chat deleted successfully");
    }



    @MessageMapping("/chat.sendMessage")
    public void handleChatMessage(@Payload ChatMessage chatMessage, Principal principal) {
        chatService.processMessage(chatMessage, principal);
    }
}
