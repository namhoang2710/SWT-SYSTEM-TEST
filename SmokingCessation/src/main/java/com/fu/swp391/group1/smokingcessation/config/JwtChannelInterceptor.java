package com.fu.swp391.group1.smokingcessation.config;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.simp.stomp.StompCommand;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.messaging.support.ChannelInterceptor;
import org.springframework.messaging.support.MessageHeaderAccessor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class JwtChannelInterceptor implements ChannelInterceptor {

    @Autowired
    private JwtUtil jwtUtil;

    @Override
    public Message<?> preSend(Message<?> message, MessageChannel channel) {
        StompHeaderAccessor acc =
                MessageHeaderAccessor.getAccessor(message, StompHeaderAccessor.class);

        if (acc != null && StompCommand.CONNECT.equals(acc.getCommand())) {
            List<String> auth = acc.getNativeHeader("Authorization");
            if (auth != null && !auth.isEmpty()) {
                String token = auth.get(0).replace("Bearer ", "");
                if (jwtUtil.validateToken(token, jwtUtil.extractUsername(token))) {
                    Long userId = jwtUtil.extractId(token);
                    String role   = jwtUtil.extractRole(token);
                    acc.setUser(new StompPrincipal(userId, role));
                }
            }
        }
        return message;
    }


}
