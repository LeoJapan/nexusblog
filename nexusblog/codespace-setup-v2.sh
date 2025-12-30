#!/bin/bash

echo "============================================"
echo "  NexusBlog Codespace 一键启动脚本 (修正版)"
echo "============================================"
echo

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

print_step() {
    echo -e "${BLUE}[步骤]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

echo "开始检测和配置环境..."
echo

# ============ 步骤 1: 检查并升级 Java ============
print_step "1/5 检查 Java 版本..."

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)

if [ "$JAVA_VERSION" -lt 17 ]; then
    print_warning "检测到 Java $JAVA_VERSION，需要升级到 Java 17..."
    
    # 安装 Java 17
    apt-get update -qq
    apt-get install -y -qq openjdk-17-jdk > /dev/null 2>&1
    
    # 设置 Java 17 为默认
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    
    print_success "Java 17 已安装"
else
    print_success "Java 版本兼容 (Java $JAVA_VERSION)"
fi

echo "Java 版本: $(java -version 2>&1 | head -n 1)"
echo

# ============ 步骤 2: 安装 MySQL ============
print_step "2/5 安装和配置 MySQL 数据库..."

# 检查 MySQL 是否已安装
if ! command -v mysql &> /dev/null; then
    # 安装 MySQL
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mysql-server > /dev/null 2>&1
    
    # 启动服务
    service mysql start
    sleep 2
    print_success "MySQL 已安装并启动"
else
    # 确保 MySQL 正在运行
    service mysql start 2>/dev/null || true
    print_success "MySQL 服务已就绪"
fi

# 配置密码
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';" 2>/dev/null || true

# 创建数据库
mysql -u root -proot123 -e "CREATE DATABASE IF NOT EXISTS nexusblog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true

print_success "数据库已配置"
echo

# ============ 步骤 3: 导入数据库 ============
print_step "3/5 导入初始数据..."

cd /workspace/nexusblog
mysql -u root -proot123 nexusblog < database/init.sql 2>/dev/null

if [ $? -eq 0 ]; then
    print_success "数据库已初始化"
else
    print_warning "数据库可能已存在，跳过导入"
fi
echo

# ============ 步骤 4: 构建后端 ============
print_step "4/5 构建后端 Spring Boot 项目..."

cd /workspace/nexusblog/backend

# 确保使用 Java 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

mvn clean package -DskipTests -q

if [ $? -eq 0 ]; then
    print_success "后端构建成功"
else
    print_error "后端构建失败，请检查错误信息"
    exit 1
fi
echo

# ============ 步骤 5: 安装前端依赖 ============
print_step "5/5 安装前端依赖..."

cd /workspace/nexusblog/frontend
npm install > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "前端依赖安装成功"
else
    print_warning "前端依赖安装遇到问题，但继续尝试启动"
fi

echo
echo "============================================"
echo "  环境配置完成！准备启动服务..."
echo "============================================"
echo

# 询问用户是否启动服务
read -p "是否立即启动后端和前端服务？(y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo
    
    # 启动后端
    print_step "启动后端服务（端口 8080）..."
    cd /workspace/nexusblog/backend
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    mvn spring-boot:run &
    BACKEND_PID=$!
    
    echo "后端正在启动...（需要约 1-2 分钟）"
    
    # 等待后端启动
    sleep 40
    
    # 检查后端是否启动
    if curl -s http://localhost:8080/api/auth/me > /dev/null 2>&1; then
        print_success "后端服务已启动: http://localhost:8080"
    else
        print_warning "后端服务仍在启动中，请稍后访问 http://localhost:8080"
    fi
    
    # 启动前端
    echo
    print_step "启动前端服务（端口 3000）..."
    cd /workspace/nexusblog/frontend
    npm run dev -- --host 0.0.0.0 &
    FRONTEND_PID=$!
    
    sleep 5
    
    print_success "前端服务已启动: http://localhost:3000"
    
    echo
    echo "============================================"
    echo "  🎉 NexusBlog 已成功启动！"
    echo "============================================"
    echo
    echo "访问地址:"
    echo "  🌐 前端页面: http://localhost:3000"
    echo "  🔌 后端 API:  http://localhost:8080"
    echo "  📚 API 文档:  http://localhost:8080/api-docs"
    echo "  🔎 Swagger:   http://localhost:8080/swagger-ui.html"
    echo
    echo "测试账号:"
    echo "  👤 管理员: admin / admin123"
    echo "  👤 普通用户: user / user123"
    echo
    echo "后台进程 PID:"
    echo "  后端: $BACKEND_PID"
    echo "  前端: $FRONTEND_PID"
    echo
    echo "停止服务命令:"
    echo "  kill $BACKEND_PID $FRONTEND_PID"
    echo
    
else
    echo
    echo "安装完成，稍后可以使用以下命令启动服务："
    echo
    echo "  # 设置 Java 17"
    echo "  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
    echo "  export PATH=\$JAVA_HOME/bin:\$PATH"
    echo
    echo "  # 启动后端"
    echo "  cd /workspace/nexusblog/backend"
    echo "  mvn spring-boot:run"
    echo
    echo "  # 启动前端（新终端）"
    echo "  cd /workspace/nexusblog/frontend"
    echo "  npm run dev"
    echo
fi
