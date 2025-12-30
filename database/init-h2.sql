-- H2 Database Initialization Script
-- For use without MySQL

-- Create admin user
INSERT INTO users (username, password, email, role, status) 
VALUES ('admin', '$2a$10$N.zmdr9k7uOCQb376NoUnuTJ8iAt6Z5EHsM8lE9lBpF3x/tzx7kn6', 'admin@nexusblog.com', 'ADMIN', 1);

-- Insert sample categories and articles
INSERT INTO articles (title, content, summary, author_id, category, tags, status) VALUES
('欢迎使用 NexusBlog', 
 '# 欢迎使用 NexusBlog\n\n这是一个现代化的全栈博客系统。\n\n## 功能特性\n\n- 用户注册和登录\n- 文章发布和管理\n- 评论系统\n- 分类和标签\n- 搜索功能\n- 管理后台', 
 'NexusBlog 是一个现代化的全栈博客系统。',
 1, '技术分享', '欢迎,系统介绍', 'PUBLISHED');

INSERT INTO articles (title, content, summary, author_id, category, tags, status) VALUES
('Vue 3 组合式 API 入门指南',
 '# Vue 3 组合式 API 入门指南\n\nVue 3 引入了组合式 API。\n\n## 核心函数\n\n- ref\n- computed\n- watch', 
 '本文介绍 Vue 3 组合式 API 的基础知识。',
 1, '前端开发', 'Vue,前端', 'PUBLISHED');

INSERT INTO articles (title, content, summary, author_id, category, tags, status) VALUES
('Spring Boot 3 新特性详解',
 '# Spring Boot 3 新特性详解\n\nSpring Boot 3.0 带来许多新特性。\n\n## 主要更新\n\n1. 基于 Spring Framework 6\n2. 支持 Jakarta EE 9+', 
 '详细介绍 Spring Boot 3 的新特性。',
 1, '后端开发', 'Spring Boot,Java', 'PUBLISHED');

-- Insert sample comments
INSERT INTO comments (article_id, user_id, content, parent_id, status) VALUES
(1, 1, '系统看起来很不错！', NULL, 1),
(2, 1, '写得很好，学习了！', NULL, 1);
