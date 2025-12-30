package com.nexusblog.service;

import com.nexusblog.dto.*;
import com.nexusblog.entity.Article;
import com.nexusblog.entity.Article.ArticleStatus;
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
 * Article Service - 文章服务类
 * Handles article CRUD operations and queries.
 */
@Service
public class ArticleService {
    
    private final ArticleRepository articleRepository;
    private final UserRepository userRepository;
    private final CommentRepository commentRepository;
    
    public ArticleService(ArticleRepository articleRepository,
                         UserRepository userRepository,
                         CommentRepository commentRepository) {
        this.articleRepository = articleRepository;
        this.userRepository = userRepository;
        this.commentRepository = commentRepository;
    }
    
    /**
     * Get all published articles with pagination
     */
    public ApiResponse<PageResponse<ArticleResponse>> getPublishedArticles(
            int page, int size, String category, String tag, String keyword) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        
        Page<Article> articles;
        
        if (keyword != null && !keyword.isEmpty()) {
            // Search by keyword
            articles = articleRepository.searchByKeyword(ArticleStatus.PUBLISHED, keyword, pageable);
        } else if (tag != null && !tag.isEmpty()) {
            // Filter by tag
            articles = articleRepository.findByTag(ArticleStatus.PUBLISHED, tag, pageable);
        } else if (category != null && !category.isEmpty()) {
            // Filter by category
            articles = articleRepository.findByCategoryAndStatus(
                    category, ArticleStatus.PUBLISHED, pageable);
        } else {
            // Get all published
            articles = articleRepository.findByStatus(ArticleStatus.PUBLISHED, pageable);
        }
        
        PageResponse<ArticleResponse> pageResponse = mapToPageResponse(articles);
        return ApiResponse.success(pageResponse);
    }
    
    /**
     * Get article by ID
     */
    @Transactional
    public ApiResponse<ArticleResponse> getArticleById(Long id) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Article", "id", id));
        
        // Only show published articles to public
        if (article.getStatus() != ArticleStatus.PUBLISHED) {
            return ApiResponse.error("文章不存在或已被删除");
        }
        
        // Increment view count
        article.setViews(article.getViews() + 1);
        articleRepository.save(article);
        
        return ApiResponse.success(mapToArticleResponse(article, true));
    }
    
    /**
     * Create new article
     */
    @Transactional
    public ApiResponse<ArticleResponse> createArticle(ArticleRequest request, Long userId) {
        User author = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User", "id", userId));
        
        Article article = new Article();
        article.setTitle(request.getTitle());
        article.setContent(request.getContent());
        article.setSummary(request.getSummary() != null ? request.getSummary() : 
                truncateSummary(request.getContent(), 200));
        article.setCategory(request.getCategory());
        article.setTags(request.getTags());
        article.setAuthor(author);
        article.setStatus(ArticleStatus.DRAFT);  // Default to draft
        
        if (request.getStatus() != null) {
            try {
                article.setStatus(ArticleStatus.valueOf(request.getStatus()));
            } catch (IllegalArgumentException e) {
                article.setStatus(ArticleStatus.DRAFT);
            }
        }
        
        article = articleRepository.save(article);
        
        return ApiResponse.success("文章创建成功", mapToArticleResponse(article, false));
    }
    
    /**
     * Update article
     */
    @Transactional
    public ApiResponse<ArticleResponse> updateArticle(Long id, ArticleRequest request, Long userId) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Article", "id", id));
        
        // Check if user is author or admin
        User user = userRepository.findById(userId).orElse(null);
        if (user == null || (!article.getAuthor().getId().equals(userId) && 
                user.getRole() != User.Role.ADMIN)) {
            return ApiResponse.error("您没有权限编辑此文章");
        }
        
        article.setTitle(request.getTitle());
        article.setContent(request.getContent());
        article.setSummary(request.getSummary() != null ? request.getSummary() : 
                truncateSummary(request.getContent(), 200));
        article.setCategory(request.getCategory());
        article.setTags(request.getTags());
        
        if (request.getStatus() != null) {
            try {
                article.setStatus(ArticleStatus.valueOf(request.getStatus()));
            } catch (IllegalArgumentException e) {
                // Keep existing status
            }
        }
        
        article = articleRepository.save(article);
        
        return ApiResponse.success("文章更新成功", mapToArticleResponse(article, false));
    }
    
    /**
     * Delete article
     */
    @Transactional
    public ApiResponse<Void> deleteArticle(Long id, Long userId) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Article", "id", id));
        
        // Check if user is author or admin
        User user = userRepository.findById(userId).orElse(null);
        if (user == null || (!article.getAuthor().getId().equals(userId) && 
                user.getRole() != User.Role.ADMIN)) {
            return ApiResponse.error("您没有权限删除此文章");
        }
        
        articleRepository.delete(article);
        
        return ApiResponse.success("文章删除成功", null);
    }
    
    /**
     * Get articles by author
     */
    public ApiResponse<PageResponse<ArticleResponse>> getArticlesByAuthor(Long authorId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Article> articles = articleRepository.findByAuthorId(authorId, pageable);
        
        return ApiResponse.success(mapToPageResponse(articles));
    }
    
    /**
     * Get popular articles
     */
    public ApiResponse<List<ArticleResponse>> getPopularArticles(int limit) {
        List<Article> articles = articleRepository.findPopularArticles(
                PageRequest.of(0, limit));
        
        List<ArticleResponse> responses = articles.stream()
                .map(article -> mapToArticleResponse(article, false))
                .collect(Collectors.toList());
        
        return ApiResponse.success(responses);
    }
    
    /**
     * Get all categories
     */
    public ApiResponse<List<String>> getCategories() {
        List<String> categories = articleRepository.findAll()
                .stream()
                .map(Article::getCategory)
                .distinct()
                .collect(Collectors.toList());
        
        return ApiResponse.success(categories);
    }
    
    /**
     * Like article
     */
    @Transactional
    public ApiResponse<ArticleResponse> likeArticle(Long id) {
        Article article = articleRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Article", "id", id));
        
        article.setLikes(article.getLikes() + 1);
        articleRepository.save(article);
        
        return ApiResponse.success(mapToArticleResponse(article, false));
    }
    
    // Helper methods
    
    private String truncateSummary(String content, int maxLength) {
        if (content == null) return "";
        String plainText = content.replaceAll("<[^>]*>", "");
        if (plainText.length() <= maxLength) {
            return plainText;
        }
        return plainText.substring(0, maxLength) + "...";
    }
    
    private PageResponse<ArticleResponse> mapToPageResponse(Page<Article> page) {
        List<ArticleResponse> content = page.getContent().stream()
                .map(article -> mapToArticleResponse(article, false))
                .collect(Collectors.toList());
        
        return PageResponse.<ArticleResponse>builder()
                .content(content)
                .page(page.getNumber())
                .size(page.getSize())
                .totalElements(page.getTotalElements())
                .totalPages(page.getTotalPages())
                .first(page.isFirst())
                .last(page.isLast())
                .build();
    }
    
    private ArticleResponse mapToArticleResponse(Article article, boolean includeComments) {
        ArticleResponse.ArticleResponseBuilder builder = ArticleResponse.builder()
                .id(article.getId())
                .title(article.getTitle())
                .content(article.getContent())
                .summary(article.getSummary())
                .category(article.getCategory())
                .tags(article.getTags())
                .views(article.getViews())
                .likes(article.getLikes())
                .status(article.getStatus().name())
                .createdAt(article.getCreatedAt())
                .updatedAt(article.getUpdatedAt())
                .author(ArticleResponse.AuthorInfo.builder()
                        .id(article.getAuthor().getId())
                        .username(article.getAuthor().getUsername())
                        .avatar(article.getAuthor().getAvatar())
                        .build());
        
        if (includeComments) {
            List<CommentResponse> comments = commentRepository
                    .findByArticleIdAndStatusOrderByCreatedAtAsc(article.getId(), 1)
                    .stream()
                    .map(this::mapToCommentResponse)
                    .collect(Collectors.toList());
            
            builder.comments(comments)
                   .commentCount((int) commentRepository.countByArticleIdAndStatus(article.getId(), 1));
        }
        
        return builder.build();
    }
    
    private CommentResponse mapToCommentResponse(com.nexusblog.entity.Comment comment) {
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
