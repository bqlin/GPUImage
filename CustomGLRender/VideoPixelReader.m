//
//  VideoPixelReader.m
//  RenderVideo
//
//  Created by Bq on 2018/12/10.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "VideoPixelReader.h"
#import "AssetFrameReader.h"
#import <GLKit/GLKit.h>

#import "ColorConversion.h"
#import "StandardShader.h"
#import "ContextManager.h"

@interface VideoPixelReader()<AssetFrameReaderDelegate>

@property (nonatomic, strong) AssetFrameReader *reader;

@property (nonatomic, assign) TextureOptions outputTextureOptions;

@property (nonatomic, assign) GLuint luminanceTexture;
@property (nonatomic, assign) GLuint chrominanceTexture;

@property (nonatomic, strong) GLShaderProgram *yuvConverProgram;

@property (nonatomic, assign) GLint yuvPositionAttribute;
@property (nonatomic, assign) GLint yuvTextureCoordinateAttribute;
@property (nonatomic, assign) GLint yuvLuminanceTextureUniform;
@property (nonatomic, assign) GLint yuvChrominanceTextureUniform;
@property (nonatomic, assign) GLint yuvMatrixUniform;

@property (nonatomic, assign) size_t imageBufferWidth;
@property (nonatomic, assign) size_t imageBufferHeight;

@property (nonatomic, strong) Framebuffer *outputFramebuffer;

@property (nonatomic, assign) CMTime processingFrameTime;

@property (nonatomic, assign) const GLfloat *preferredConversion;

@end

@implementation VideoPixelReader

+ (instancetype)readerForAsset:(AVAsset *)asset {
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (self = [super init]) {
        [self commonInit];
        _reader = [AssetFrameReader readerForAsset:asset];
        _reader.delegate = self;
    }
    return self;
}

- (void)commonInit {
    _outputTextureOptions.minFilter = GL_LINEAR;
    _outputTextureOptions.magFilter = GL_LINEAR;
    _outputTextureOptions.wrapS = GL_CLAMP_TO_EDGE;
    _outputTextureOptions.wrapT = GL_CLAMP_TO_EDGE;
    _outputTextureOptions.internalFormat = GL_RGBA;
    _outputTextureOptions.format = GL_BGRA;
    _outputTextureOptions.type = GL_UNSIGNED_BYTE;
    
    [self yuvConver];
}

- (void)startReading {
    [_reader startReading];
}

#pragma mark -

- (void)yuvConver {
    [ContextManager syncActionOnVideoProcessingQueue:^{
        [self _yuvConver];
    }];
}
- (void)_yuvConver {
    [[ContextManager sharedInstance] context];
    
    _preferredConversion = kColorConver709;
    
    _yuvConverProgram = [[ContextManager sharedInstance] programForVertexShaderString:kStandardVertexShaderString fragmentShaderString:kFragmentShaderStringForYuvFullRanageConversion];
    
    if (!_yuvConverProgram.linked) {
        [_yuvConverProgram addAttribute:@"position"];
        [_yuvConverProgram addAttribute:@"inputTextureCoordinate"];
        
        [_yuvConverProgram link];
    }
    
    _yuvPositionAttribute = [_yuvConverProgram indexOfAttribute:@"position"];
    _yuvTextureCoordinateAttribute = [_yuvConverProgram indexOfAttribute:@"inputTextureCoordinate"];
    _yuvLuminanceTextureUniform = [_yuvConverProgram indexOfUniform:@"luminanceTexture"];
    _yuvChrominanceTextureUniform = [_yuvConverProgram indexOfUniform:@"chrominanceTexture"];
    _yuvMatrixUniform = [_yuvConverProgram indexOfUniform:@"colorConversionMatrix"];
    
    [ContextManager sharedInstance].currentShaderProgram = _yuvConverProgram;
    glEnableVertexAttribArray(_yuvPositionAttribute);
    glEnableVertexAttribArray(_yuvTextureCoordinateAttribute);
}

#pragma mark -
/// 处理指定时间的 CVPixelBufferRef 视频帧
- (void)processMovieFrame:(CVPixelBufferRef)movieFrame withSampleTime:(CMTime)currentSampleTime {
    // 获取尺寸（单位：像素）
    size_t bufferHeight = CVPixelBufferGetHeight(movieFrame);
    size_t bufferWidth = CVPixelBufferGetWidth(movieFrame);
    
    const GLfloat *preferredConversion;
    CFTypeRef colorAttachments = CVBufferGetAttachment(movieFrame, kCVImageBufferYCbCrMatrixKey, NULL);
    if (colorAttachments != NULL) {
        if(CFStringCompare(colorAttachments, kCVImageBufferYCbCrMatrix_ITU_R_601_4, 0) == kCFCompareEqualTo) {
            preferredConversion = kColorConver601FullRange;
        } else {
            preferredConversion = kColorConver709;
        }
    } else {
        preferredConversion = kColorConver601FullRange;
    }
    _preferredConversion = preferredConversion;
    
    //CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    [[ContextManager sharedInstance] context];
    
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    
    if (CVPixelBufferGetPlaneCount(movieFrame) <= 0) {
        NSLog(@"Mesh this with the new framebuffer cache");
        return;
    }
    
    CVPixelBufferLockBaseAddress(movieFrame, 0);
    
    if (_imageBufferWidth != bufferWidth || _imageBufferHeight != bufferHeight) {
        _imageBufferWidth = bufferWidth;
        _imageBufferHeight = bufferHeight;
    }
    CVReturn err;
    
    /// 处理亮度纹理
    // 创建亮度纹理
    glActiveTexture(GL_TEXTURE4);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [ContextManager sharedInstance].coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, (GLsizei)bufferWidth, (GLsizei)bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
    if (err) {
        NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        err = 0;
    }
    _luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
    // 绑定并配置亮度纹理
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    /// 处理色度纹理
    // 创建色度纹理
    glActiveTexture(GL_TEXTURE5);
    err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [ContextManager sharedInstance].coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, (GLsizei)bufferWidth/2, (GLsizei)bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
    if (err) {
        NSLog(@"luminanceTexture Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
        err = 0;
    }
    _chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
    // 绑定并配置色度纹理
    glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    // 转换成 RGB 并绘制
    [self convertYUVToRGB];
    
    /// 回调信息以继续处理
    if ([self.delegate respondsToSelector:@selector(reader:inputSize:inputFrameBuffer:)]) {
        [self.delegate reader:self inputSize:CGSizeMake(_imageBufferWidth, _imageBufferHeight) inputFrameBuffer:_outputFramebuffer];
    }
    if ([self.delegate respondsToSelector:@selector(reader:newFrameReadyAtTime:)]) {
        [self.delegate reader:self newFrameReadyAtTime:currentSampleTime];
    }
    
    // 销毁
    CVPixelBufferUnlockBaseAddress(movieFrame, 0);
    CFRelease(luminanceTextureRef);
    CFRelease(chrominanceTextureRef);
}

/// 转换 YUV 纹理为 RGB 纹理，并绘制
- (void)convertYUVToRGB {
    [ContextManager sharedInstance].currentShaderProgram = _yuvConverProgram;
    _outputFramebuffer = [[Framebuffer alloc] initWithSize:CGSizeMake(_imageBufferWidth, _imageBufferHeight) textureOptions:_outputTextureOptions onlyTexture:NO];
    [_outputFramebuffer activateFramebuffer];
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    static const GLfloat squareVertices[] = {
        -1.0f, -1.0f,
        1.0f, -1.0f,
        -1.0f,  1.0f,
        1.0f,  1.0f,
    };
    
    static const GLfloat textureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
    glUniform1i(_yuvLuminanceTextureUniform, 4);
    
    glActiveTexture(GL_TEXTURE5);
    glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
    glUniform1i(_yuvChrominanceTextureUniform, 5);
    
    glUniformMatrix3fv(_yuvMatrixUniform, 1, GL_FALSE, _preferredConversion);
    
    glVertexAttribPointer(_yuvPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(_yuvTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

#pragma mark - AssetFrameReaderDelegate

- (void)reader:(AssetFrameReader *)reader didReadVideoSample:(CMSampleBufferRef)videoSampleBuffer {
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(videoSampleBuffer);
    self.processingFrameTime = currentSampleTime;
    CVPixelBufferRef movieFrame = CMSampleBufferGetImageBuffer(videoSampleBuffer);
    
    [ContextManager syncActionOnVideoProcessingQueue:^{
        [self processMovieFrame:movieFrame withSampleTime:currentSampleTime];
    }];
}

@end
