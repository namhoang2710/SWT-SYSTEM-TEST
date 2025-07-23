package com.fu.swp391.group1.smokingcessation.config;

import io.jsonwebtoken.*;
import io.jsonwebtoken.SignatureAlgorithm;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Component
public class JwtUtil {
    private final String SECRET_KEY = "6b2uI3Q4r5Tv0X87zPq9YmLSV7CZlKM48RfWZEGxq0g=";


    public String generateToken(String username, String role, Long id,Long coachId) {
        Map<String, Object> claims = new HashMap<>();
        claims.put("role", role);
        claims.put("id", id);
        claims.put("coachId", coachId);


        return Jwts.builder()
                .setClaims(claims)
                .setSubject(username)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 10)) // 10 giờ
                .signWith(SignatureAlgorithm.HS256, SECRET_KEY)
                .compact();
    }

    public String extractUsername(String token) {
        return extractClaims(token).getSubject();
    }

    public String extractRole(String token) {
        return (String) extractClaims(token).get("role");
    }



    public Long extractId(String token) {
        Object idObj = extractClaims(token).get("id");
        if (idObj == null) {
            return null;
        }

        if (idObj instanceof Integer) {
            return ((Integer) idObj).longValue();
        } else if (idObj instanceof Long) {
            return (Long) idObj;
        } else if (idObj instanceof Number) {
            return ((Number) idObj).longValue();
        } else {
            throw new IllegalArgumentException("Invalid token id format");
        }
    }
    public Long extractCoachId(String token) {
        Object coachIdObj = extractClaims(token).get("coachId");

        // Kiểm tra nếu coachId không tồn tại hoặc là null
        if (coachIdObj == null) {
            return null;  // Trả về null thay vì throw exception
        }

        if (coachIdObj instanceof Long) {
            return (Long) coachIdObj;
        } else if (coachIdObj instanceof Integer) {
            return ((Integer) coachIdObj).longValue();
        } else if (coachIdObj instanceof Number) {
            return ((Number) coachIdObj).longValue();
        } else {
            throw new IllegalArgumentException("Invalid token coachId format");
        }
    }


    public boolean validateToken(String token, String username) {
        return (extractUsername(token).equals(username) && !isTokenExpired(token));
    }

    private Claims extractClaims(String token) {
        return Jwts.parser().setSigningKey(SECRET_KEY).parseClaimsJws(token).getBody();
    }

    private boolean isTokenExpired(String token) {
        return extractClaims(token).getExpiration().before(new Date());
    }
}
