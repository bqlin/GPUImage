//
//  GLRenderController.m
//  RenderVideo
//
//  Created by Bq on 2018/11/30.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GLRenderController.h"
#import "AssetFrameReader.h"

#import "ColorConversion.h"
#import "StandardShader.h"
#import "ContextManager.h"
#import "GLImageView.h"

@interface GLRenderController ()<AssetFrameReaderDelegate>

@property (nonatomic, strong) AssetFrameReader *reader;

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

@property (nonatomic, strong) GLImageView *glRenderView;

@end

@implementation GLRenderController (YUV)



@end



@implementation GLRenderController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _glRenderView = [[GLImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 320)];
    [self.view addSubview:_glRenderView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVURLAsset assetWithURL:URL];
    _reader = [AssetFrameReader readerForAsset:asset];
    _reader.delegate = self;
    [_reader startReading];
    
    [self yuvConver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - AssetFrameReaderDelegate

- (void)reader:(AssetFrameReader *)reader didReadVideoSample:(CMSampleBufferRef)videoSampleBuffer {
    NSLog(@"videoSample: %@", videoSampleBuffer);
    
    CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(videoSampleBuffer);
    CVImageBufferRef movieFrame = CMSampleBufferGetImageBuffer(videoSampleBuffer);
    
    // 获取尺寸（单位：像素）
    size_t bufferHeight = CVPixelBufferGetHeight(movieFrame);
    size_t bufferWidth = CVPixelBufferGetWidth(movieFrame);
    
    CVOpenGLESTextureRef luminanceTextureRef = NULL;
    CVOpenGLESTextureRef chrominanceTextureRef = NULL;
    
    if (CVPixelBufferGetPlaneCount(movieFrame) > 0) {
        CVPixelBufferLockBaseAddress(movieFrame, 0);
        
        if (_imageBufferWidth != bufferWidth || _imageBufferHeight != bufferHeight) {
            _imageBufferWidth = bufferWidth;
            _imageBufferHeight = bufferHeight;
        }
        CVReturn err;
        
        /// 处理亮度纹理
        glActiveTexture(GL_TEXTURE4);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [ContextManager sharedInstance].coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE, bufferWidth, bufferHeight, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0, &luminanceTextureRef);
        if (err) {
            NSLog(@"Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            err = 0;
        }
        
        _luminanceTexture = CVOpenGLESTextureGetName(luminanceTextureRef);
        // 绑定纹理，设置纹理填充模式
        glBindTexture(GL_TEXTURE_2D, _luminanceTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        /// 处理色度纹理
        glActiveTexture(GL_TEXTURE5);
        err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, [ContextManager sharedInstance].coreVideoTextureCache, movieFrame, NULL, GL_TEXTURE_2D, GL_LUMINANCE_ALPHA, bufferWidth/2, bufferHeight/2, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, 1, &chrominanceTextureRef);
        if (err) {
            NSLog(@"luminanceTexture Error at CVOpenGLESTextureCacheCreateTextureFromImage %d", err);
            err = 0;
        }
        
        _chrominanceTexture = CVOpenGLESTextureGetName(chrominanceTextureRef);
        // 绑定纹理，设置纹理填充模式
        glBindTexture(GL_TEXTURE_2D, _chrominanceTexture);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        [self convertYUVToRGB];
        
        _glRenderView.inputImageSize = CGSizeMake(_imageBufferWidth, _imageBufferHeight);
        _glRenderView.inputFramebufferForDisplay = _outputFramebuffer;
        //[_glRenderView newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
    }
}

#pragma mark -

- (void)yuvConver {
    [[ContextManager sharedInstance] context];
    
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

/// 转换 YUV 纹理为 RGB 纹理，并绘制
- (void)convertYUVToRGB {
    [ContextManager sharedInstance].currentShaderProgram = _yuvConverProgram;
    _outputFramebuffer = [[Framebuffer alloc] initWithSize:CGSizeMake(_imageBufferWidth, _imageBufferHeight) overriddenTexture:NO];
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
    
    glUniformMatrix3fv(_yuvMatrixUniform, 1, GL_FALSE, kColorConversion601FullRange);
    
    glVertexAttribPointer(_yuvPositionAttribute, 2, GL_FLOAT, 0, 0, squareVertices);
    glVertexAttribPointer(_yuvTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
