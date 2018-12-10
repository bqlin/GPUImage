//
//  GLRenderController.m
//  RenderVideo
//
//  Created by Bq on 2018/11/30.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GLRenderController.h"
#import "VideoPixelReader.h"
#import "GLImageView.h"

@interface GLRenderController ()<VideoPixelReaderDelegate>

@property (nonatomic, strong) VideoPixelReader *reader;

@property (nonatomic, strong) GLImageView *glRenderView;

@end


@implementation GLRenderController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    _glRenderView = [[GLImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 320)];
    [self.view addSubview:_glRenderView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVURLAsset assetWithURL:URL];
    _reader = [VideoPixelReader readerForAsset:asset];
    _reader.delegate = self;
    [_reader startReading];
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

#pragma mark - VideoPixelReaderDelegate

- (void)reader:(VideoPixelReader *)reader inputSize:(CGSize)inputSize inputFrameBuffer:(Framebuffer *)inputFrameBuffer {
    _glRenderView.inputImageSize = inputSize;
    _glRenderView.inputFramebufferForDisplay = inputFrameBuffer;
}

- (void)reader:(VideoPixelReader *)reader newFrameReadyAtTime:(CMTime)currentSampleTime {
    [_glRenderView newFrameReadyAtTime:currentSampleTime atIndex:0];
}

@end
