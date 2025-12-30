package com.nexusblog.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

/**
 * User Response DTO - 用户响应数据传输对象
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    
    private Long id;
    private String username;
    private String email;
    private String avatar;
    private String role;
    private Integer status;
    private LocalDateTime createdAt;
    private Integer articleCount;
    private Integer commentCount;
}
