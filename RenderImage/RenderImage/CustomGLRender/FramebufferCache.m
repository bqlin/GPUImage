//
//  FramebufferCache.m
//  RenderImage
//
//  Created by bqlin on 2018/11/17.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "FramebufferCache.h"

@implementation FramebufferCache

- (Framebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize onlyTexture:(BOOL)onlyTexture {
    return [self fetchFramebufferForSize:framebufferSize textureOptions:DefaultTextureOptions() onlyTexture:YES];
}

- (Framebuffer *)fetchFramebufferForSize:(CGSize)framebufferSize textureOptions:(TextureOptions)textureOptions onlyTexture:(BOOL)onlyTexture {
    Framebuffer *cachedFramebuffer = nil;
    cachedFramebuffer = [[Framebuffer alloc] initWithSize:framebufferSize textureOptions:textureOptions onlyTexture:onlyTexture];
    return cachedFramebuffer;
}


@end
