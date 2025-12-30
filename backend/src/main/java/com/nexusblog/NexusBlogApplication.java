package com.nexusblog;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * NexusBlog Application Entry Point
 * A full-stack blog system with user management, article publishing, and admin features.
 */
@SpringBootApplication
public class NexusBlogApplication {
    
    public static void main(String[] args) {
        SpringApplication.run(NexusBlogApplication.class, args);
        System.out.println("====================================");
        System.out.println("  NexusBlog System Started!");
        System.out.println("  API Docs: http://localhost:8080/api-docs");
        System.out.println("  Swagger UI: http://localhost:8080/swagger-ui.html");
        System.out.println("====================================");
    }
}
