//
//  GLRenderViewController.m
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GLRenderViewController.h"
#import "ImageRender.h"
#import "GLImageView.h"

@interface GLRenderViewController ()

@end

@implementation GLRenderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [[ContextManager sharedInstance] context];
    UIImage *image = [UIImage imageNamed:@"concentric_circle_calibration_plate.jpg"];
    ImageRender *imageRender = [[ImageRender alloc] init];
    imageRender.imageRef = image.CGImage;
    [imageRender fetchInfo];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    GLImageView *renderView = [[GLImageView alloc] initWithFrame:CGRectMake(0, 100, width, width)];
    [self.view addSubview:renderView];
    
    renderView.inputImageSize = imageRender.pixelSizeToUseForTexture;
    renderView.inputFramebufferForDisplay = imageRender.outputFramebuffer;
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
