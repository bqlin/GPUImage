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

@property (nonatomic, assign) CVOpenGLESTextureCacheRef coreVideoTextureCache;

@property(nonatomic, strong, readonly) dispatch_queue_t contextQueue;

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

- (void)commonInit {
    dispatch_queue_attr_t queueAtrribute = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_DEFAULT, 0);
    _contextQueue = dispatch_queue_create("queue.GLRender", queueAtrribute);
}

#pragma mark - property

/// 共享的上下文
- (EAGLContext *)context {
    if (!_context) {
        _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    }
    if ([EAGLContext currentContext] != _context) {
        [EAGLContext setCurrentContext:_context];
    }
    return _context;
}

/// 共享的 CoreVideo 纹理缓存
- (CVOpenGLESTextureCacheRef)coreVideoTextureCache {
    if (!_coreVideoTextureCache) {
        CVReturn error = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_coreVideoTextureCache);
        NSAssert(!error, @"Error at CVOpenGLESTextureCacheCreate %d", error);
    }
    return _coreVideoTextureCache;
}

/// 设置当前的着色器程序，并使用
- (void)setCurrentShaderProgram:(GLShaderProgram *)currentShaderProgram {
    [self context];
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

+ (void)runSynchronouslyOnVideoProcessingQueueWithAction:(void (^)(void))action {
    ContextManager *contextManager = [ContextManager sharedInstance];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (dispatch_get_current_queue() == contextManager.contextQueue)
#pragma clang diagnostic pop
    {
        action();
    } else {
        dispatch_sync(contextManager.contextQueue, action);
    }
}

@end
