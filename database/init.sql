-- NexusBlog Database Initialization Script
-- Create database and tables for the blog system

-- Create database
CREATE DATABASE IF NOT EXISTS nexusblog DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE nexusblog;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    role ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER',
    avatar VARCHAR(255),
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status INT NOT NULL DEFAULT 1,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Articles table
CREATE TABLE IF NOT EXISTS articles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content LONGTEXT NOT NULL,
    summary VARCHAR(500),
    author_id BIGINT NOT NULL,
    category VARCHAR(50) NOT NULL,
    tags VARCHAR(255),
    views INT NOT NULL DEFAULT 0,
    likes INT NOT NULL DEFAULT 0,
    status ENUM('DRAFT', 'PUBLISHED', 'HIDDEN', 'ARCHIVED') NOT NULL DEFAULT 'DRAFT',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_author_id (author_id),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    article_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    content VARCHAR(1000) NOT NULL,
    parent_id BIGINT,
    status INT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_article_id (article_id),
    INDEX idx_user_id (user_id),
    INDEX idx_parent_id (parent_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at),
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (parent_id) REFERENCES comments(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert default admin user (password: admin123)
-- Password is BCrypt hash of 'admin123'
INSERT INTO users (username, password, email, role, status) 
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBpF3x/tzx7kn6', 'admin@nexusblog.com', 'ADMIN', 1);

-- Insert sample categories
INSERT INTO articles (title, content, summary, author_id, category, tags, status) VALUES
('欢迎使用 NexusBlog', 
 '# 欢迎使用 NexusBlog\n\n这是一个现代化的全栈博客系统。\n\n## 功能特性\n\n- 用户注册和登录\n- 文章发布和管理\n- 评论系统\n- 分类和标签\n- 搜索功能\n- 管理后台', 
 'NexusBlog 是一个现代化的全栈博客系统，支持用户发布、阅读和互动博客文章。',
 1, '技术分享', '欢迎,系统介绍', 'PUBLISHED');

-- Insert sample articles
INSERT INTO articles (title, content, summary, author_id, category, tags, status) VALUES
('Vue 3 组合式 API 入门指南',
 '# Vue 3 组合式 API 入门指南\n\nVue 3 引入了组合式 API，这是一种新的编写 Vue 组件的方式。\n\n## 为什么使用组合式 API？\n\n1. 更好的逻辑复用\n2. 更灵活的代码组织\n3. 更好的 TypeScript 支持\n\n## 核心函数\n\n- `ref` - 定义响应式数据\n- `computed` - 定义计算属性\n- `watch` - 监听数据变化\n- `onMounted` - 组件挂载后执行',
 '本文介绍 Vue 3 组合式 API 的基础知识和使用方法。',
 1, '前端开发', 'Vue,前端,JavaScript', 'PUBLISHED'),
 
('Spring Boot 3 新特性详解',
 '# Spring Boot 3 新特性详解\n\nSpring Boot 3.0 是一个重大版本更新，带来许多新特性。\n\n## 主要更新\n\n1. 基于 Spring Framework 6\n2. 支持 Jakarta EE 9+\n3. 更好的 GraalVM 原生支持\n4. 改进的 AOT 编译',
 '详细介绍 Spring Boot 3 的新特性和升级指南。',
 1, '后端开发', 'Spring Boot,Java,后端', 'PUBLISHED'),
 
('MySQL 8.0 性能优化技巧',
 '# MySQL 8.0 性能优化技巧\n\nMySQL 8.0 带来了许多性能改进和新功能。\n\n## 优化建议\n\n1. 使用索引优化查询\n2. 避免 SELECT *\n3. 使用 EXPLAIN 分析执行计划\n4. 适当使用缓存',
 '分享 MySQL 8.0 的性能优化技巧和最佳实践。',
 1, '数据库', 'MySQL,数据库,性能优化', 'PUBLISHED');

-- Insert sample comments
INSERT INTO comments (article_id, user_id, content, parent_id, status) VALUES
(1, 1, '系统看起来很不错！', NULL, 1),
(2, 1, '写得很好，学习了！', NULL, 1),
(2, 1, '请问有完整的项目源码吗？', 2, 1);

-- Verify data
SELECT 'Users:' as '';
SELECT id, username, email, role, status FROM users;

SELECT 'Articles:' as '';
SELECT id, title, category, status FROM articles;

SELECT 'Comments:' as '';
SELECT id, article_id, content, status FROM comments;
