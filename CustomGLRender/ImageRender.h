//
//  ImageRender.h
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContextManager.h"

@interface ImageRender : NSObject

/// 输入图像
@property (nonatomic, assign) CGImageRef imageRef;

/// 图像输出帧缓存
@property (nonatomic, strong, readonly) Framebuffer *outputFramebuffer;
/// 纹理的像素尺寸
@property (nonatomic, assign, readonly) CGSize pixelSizeToUseForTexture;

- (void)fetchInfo;

@end
