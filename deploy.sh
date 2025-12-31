#!/bin/bash

# NexusBlog 一键部署脚本 - 增强版
# 支持自动安装 Java 17 和管理 MySQL 容器

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 默认配置
DB_TYPE=${1:-h2}
MYSQL_HOST=${MYSQL_HOST:-localhost}
MYSQL_PORT=${MYSQL_PORT:-3306}
MYSQL_DATABASE=${MYSQL_DATABASE:-nexusblog}
MYSQL_USER=${MYSQL_USER:-root}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-root123}
BACKEND_PORT=${BACKEND_PORT:-8080}
FRONTEND_PORT=${FRONTEND_PORT:-8088}

# 打印函数
print_header() {
    echo -e "\n${CYAN}=========================================$NC"
    echo -e "${CYAN}  $1$NC"
    echo -e "${CYAN}=========================================$NC\n"
}

print_step() {
    echo -e "${BLUE}[步骤 $1]${NC} $2"
}

print_success() {
    echo -e "${GREEN}✓ 成功:${NC} $1"
}

print_error() {
    echo -e "${RED}✗ 错误:${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠ 警告:${NC} $1"
}

print_info() {
    echo -e "${CYAN}ℹ 信息:${NC} $1"
}

# 安装 Java 17
install_java17() {
    print_header "安装 Java 17"
    
    print_step "1" "检查当前 Java 版本..."
    local current_java=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1)
    
    if [ "$current_java" -ge 17 ]; then
        print_success "Java 版本已经是 17 或更高: $(java -version 2>&1 | head -1)"
        return 0
    fi
    
    print_warning "当前 Java 版本: $current_java，需要升级到 Java 17"
    
    print_step "2" "安装 Java 17..."
    
    # 检查是否为 root 用户
    if [ "$EUID" -ne 0 ]; then
        print_info "尝试使用 sudo 安装..."
        sudo apt-get update -qq
        sudo apt-get install -y -qq openjdk-17-jdk
    else
        apt-get update -qq
        apt-get install -y -qq openjdk-17-jdk
    fi
    
    if [ $? -eq 0 ]; then
        print_success "Java 17 安装成功"
    else
        print_error "Java 17 安装失败，请手动安装"
        return 1
    fi
    
    print_step "3" "配置 Java 17..."
    
    # 查找 Java 17 安装位置
    local java17_path=$(update-alternatives --list java 2>/dev/null | grep "java-17" | head -1 || true)
    
    if [ -z "$java17_path" ]; then
        java17_path=$(find /usr/lib/jvm -name "java-17*" -type d 2>/dev/null | head -1)/bin/java
    fi
    
    if [ -f "$java17_path" ]; then
        export JAVA_HOME=$(dirname $(dirname $java17_path))
        export PATH=$JAVA_HOME/bin:$PATH
        print_success "JAVA_HOME 设置为: $JAVA_HOME"
    else
        # 尝试查找
        java17_path=$(which java)
        print_warning "使用系统默认 Java: $java17_path"
    fi
    
    print_info "Java 版本: $(java -version 2>&1 | head -1)"
}

# 检查 Docker
check_docker() {
    if command -v docker &> /dev/null; then
        print_success "Docker 已安装: $(docker --version | head -1)"
        return 0
    else
        print_warning "Docker 未安装"
        return 1
    fi
}

# 管理 MySQL 容器
manage_mysql_container() {
    print_header "管理 MySQL 容器"
    
    # 检查容器是否存在
    if docker ps -a --format '{{.Names}}' | grep -q "nexusblog-mysql"; then
        print_info "MySQL 容器已存在"
        
        # 检查是否在运行
        if docker ps --format '{{.Names}}' | grep -q "nexusblog-mysql"; then
            print_success "MySQL 容器已在运行"
            return 0
        else
            print_warning "MySQL 容器已存在但未运行，尝试启动..."
            docker start nexusblog-mysql
            if [ $? -eq 0 ]; then
                print_success "MySQL 容器已启动"
                sleep 10
                return 0
            else
                print_error "无法启动容器，尝试删除后重新创建..."
                docker rm -f nexusblog-mysql
            fi
        fi
    fi
    
    # 检查端口 3306 是否被占用
    if docker ps --format '{{.Ports}}' | grep -q "3306->3306"; then
        print_warning "端口 3306 已被其他容器占用"
        print_info "假设外部 MySQL 服务已就绪，跳过容器创建"
        return 0
    fi
    
    # 创建新的 MySQL 容器
    print_step "1" "创建 MySQL 容器..."
    
    docker run -d \
        --name nexusblog-mysql \
        -p 3306:3306 \
        -e MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD \
        -e MYSQL_DATABASE=$MYSQL_DATABASE \
        -e MYSQL_USER=$MYSQL_USER \
        -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
        -v mysql_data:/var/lib/mysql \
        mysql:8.0 \
        --character-set-server=utf8mb4 \
        --collation-server=utf8mb4_unicode_ci \
        --default-authentication-plugin=mysql_native_password
    
    if [ $? -ne 0 ]; then
        print_error "无法创建 MySQL 容器"
        print_info "请手动执行以下命令:"
        echo "docker run -d --name nexusblog-mysql -p 3306:3306 \
-e MYSQL_ROOT_PASSWORD=$MYSQL_PASSWORD \
-e MYSQL_DATABASE=$MYSQL_DATABASE \
mysql:8.0"
        return 1
    fi
    
    print_success "MySQL 容器创建成功"
    
    # 等待 MySQL 启动
    print_step "2" "等待 MySQL 启动（最多 60 秒）..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker exec nexusblog-mysql mysqladmin ping -h localhost -u root -p$MYSQL_PASSWORD &> /dev/null; then
            print_success "MySQL 已就绪"
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
        echo -n "."
    done
    
    echo ""
    print_warning "MySQL 启动超时，但将继续..."
}

# 停止已有服务
stop_services() {
    print_header "停止已有服务"
    
    print_step "1" "停止后端服务..."
    local backend_pids=$(pgrep -f "nexusblog-backend.jar" 2>/dev/null || true)
    if [ -n "$backend_pids" ]; then
        echo "  找到后端进程: $backend_pids"
        kill $backend_pids 2>/dev/null || true
        sleep 2
        print_success "后端服务已停止"
    else
        echo "  没有运行的后端服务"
    fi
    
    print_step "2" "停止前端服务..."
    local frontend_pids=$(pgrep -f "vite" 2>/dev/null || true)
    if [ -n "$frontend_pids" ]; then
        echo "  找到前端进程: $frontend_pids"
        kill $frontend_pids 2>/dev/null || true
        sleep 2
        print_success "前端服务已停止"
    else
        echo "  没有运行的前端服务"
    fi
}

# 清理构建缓存
clean_cache() {
    print_header "清理构建缓存"
    
    print_step "1" "清理 Maven 和前端缓存..."
    
    cd backend
    mvn clean -q
    print_success "Maven 缓存已清理"
    
    cd ../frontend
    rm -rf node_modules/.vite 2>/dev/null || true
    print_success "前端构建缓存已清理"
    
    cd ..
}

# 配置数据库
configure_database() {
    print_header "配置数据库 (模式: $DB_TYPE)"
    
    cd backend
    
    if [ "$DB_TYPE" = "h2" ]; then
        print_info "使用 H2 内存数据库"
        
        if [ -f "../database/init-h2.sql" ]; then
            cp ../database/init-h2.sql src/main/resources/data.sql
            print_success "已复制 H2 初始化脚本"
        fi
        
        SPRING_PROFILE="h2"
        
    else
        print_info "使用 MySQL 数据库"
        print_info "连接: $MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE"
        
        if [ -f "../database/init.sql" ]; then
            cp ../database/init.sql src/main/resources/data.sql
            print_success "已复制 MySQL 初始化脚本"
        fi
        
        SPRING_PROFILE="mysql"
    fi
    
    cd ..
    print_success "数据库配置完成 (Profile: $SPRING_PROFILE)"
}

# 构建后端
build_backend() {
    print_header "构建后端服务"
    
    # 确保使用 Java 17
    if ! java -version 2>&1 | grep -q "version \"1[789]"; then
        if [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
            export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
            export PATH=$JAVA_HOME/bin:$PATH
            print_info "使用 Java 17: $JAVA_HOME"
        fi
    fi
    
    print_step "1" "编译和打包后端..."
    
    cd backend
    
    if [ "$DB_TYPE" = "h2" ]; then
        mvn clean package -DskipTests -Dspring.profiles.active=h2
    else
        mvn clean package -DskipTests -Dspring.profiles.active=mysql
    fi
    
    if [ $? -eq 0 ]; then
        print_success "后端构建成功"
    else
        print_error "后端构建失败"
        exit 1
    fi
    
    cd ..
}

# 构建前端
build_frontend() {
    print_header "构建前端服务"
    
    cd frontend
    
    print_step "1" "安装前端依赖..."
    
    if [ ! -d "node_modules" ]; then
        print_info "首次运行，正在安装依赖..."
        npm install
    else
        print_info "依赖已存在，跳过安装"
    fi
    
    if [ $? -eq 0 ]; then
        print_success "前端依赖安装成功"
    else
        print_error "前端依赖安装失败"
        exit 1
    fi
    
    cd ..
}

# 启动后端服务
start_backend() {
    print_header "启动后端服务"
    
    cd backend
    
    print_step "1" "启动 Spring Boot 应用..."
    
    # 确保使用 Java 17
    if ! java -version 2>&1 | grep -q "version \"1[789]"; then
        if [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
            export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
            export PATH=$JAVA_HOME/bin:$PATH
        fi
    fi
    
    nohup java -jar target/nexusblog-backend.jar \
        --server.port=$BACKEND_PORT \
        --spring.profiles.active=$SPRING_PROFILE \
        > ../backend.log 2>&1 &
    
    BACKEND_PID=$!
    
    print_info "等待后端服务启动..."
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:$BACKEND_PORT/api/health > /dev/null 2>&1; then
            print_success "后端服务已启动 (PID: $BACKEND_PID)"
            echo $BACKEND_PID > ../backend.pid
            cd ..
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
        echo -n "."
    done
    
    echo ""
    print_warning "后端服务启动超时，请检查 backend.log 日志"
    cd ..
    return 1
}

# 启动前端服务
start_frontend() {
    print_header "启动前端服务"
    
    cd frontend
    
    print_step "1" "启动 Vue 开发服务器..."
    
    nohup npm run dev -- --host 0.0.0.0 --port $FRONTEND_PORT \
        > ../frontend.log 2>&1 &
    
    FRONTEND_PID=$!
    
    print_info "等待前端服务启动..."
    local max_attempts=20
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:$FRONTEND_PORT > /dev/null 2>&1; then
            print_success "前端服务已启动 (PID: $FRONTEND_PID)"
            echo $FRONTEND_PID > ../frontend.pid
            cd ..
            return 0
        fi
        sleep 2
        attempt=$((attempt + 1))
        echo -n "."
    done
    
    echo ""
    print_warning "前端服务启动超时，请检查 frontend.log 日志"
    cd ..
    return 1
}

# 显示启动信息
show_info() {
    print_header "部署完成！"
    
    echo -e "${GREEN}✓ NexusBlog 已成功启动！${NC}\n"
    
    echo -e "${CYAN}📊 数据库模式:${NC} $DB_TYPE"
    
    if [ "$DB_TYPE" = "mysql" ]; then
        echo -e "${CYAN}🗄  MySQL 连接:${NC} $MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE"
    fi
    
    echo ""
    echo -e "${CYAN}🌐 服务访问地址:${NC}"
    echo "   • 前端页面: http://localhost:$FRONTEND_PORT"
    echo "   • 后端 API: http://localhost:$BACKEND_PORT"
    echo "   • API 文档: http://localhost:$BACKEND_PORT/api-docs"
    
    echo ""
    echo -e "${CYAN}🔐 测试账号:${NC}"
    echo "   • 管理员: admin / admin123"
    echo "   • 普通用户: user / user123"
    
    echo ""
    echo -e "${CYAN}📝 日志文件:${NC}"
    echo "   • 后端日志: backend.log"
    echo "   • 前端日志: frontend.log"
    
    echo ""
    echo -e "${CYAN}🛑 停止服务命令:${NC}"
    echo "   kill \$(cat backend.pid) \$(cat frontend.pid)"
}

# 主函数
main() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                    ║${NC}"
    echo -e "${CYAN}║          NexusBlog 一键部署脚本 v2.0               ║${NC}"
    echo -e "${CYAN}║                                                    ║${NC}"
    echo -e "${CYAN}║  支持自动安装 Java 17 和管理 MySQL 容器           ║${NC}"
    echo -e "${CYAN}║                                                    ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "数据库模式: $DB_TYPE"
    print_info "后端端口: $BACKEND_PORT"
    print_info "前端端口: $FRONTEND_PORT"
    echo ""
    
    # 执行部署步骤
    if [ "$DB_TYPE" = "mysql" ]; then
        install_java17
        check_docker
        manage_mysql_container
    fi
    
    stop_services
    clean_cache
    configure_database
    build_backend
    build_frontend
    start_backend
    start_frontend
    show_info
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    case $1 in
        h2)
            DB_TYPE="h2"
            shift
            ;;
        mysql)
            DB_TYPE="mysql"
            shift
            ;;
        -h|--help)
            echo "用法: $0 [数据库类型] [选项]"
            echo ""
            echo "数据库类型:"
            echo "  h2      使用 H2 内存数据库（默认）"
            echo "  mysql   使用 MySQL 数据库"
            echo ""
            echo "示例:"
            echo "  $0                    # 使用 H2 启动"
            echo "  $0 mysql              # 使用 MySQL 启动"
            exit 0
            ;;
        *)
            print_error "未知参数: $1"
            exit 1
            ;;
    esac
done

main
