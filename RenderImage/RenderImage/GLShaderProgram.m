//
//  GLShaderProgram.m
//  RenderImage
//
//  Created by bqlin on 2018/11/16.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GLShaderProgram.h"

@interface GLShaderProgram ()

@property (nonatomic, strong) NSMutableArray *attributes;
@property (nonatomic, strong) NSMutableArray *uniforms;

@property (nonatomic, assign, readonly) GLuint programId;
@property (nonatomic, assign, readonly) GLuint vertexShaderId;
@property (nonatomic, assign, readonly) GLuint fragmentShaderId;

@end

@implementation GLShaderProgram

- (instancetype)initWithVertexShaderString:(NSString *)vShaderString fragmentShaderString:(NSString *)fShaderString {
    if (self = [super init]) {
        _attributes = [NSMutableArray array];
        _uniforms = [NSMutableArray array];
        
        // 创建着色器程序
        _programId = glCreateProgram();
        
        // 编译着色器
        [self compileShaderString:vShaderString type:GL_VERTEX_SHADER resultId:&_vertexShaderId];
        [self compileShaderString:fShaderString type:GL_FRAGMENT_SHADER resultId:&_fragmentShaderId];
        
        // 连接着色器
        glAttachShader(_programId, _vertexShaderId);
        glAttachShader(_programId, _fragmentShaderId);
    }
    return self;
}

#pragma mark - private

- (BOOL)compileShaderString:(NSString *)shaderString type:(GLenum)type resultId:(GLuint *)shaderId {
    GLint status;
    const GLchar *source = (GLchar *)shaderString.UTF8String;
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shaderId = glCreateShader(type);
    glShaderSource(*shaderId, 1, &source, NULL);
    glCompileShader(*shaderId);
    
    glGetShaderiv(*shaderId, GL_COMPILE_STATUS, &status);
    
    // 输出编译错误信息
    if (status != GL_TRUE) {
        GLint logLength;
        glGetShaderiv(*shaderId, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *errorLog = (GLchar *)malloc(logLength);
            glGetShaderInfoLog(*shaderId, logLength, &logLength, errorLog);
            NSString *typeName = nil;
            if (type == GL_VERTEX_SHADER) typeName = @"vertex";
            else if (type == GL_FRAGMENT_SHADER) typeName = @"fragment";
            NSLog(@"%@ shader compile log: \n%s", typeName, errorLog);
            free(errorLog);
        }
        glDeleteShader(*shaderId);
    }
    
    return status == GL_TRUE;
}

#pragma mark - public

- (void)addAttribute:(NSString *)attributeName {
    // 只绑定不存在的属性
    if ([_attributes containsObject:attributeName]) return;
    
    // 加入属性数组，并绑定该属性的位置在其数组中的索引
    [_attributes addObject:attributeName];
    glBindAttribLocation(_programId, (GLuint)[_attributes indexOfObject:attributeName], attributeName.UTF8String);
}

- (GLuint)indexOfAttribute:(NSString *)attributeName {
    // 获取属性位置，由 `-addAttribute:` 可知即其在属性数组的索引
    return (GLuint)[_attributes indexOfObject:attributeName];
}

- (GLuint)indexOfUniform:(NSString *)uniformName {
    // 获取 uniform  的位置
    return glGetUniformLocation(_programId, uniformName.UTF8String);
}

- (BOOL)link {
    // 链接着色器
    glLinkProgram(_programId);
    
    // 获取链接状态
    GLint status;
    glGetProgramiv(_programId, GL_LINK_STATUS, &status);
    
    if (status == GL_FALSE) {
        GLint logLength;
        glGetProgramiv(_programId, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar *)malloc(logLength);
            glGetProgramInfoLog(_programId, logLength, &logLength, log);
            NSLog(@"Program link log:\n%s", log);
            free(log);
        }
        return NO;
    }
    
    /// 如果链接成功，则删除着色器，释放资源
    if (_vertexShaderId) {
        glDeleteShader(_vertexShaderId);
        _vertexShaderId = 0;
    }
    if (_fragmentShaderId) {
        glDeleteShader(_fragmentShaderId);
        _fragmentShaderId = 0;
    }
    
    _linked = YES;
    
    return YES;
}

- (void)use {
    glUseProgram(_programId);
}

- (BOOL)validate {
    GLint logLength, status;
    
    glValidateProgram(_programId);
    glGetProgramiv(_programId, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_programId, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(_programId, GL_VALIDATE_STATUS, &status);
    return status == GL_TRUE;
}

#pragma mark -

- (void)dealloc {
    // 销毁着色器与着色器程序
    if (_vertexShaderId)
        glDeleteShader(_vertexShaderId);
    
    if (_fragmentShaderId)
        glDeleteShader(_fragmentShaderId);
    
    if (_programId)
        glDeleteProgram(_programId);
}

@end
