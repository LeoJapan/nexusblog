#!/bin/bash

echo "============================================"
echo "  NexusBlog 一键启动脚本 (Linux/Mac)"
echo "============================================"
echo

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "[错误] 未检测到 Docker，请先安装 Docker"
    echo "macOS: brew install --cask docker"
    echo "Ubuntu: sudo apt-get install docker.io"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "[错误] 未检测到 Docker Compose"
    exit 1
fi

# 检查 Docker 服务状态
if ! docker info &> /dev/null; then
    echo "[错误] Docker 服务未启动，请启动 Docker Desktop"
    exit 1
fi

# 进入项目目录
cd "$(dirname "$0")"

echo "[1/5] 停止旧容器（如果有）..."
docker-compose down 2>/dev/null

echo "[2/5] 构建并启动服务..."
docker-compose up -d --build

if [ $? -ne 0 ]; then
    echo "[错误] 启动失败"
    exit 1
fi

echo
echo "============================================"
echo "  启动成功！"
echo "============================================"
echo
echo "前端页面: http://localhost:3000"
echo "后端 API:  http://localhost:8080"
echo "API 文档:  http://localhost:3000/api-docs"
echo "Swagger:  http://localhost:3000/swagger-ui"
echo
echo "默认账号:"
echo "  管理员: admin / admin123"
echo "  普通用户: user / user123"
echo
echo "查看日志: docker-compose logs -f"
echo "停止服务: docker-compose down"
echo
