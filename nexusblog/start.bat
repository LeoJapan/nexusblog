@echo
echo ============================================
echo   NexusBlog 一键启动脚本 (Windows)
echo ============================================
echo.

REM 检查 Docker 是否安装
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Docker，请先安装 Docker Desktop
    echo 下载地址: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo [1/5] 检查 Docker 服务状态...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker 服务未启动，请打开 Docker Desktop
    pause
    exit /b 1
)

REM 进入项目目录
cd /d "%~dp0"

echo [2/5] 停止旧容器（如果有）...
docker-compose down >nul 2>&1

echo [3/5] 构建并启动服务...
docker-compose up -d --build

if %errorlevel% neq 0 (
    echo [错误] 启动失败
    pause
    exit /b 1
)

echo.
echo ============================================
echo   启动成功！
echo ============================================
echo.
echo 前端页面: http://localhost:3000
echo 后端 API:  http://localhost:8080
echo API 文档:  http://localhost:3000/api-docs
echo Swagger:  http://localhost:3000/swagger-ui
echo.
echo 默认账号:
echo   管理员: admin / admin123
echo   普通用户: user / user123
echo.
echo 查看日志: docker-compose logs -f
echo 停止服务: docker-compose down
echo.
pause
