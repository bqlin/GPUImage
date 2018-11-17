//
//  ContextManager.m
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ContextManager.h"

@interface ContextManager ()

@property (nonatomic, strong) EAGLContext *context;

@property (nonatomic, strong) FramebufferCache *framebufferCache;

@property (nonatomic, assign) CVOpenGLESTextureCacheRef coreVideoTextureCache;

@end

@implementation ContextManager

static id _sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
        [_sharedInstance commonInit];
    });
    return _sharedInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_sharedInstance) {
            _sharedInstance = [super allocWithZone:zone];
        }
    });
    return _sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _sharedInstance;
}

- (void)commonInit {}

#pragma mark - property

- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        [EAGLContext setCurrentContext:_context];
    }
    return _context;
}

- (FramebufferCache *)framebufferCache {
    if (!_framebufferCache) {
        _framebufferCache = [[FramebufferCache alloc] init];
    }
    return _framebufferCache;
}

- (CVOpenGLESTextureCacheRef)coreVideoTextureCache {
    if (!_coreVideoTextureCache) {
        CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_coreVideoTextureCache);
        NSAssert(!error, @"Error at CVOpenGLESTextureCacheCreate %d", error);
    }
    return _coreVideoTextureCache;
}

- (void)setCurrentShaderProgram:(GLShaderProgram *)currentShaderProgram {
    [EAGLContext setCurrentContext:self.context];
    if (_currentShaderProgram == currentShaderProgram) return;
    _currentShaderProgram = currentShaderProgram;
    [currentShaderProgram use];
}

#pragma mark - public

- (GLShaderProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString {
    GLShaderProgram *program = [[GLShaderProgram alloc] initWithVertexShaderString:vertexShaderString fragmentShaderString:fragmentShaderString];
    return program;
}

/// 把一帧展示在屏幕上
- (void)presentBufferForDisplay {
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}



@end
