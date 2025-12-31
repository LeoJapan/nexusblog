package com.nexusblog.service;

import com.nexusblog.dto.*;
import com.nexusblog.entity.User;
import com.nexusblog.exception.ResourceNotFoundException;
import com.nexusblog.repository.ArticleRepository;
import com.nexusblog.repository.CommentRepository;
import com.nexusblog.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * User Service - 用户服务类
 * Handles user management operations.
 */
@Service
public class UserService {
    
    private final UserRepository userRepository;
    private final ArticleRepository articleRepository;
    private final CommentRepository commentRepository;
    
    public UserService(UserRepository userRepository,
                      ArticleRepository articleRepository,
                      CommentRepository commentRepository) {
        this.userRepository = userRepository;
        this.articleRepository = articleRepository;
        this.commentRepository = commentRepository;
    }
    
    /**
     * Get user by ID
     */
    public ApiResponse<UserResponse> getUserById(Long id) {
        User user = userRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", id));
        
        return ApiResponse.success(mapToUserResponse(user));
    }
    
    /**
     * Update user profile
     */
    @Transactional
    public ApiResponse<UserResponse> updateProfile(Long userId, User userDetails) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        
        // Update fields
        if (userDetails.getUsername() != null && !userDetails.getUsername().isEmpty()) {
            // Check if username is taken
            if (!userDetails.getUsername().equals(user.getUsername()) && 
                    userRepository.existsByUsername(userDetails.getUsername())) {
                return ApiResponse.error("用户名已被使用");
            }
            user.setUsername(userDetails.getUsername());
        }
        
        if (userDetails.getEmail() != null && !userDetails.getEmail().isEmpty()) {
            // Check if email is taken
            if (!userDetails.getEmail().equals(user.getEmail()) && 
                    userRepository.existsByEmail(userDetails.getEmail())) {
                return ApiResponse.error("邮箱已被使用");
            }
            user.setEmail(userDetails.getEmail());
        }
        
        if (userDetails.getAvatar() != null) {
            user.setAvatar(userDetails.getAvatar());
        }
        
        user = userRepository.save(user);
        
        return ApiResponse.success("资料更新成功", mapToUserResponse(user));
    }
    
    /**
     * Get all users (for admin)
     */
    public ApiResponse<PageResponse<UserResponse>> getAllUsers(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<User> users = userRepository.findAll(pageable);
        
        List<UserResponse> content = users.getContent().stream()
                .map(this::mapToUserResponse)
                .collect(Collectors.toList());
        
        PageResponse<UserResponse> pageResponse = PageResponse.<UserResponse>builder()
                .content(content)
                .page(users.getNumber())
                .size(users.getSize())
                .totalElements(users.getTotalElements())
                .totalPages(users.getTotalPages())
                .first(users.isFirst())
                .last(users.isLast())
                .build();
        
        return ApiResponse.success(pageResponse);
    }
    
    /**
     * Ban/Unban user (for admin)
     */
    @Transactional
    public ApiResponse<Void> updateUserStatus(Long userId, Integer status) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        
        if (status != 0 && status != 1) {
            return ApiResponse.error("无效的状态值");
        }
        
        user.setStatus(status);
        userRepository.save(user);
        
        String message = status == 0 ? "用户已封禁" : "用户已解封";
        return ApiResponse.success(message, null);
    }
    
    /**
     * Get user statistics (for admin)
     */
    public ApiResponse<UserStatsResponse> getUserStats() {
        long totalUsers = userRepository.count();
        long activeUsers = totalUsers; // Simplified - count all users as active
        long bannedUsers = 0L; // Need to implement if needed
        
        UserStatsResponse stats = UserStatsResponse.builder()
                .totalUsers(totalUsers)
                .activeUsers(activeUsers)
                .bannedUsers(bannedUsers)
                .build();
        
        return ApiResponse.success(stats);
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
                .articleCount((int) articleRepository.countByAuthorId(user.getId()))
                .commentCount((int) commentRepository.countByUserId(user.getId()))
                .build();
    }
    
    /**
     * User Statistics Response DTO
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserStatsResponse {
        private Long totalUsers;
        private Long activeUsers;
        private Long bannedUsers;
    }
}
