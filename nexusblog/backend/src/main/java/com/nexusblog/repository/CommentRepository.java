package com.nexusblog.repository;

import com.nexusblog.entity.Comment;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Comment Repository - 评论数据访问接口
 * Provides database operations for Comment entity.
 */
@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {
    
    /**
     * Find comments by article
     */
    List<Comment> findByArticleIdAndStatusOrderByCreatedAtAsc(Long articleId, Integer status);
    
    /**
     * Find top-level comments (no parent)
     */
    @Query("SELECT c FROM Comment c WHERE c.article.id = :articleId AND c.parent IS NULL AND c.status = 1 ORDER BY c.createdAt DESC")
    List<Comment> findTopLevelComments(@Param("articleId") Long articleId);
    
    /**
     * Find replies to a comment
     */
    @Query("SELECT c FROM Comment c WHERE c.parent.id = :parentId AND c.status = 1 ORDER BY c.createdAt ASC")
    List<Comment> findReplies(@Param("parentId") Long parentId);
    
    /**
     * Count comments by article
     */
    long countByArticleIdAndStatus(Long articleId, Integer status);
    
    /**
     * Count comments by user
     */
    long countByUserId(Long userId);
    
    /**
     * Find all comments by user (for profile)
     */
    Page<Comment> findByUserId(Long userId, Pageable pageable);
    
    /**
     * Find pending comments (for admin)
     */
    @Query("SELECT c FROM Comment c WHERE c.status = 0 ORDER BY c.createdAt DESC")
    Page<Comment> findPendingComments(Pageable pageable);
    
    /**
     * Find all comments (for admin)
     */
    Page<Comment> findAll(Pageable pageable);
}
