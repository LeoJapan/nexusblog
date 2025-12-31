#!/bin/bash

echo "============================================"
echo "  NexusBlog MySQL 启动脚本"
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
if [ -d "/workspaces/nexusblog" ]; then
    PROJECT_ROOT="/workspaces/nexusblog"
elif [ -d "/workspace/nexusblog" ]; then
    PROJECT_ROOT="/workspace/nexusblog"
else
    print_error "无法找到 nexusblog 项目目录"
    exit 1
fi

echo "检测到项目目录: $PROJECT_ROOT"
echo

# 检查是否是 root 用户
if [ "$EUID" -ne 0 ]; then
    SUDO="sudo"
else
    SUDO=""
fi

echo "开始配置环境..."
echo

# ============ 步骤 1: 拉取最新代码 ============
print_step "1/5 拉取最新代码..."

cd "$PROJECT_ROOT"

git fetch origin
git reset --hard origin/master
git clean -fd

print_success "已更新到最新代码"
echo

# ============ 步骤 2: 检查并安装 Java ============
print_step "2/5 检查 Java 版本..."

JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)

if [ "$JAVA_VERSION" -lt 17 ]; then
    print_warning "检测到 Java $JAVA_VERSION，需要升级到 Java 17..."
    
    rm -f /var/lib/apt/lists/lock 2>/dev/null
    rm -f /var/cache/apt/archives/lock 2>/dev/null
    rm -f /var/lib/dpkg/lock 2>/dev/null
    rm -f /var/lib/dpkg/lock-frontend 2>/dev/null
    
    $SUDO apt-get update -qq 2>&1 | grep -v "debconf: unable to initialize" || true
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq openjdk-17-jdk 2>&1 | grep -v "debconf: unable to initialize" || true
    
    export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
    export PATH=$JAVA_HOME/bin:$PATH
    
    print_success "Java 17 已安装"
else
    print_success "Java 版本兼容 (Java $JAVA_VERSION)"
fi

echo "当前 Java 版本: $(java -version 2>&1 | head -n 1)"
echo

# ============ 步骤 3: 安装和配置 MySQL ============
print_step "3/5 安装和配置 MySQL 数据库..."

# 检查 MySQL 是否已安装
if ! command -v mysql &> /dev/null; then
    print_warning "正在安装 MySQL..."
    
    # 清理锁
    rm -f /var/lib/apt/lists/lock 2>/dev/null
    rm -f /var/cache/apt/archives/lock 2>/dev/null
    rm -f /var/lib/dpkg/lock 2>/dev/null
    rm -f /var/lib/dpkg/lock-frontend 2>/dev/null
    
    # 安装 MySQL
    $SUDO DEBIAN_FRONTEND=noninteractive apt-get install -y -qq mysql-server 2>&1 | grep -v "debconf: unable to initialize" || true
    
    # 启动 MySQL 服务
    $SUDO service mysql start
    sleep 3
    
    print_success "MySQL 已安装并启动"
else
    # 确保 MySQL 正在运行
    $SUDO service mysql start 2>/dev/null || true
    sleep 2
    print_success "MySQL 服务已就绪"
fi

# 配置 MySQL 密码
$SUDO mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root123';" 2>/dev/null || true

# 创建数据库
$SUDO mysql -u root -proot123 -e "CREATE DATABASE IF NOT EXISTS nexusblog CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true

print_success "数据库已配置"
echo

# ============ 步骤 4: 导入初始数据 ============
print_step "4/5 导入初始数据..."

cd "$PROJECT_ROOT"

# 导入数据
if [ -f "database/init.sql" ]; then
    $SUDO mysql -u root -proot123 nexusblog < database/init.sql 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "数据库已初始化，包含测试用户 admin/admin123"
    else
        print_warning "数据库可能已存在，跳过导入"
    fi
else
    print_warning "找不到数据库初始化文件 database/init.sql"
fi
echo

# ============ 步骤 5: 构建并启动后端 ============
print_step "5/5 构建并启动后端..."

BACKEND_DIR="$PROJECT_ROOT/backend"

if [ ! -d "$BACKEND_DIR" ]; then
    print_error "找不到后端目录: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

echo "当前目录: $(pwd)"

# 构建（使用 MySQL profile）
mvn clean package -DskipTests -Dspring.profiles.active=mysql -q

if [ $? -eq 0 ]; then
    print_success "后端构建成功！"
else
    print_error "后端构建失败"
    mvn clean package -DskipTests -Dspring.profiles.active=mysql 2>&1 | tail -30
    exit 1
fi

echo
echo "============================================"
echo "  ✅ 环境配置完成！"
echo "============================================"
echo
echo "请选择启动方式："
echo
echo "1. 启动后端服务（使用 MySQL）"
echo "2. 只构建不启动"
echo "3. 退出"
echo
read -p "请输入选项 (1-3): " choice

case $choice in
    1)
        echo
        print_step "启动后端服务（端口 8080，使用 MySQL 数据库）..."
        cd "$BACKEND_DIR"
        export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
        export PATH=$JAVA_HOME/bin:$PATH
        
        java -jar target/nexusblog-1.0.0.jar --spring.profiles.active=mysql &
        BACKEND_PID=$!
        
        echo "后端正在启动...（需要约 1-2 分钟）"
        echo "后端 PID: $BACKEND_PID"
        
        # 等待 45 秒让后端启动
        sleep 45
        
        # 检查后端是否启动
        if curl -s http://localhost:8080/api-docs > /dev/null 2>&1; then
            print_success "后端服务已启动: http://localhost:8080"
        else
            print_warning "后端服务仍在启动中，请稍后访问 http://localhost:8080"
        fi
        
        echo
        echo "============================================"
        echo "  🎉 NexusBlog 已成功启动！"
        echo "============================================"
        echo
        echo "访问地址:"
        echo "  🔌 后端 API:  http://localhost:8080"
        echo "  📚 API 文档:  http://localhost:8080/api-docs"
        echo "  🔎 Swagger:   http://localhost:8080/swagger-ui.html"
        echo
        echo "数据库信息:"
        echo "  🗄️ 数据库: MySQL (nexusblog)"
        echo "  👤 用户名: root"
        echo "  🔑 密码: root123"
        echo
        echo "测试账号:"
        echo "  👤 管理员: admin / admin123"
        echo "  👤 普通用户: user / user123"
        echo
        echo "注意: 数据会持久化保存在 MySQL 中！"
        echo
        ;;
        
    2)
        echo
        print_step "构建完成，未启动服务。"
        echo "稍后可以使用以下命令启动："
        echo "  cd $BACKEND_DIR"
        echo "  java -jar target/nexusblog-1.0.0.jar --spring.profiles.active=mysql"
        ;;
        
    3)
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
