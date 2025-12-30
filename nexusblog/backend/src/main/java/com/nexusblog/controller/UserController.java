package com.nexusblog.controller;

import com.nexusblog.dto.ApiResponse;
import com.nexusblog.dto.PageResponse;
import com.nexusblog.dto.UserResponse;
import com.nexusblog.entity.User;
import com.nexusblog.service.UserService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * User Controller - 用户控制器
 * Handles user profile and management operations.
 */
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    private final UserService userService;
    
    public UserController(UserService userService) {
        this.userService = userService;
    }
    
    /**
     * Get user by ID
     * GET /api/users/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<UserResponse>> getUser(@PathVariable Long id) {
        ApiResponse<UserResponse> response = userService.getUserById(id);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get current user's profile
     * GET /api/users/profile
     */
    @GetMapping("/profile")
    public ResponseEntity<ApiResponse<UserResponse>> getProfile(
            @AuthenticationPrincipal User user) {
        ApiResponse<UserResponse> response = userService.getUserById(user.getId());
        return ResponseEntity.ok(response);
    }
    
    /**
     * Update current user's profile
     * PUT /api/users/profile
     */
    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<UserResponse>> updateProfile(
            @RequestBody User userDetails,
            @AuthenticationPrincipal User user) {
        ApiResponse<UserResponse> response = userService.updateProfile(user.getId(), userDetails);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get all users (for admin)
     * GET /api/users/admin/all
     */
    @GetMapping("/admin/all")
    public ResponseEntity<ApiResponse<PageResponse<UserResponse>>> getAllUsers(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        ApiResponse<PageResponse<UserResponse>> response = userService.getAllUsers(page, size);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Update user status (for admin)
     * PUT /api/users/admin/{id}/status
     */
    @PutMapping("/admin/{id}/status")
    public ResponseEntity<ApiResponse<Void>> updateUserStatus(
            @PathVariable Long id,
            @RequestParam Integer status) {
        ApiResponse<Void> response = userService.updateUserStatus(id, status);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get user statistics (for admin)
     * GET /api/users/admin/stats
     */
    @GetMapping("/admin/stats")
    public ResponseEntity<ApiResponse<UserService.UserStatsResponse>> getUserStats() {
        ApiResponse<UserService.UserStatsResponse> response = userService.getUserStats();
        return ResponseEntity.ok(response);
    }
}
