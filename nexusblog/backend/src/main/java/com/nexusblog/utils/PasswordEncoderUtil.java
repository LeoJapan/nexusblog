package com.nexusblog.utils;

import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

/**
 * Password Encoder Utility - 密码编码工具类
 * Handles password encryption using BCrypt.
 */
@Component
public class PasswordEncoderUtil {
    
    private final PasswordEncoder passwordEncoder;
    
    public PasswordEncoderUtil() {
        this.passwordEncoder = new BCryptPasswordEncoder();
    }
    
    /**
     * Encode password using BCrypt
     */
    public String encode(String rawPassword) {
        return passwordEncoder.encode(rawPassword);
    }
    
    /**
     * Verify password matches encoded password
     */
    public boolean matches(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
}
