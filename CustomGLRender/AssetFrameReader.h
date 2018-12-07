//
//  AssetFrameReader.h
//  RenderVideo
//
//  Created by Bq on 2018/12/6.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class AssetFrameReader;

@protocol AssetFrameReaderDelegate <NSObject>
@optional

//- (void)readerDidComplete:(AssetFrameReader *)reader;
- (void)reader:(AssetFrameReader *)reader didReadVideoSample:(CMSampleBufferRef)videoSampleBuffer;

@end

@interface AssetFrameReader : NSObject

@property (nonatomic, strong, readonly) AVAsset *asset;

@property (nonatomic, weak) id<AssetFrameReaderDelegate> delegate;

+ (instancetype)readerForAsset:(AVAsset *)asset;

- (void)startReading;

@end
