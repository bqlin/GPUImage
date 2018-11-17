//
//  Framebuffer.h
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef struct {
    GLenum minFilter;
    GLenum magFilter;
    GLenum wrapS;
    GLenum wrapT;
    GLenum internalFormat;
    GLenum format;
    GLenum type;
} TextureOptions;

/// 默认纹理选项
NS_INLINE TextureOptions DefaultTextureOptions() {
    TextureOptions defaultTextureOptions;
    defaultTextureOptions.minFilter = GL_LINEAR;
    defaultTextureOptions.magFilter = GL_LINEAR;
    defaultTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    defaultTextureOptions.internalFormat = GL_RGBA;
    defaultTextureOptions.format = GL_BGRA;
    defaultTextureOptions.type = GL_UNSIGNED_BYTE;
    
    return defaultTextureOptions;
}

@interface Framebuffer : NSObject

/// 纹理缓存 ID
@property (nonatomic, assign, readonly) GLuint texture;

@property (nonatomic, assign, readonly) TextureOptions textureOptions;

@property (nonatomic, assign, readonly) CGSize framebufferSize;

@property (nonatomic, assign, readonly) BOOL missingFramebuffer;

- (instancetype)initWithSize:(CGSize)framebufferSize;
- (instancetype)initWithSize:(CGSize)framebufferSize overriddenTexture:(GLuint)inputTexture;
- (instancetype)initWithSize:(CGSize)framebufferSize textureOptions:(TextureOptions)textureOptions onlyTexture:(BOOL)onlyGenerateTexture;

@end
