//
//  FramebufferCache.h
//  RenderImage
//
//  Created by bqlin on 2018/11/17.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Framebuffer.h"

@interface FramebufferCache : NSObject

- (Framebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize onlyTexture:(BOOL)onlyTexture;
- (Framebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize textureOptions:(TextureOptions)textureOptions onlyTexture:(BOOL)onlyTexture;

@end
