//
//  ReaderImageViewController.m
//  RenderVideo
//
//  Created by Bq on 2018/12/6.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ReaderImageViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ReaderImageViewController ()

@property (nonatomic, assign) CMTime previousFrameTime;
@property (nonatomic, assign) CFAbsoluteTime previousActualTime;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation ReaderImageViewController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 320)];
    [self.view addSubview:_imageView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    
    NSDictionary *inputOptions = @{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)};
    AVURLAsset *inputAsset = [[AVURLAsset alloc] initWithURL:URL options:inputOptions];
    
    AVAssetReader *assetReader = [AVAssetReader assetReaderWithAsset:inputAsset error:nil];
    NSDictionary *outputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    
    AVAssetReaderTrackOutput *videoTrackOuput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:[inputAsset tracksWithMediaType:AVMediaTypeVideo].firstObject outputSettings:outputSettings];
    [assetReader addOutput:videoTrackOuput];
    
    if (![assetReader startReading]) {
        NSLog(@"error reading");
    }
    
    __weak typeof(self) weakSelf = self;
    NSOperationQueue *readerQueue = [[NSOperationQueue alloc] init];
    readerQueue.maxConcurrentOperationCount = 1;
    [readerQueue addOperationWithBlock:^{
        while (assetReader.status == AVAssetReaderStatusReading) {
            
            CMSampleBufferRef sampleBufferRef = [videoTrackOuput copyNextSampleBuffer];
            if (sampleBufferRef) {
                CMTime currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBufferRef);
                CMTime frameTimeDiff = CMTimeSubtract(currentSampleTime, weakSelf.previousFrameTime);
                // 当前时间
                CFAbsoluteTime currentActualTime = CFAbsoluteTimeGetCurrent();
                
                double frameTimeDiffSec = CMTimeGetSeconds(frameTimeDiff);
                double actualTimeDiff = currentActualTime - weakSelf.previousActualTime;
                double sleepTime = 1000000.0 * (frameTimeDiffSec - actualTimeDiff);
                
                if (sleepTime > 0) {
                    usleep(sleepTime);
                }
                
                weakSelf.previousFrameTime = currentSampleTime;
                weakSelf.previousActualTime = CFAbsoluteTimeGetCurrent();
                
                [weakSelf processVideoFrame:sampleBufferRef];
                
                // 销毁资源
                CMSampleBufferInvalidate(sampleBufferRef);
                CFRelease(sampleBufferRef);
            }
            
        }
    }];
}

- (void)processVideoFrame:(CMSampleBufferRef)videoSampleBuffer {
    //NSLog(@"videoSampleBuffer: %@", videoSampleBuffer);
    
    //int bufferHeight = (int) CVPixelBufferGetHeight(videoSampleBuffer);
    //int bufferWidth = (int) CVPixelBufferGetWidth(videoSampleBuffer);
    //CMTime frameTime = CMSampleBufferGetOutputPresentationTimeStamp(videoSampleBuffer);
    
    CVImageBufferRef frame = CMSampleBufferGetImageBuffer(videoSampleBuffer);
    CIImage *ciImage = [CIImage imageWithCVImageBuffer:frame];
    UIImage *currentImage = [UIImage imageWithCIImage:ciImage];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.image = currentImage;
    });
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

@end
