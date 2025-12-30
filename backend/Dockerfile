# 后端 Dockerfile - Spring Boot
FROM eclipse-temurin:17-jdk-alpine

WORKDIR /app

# 设置时区
RUN apk add --no-cache tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 复制并解压 jar 文件
COPY target/nexusblog-1.0.0.jar app.jar

# 暴露端口
EXPOSE 8080

# 启动命令
ENTRYPOINT ["java", "-jar", "-Dspring.profiles.active=prod", "app.jar"]
