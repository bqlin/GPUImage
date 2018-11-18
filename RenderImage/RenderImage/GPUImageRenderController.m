//
//  GPUImageRenderController.m
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GPUImageRenderController.h"
#import <GPUImage.h>

@interface GPUImageRenderController ()

@end

@implementation GPUImageRenderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    GPUImagePicture *picture = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"concentric_circle_calibration_plate.jpg"]];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    GPUImageView *renderView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 100, width, width)];
    [self.view addSubview:renderView];
    
//    [picture addTarget:renderView];
//    [picture processImage];
    
    // 等同于以下实现
    //[renderView setInputImageSize:picture.outputImageSize];
    [renderView setInputSize:picture.outputImageSize atIndex:0];
    [renderView setInputFramebuffer:picture.framebufferForOutput atIndex:0];
    [renderView newFrameReadyAtTime:kCMTimeIndefinite atIndex:0];
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
