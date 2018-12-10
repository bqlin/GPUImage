//
//  LYCameraViewController.m
//  LYGLViewExp
//
//  Created by Bq on 2018/12/10.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "LYCameraViewController.h"
#import "LYOpenGLView.h"
#import <AVFoundation/AVFoundation.h>

@interface LYCameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;

@end

@implementation LYCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    LYOpenGLView *glView = (LYOpenGLView *)self.view;
    [glView setupGL];
    glView.isFullYUVRange = YES;
    
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    _captureSession = captureSession;
    captureSession.sessionPreset = AVCaptureSessionPreset640x480;
    
    AVCaptureDevice *inputCamera = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *cameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:nil];
    
    if ([captureSession canAddInput:cameraInput]) {
        [captureSession addInput:cameraInput];
    }
    
    AVCaptureVideoDataOutput *cameraDataOutput = [[AVCaptureVideoDataOutput alloc] init];
    cameraDataOutput.alwaysDiscardsLateVideoFrames = NO;
    
    dispatch_queue_t processQueue = dispatch_queue_create("videoProcessQueue", DISPATCH_QUEUE_SERIAL);
    NSDictionary *videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)};
    cameraDataOutput.videoSettings = videoSettings;
    [cameraDataOutput setSampleBufferDelegate:self queue:processQueue];
    if ([captureSession canAddOutput:cameraDataOutput]) {
        [captureSession addOutput:cameraDataOutput];
    }
    
    AVCaptureConnection *connection = [cameraDataOutput connectionWithMediaType:AVMediaTypeVideo];
    connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    connection.videoMirrored = NO;
    
    [captureSession startRunning];
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

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFRetain(sampleBuffer);
    dispatch_async(dispatch_get_main_queue(), ^{
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [(LYOpenGLView *)self.view displayPixelBuffer:pixelBuffer];
        CFRelease(sampleBuffer);
    });
}

@end
