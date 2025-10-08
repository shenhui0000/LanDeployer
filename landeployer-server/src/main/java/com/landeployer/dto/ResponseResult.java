package com.landeployer.dto;

import lombok.Data;

/**
 * 统一响应结果
 */
@Data
public class ResponseResult<T> {
    
    private Integer code;
    private String message;
    private T data;
    private Long timestamp;
    
    public ResponseResult() {
        this.timestamp = System.currentTimeMillis();
    }
    
    public ResponseResult(Integer code, String message, T data) {
        this.code = code;
        this.message = message;
        this.data = data;
        this.timestamp = System.currentTimeMillis();
    }
    
    public static <T> ResponseResult<T> success() {
        return new ResponseResult<>(200, "操作成功", null);
    }
    
    public static <T> ResponseResult<T> success(T data) {
        return new ResponseResult<>(200, "操作成功", data);
    }
    
    public static <T> ResponseResult<T> success(String message, T data) {
        return new ResponseResult<>(200, message, data);
    }
    
    public static <T> ResponseResult<T> error(String message) {
        return new ResponseResult<>(500, message, null);
    }
    
    public static <T> ResponseResult<T> error(Integer code, String message) {
        return new ResponseResult<>(code, message, null);
    }
}

