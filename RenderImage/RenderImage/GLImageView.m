//
//  GLImageView.m
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GLImageView.h"
#import "ContextManager.h"
#import "GLShaderProgram.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

static NSString *const kStandardVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

static NSString *const kStandardPassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

@interface GLImageView ()

@end

@implementation GLImageView
{
    /// 用于渲染、显示的帧缓存
    GLuint _displayRenderbuffer, _displayFramebuffer;
    
    /// 着色器程序
    GLShaderProgram *_displayProgram;
    /// 着色器外部变量
    GLint _displayPositionAttribute, _displayTextureCoordinateAttribute;
    GLint _displayInputTextureUniform;
    
    /// 图像纹理顶点
    GLfloat _imageVertices[8];
    /// 背景色
    GLfloat _backgroundColorRed, _backgroundColorGreen, _backgroundColorBlue, _backgroundColorAlpha;
    
    /// 帧缓存尺寸，会设置为 self.bounds
    CGSize _boundsSizeAtFrameBufferEpoch;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (instancetype)initWithCoder:(NSCoder *)decoder {
    if (self = [super initWithCoder:decoder]) {
        [self commonInit];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.contentScaleFactor = [UIScreen mainScreen].scale;
    self.opaque = YES;
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties =
    @{
      kEAGLDrawablePropertyRetainedBacking: @(NO),
      kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
      };
    _backgroundColorAlpha = 1;
    
    [[ContextManager sharedInstance] context];
    _displayProgram = [[ContextManager sharedInstance] programForVertexShaderString:kStandardVertexShaderString fragmentShaderString:kStandardPassthroughFragmentShaderString];
    // 链接
    if (!_displayProgram.linked) {
        [_displayProgram addAttribute:@"position"];
        [_displayProgram addAttribute:@"inputTextureCoordinate"];
        [_displayProgram link];
    }
    
    // 使用成员变量连接着色器
    _displayPositionAttribute = [_displayProgram indexOfAttribute:@"position"];
    _displayTextureCoordinateAttribute = [_displayProgram indexOfAttribute:@"inputTextureCoordinate"];
    _displayInputTextureUniform = [_displayProgram indexOfUniform:@"inputImageTexture"];
    
    [ContextManager sharedInstance].currentShaderProgram = _displayProgram;
    glEnableVertexAttribArray(_displayPositionAttribute);
    glEnableVertexAttribArray(_displayTextureCoordinateAttribute);
    
    // 创建帧缓存
    [self createDisplayFramebuffer];
}

#pragma mark - property

- (void)setInputFramebufferForDisplay:(Framebuffer *)inputFramebufferForDisplay {
    _inputFramebufferForDisplay = inputFramebufferForDisplay;
}

- (void)setInputImageSize:(CGSize)inputImageSize {
    _inputImageSize = inputImageSize;
    [self recalculateViewGeometry];
}

#pragma mark -

- (void)recalculateViewGeometry {
    CGFloat heightScaling = 1.0, widthScaling = 1.0;
    _imageVertices[0] = -widthScaling;
    _imageVertices[1] = -heightScaling;
    _imageVertices[2] = widthScaling;
    _imageVertices[3] = -heightScaling;
    _imageVertices[4] = -widthScaling;
    _imageVertices[5] = heightScaling;
    _imageVertices[6] = widthScaling;
    _imageVertices[7] = heightScaling;
}

/// 根据旋转模式获取纹理坐标
+ (const GLfloat *)textureCoordinatesForRotation:(ImageRotation)rotation {
    //    static const GLfloat noRotationTextureCoordinates[] = {
    //        0.0f, 0.0f,
    //        1.0f, 0.0f,
    //        0.0f, 1.0f,
    //        1.0f, 1.0f,
    //    };
    
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] = {
        0.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
    };
    
    switch (rotation) {
        case ImageRotationNone: return noRotationTextureCoordinates;
        case ImageRotationLeft: return rotateLeftTextureCoordinates;
        case ImageRotationRight: return rotateRightTextureCoordinates;
        case ImageRotationFlipVertical: return verticalFlipTextureCoordinates;
        case ImageRotationFlipHorizontal: return horizontalFlipTextureCoordinates;
        case ImageRotationRightFlipVertical: return rotateRightVerticalFlipTextureCoordinates;
        case ImageRotationRightFlipHorizontal: return rotateRightHorizontalFlipTextureCoordinates;
        case ImageRotation180: return rotate180TextureCoordinates;
    }
}

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex {
    [ContextManager sharedInstance].currentShaderProgram = _displayProgram;
    [self setDisplayFramebuffer];

    // 清屏
    glClearColor(_backgroundColorRed, _backgroundColorGreen, _backgroundColorBlue, _backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glActiveTexture(GL_TEXTURE4);
    glBindTexture(GL_TEXTURE_2D, _inputFramebufferForDisplay.texture);
    glUniform1i(_displayInputTextureUniform, 4);

    glVertexAttribPointer(_displayPositionAttribute, 2, GL_FLOAT, 0, 0, _imageVertices);
    glVertexAttribPointer(_displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [self.class textureCoordinatesForRotation:_inputRotation]);

    // 绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // 显示
    [self presentFramebuffer];
//    [inputFramebufferForDisplay unlock];
//    _inputFramebufferForDisplay = nil;
}

- (void)setDisplayFramebuffer {
    if (!_displayFramebuffer) {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, _displayFramebuffer);
    glViewport(0, 0, (GLint)_sizeInPixels.width, (GLint)_sizeInPixels.height);
}

- (void)createDisplayFramebuffer {
    // 设置上下文
    EAGLContext *contex = [[ContextManager sharedInstance] context];
    
    // 创建、绑定用于显示的帧缓存
    glGenFramebuffers(1, &_displayFramebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _displayFramebuffer);
    
    // 创建、绑定用于渲染的帧缓存
    glGenRenderbuffers(1, &_displayRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _displayRenderbuffer);
    
    // 绑定显示渲染结果的图层
    [contex renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
    
    // 获取渲染后的宽高
    GLint backingWidth, backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    if ( (backingWidth == 0) || (backingHeight == 0) )
    {
        [self destroyDisplayFramebuffer];
        return;
    }
    _sizeInPixels.width = (CGFloat)backingWidth;
    _sizeInPixels.height = (CGFloat)backingHeight;
    
    //    NSLog(@"Backing width: %d, height: %d", backingWidth, backingHeight);
    
    // 渲染
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _displayRenderbuffer);
    
    __unused GLuint framebufferCreationStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(framebufferCreationStatus == GL_FRAMEBUFFER_COMPLETE, @"Failure with display framebuffer generation for display of size: %f, %f", self.bounds.size.width, self.bounds.size.height);
    _boundsSizeAtFrameBufferEpoch = self.bounds.size;
    
    [self recalculateViewGeometry];
}

- (void)destroyDisplayFramebuffer {
    [[ContextManager sharedInstance] context];
    
    if (_displayFramebuffer) {
        glDeleteFramebuffers(1, &_displayFramebuffer);
        _displayFramebuffer = 0;
    }
    
    if (_displayRenderbuffer) {
        glDeleteRenderbuffers(1, &_displayRenderbuffer);
        _displayRenderbuffer = 0;
    }
}

- (void)presentFramebuffer {
    glBindRenderbuffer(GL_RENDERBUFFER, _displayRenderbuffer);
    [[ContextManager sharedInstance] presentBufferForDisplay];
}

@end
