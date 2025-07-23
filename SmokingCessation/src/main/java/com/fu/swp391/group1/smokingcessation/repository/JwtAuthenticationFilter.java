package com.fu.swp391.group1.smokingcessation.repository;

import com.fu.swp391.group1.smokingcessation.config.JwtUtil;
import com.fu.swp391.group1.smokingcessation.dto.UserPrincipal;
import com.fu.swp391.group1.smokingcessation.service.TokenBlacklistService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    private final TokenBlacklistService tokenBlacklistService;

    public JwtAuthenticationFilter(JwtUtil jwtUtil,TokenBlacklistService tokenBlacklistService) {
        this.jwtUtil = jwtUtil;
        this.tokenBlacklistService = tokenBlacklistService;
    }
    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) throws ServletException {
        String path = request.getServletPath();

        // Danh sách các endpoint không cần authentication
        boolean shouldSkip = path.equals("/api/account/login") ||
                path.equals("/api/account/register") ||
                path.equals("/api/account/verify") ||
                path.equals("/api/admin/packages/all") ||
                path.equals("/api/comments/all") ||
                path.equals("/api/comments/{blogId}") ||
                path.equals("/api/comments/blog/") ||
                path.matches("/api/comments/\\d+") ||
                path.startsWith("/swagger-ui") ||
                path.startsWith("/v3/api-docs") ||
                path.equals("/api/account/forgot-password")||
                path.equals("/api/account/reset-password")||
                path.equals("/api/account/verify-code")||
                path.equals("/swagger-ui.html") ||
                path.equals("/api/blogs/all");

        return shouldSkip;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String path = request.getServletPath();
        String authHeader = request.getHeader("Authorization");

        // Nếu không có header Authorization, cho qua luôn (sẽ bị chặn ở SecurityConfig nếu cần auth)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Lấy token từ header
        String token = authHeader.substring(7);
        if (tokenBlacklistService.isTokenBlacklisted(token)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Token has been invalidated\"}");
            return;
        }
        String username = null;

        try {
            username = jwtUtil.extractUsername(token);
        } catch (Exception e) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.getWriter().write("{\"error\": \"Invalid token\"}");
            return;
        }

        // Validate và set authentication nếu chưa có
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            if (jwtUtil.validateToken(token, username)) {
                try {
                    String role = jwtUtil.extractRole(token);
                    Long userId = jwtUtil.extractId(token);
                    Long coachId = null;

                    // Try to extract coachId, but it's optional
                    try {
                        coachId = jwtUtil.extractCoachId(token);
                    } catch (Exception e) {
                        // Ignore - not all users have coachId
                    }

                    // Create UserPrincipal

                    UserPrincipal principal = new UserPrincipal(username, userId, coachId, role);


                    // Create authentication token
                    UsernamePasswordAuthenticationToken authToken =
                            new UsernamePasswordAuthenticationToken(
                                    principal,
                                    null,
                                    Collections.singletonList(new SimpleGrantedAuthority(role))
                            );

                    // Set authentication in context
                    SecurityContextHolder.getContext().setAuthentication(authToken);

                } catch (Exception e) {
                    response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                    response.setContentType("application/json");
                    response.getWriter().write("{\"error\": \"Token processing failed\"}");
                    return;
                }
            } else {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                response.getWriter().write("{\"error\": \"Token validation failed\"}");
                return;
            }
        }

        // Continue with the filter chain
        filterChain.doFilter(request, response);
    }
}