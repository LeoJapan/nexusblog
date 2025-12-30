#!/bin/bash

echo "============================================"
echo "  NexusBlog Codespace 一键启动脚本"
echo "============================================"
echo

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}[步骤]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[警告]${NC} $1"
}

# 检查是否在 Codespace 环境中
if [ -z "$CODESPACES" ]; then
    print_warning "检测到可能不在 Codespace 环境中，但仍将继续..."
fi

echo "开始安装和配置 NexusBlog..."
echo

# ============ 步骤 1: 安装 MySQL ============
print_step "1/4 安装和配置 MySQL 数据库..."

# 安装 MySQL
sudo apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mysql-server > /dev/null 2>&1

# 启动 MySQL 服务
sudo service mysql start
sleep 2

# 配置密码
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';" 2>/dev/null

# 创建数据库
mysql -u root -proot123 -e "CREATE DATABASE IF NOT EXISTS nexusblog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null

print_success "MySQL 数据库已安装并启动"

# ============ 步骤 2: 导入数据库 ============
print_step "2/4 导入初始数据..."

cd /workspace/nexusblog
mysql -u root -proot123 nexusblog < database/init.sql 2>/dev/null

if [ $? -eq 0 ]; then
    print_success "数据库已初始化"
else
    print_warning "数据库可能已经初始化，跳过导入"
fi

# ============ 步骤 3: 构建后端 ============
print_step "3/4 构建后端 Spring Boot 项目..."

cd /workspace/nexusblog/backend
mvn clean package -DskipTests -q

if [ $? -eq 0 ]; then
    print_success "后端构建成功"
else
    print_warning "后端构建遇到问题，尝试继续..."
fi

# ============ 步骤 4: 安装前端依赖 ============
print_step "4/4 安装前端依赖..."

cd /workspace/nexusblog/frontend
npm install > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "前端依赖安装成功"
else
    print_warning "前端依赖安装遇到问题"
fi

echo
echo "============================================"
echo "  安装完成！准备启动服务..."
echo "============================================"
echo

# 询问用户是否启动服务
read -p "是否立即启动后端和前端服务？(y/n): " choice

if [ "$choice" = "y" ] || [ "$choice" = "Y" ]; then
    echo
    
    # 启动后端
    print_step "启动后端服务（端口 8080）..."
    cd /workspace/nexusblog/backend
    mvn spring-boot:run &
    BACKEND_PID=$!
    
    echo "后端正在启动...（需要约 1-2 分钟）"
    
    # 等待后端启动
    sleep 30
    
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
    echo "  NexusBlog 已成功启动！"
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
    echo "  # 启动后端"
    echo "  cd /workspace/nexusblog/backend"
    echo "  mvn spring-boot:run"
    echo
    echo "  # 启动前端（新终端）"
    echo "  cd /workspace/nexusblog/frontend"
    echo "  npm run dev"
    echo
fi
