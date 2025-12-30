package com.nexusblog.exception;

/**
 * Resource Not Found Exception - 资源未找到异常
 * Thrown when a requested resource (article, user, etc.) is not found.
 */
public class ResourceNotFoundException extends RuntimeException {
    
    public ResourceNotFoundException(String message) {
        super(message);
    }
    
    public ResourceNotFoundException(String resourceName, String fieldName, Object fieldValue) {
        super(String.format("%s not found with %s: '%s'", resourceName, fieldName, fieldValue));
    }
}
