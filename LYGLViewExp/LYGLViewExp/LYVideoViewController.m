//
//  LYVideoViewController.m
//  LYGLViewExp
//
//  Created by Bq on 2018/12/10.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "LYVideoViewController.h"
#import "AssetFrameReader.h"
#import "LYOpenGLView.h"

@interface LYVideoViewController ()<AssetFrameReaderDelegate>

@property (nonatomic, strong) AssetFrameReader *reader;

@end

@implementation LYVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LYOpenGLView *glView = (LYOpenGLView *)self.view;
    [glView setupGL];
    glView.isFullYUVRange = YES;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVURLAsset assetWithURL:URL];
    _reader = [AssetFrameReader readerForAsset:asset];
    _reader.delegate = self;
    [_reader startReading];
}

- (BOOL)shouldAutorotate {
    return NO;
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

- (void)reader:(AssetFrameReader *)reader didReadVideoSample:(CMSampleBufferRef)sampleBuffer {
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [(LYOpenGLView *)self.view displayPixelBuffer:pixelBuffer];
        CFRelease(sampleBuffer);
    });
}

@end
