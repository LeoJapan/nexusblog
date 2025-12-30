#!/bin/bash

echo "============================================"
echo "  NexusBlog 极简启动脚本 (无需安装 JDK/MySQL)"
echo "============================================"
echo

# 检查 Java
if ! command -v java &> /dev/null; then
    echo "[错误] 未检测到 Java，请先安装 JDK 17"
    echo "Ubuntu: sudo apt install openjdk-17-jdk"
    echo "macOS: brew install openjdk@17"
    exit 1
fi

echo "[✓] Java 已安装 ($(java -version 2>&1 | head -n 1))"

# 检查 Maven
if ! command -v mvn &> /dev/null; then
    echo "[错误] 未检测到 Maven，请先安装 Maven"
    echo "Ubuntu: sudo apt install maven"
    echo "macOS: brew install maven"
    exit 1
fi

echo "[✓] Maven 已安装"

cd "$(dirname "$0")/backend"

echo "[1/3] 构建后端项目..."
mvn clean package -DskipTests -q

if [ $? -ne 0 ]; then
    echo "[错误] 构建失败"
    exit 1
fi

echo "[✓] 构建成功"

echo "[2/3] 启动后端服务（使用 H2 内存数据库）..."
echo "后端将在 http://localhost:8080 启动"

mvn spring-boot:run -Dspring-boot.run.profiles=h2 > ../backend.log 2>&1 &
BACKEND_PID=$!

echo "[3/3] 等待服务启动中..."
sleep 15

# 检查服务是否启动
if curl -s http://localhost:8080/api/auth/me > /dev/null 2>&1; then
    echo "[✓] 后端服务启动成功！"
else
    echo "[警告] 后端服务可能还在启动中，请稍后访问 http://localhost:8080"
fi

echo
echo "============================================"
echo "  后端服务已启动！"
echo "============================================"
echo
echo "访问地址:"
echo "  - 后端 API:  http://localhost:8080"
echo "  - API 文档:  http://localhost:8080/api-docs"
echo "  - Swagger:   http://localhost:8080/swagger-ui.html"
echo "  - H2 数据库: http://localhost:8080/h2-console"
echo
echo "默认账号:"
echo "  - 管理员: admin / admin123"
echo "  - 普通用户: user / user123"
echo
echo "下一步启动前端:"
echo "  cd ../frontend"
echo "  npm install"
echo "  npm run dev"
echo
echo "查看日志: tail -f ../backend.log"
echo "停止服务: kill $BACKEND_PID"
echo
