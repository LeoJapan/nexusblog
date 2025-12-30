package com.nexusblog.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Article Response DTO - 文章响应数据传输对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ArticleResponse {
    
    private Long id;
    private String title;
    private String content;
    private String summary;
    private String category;
    private String tags;
    private Integer views;
    private Integer likes;
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // Author Information
    private AuthorInfo author;
    
    // Comments
    private List<CommentResponse> comments;
    private Integer commentCount;
    
    /**
     * Author Information Nested Class
     */
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class AuthorInfo {
        private Long id;
        private String username;
        private String avatar;
    }
}
