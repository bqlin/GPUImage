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

@property (nonatomic, assign) CGImageRef imageRef;
@property (nonatomic, strong, readonly) Framebuffer *outputFramebuffer;
@property (nonatomic, assign, readonly) CGSize pixelSizeToUseForTexture;

- (void)fetchInfo;

@end
