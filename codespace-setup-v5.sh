#!/bin/bash

echo "============================================"
echo "  NexusBlog Codespace 启动脚本 (v5 H2版)"
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

# 自动检测项目根目录
if [ -d "/workspace/nexusblog" ]; then
    PROJECT_ROOT="/workspace/nexusblog"
elif [ -d "/workspaces/nexusblog" ]; then
    PROJECT_ROOT="/workspaces/nexusblog"
elif [ -d "$HOME/nexusblog" ]; then
    PROJECT_ROOT="$HOME/nexusblog"
else
    CURRENT_DIR=$(pwd)
    if [ -d "$CURRENT_DIR/backend" ]; then
        PROJECT_ROOT="$CURRENT_DIR"
    else
        print_error "无法找到项目目录！请确保在 nexusblog 目录下运行此脚本"
        exit 1
    fi
fi

echo "检测到项目目录: $PROJECT_ROOT"

# 检查是否是 root 用户
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo
echo "开始配置环境..."
echo

# ============ 步骤 1: 检查并升级 Java ============
print_step "1/4 检查 Java 版本..."

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)

if [ "$JAVA_VERSION" -lt 17 ]; then
    print_warning "检测到 Java $JAVA_VERSION，需要升级到 Java 17..."
    
    # 清理 apt 锁
    rm -f /var/lib/apt/lists/lock 2>/dev/null
    rm -f /var/cache/apt/archives/lock 2>/dev/null
    rm -f /var/lib/dpkg/lock 2>/dev/null
    rm -f /var/lib/dpkg/lock-frontend 2>/dev/null
    
    # 安装 Java 17
    $SUDO apt-get update -qq 2>&1 | grep -v "debconf: unable to initialize" || true
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openjdk-17-jdk 2>&1 | grep -v "debconf: unable to initialize" || true
    
    # 设置 Java 17
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    
    print_success "Java 17 已安装"
else
    print_success "Java 版本兼容 (Java $JAVA_VERSION)"
fi

echo "当前 Java 版本: $(java -version 2>&1 | head -n 1)"
echo

# ============ 步骤 2: 构建后端 (使用 H2 数据库) ============
print_step "2/4 构建后端 Spring Boot 项目..."

BACKEND_DIR="$PROJECT_ROOT/backend"

if [ ! -d "$BACKEND_DIR" ]; then
    print_error "找不到后端目录: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

# 确保使用 Java 17
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "当前目录: $(pwd)"
echo "Java Home: $JAVA_HOME"

# 使用 H2 profile 构建并运行
mvn clean package -DskipTests -Dspring.profiles.active=h2 -q

if [ $? -eq 0 ]; then
    print_success "后端构建成功"
else
    print_error "后端构建失败"
    echo "尝试显示详细错误..."
    mvn clean package -DskipTests -Dspring.profiles.active=h2 2>&1 | tail -30
    exit 1
fi
echo

# ============ 步骤 3: 安装前端依赖 ============
print_step "3/4 安装前端依赖..."

FRONTEND_DIR="$PROJECT_ROOT/frontend"

if [ ! -d "$FRONTEND_DIR" ]; then
    print_error "找不到前端目录: $FRONTEND_DIR"
    exit 1
fi

cd "$FRONTEND_DIR"

npm install > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "前端依赖安装成功"
else
    print_warning "前端依赖安装遇到问题，但继续尝试"
fi

echo

# ============ 步骤 4: 启动服务 ============
print_step "4/4 启动服务..."

echo
echo "============================================"
echo "  ✅ 环境配置完成！"
echo "============================================"
echo
echo "请选择启动方式："
echo
echo "1. 启动所有服务（后端 + 前端）"
echo "2. 只启动后端"
echo "3. 只启动前端"
echo "4. 退出"
echo
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo
        # 启动后端 (使用 H2)
        print_step "启动后端服务（端口 8080，使用 H2 数据库）..."
        cd "$BACKEND_DIR"
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
        export PATH=$JAVA_HOME/bin:$PATH
        java -jar target/nexusblog-1.0.0.jar --spring.profiles.active=h2 &
        BACKEND_PID=$!
        
        echo "后端正在启动...（需要约 1-2 分钟）"
        echo "后端 PID: $BACKEND_PID"
        
        # 等待后端启动
        sleep 45
        
        # 检查后端是否启动
        if curl -s http://localhost:8080/api-docs > /dev/null 2>&1; then
            print_success "后端服务已启动: http://localhost:8080"
        else
            print_warning "后端服务仍在启动中，请稍后访问 http://localhost:8080"
        fi
        
        # 启动前端
        echo
        print_step "启动前端服务（端口 3000）..."
        cd "$FRONTEND_DIR"
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
        echo "  🗄️ H2 控制台: http://localhost:8080/h2-console"
        echo
        echo "测试账号:"
        echo "  👤 管理员: admin / admin123"
        echo "  👤 普通用户: user / user123"
        echo
        echo "注意: 使用 H2 内存数据库，数据不会持久化"
        echo
        ;;
        
    2)
        echo
        print_step "启动后端服务（使用 H2 数据库）..."
        cd "$BACKEND_DIR"
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
        export PATH=$JAVA_HOME/bin:$PATH
        java -jar target/nexusblog-1.0.0.jar --spring.profiles.active=h2
        ;;
        
    3)
        echo
        print_step "启动前端服务..."
        cd "$FRONTEND_DIR"
        npm run dev -- --host 0.0.0.0
        ;;
        
    4)
        echo
        echo "再见！需要启动时再次运行此脚本。"
        exit 0
        ;;
        
    *)
        echo
        print_error "无效选项"
        exit 1
        ;;
esac
