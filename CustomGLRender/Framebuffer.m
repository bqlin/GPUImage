//
//  Framebuffer.m
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "Framebuffer.h"
#import "ContextManager.h"

@implementation Framebuffer
{
    /// 帧缓存 ID
    GLuint _framebuffer;
    /// 渲染目标 CVPixelBufferRef
    CVPixelBufferRef _renderTarget;
    /// 渲染纹理 CVOpenGLESTextureRef
    CVOpenGLESTextureRef _renderTexture;
}

- (void)dealloc {
    [self destroyFramebuffer];
}

//- (instancetype)initWithSize:(CGSize)framebufferSize overriddenTexture:(GLuint)inputTexture {
//    if (self = [super init]) {
//        _textureOptions = DefaultTextureOptions();
//        _framebufferSize = framebufferSize;
//        
//        _texture = inputTexture;
//    }
//    return self;
//}

- (instancetype)initWithSize:(CGSize)framebufferSize {
    return [self initWithSize:framebufferSize textureOptions:DefaultTextureOptions() onlyTexture:NO];
}

- (instancetype)initWithSize:(CGSize)framebufferSize textureOptions:(TextureOptions)textureOptions onlyTexture:(BOOL)onlyGenerateTexture {
    if (self = [super init]) {
        _textureOptions = textureOptions;
        _framebufferSize = framebufferSize;
        _missingFramebuffer = onlyGenerateTexture;
        
        if (_missingFramebuffer) {
            [ContextManager syncActionOnVideoProcessingQueue:^{
                [[ContextManager sharedInstance] context];
                [self generateTexture];
                self->_framebuffer = 0;
            }];
        } else {
            [ContextManager syncActionOnVideoProcessingQueue:^{
                [self generateFramebuffer];
            }];
        }
    }
    return self;
}

/// 创建普通纹理
- (void)generateTexture {
    // glActiveTextue 并不是激活纹理单元，而是选择当前活跃的纹理单元。每一个纹理单元都有GL_TEXTURE_1D, 2D, 3D 和 CUBE_MAP。
    glActiveTexture(GL_TEXTURE1);
    // 生成纹理缓存唯一 ID
    glGenTextures(1, &_texture);
    // 绑定缓存
    glBindTexture(GL_TEXTURE_2D, _texture);
    // 配置纹理
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, _textureOptions.minFilter);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, _textureOptions.magFilter);
    // This is necessary for non-power-of-two textures
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
    
    // TODO: Handle mipmaps
}

/// 创建 CoreVideo 帧缓存
- (void)generateFramebuffer {
    [[ContextManager sharedInstance] context];
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    
    // 若设备支持快速纹理上传，则生成 Core Video 的 OpenGLESTextureCache，否则生成普通的纹理缓存
    // By default, all framebuffers on iOS 5.0+ devices are backed by texture caches, using one shared cache
    CVOpenGLESTextureCacheRef coreVideoTextureCache = [[ContextManager sharedInstance] coreVideoTextureCache];
    // Code originally sourced from http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
    
    CFDictionaryRef empty; // empty value for attr value.
    CFMutableDictionaryRef attrs;
    empty = CFDictionaryCreate(kCFAllocatorDefault, NULL, NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks); // our empty IOSurface properties dictionary
    attrs = CFDictionaryCreateMutable(kCFAllocatorDefault, 1, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, (int)_framebufferSize.width, (int)_framebufferSize.height, kCVPixelFormatType_32BGRA, attrs, &_renderTarget);
    if (err) {
        NSLog(@"FBO size: %f, %f", _framebufferSize.width, _framebufferSize.height);
        NSAssert(NO, @"Error at CVPixelBufferCreate %d", err);
    }
    
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, coreVideoTextureCache, _renderTarget,
                                                       NULL, // texture attributes
                                                       GL_TEXTURE_2D,
                                                       _textureOptions.internalFormat, // opengl format
                                                       (int)_framebufferSize.width,
                                                       (int)_framebufferSize.height,
                                                       _textureOptions.format, // native iOS format
                                                       _textureOptions.type,
                                                       0,
                                                       &_renderTexture);
    NSAssert(!err, @"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
    
    // 销毁字典
    CFRelease(attrs);
    CFRelease(empty);
    
    // 绑定纹理缓存
    glBindTexture(CVOpenGLESTextureGetTarget(_renderTexture), CVOpenGLESTextureGetName(_renderTexture));
    _texture = CVOpenGLESTextureGetName(_renderTexture);
    // 配置纹理
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, _textureOptions.wrapS);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, _textureOptions.wrapT);
    
    // 复制颜色数据到纹理缓存中
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_renderTexture), 0);
    
#ifndef NS_BLOCK_ASSERTIONS
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(status == GL_FRAMEBUFFER_COMPLETE, @"Incomplete filter FBO: %d", status);
#endif
    
    glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)destroyFramebuffer {
    [ContextManager syncActionOnVideoProcessingQueue:^{
        [self _destroyFramebuffer];
    }];
}
- (void)_destroyFramebuffer {
    [[ContextManager sharedInstance] context];
    if (_framebuffer) {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }
    
    if (!_missingFramebuffer) {
        if (_renderTarget) {
            CFRelease(_renderTarget);
            _renderTarget = NULL;
        }
        if (_renderTexture) {
            CFRelease(_renderTexture);
            _renderTexture = NULL;
        }
    } else {
        glDeleteTextures(1, &_texture);
    }
}

- (void)activateFramebuffer {
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    // 激活的时候需设置视口大小
    glViewport(0, 0, (int)_framebufferSize.width, (int)_framebufferSize.height);
}

@end
