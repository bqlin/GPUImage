//
//  ContextManager.h
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Framebuffer.h"
#import "GLShaderProgram.h"

@interface ContextManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) EAGLContext *context;

@property (nonatomic, assign, readonly) CVOpenGLESTextureCacheRef coreVideoTextureCache;

@property (nonatomic, strong) GLShaderProgram *currentShaderProgram;

- (GLShaderProgram *)programForVertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;

- (void)presentBufferForDisplay;

+ (void)runSynchronouslyOnVideoProcessingQueueWithAction:(void (^)(void))action;

@end
