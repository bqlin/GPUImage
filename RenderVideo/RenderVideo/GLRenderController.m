//
//  GLRenderController.m
//  RenderVideo
//
//  Created by Bq on 2018/11/30.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GLRenderController.h"
#import "AssetFrameReader.h"

@interface GLRenderController ()<AssetFrameReaderDelegate>

@property (nonatomic, strong) AssetFrameReader *reader;

@end

@implementation GLRenderController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    AVAsset *asset = [AVURLAsset assetWithURL:URL];
    _reader = [AssetFrameReader readerForAsset:asset];
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

#pragma mark - AssetFrameReaderDelegate

- (void)reader:(AssetFrameReader *)reader didReadVideoSample:(CMSampleBufferRef)videoSampleBuffer {
    NSLog(@"videoSample: %@", videoSampleBuffer);
}

@end
