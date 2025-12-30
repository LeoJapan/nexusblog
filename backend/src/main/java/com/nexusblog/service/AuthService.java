package com.nexusblog.service;

import com.nexusblog.dto.*;
import com.nexusblog.entity.User;
import com.nexusblog.exception.ResourceNotFoundException;
import com.nexusblog.repository.UserRepository;
import com.nexusblog.utils.JwtUtil;
import com.nexusblog.utils.PasswordEncoderUtil;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Authentication Service - 认证服务类
 * Handles user registration, login, and authentication.
 */
@Service
public class AuthService {
    
    private final UserRepository userRepository;
    private final PasswordEncoderUtil passwordEncoderUtil;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    
    public AuthService(UserRepository userRepository,
                       PasswordEncoderUtil passwordEncoderUtil,
                       JwtUtil jwtUtil,
                       AuthenticationManager authenticationManager) {
        this.userRepository = userRepository;
        this.passwordEncoderUtil = passwordEncoderUtil;
        this.jwtUtil = jwtUtil;
        this.authenticationManager = authenticationManager;
    }
    
    /**
     * Register new user
     */
    @Transactional
    public ApiResponse<AuthResponse> register(RegisterRequest request) {
        // Check if username exists
        if (userRepository.existsByUsername(request.getUsername())) {
            return ApiResponse.error("用户名已存在");
        }
        
        // Check if email exists
        if (userRepository.existsByEmail(request.getEmail())) {
            return ApiResponse.error("邮箱已被注册");
        }
        
        // Create new user
        User user = new User();
        user.setUsername(request.getUsername());
        user.setEmail(request.getEmail());
        user.setPassword(passwordEncoderUtil.encode(request.getPassword()));
        user.setRole(User.Role.USER);
        user.setStatus(1);
        
        user = userRepository.save(user);
        
        // Generate token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole().name());
        
        AuthResponse authResponse = AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .expiresIn(jwtUtil.getExpirationTime())
                .user(mapToUserResponse(user))
                .build();
        
        return ApiResponse.success("注册成功", authResponse);
    }
    
    /**
     * Authenticate user login
     */
    public ApiResponse<AuthResponse> login(LoginRequest request) {
        // Authenticate with Spring Security
        Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword())
        );
        
        // Get user from authentication
        User user = (User) authentication.getPrincipal();
        
        // Check if user is active
        if (user.getStatus() != 1) {
            return ApiResponse.error("用户已被禁用");
        }
        
        // Generate token
        String token = jwtUtil.generateToken(user.getId(), user.getUsername(), user.getRole().name());
        
        AuthResponse authResponse = AuthResponse.builder()
                .token(token)
                .tokenType("Bearer")
                .expiresIn(jwtUtil.getExpirationTime())
                .user(mapToUserResponse(user))
                .build();
        
        return ApiResponse.success("登录成功", authResponse);
    }
    
    /**
     * Get current user information
     */
    public ApiResponse<UserResponse> getCurrentUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        
        return ApiResponse.success(mapToUserResponse(user));
    }
    
    /**
     * Map User entity to UserResponse DTO
     */
    private UserResponse mapToUserResponse(User user) {
        return UserResponse.builder()
                .id(user.getId())
                .username(user.getUsername())
                .email(user.getEmail())
                .avatar(user.getAvatar())
                .role(user.getRole().name())
                .status(user.getStatus())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
