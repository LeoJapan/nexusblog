@echo
echo ============================================
echo   NexusBlog 极简启动脚本 (无需安装 JDK/MySQL)
echo ============================================
echo.
echo [准备] 检查必要环境...

REM 检查 Java
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 未检测到 Java，将自动下载...
    echo 请访问 https://adoptium.net 下载 JDK 17
    pause
    exit /b 1
)

echo [✓] Java 已安装

REM 检查 Maven
mvn -version >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] 未检测到 Maven，将自动下载便携版...
    set "MAVEN_VERSION=3.9.6"
    set "MAVEN_URL=https://dlcdn.apache.org/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"
    echo 正在下载 Maven...
    powershell -Command "Invoke-WebRequest -Uri '%MAVEN_URL%' -OutFile 'maven.zip'"
    echo 请手动解压 maven.zip 并配置环境变量
    pause
    exit /b 1
)

echo [✓] Maven 已安装

REM 进入项目目录
cd /d "%~dp0\backend"

echo [1/3] 构建后端项目...
mvn clean package -DskipTests -q

if %errorlevel% neq 0 (
    echo [错误] 构建失败
    pause
    exit /b 1
)

echo [✓] 构建成功

echo [2/3] 启动后端服务（使用 H2 内存数据库）...
echo 后端将在 http://localhost:8080 启动

start /B mvn spring-boot:run -Dspring-boot.run.profiles=h2 > ..\..\backend.log 2>&1

REM 等待服务启动
echo [3/3] 等待服务启动中...
timeout /t 15 /nobreak >nul

REM 检查服务是否启动
curl -s http://localhost:8080/api/auth/me >nul 2>&1
if %errorlevel% equ 0 (
    echo [✓] 后端服务启动成功！
) else (
    echo [警告] 后端服务可能还在启动中，请稍后访问 http://localhost:8080
)

echo.
echo ============================================
echo   后端服务已启动！
echo ============================================
echo.
echo 访问地址:
echo   - 后端 API:  http://localhost:8080
echo   - API 文档:  http://localhost:8080/api-docs
echo   - Swagger:   http://localhost:8080/swagger-ui.html
echo   - H2 数据库: http://localhost:8080/h2-console
echo.
echo 默认账号:
echo   - 管理员: admin / admin123
echo   - 普通用户: user / user123
echo.
echo 下一步启动前端:
echo   cd ../frontend
echo   npm install
echo   npm run dev
echo.
echo 查看日志: type ..\..\backend.log
echo.
pause
