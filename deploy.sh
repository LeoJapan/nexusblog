# NexusBlog 一键部署脚本
# 支持 H2（默认）和 MySQL 两种数据库模式

#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 默认配置
DB_TYPE=${1:-h2}  # 默认使用 H2 数据库
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
    echo -e "${BLUE}[步骤 $1/$2]${NC} $3"
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

# 检查必要的工具
check_dependencies() {
    print_header "检查环境依赖"
    
    local missing_tools=()
    
    # 检查 Java
    if ! command -v java &> /dev/null; then
        missing_tools+=("Java")
    else
        print_success "Java 已安装: $(java -version 2>&1 | head -1)"
    fi
    
    # 检查 Maven
    if ! command -v mvn &> /dev/null; then
        missing_tools+=("Maven")
    else
        print_success "Maven 已安装: $(mvn -version 2>&1 | head -1)"
    fi
    
    # 检查 Node.js
    if ! command -v node &> /dev/null; then
        missing_tools+=("Node.js")
    else
        print_success "Node.js 已安装: $(node -v)"
    fi
    
    # 检查 npm
    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    else
        print_success "npm 已安装: $(npm -v)"
    fi
    
    # 如果缺少工具，提示用户
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "缺少必要的工具: ${missing_tools[*]}"
        echo "请先安装这些工具后再运行此脚本。"
        exit 1
    fi
}

# 检查 Docker（可选）
check_docker() {
    if command -v docker &> /dev/null; then
        print_success "Docker 可用"
        docker --version | head -1
        return 0
    else
        print_warning "Docker 未安装，将跳过 MySQL 容器管理"
        return 1
    fi
}

# 停止已有服务
stop_services() {
    print_header "停止已有服务"
    
    # 停止后端服务
    print_step "1" "2" "停止后端服务..."
    local backend_pids=$(pgrep -f "nexusblog-backend.jar" 2>/dev/null || true)
    if [ -n "$backend_pids" ]; then
        echo "  找到后端进程: $backend_pids"
        kill $backend_pids 2>/dev/null || true
        sleep 2
        print_success "后端服务已停止"
    else
        echo "  没有运行的后端服务"
    fi
    
    # 停止前端服务
    print_step "2" "2" "停止前端服务..."
    local frontend_pids=$(pgrep -f "vite" 2>/dev/null || true)
    if [ -n "$frontend_pids" ]; then
        echo "  找到前端进程: $frontend_pids"
        kill $frontend_pids 2>/dev/null || true
        sleep 2
        print_success "前端服务已停止"
    else
        echo "  没有运行的前端服务"
    fi
    
    # 如果使用 MySQL 且 Docker 可用，询问是否停止容器
    if [ "$DB_TYPE" = "mysql" ] && check_docker; then
        print_info "MySQL 容器仍在运行中（如需停止，请手动执行: docker stop nexusblog-mysql）"
    fi
}

# 清理构建缓存
clean_cache() {
    print_header "清理构建缓存"
    
    print_step "1" "1" "清理 Maven 和前端缓存..."
    
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
        print_info "使用 H2 内存数据库（无需外部数据库）"
        print_info "数据将在服务重启时重置"
        
        # 复制 H2 初始化脚本
        if [ -f "../database/init-h2.sql" ]; then
            cp ../database/init-h2.sql src/main/resources/data.sql
            print_success "已复制 H2 初始化脚本"
        fi
        
        # 使用 H2 profile 启动
        SPRING_PROFILE="h2"
        
    elif [ "$DB_TYPE" = "mysql" ]; then
        print_info "配置 MySQL 数据库连接"
        echo "  主机: $MYSQL_HOST:$MYSQL_PORT"
        echo "  数据库: $MYSQL_DATABASE"
        echo "  用户: $MYSQL_USER"
        
        # 检查 Docker 是否可用
        if check_docker; then
            # 检查 MySQL 容器是否在运行
            if ! docker ps --format '{{.Names}}' | grep -q "nexusblog-mysql"; then
                print_warning "MySQL 容器未运行，尝试启动..."
                if docker start nexusblog-mysql 2>/dev/null; then
                    print_success "MySQL 容器已启动"
                    sleep 5
                else
                    print_error "无法启动 MySQL 容器，请手动启动"
                    print_info "运行命令: docker run -d --name nexusblog-mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root123 -e MYSQL_DATABASE=nexusblog mysql:8.0"
                fi
            else
                print_success "MySQL 容器已在运行"
            fi
            
            # 更新环境变量供 Java 应用使用
            export MYSQL_HOST=localhost
            export MYSQL_PORT=3306
        else
            print_warning "Docker 不可用，假设外部 MySQL 已就绪"
        fi
        
        # 复制 MySQL 初始化脚本
        if [ -f "../database/init.sql" ]; then
            cp ../database/init.sql src/main/resources/data.sql
            print_success "已复制 MySQL 初始化脚本"
        fi
        
        SPRING_PROFILE="mysql"
        
    else
        print_error "不支持的数据库类型: $DB_TYPE"
        print_info "支持的类型: h2, mysql"
        exit 1
    fi
    
    cd ..
    
    # 创建环境变量文件
    cat > backend/.env << EOF
MYSQL_HOST=$MYSQL_HOST
MYSQL_PORT=$MYSQL_PORT
MYSQL_DATABASE=$MYSQL_DATABASE
MYSQL_USER=$MYSQL_USER
MYSQL_PASSWORD=$MYSQL_PASSWORD
SPRING_PROFILES_ACTIVE=$SPRING_PROFILE
EOF
    
    print_success "数据库配置完成 (Profile: $SPRING_PROFILE)"
}

# 构建后端
build_backend() {
    print_header "构建后端服务"
    
    cd backend
    
    print_step "1" "1" "编译和打包后端..."
    
    # 使用指定 profile 构建
    if [ "$DB_TYPE" = "h2" ]; then
        mvn clean package -DskipTests -Dspring.profiles.active=h2 -q
    else
        mvn clean package -DskipTests -Dspring.profiles.active=mysql -q
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
    
    print_step "1" "1" "安装前端依赖..."
    
    # 检查是否需要安装依赖
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
    
    print_step "1" "1" "启动 Spring Boot 应用..."
    
    # 加载环境变量
    if [ -f .env ]; then
        export $(cat .env | xargs)
    fi
    
    # 使用 nohup 启动后端
    nohup java -jar target/nexusblog-backend.jar \
        --server.port=$BACKEND_PORT \
        --spring.profiles.active=$SPRING_PROFILES_ACTIVE \
        > ../backend.log 2>&1 &
    
    BACKEND_PID=$!
    
    # 等待服务启动
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
    
    print_step "1" "1" "启动 Vue 开发服务器..."
    
    # 使用 nohup 启动前端
    nohup npm run dev -- --host 0.0.0.0 --port $FRONTEND_PORT \
        > ../frontend.log 2>&1 &
    
    FRONTEND_PID=$!
    
    # 等待服务启动
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
    
    echo ""
    echo -e "${YELLOW}💡 提示:${NC}"
    echo "   • H2 模式数据不会持久化，重启服务后数据会重置"
    echo "   • 如需使用 MySQL，请运行: ./deploy.sh mysql"
    echo "   • 如需后台运行，请使用: nohup ./deploy.sh &"
}

# 主函数
main() {
    clear
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                                                    ║${NC}"
    echo -e "${CYAN}║          NexusBlog 一键部署脚本 v1.0               ║${NC}"
    echo -e "${CYAN}║                                                    ║${NC}"
    echo -e "${CYAN}║  支持 H2（默认）和 MySQL 数据库模式                ║${NC}"
    echo -e "${CYAN}║                                                    ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_info "数据库模式: $DB_TYPE"
    print_info "后端端口: $BACKEND_PORT"
    print_info "前端端口: $FRONTEND_PORT"
    echo ""
    
    # 执行部署步骤
    check_dependencies
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
            echo "环境变量:"
            echo "  MYSQL_HOST      MySQL 主机地址（默认: localhost）"
            echo "  MYSQL_PORT      MySQL 端口（默认: 3306）"
            echo "  MYSQL_DATABASE  数据库名称（默认: nexusblog）"
            echo "  MYSQL_USER      数据库用户（默认: root）"
            echo "  MYSQL_PASSWORD  数据库密码（默认: root123）"
            echo "  BACKEND_PORT    后端服务端口（默认: 8080）"
            echo "  FRONTEND_PORT   前端服务端口（默认: 8088）"
            echo ""
            echo "示例:"
            echo "  $0                    # 使用 H2 启动"
            echo "  $0 mysql              # 使用 MySQL 启动"
            echo "  MYSQL_PASSWORD=123456 $0 mysql  # 自定义密码"
            exit 0
            ;;
        *)
            print_error "未知参数: $1"
            echo "使用 $0 --查看帮助"
            exit 1
            ;;
    esac
done

# 运行主函数
main
