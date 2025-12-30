package com.nexusblog.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

/**
 * Article Create/Update Request DTO - 文章创建/更新请求数据传输对象
 */
@Data
public class ArticleRequest {
    
    private Long id;  // For update operations
    
    @NotBlank(message = "标题不能为空")
    @Size(max = 255, message = "标题长度不能超过255个字符")
    private String title;
    
    @NotBlank(message = "内容不能为空")
    private String content;
    
    @Size(max = 500, message = "摘要长度不能超过500个字符")
    private String summary;
    
    @NotBlank(message = "分类不能为空")
    @Size(max = 50, message = "分类长度不能超过50个字符")
    private String category;
    
    @Size(max = 255, message = "标签长度不能超过255个字符")
    private String tags;
    
    private String status;  // DRAFT, PUBLISHED, etc.
}
