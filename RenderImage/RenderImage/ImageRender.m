//
//  ImageRender.m
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ImageRender.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface ImageRender()

@end

@implementation ImageRender

- (void)fetchInfo {
    size_t widthOfImage = CGImageGetWidth(_imageRef);
    size_t heightOfImage = CGImageGetHeight(_imageRef);
    NSAssert( widthOfImage > 0 && heightOfImage > 0, @"Passed image must not be empty - it should be at least 1px tall and width");
    
    CGSize pixelSizeToUseForTexture = CGSizeMake(widthOfImage, heightOfImage);
    NSLog(@"图像尺寸：%@", NSStringFromCGSize(pixelSizeToUseForTexture));
    _pixelSizeToUseForTexture = pixelSizeToUseForTexture;
    
    GLubyte *imageData = NULL;
    CFDataRef dataFromImageDataProvider = NULL;
    GLenum format = GL_BGRA;
    BOOL isLitteEndian = YES;
    BOOL alphaFirst = NO;
    BOOL premultiplied = NO;
    
    // 直接访问图片数据
    dataFromImageDataProvider = CGDataProviderCopyData(CGImageGetDataProvider(_imageRef));
    imageData = (GLubyte *)CFDataGetBytePtr(dataFromImageDataProvider);
    
    // 创建并设置上下文
    [[ContextManager sharedInstance] context];
    
    _outputFramebuffer = [[ContextManager sharedInstance].framebufferCache fetchFramebufferForSize:pixelSizeToUseForTexture onlyTexture:YES];
    glBindTexture(GL_TEXTURE_2D, (int)_outputFramebuffer.texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)widthOfImage, (GLsizei)heightOfImage, 0, format, GL_UNSIGNED_BYTE, imageData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    // 清空资源
    CFRelease(dataFromImageDataProvider);
}

- (void)render {
    
}

@end
