package com.nexusblog.controller;

import com.nexusblog.dto.ApiResponse;
import com.nexusblog.dto.CommentRequest;
import com.nexusblog.dto.CommentResponse;
import com.nexusblog.dto.PageResponse;
import com.nexusblog.entity.User;
import com.nexusblog.service.CommentService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Comment Controller - 评论控制器
 * Handles comment CRUD operations.
 */
@RestController
@RequestMapping("/api/comments")
public class CommentController {
    
    private final CommentService commentService;
    
    public CommentController(CommentService commentService) {
        this.commentService = commentService;
    }
    
    /**
     * Get comments for an article
     * GET /api/comments/article/{articleId}
     */
    @GetMapping("/article/{articleId}")
    public ResponseEntity<ApiResponse<List<CommentResponse>>> getCommentsByArticle(
            @PathVariable Long articleId) {
        ApiResponse<List<CommentResponse>> response = commentService.getCommentsByArticle(articleId);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Create new comment
     * POST /api/comments
     */
    @PostMapping
    public ResponseEntity<ApiResponse<CommentResponse>> createComment(
            @Valid @RequestBody CommentRequest request,
            @AuthenticationPrincipal User user) {
        ApiResponse<CommentResponse> response = commentService.createComment(request, user.getId());
        
        if (response.getSuccess()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
    
    /**
     * Delete comment
     * DELETE /api/comments/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteComment(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        ApiResponse<Void> response = commentService.deleteComment(id, user.getId());
        
        if (response.getSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
    
    /**
     * Get comments by user
     * GET /api/comments/user/{userId}
     */
    @GetMapping("/user/{userId}")
    public ResponseEntity<ApiResponse<PageResponse<CommentResponse>>> getCommentsByUser(
            @PathVariable Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        ApiResponse<PageResponse<CommentResponse>> response = commentService.getCommentsByUser(
                userId, page, size);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get all comments (for admin)
     * GET /api/comments/admin/all
     */
    @GetMapping("/admin/all")
    public ResponseEntity<ApiResponse<PageResponse<CommentResponse>>> getAllComments(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        ApiResponse<PageResponse<CommentResponse>> response = commentService.getAllComments(page, size);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Approve comment (for admin)
     * PUT /api/comments/admin/{id}/approve
     */
    @PutMapping("/admin/{id}/approve")
    public ResponseEntity<ApiResponse<Void>> approveComment(@PathVariable Long id) {
        ApiResponse<Void> response = commentService.approveComment(id);
        return ResponseEntity.ok(response);
    }
}
