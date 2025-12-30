package com.nexusblog.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

/**
 * Article Entity - 文章实体类
 * Maps to the 'articles' table in the database.
 */
@Entity
@Table(name = "articles")
@Data
public class Article {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false, length = 255)
    private String title;
    
    @Column(nullable = false, columnDefinition = "LONGTEXT")
    private String content;
    
    @Column(length = 500)
    private String summary;
    
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "author_id", nullable = false)
    private User author;
    
    @Column(nullable = false, length = 50)
    private String category;
    
    @Column(length = 255)
    private String tags;
    
    @Column(nullable = false)
    private Integer views = 0;
    
    @Column(nullable = false)
    private Integer likes = 0;
    
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ArticleStatus status = ArticleStatus.DRAFT;
    
    @Column(name = "created_at", nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
    
    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }
    
    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
    
    /**
     * Article Status Enum
     */
    public enum ArticleStatus {
        DRAFT,
        PUBLISHED,
        HIDDEN,
        ARCHIVED
    }
}
