package com.nexusblog.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

/**
 * Comment Request DTO - 评论请求数据传输对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CommentRequest {
    
    private Long articleId;
    
    private String content;
    
    private Long parentId;  // For replies, null for top-level comments
}
