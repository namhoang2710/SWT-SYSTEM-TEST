package com.fu.swp391.group1.smokingcessation.controller;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.ChatBoxRequestDTO;
import com.fu.swp391.group1.smokingcessation.entity.ChatBox;
import com.fu.swp391.group1.smokingcessation.service.ChatBoxService;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chatbox")
public class ChatBoxController {

    @Autowired
    private ChatBoxService chatBoxService;

    @Autowired
    private JwtUtil jwtUtil;

    private String extractToken(HttpServletRequest request) {
        String authorization = request.getHeader("Authorization");
        if (authorization != null && authorization.startsWith("Bearer ")) {
            return authorization.substring(7);
        }
        return null;
    }


    @PostMapping("/create/{memberId}")
    public ResponseEntity<?> createChatBox(@RequestBody ChatBoxRequestDTO boxRequest, HttpServletRequest request) {
        String token = extractToken(request);
        if (token == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Login required");
        }

        Long coachID = jwtUtil.extractId(token);
        String role = jwtUtil.extractRole(token);

        if (!"Coach".equalsIgnoreCase(role)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Chỉ Coach mới được tạo Box chat");
        }

        return chatBoxService.createChatBox(coachID, boxRequest.getMemberID(), boxRequest.getNameChatBox());
    }

    @GetMapping("/coach/me")
    public ResponseEntity<?> getChatBoxesOfCoach(HttpServletRequest request) {
        Long coachId = jwtUtil.extractId(extractToken(request));
        List<ChatBox> boxes = chatBoxService.getChatBoxesByCoachId(coachId);
        return ResponseEntity.ok(boxes);
    }

    @GetMapping("/member/me")
    public ResponseEntity<?> getChatBoxesOfMember(HttpServletRequest request) {
        Long memberId = jwtUtil.extractId(extractToken(request));
        List<ChatBox> boxes = chatBoxService.getChatBoxesByMemberId(memberId);
        return ResponseEntity.ok(boxes);
    }

    @GetMapping("/admin/all")
    public ResponseEntity<?> getAllChatBoxes(HttpServletRequest request) {
        String role = jwtUtil.extractRole(extractToken(request));
        if (!"Admin".equalsIgnoreCase(role)) {
            return ResponseEntity.status(403).body("Chỉ Admin có thể truy cập về tất cả ChatBox.");
        }

        List<ChatBox> chatBoxes = chatBoxService.getAllChatBoxes();
        return ResponseEntity.ok(chatBoxes);
    }

    @DeleteMapping("/delete/{chatBoxId}")
    public ResponseEntity<?> deleteChatBox(@PathVariable Long chatBoxId, HttpServletRequest request) {
        String role = jwtUtil.extractRole(extractToken(request));
        Long accountId = jwtUtil.extractId(extractToken(request));

        if (!"Coach".equalsIgnoreCase(role) && !"Admin".equalsIgnoreCase(role)) {
            return ResponseEntity.status(403).body("Chỉ Coach hoặc Admin mới có quyền xóa ChatBox.");
        }

        boolean deleted;
        if ("Admin".equalsIgnoreCase(role)) {
            deleted = chatBoxService.deleteById(chatBoxId);
        } else {
            deleted = chatBoxService.deleteChatBoxIfOwner(chatBoxId, accountId);
        }

        if (deleted) {
            return ResponseEntity.ok("Xóa ChatBox thành công.");
        } else {
            return ResponseEntity.status(403)
                    .body("Bạn không có quyền xóa ChatBox này.");
        }
    }

}
