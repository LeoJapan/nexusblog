package com.nexusblog.service;

import com.nexusblog.dto.ApiResponse;
import com.nexusblog.dto.PageResponse;
import com.nexusblog.entity.Article;
import com.nexusblog.entity.Article.ArticleStatus;
import com.nexusblog.entity.User;
import com.nexusblog.repository.ArticleRepository;
import com.nexusblog.repository.CommentRepository;
import com.nexusblog.repository.UserRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Admin Service - 管理员服务类
 * Handles admin dashboard and management operations.
 */
@Service
public class AdminService {
    
    private final UserRepository userRepository;
    private final ArticleRepository articleRepository;
    private final CommentRepository commentRepository;
    
    public AdminService(UserRepository userRepository,
                       ArticleRepository articleRepository,
                       CommentRepository commentRepository) {
        this.userRepository = userRepository;
        this.articleRepository = articleRepository;
        this.commentRepository = commentRepository;
    }
    
    /**
     * Get dashboard statistics
     */
    public ApiResponse<DashboardStats> getDashboardStats() {
        long totalUsers = userRepository.count();
        long activeUsers = userRepository.count(); // Simplified - count all users as active
        long totalArticles = articleRepository.count();
        long publishedArticles = articleRepository.countByStatus(ArticleStatus.PUBLISHED);
        long draftArticles = articleRepository.countByStatus(ArticleStatus.DRAFT);
        long totalComments = commentRepository.count();
        
        DashboardStats stats = DashboardStats.builder()
                .totalUsers(totalUsers)
                .activeUsers(activeUsers)
                .totalArticles(totalArticles)
                .publishedArticles(publishedArticles)
                .draftArticles(draftArticles)
                .totalComments(totalComments)
                .build();
        
        return ApiResponse.success(stats);
    }
    
    /**
     * Get pending articles for review
     */
    public ApiResponse<PageResponse<Map<String, Object>>> getPendingArticles(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Article> articles = articleRepository.findPendingArticles(pageable);
        
        List<Map<String, Object>> content = articles.getContent().stream()
                .map(this::mapToArticleSummary)
                .collect(Collectors.toList());
        
        PageResponse<Map<String, Object>> pageResponse = PageResponse.<Map<String, Object>>builder()
                .content(content)
                .page(articles.getNumber())
                .size(articles.getSize())
                .totalElements(articles.getTotalElements())
                .totalPages(articles.getTotalPages())
                .first(articles.isFirst())
                .last(articles.isLast())
                .build();
        
        return ApiResponse.success(pageResponse);
    }
    
    /**
     * Approve or reject article
     */
    public ApiResponse<Void> auditArticle(Long articleId, String action) {
        Article article = articleRepository.findById(articleId)
                .orElseThrow(() -> new RuntimeException("文章不存在"));
        
        switch (action.toLowerCase()) {
            case "publish":
                article.setStatus(ArticleStatus.PUBLISHED);
                break;
            case "reject":
                article.setStatus(ArticleStatus.HIDDEN);
                break;
            case "archive":
                article.setStatus(ArticleStatus.ARCHIVED);
                break;
            default:
                return ApiResponse.error("无效的操作");
        }
        
        articleRepository.save(article);
        
        String message = switch (action.toLowerCase()) {
            case "publish" -> "文章已发布";
            case "reject" -> "文章已拒绝";
            case "archive" -> "文章已归档";
            default -> "操作成功";
        };
        
        return ApiResponse.success(message, null);
    }
    
    /**
     * Get all articles for admin
     */
    public ApiResponse<PageResponse<Map<String, Object>>> getAllArticles(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Article> articles = articleRepository.findAll(pageable);
        
        List<Map<String, Object>> content = articles.getContent().stream()
                .map(this::mapToArticleSummary)
                .collect(Collectors.toList());
        
        PageResponse<Map<String, Object>> pageResponse = PageResponse.<Map<String, Object>>builder()
                .content(content)
                .page(articles.getNumber())
                .size(articles.getSize())
                .totalElements(articles.getTotalElements())
                .totalPages(articles.getTotalPages())
                .first(articles.isFirst())
                .last(articles.isLast())
                .build();
        
        return ApiResponse.success(pageResponse);
    }
    
    /**
     * Map article to summary map
     */
    private Map<String, Object> mapToArticleSummary(Article article) {
        Map<String, Object> map = new HashMap<>();
        map.put("id", article.getId());
        map.put("title", article.getTitle());
        map.put("category", article.getCategory());
        map.put("status", article.getStatus().name());
        map.put("views", article.getViews());
        map.put("likes", article.getLikes());
        map.put("createdAt", article.getCreatedAt());
        map.put("authorId", article.getAuthor().getId());
        map.put("authorName", article.getAuthor().getUsername());
        return map;
    }
    
    /**
     * Dashboard Statistics Response DTO
     */
    @lombok.Data
    @lombok.Builder
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class DashboardStats {
        private Long totalUsers;
        private Long activeUsers;
        private Long totalArticles;
        private Long publishedArticles;
        private Long draftArticles;
        private Long totalComments;
    }
}
