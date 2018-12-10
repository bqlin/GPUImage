//
//  VideoPixelReader.h
//  RenderVideo
//
//  Created by Bq on 2018/12/10.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "Framebuffer.h"

@class VideoPixelReader;

@protocol VideoPixelReaderDelegate <NSObject>

@optional
- (void)reader:(VideoPixelReader *)reader inputSize:(CGSize)inputSize inputFrameBuffer:(Framebuffer *)inputFrameBuffer;
- (void)reader:(VideoPixelReader *)reader newFrameReadyAtTime:(CMTime)currentSampleTime;

@end

@interface VideoPixelReader : NSObject

@property (nonatomic, weak) id<VideoPixelReaderDelegate> delegate;

+ (instancetype)readerForAsset:(AVAsset *)asset;
- (void)startReading;

@end
