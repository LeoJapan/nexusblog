package com.nexusblog.repository;

import com.nexusblog.entity.Article;
import com.nexusblog.entity.Article.ArticleStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Article Repository - 文章数据访问接口
 * Provides database operations for Article entity.
 */
@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {
    
    /**
     * Find all published articles with pagination
     */
    Page<Article> findByStatus(ArticleStatus status, Pageable pageable);
    
    /**
     * Find articles by category
     */
    Page<Article> findByCategoryAndStatus(String category, ArticleStatus status, Pageable pageable);
    
    /**
     * Find articles by author
     */
    Page<Article> findByAuthorId(Long authorId, Pageable pageable);
    
    /**
     * Search articles by title or content
     */
    @Query("SELECT a FROM Article a WHERE a.status = :status AND " +
           "(a.title LIKE %:keyword% OR a.content LIKE %:keyword%)")
    Page<Article> searchByKeyword(@Param("status") ArticleStatus status,
                                   @Param("keyword") String keyword,
                                   Pageable pageable);
    
    /**
     * Find articles by tag
     */
    @Query("SELECT a FROM Article a WHERE a.status = :status AND a.tags LIKE %:tag%")
    Page<Article> findByTag(@Param("status") ArticleStatus status,
                            @Param("tag") String tag,
                            Pageable pageable);
    
    /**
     * Get popular articles (most viewed)
     */
    @Query("SELECT a FROM Article a WHERE a.status = 'PUBLISHED' ORDER BY a.views DESC")
    List<Article> findPopularArticles(Pageable pageable);
    
    /**
     * Get all articles for admin (including drafts)
     */
    Page<Article> findAll(Pageable pageable);
    
    /**
     * Count articles by status
     */
    long countByStatus(ArticleStatus status);
    
    /**
     * Count articles by author
     */
    long countByAuthorId(Long authorId);
    
    /**
     * Find articles pending review
     */
    @Query("SELECT a FROM Article a WHERE a.status = 'DRAFT' ORDER BY a.createdAt DESC")
    Page<Article> findPendingArticles(Pageable pageable);
}
