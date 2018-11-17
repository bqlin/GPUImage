//
//  GLImageView.h
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Framebuffer.h"

typedef NS_ENUM(NSInteger, ImageRotation) {
    ImageRotationNone,
    ImageRotationLeft,
    ImageRotationRight,
    ImageRotationFlipVertical,
    ImageRotationFlipHorizontal,
    ImageRotationRightFlipVertical,
    ImageRotationRightFlipHorizontal,
    ImageRotation180,
};

@interface GLImageView : UIView

@property (nonatomic, assign, readonly) CGSize sizeInPixels;

/// 输入图片尺寸
@property (nonatomic, assign) CGSize inputImageSize;

@property (nonatomic, assign) ImageRotation inputRotation;

/// 输入帧缓存
@property (nonatomic, strong) Framebuffer *inputFramebufferForDisplay;
- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;

@end
