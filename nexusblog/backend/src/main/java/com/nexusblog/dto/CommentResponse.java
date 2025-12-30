package com.nexusblog.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Comment Response DTO - 评论响应数据传输对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommentResponse {
    
    private Long id;
    private String content;
    private LocalDateTime createdAt;
    
    // User Information
    private UserInfo user;
    
    // Parent Comment Information (for replies)
    private Long parentId;
    private String parentContent;
    
    // Replies
    private java.util.List<CommentResponse> replies;
    
    @Data
    @Builder
    @NoArgsConstructor
    @AllArgsConstructor
    public static class UserInfo {
        private Long id;
        private String username;
        private String avatar;
    }
}
