//
//  AssetFrameReader.m
//  RenderVideo
//
//  Created by Bq on 2018/12/6.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "AssetFrameReader.h"

@interface AssetFrameReader ()

@property (nonatomic, strong) AVAssetReader *reader;

@property (nonatomic, assign) CMTime previousFrameTime;
@property (nonatomic, assign) CFAbsoluteTime previousActualTime;

@end

@implementation AssetFrameReader

+ (instancetype)readerForAsset:(AVAsset *)asset {
    return [[self alloc] initWithAsset:asset];
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (self = [super init]) {
        _asset = asset;
        _reader = [AVAssetReader assetReaderWithAsset:_asset error:nil];
        
        // 创建视频轨道输出
        NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
        AVAssetReaderTrackOutput *videoTrackOuput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[asset tracksWithMediaType:AVMediaTypeVideo].firstObject outputSettings:outputSettings];
        [_reader addOutput:videoTrackOuput];
    }
    return self;
}

- (void)startReading {
    if (![_reader startReading]) {
        NSLog(@"reading error");
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *readerQueue = [[NSOperationQueue alloc] init];
    readerQueue.maxConcurrentOperationCount = 1;
    [readerQueue addOperationWithBlock:^{
        [weakSelf _readingFrame];
    }];
}

- (void)_readingFrame {
    AVAssetReaderOutput *videoOuput = nil;
    for (AVAssetReaderOutput *output in _reader.outputs) {
        if ([output.mediaType isEqualToString:AVMediaTypeVideo]) {
            videoOuput = output;
        }
    }
    while (_reader.status == AVAssetReaderStatusReading) {
        CMSampleBufferRef sampleBufferRef = [videoOuput copyNextSampleBuffer];
        if (sampleBufferRef) {
            CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
            CMTime frameTimeDiff = CMTimeSubtract(currentSampleTime, _previousFrameTime);
            // 当前时间
            CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
            
            double frameTimeDiffSec = CMTimeGetSeconds(frameTimeDiff);
            double actualTimeDiff = currentActualTime - _previousActualTime;
            double sleepTime = 1000000.0 * (frameTimeDiffSec - actualTimeDiff);
            
            // 利用挂起实现以视频播放速度读取帧
            if (sleepTime > 0) {
                usleep(sleepTime);
            }
            
            _previousFrameTime = currentSampleTime;
            _previousActualTime = CFAbsoluteTimeGetCurrent();
            
            [self processVideoFrame:sampleBufferRef];
            
            // 销毁资源
            CMSampleBufferInvalidate(sampleBufferRef);
            CFRelease(sampleBufferRef);
        }
    }
}

- (void)processVideoFrame:(CMSampleBufferRef)videoSampleBuffer {
    if ([self.delegate respondsToSelector:@selector(reader:didReadVideoSample:)]) {
        [self.delegate reader:self didReadVideoSample:videoSampleBuffer];
    }
}

@end
