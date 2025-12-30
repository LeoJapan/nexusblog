# NexusBlog 全栈博客系统

一个现代化的全栈博客系统，支持用户发布、阅读和互动博客文章。

## 技术栈

### 前端
- **Vue 3** - 渐进式 JavaScript 框架
- **Vite** - 构建工具
- **Pinia** - 状态管理
- **Vue Router** - 路由管理
- **Tailwind CSS** - 原子化 CSS 框架
- **Axios** - HTTP 客户端

### 后端
- **Java** - 编程语言
- **Spring Boot 3** - 后端框架
- **Spring Security** - 安全框架
- **MySQL** - 关系型数据库
- **JPA/Hibernate** - ORM 框架
- **JWT** - 认证机制

## 功能特性

### 前台功能
- 📝 **博客展示** - 卡片或列表形式展示文章
- 🔍 **文章搜索** - 支持关键词、作者、标签搜索
- 💬 **评论系统** - 支持回复和嵌套评论
- 👤 **用户系统** - 注册、登录、个人资料管理
- ❤️ **互动功能** - 点赞、分享文章
- 📱 **响应式设计** - 支持手机和电脑访问

### 后台管理
- 📊 **仪表盘** - 统计概览
- 📝 **文章管理** - 审核、发布、编辑、删除
- 👥 **用户管理** - 封禁用户、管理权限
- 💭 **评论管理** - 审核和管理评论

## 项目结构

```
nexusblog/
├── backend/                 # 后端项目
│   ├── src/main/java/com/nexusblog/
│   │   ├── config/         # 配置类
│   │   ├── controller/     # 控制器
│   │   ├── dto/            # 数据传输对象
│   │   ├── entity/         # 实体类
│   │   ├── exception/      # 异常处理
│   │   ├── repository/     # 数据访问层
│   │   ├── service/        # 业务逻辑层
│   │   └── utils/          # 工具类
│   └── src/main/resources/
│       └── application.yml # 配置文件
│
├── frontend/               # 前端项目
│   ├── src/
│   │   ├── api/           # API 接口封装
│   │   ├── assets/        # 静态资源
│   │   ├── components/    # 公共组件
│   │   ├── router/        # 路由配置
│   │   ├── stores/        # Pinia 状态管理
│   │   ├── views/         # 页面视图
│   │   └── main.js        # 入口文件
│   ├── index.html         # HTML 模板
│   └── vite.config.js     # Vite 配置
│
└── database/
    └── init.sql           # 数据库初始化脚本
```

## 快速开始

### 1. 环境要求

- **JDK 17+**
- **Node.js 18+**
- **MySQL 8.0+**
- **Maven 3.8+**

### 2. 数据库配置

1. 创建数据库：
```sql
CREATE DATABASE nexusblog DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

2. 执行初始化脚本：
```bash
mysql -u root -p nexusblog < database/init.sql
```

3. 修改后端配置文件 `backend/src/main/resources/application.yml`：
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/nexusblog?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai
    username: your_username
    password: your_password
```

### 3. 后端启动

```bash
cd backend

# 使用 Maven 构建
mvn clean install

# 运行应用
mvn spring-boot:run

# 或者直接运行生成的 JAR 文件
java -jar target/nexusblog-1.0.0.jar
```

后端服务将在 http://localhost:8080 启动

API 文档：http://localhost:8080/api-docs
Swagger UI：http://localhost:8080/swagger-ui.html

### 4. 前端启动

```bash
cd frontend

# 安装依赖
npm install

# 开发模式运行
npm run dev

# 构建生产版本
npm run build
```

前端服务将在 http://localhost:3000 启动

### 5. 默认账号

| 角色 | 用户名 | 密码 |
|------|--------|------|
| 管理员 | admin | admin123 |
| 普通用户 | user | user123 |

## API 接口

### 认证接口
- `POST /api/auth/register` - 用户注册
- `POST /api/auth/login` - 用户登录
- `GET /api/auth/me` - 获取当前用户信息

### 文章接口
- `GET /api/articles` - 获取文章列表（支持分页、筛选）
- `GET /api/articles/{id}` - 获取文章详情
- `POST /api/articles` - 创建文章（需要登录）
- `PUT /api/articles/{id}` - 更新文章
- `DELETE /api/articles/{id}` - 删除文章
- `GET /api/articles/popular` - 获取热门文章
- `POST /api/articles/{id}/like` - 点赞文章

### 评论接口
- `GET /api/comments/article/{articleId}` - 获取文章评论
- `POST /api/comments` - 创建评论（需要登录）
- `DELETE /api/comments/{id}` - 删除评论

### 用户接口
- `GET /api/users/{id}` - 获取用户信息
- `PUT /api/users/profile` - 更新个人资料（需要登录）
- `GET /api/users/admin/all` - 获取所有用户（需要管理员权限）

### 管理接口
- `GET /api/admin/stats` - 获取统计信息
- `GET /api/admin/articles/pending` - 获取待审核文章
- `PUT /api/admin/articles/{id}/audit` - 审核文章
- `GET /api/admin/users` - 用户管理
- `PUT /api/admin/users/{id}/status` - 封禁/解封用户

## 数据库设计

### 用户表 (users)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 用户 ID |
| username | VARCHAR(50) | 用户名（唯一） |
| password | VARCHAR(255) | 密码（BCrypt 加密） |
| email | VARCHAR(100) | 邮箱（唯一） |
| role | ENUM | 角色（USER/ADMIN） |
| avatar | VARCHAR(255) | 头像 URL |
| status | INT | 状态（1: 正常, 0: 封禁） |
| created_at | DATETIME | 注册时间 |

### 文章表 (articles)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 文章 ID |
| title | VARCHAR(255) | 标题 |
| content | LONGTEXT | 内容（支持 Markdown） |
| summary | VARCHAR(500) | 摘要 |
| author_id | BIGINT | 作者 ID |
| category | VARCHAR(50) | 分类 |
| tags | VARCHAR(255) | 标签（逗号分隔） |
| views | INT | 浏览量 |
| likes | INT | 点赞数 |
| status | ENUM | 状态 |
| created_at | DATETIME | 创建时间 |
| updated_at | DATETIME | 更新时间 |

### 评论表 (comments)
| 字段 | 类型 | 说明 |
|------|------|------|
| id | BIGINT | 评论 ID |
| article_id | BIGINT | 所属文章 ID |
| user_id | BIGINT | 评论用户 ID |
| content | VARCHAR(1000) | 评论内容 |
| parent_id | BIGINT | 父评论 ID |
| status | INT | 状态 |
| created_at | DATETIME | 创建时间 |

## 安全特性

- **JWT 认证** - 使用 JSON Web Token 进行无状态认证
- **密码加密** - 使用 BCrypt 算法加密存储
- **SQL 注入防护** - 使用参数化查询
- **XSS 防护** - 前端内容转义
- **CORS 配置** - 跨域资源共享控制
- **权限控制** - 基于角色的访问控制（RBAC）

## License

MIT License
