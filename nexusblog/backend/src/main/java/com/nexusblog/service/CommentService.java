package com.nexusblog.service;

import com.nexusblog.dto.*;
import com.nexusblog.entity.Article;
import com.nexusblog.entity.Comment;
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

/**
 * Comment Service - 评论服务类
 * Handles comment CRUD operations.
 */
@Service
public class CommentService {
    
    private final CommentRepository commentRepository;
    private final ArticleRepository articleRepository;
    private final UserRepository userRepository;
    
    public CommentService(CommentRepository commentRepository,
                         ArticleRepository articleRepository,
                         UserRepository userRepository) {
        this.commentRepository = commentRepository;
        this.articleRepository = articleRepository;
        this.userRepository = userRepository;
    }
    
    /**
     * Get comments for an article
     */
    public ApiResponse<List<CommentResponse>> getCommentsByArticle(Long articleId) {
        // Verify article exists
        if (!articleRepository.existsById(articleId)) {
            return ApiResponse.error("文章不存在");
        }
        
        List<Comment> topLevelComments = commentRepository.findTopLevelComments(articleId);
        
        List<CommentResponse> responses = topLevelComments.stream()
                .map(comment -> buildCommentTree(comment))
                .collect(Collectors.toList());
        
        return ApiResponse.success(responses);
    }
    
    /**
     * Create new comment
     */
    @Transactional
    public ApiResponse<CommentResponse> createComment(CommentRequest request, Long userId) {
        // Verify article exists
        Article article = articleRepository.findById(request.getArticleId())
                .orElseThrow(() -> new ResourceNotFoundException("Article", "id", request.getArticleId()));
        
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        
        // Check if user is active
        if (user.getStatus() != 1) {
            return ApiResponse.error("用户已被禁用，无法评论");
        }
        
        Comment comment = new Comment();
        comment.setArticle(article);
        comment.setUser(user);
        comment.setContent(request.getContent());
        comment.setStatus(1);  // Auto-approve for now, can be changed to 0 for moderation
        
        // Handle reply
        if (request.getParentId() != null) {
            Comment parentComment = commentRepository.findById(request.getParentId())
                    .orElseThrow(() -> new ResourceNotFoundException("Comment", "id", request.getParentId()));
            comment.setParent(parentComment);
        }
        
        comment = commentRepository.save(comment);
        
        return ApiResponse.success("评论成功", mapToCommentResponse(comment));
    }
    
    /**
     * Delete comment
     */
    @Transactional
    public ApiResponse<Void> deleteComment(Long commentId, Long userId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("Comment", "id", commentId));
        
        // Check if user is comment author or admin
        User user = userRepository.findById(userId).orElse(null);
        if (user == null || (!comment.getUser().getId().equals(userId) && 
                user.getRole() != User.Role.ADMIN)) {
            return ApiResponse.error("您没有权限删除此评论");
        }
        
        // Soft delete - change status
        comment.setStatus(-1);
        commentRepository.save(comment);
        
        return ApiResponse.success("评论已删除", null);
    }
    
    /**
     * Get comments by user
     */
    public ApiResponse<PageResponse<CommentResponse>> getCommentsByUser(Long userId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Comment> comments = commentRepository.findByUserId(userId, pageable);
        
        List<CommentResponse> content = comments.getContent().stream()
                .map(this::mapToCommentResponse)
                .collect(Collectors.toList());
        
        PageResponse<CommentResponse> pageResponse = PageResponse.<CommentResponse>builder()
                .content(content)
                .page(comments.getNumber())
                .size(comments.getSize())
                .totalElements(comments.getTotalElements())
                .totalPages(comments.getTotalPages())
                .first(comments.isFirst())
                .last(comments.isLast())
                .build();
        
        return ApiResponse.success(pageResponse);
    }
    
    /**
     * Get all comments for admin
     */
    public ApiResponse<PageResponse<CommentResponse>> getAllComments(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Comment> comments = commentRepository.findAll(pageable);
        
        List<CommentResponse> content = comments.getContent().stream()
                .map(this::mapToCommentResponse)
                .collect(Collectors.toList());
        
        PageResponse<CommentResponse> pageResponse = PageResponse.<CommentResponse>builder()
                .content(content)
                .page(comments.getNumber())
                .size(comments.getSize())
                .totalElements(comments.getTotalElements())
                .totalPages(comments.getTotalPages())
                .first(comments.isFirst())
                .last(comments.isLast())
                .build();
        
        return ApiResponse.success(pageResponse);
    }
    
    /**
     * Approve comment (for admin)
     */
    @Transactional
    public ApiResponse<Void> approveComment(Long commentId) {
        Comment comment = commentRepository.findById(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("Comment", "id", commentId));
        
        comment.setStatus(1);
        commentRepository.save(comment);
        
        return ApiResponse.success("评论已通过审核", null);
    }
    
    /**
     * Build comment tree structure
     */
    private CommentResponse buildCommentTree(Comment comment) {
        List<Comment> replies = commentRepository.findReplies(comment.getId());
        
        List<CommentResponse> replyResponses = replies.stream()
                .map(this::mapToCommentResponse)
                .collect(Collectors.toList());
        
        return CommentResponse.builder()
                .id(comment.getId())
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .parentId(null)
                .user(CommentResponse.UserInfo.builder()
                        .id(comment.getUser().getId())
                        .username(comment.getUser().getUsername())
                        .avatar(comment.getUser().getAvatar())
                        .build())
                .replies(replyResponses)
                .build();
    }
    
    private CommentResponse mapToCommentResponse(Comment comment) {
        return CommentResponse.builder()
                .id(comment.getId())
                .content(comment.getContent())
                .createdAt(comment.getCreatedAt())
                .parentId(comment.getParent() != null ? comment.getParent().getId() : null)
                .user(CommentResponse.UserInfo.builder()
                        .id(comment.getUser().getId())
                        .username(comment.getUser().getUsername())
                        .avatar(comment.getUser().getAvatar())
                        .build())
                .build();
    }
}
