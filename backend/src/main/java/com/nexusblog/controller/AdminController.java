package com.nexusblog.controller;

import com.nexusblog.dto.ApiResponse;
import com.nexusblog.dto.PageResponse;
import com.nexusblog.service.AdminService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Admin Controller - 管理员控制器
 * Handles admin dashboard and management operations.
 */
@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {
    
    private final AdminService adminService;
    
    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }
    
    /**
     * Get dashboard statistics
     * GET /api/admin/stats
     */
    @GetMapping("/stats")
    public ResponseEntity<ApiResponse<AdminService.DashboardStats>> getDashboardStats() {
        ApiResponse<AdminService.DashboardStats> response = adminService.getDashboardStats();
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get pending articles for review
     * GET /api/admin/articles/pending
     */
    @GetMapping("/articles/pending")
    public ResponseEntity<ApiResponse<PageResponse<Map<String, Object>>>> getPendingArticles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        ApiResponse<PageResponse<Map<String, Object>>> response = adminService.getPendingArticles(page, size);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get all articles (for admin)
     * GET /api/admin/articles/all
     */
    @GetMapping("/articles/all")
    public ResponseEntity<ApiResponse<PageResponse<Map<String, Object>>>> getAllArticles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        ApiResponse<PageResponse<Map<String, Object>>> response = adminService.getAllArticles(page, size);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Audit article (publish/reject/archive)
     * PUT /api/admin/articles/{id}/audit
     */
    @PutMapping("/articles/{id}/audit")
    public ResponseEntity<ApiResponse<Void>> auditArticle(
            @PathVariable Long id,
            @RequestParam String action) {
        ApiResponse<Void> response = adminService.auditArticle(id, action);
        return ResponseEntity.ok(response);
    }
}
