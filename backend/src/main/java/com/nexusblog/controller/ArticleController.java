package com.nexusblog.controller;

import com.nexusblog.dto.ApiResponse;
import com.nexusblog.dto.ArticleRequest;
import com.nexusblog.dto.ArticleResponse;
import com.nexusblog.dto.PageResponse;
import com.nexusblog.entity.User;
import com.nexusblog.service.ArticleService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Article Controller - 文章控制器
 * Handles article CRUD operations and queries.
 */
@RestController
@RequestMapping("/api/articles")
public class ArticleController {
    
    private final ArticleService articleService;
    
    public ArticleController(ArticleService articleService) {
        this.articleService = articleService;
    }
    
    /**
     * Get all published articles with pagination
     * GET /api/articles
     */
    @GetMapping
    public ResponseEntity<ApiResponse<PageResponse<ArticleResponse>>> getArticles(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String tag,
            @RequestParam(required = false) String keyword) {
        ApiResponse<PageResponse<ArticleResponse>> response = articleService.getPublishedArticles(
                page, size, category, tag, keyword);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get article by ID
     * GET /api/articles/{id}
     */
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ArticleResponse>> getArticle(@PathVariable Long id) {
        ApiResponse<ArticleResponse> response = articleService.getArticleById(id);
        
        if (response.getSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
    }
    
    /**
     * Create new article
     * POST /api/articles
     */
    @PostMapping
    public ResponseEntity<ApiResponse<ArticleResponse>> createArticle(
            @Valid @RequestBody ArticleRequest request,
            @AuthenticationPrincipal User user) {
        ApiResponse<ArticleResponse> response = articleService.createArticle(request, user.getId());
        
        if (response.getSuccess()) {
            return ResponseEntity.status(HttpStatus.CREATED).body(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
    
    /**
     * Update article
     * PUT /api/articles/{id}
     */
    @PutMapping("/{id}")
    public ResponseEntity<ApiResponse<ArticleResponse>> updateArticle(
            @PathVariable Long id,
            @Valid @RequestBody ArticleRequest request,
            @AuthenticationPrincipal User user) {
        ApiResponse<ArticleResponse> response = articleService.updateArticle(id, request, user.getId());
        
        if (response.getSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
    
    /**
     * Delete article
     * DELETE /api/articles/{id}
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<ApiResponse<Void>> deleteArticle(
            @PathVariable Long id,
            @AuthenticationPrincipal User user) {
        ApiResponse<Void> response = articleService.deleteArticle(id, user.getId());
        
        if (response.getSuccess()) {
            return ResponseEntity.ok(response);
        }
        return ResponseEntity.badRequest().body(response);
    }
    
    /**
     * Get articles by author
     * GET /api/articles/author/{authorId}
     */
    @GetMapping("/author/{authorId}")
    public ResponseEntity<ApiResponse<PageResponse<ArticleResponse>>> getArticlesByAuthor(
            @PathVariable Long authorId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        ApiResponse<PageResponse<ArticleResponse>> response = articleService.getArticlesByAuthor(
                authorId, page, size);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get popular articles
     * GET /api/articles/popular
     */
    @GetMapping("/popular")
    public ResponseEntity<ApiResponse<List<ArticleResponse>>> getPopularArticles(
            @RequestParam(defaultValue = "5") int limit) {
        ApiResponse<List<ArticleResponse>> response = articleService.getPopularArticles(limit);
        return ResponseEntity.ok(response);
    }
    
    /**
     * Get all categories
     * GET /api/articles/categories
     */
    @GetMapping("/categories")
    public ResponseEntity<ApiResponse<List<String>>> getCategories() {
        ApiResponse<List<String>> response = articleService.getCategories();
        return ResponseEntity.ok(response);
    }
    
    /**
     * Like article
     * POST /api/articles/{id}/like
     */
    @PostMapping("/{id}/like")
    public ResponseEntity<ApiResponse<ArticleResponse>> likeArticle(@PathVariable Long id) {
        ApiResponse<ArticleResponse> response = articleService.likeArticle(id);
        return ResponseEntity.ok(response);
    }
}
