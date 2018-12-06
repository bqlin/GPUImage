//
//  GPUImageRenderController.m
//  RenderVideo
//
//  Created by Bq on 2018/11/30.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "GPUImageRenderController.h"
#import <GPUImage.h>

@interface GPUImageRenderController ()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation GPUImageRenderController

- (void)dealloc {
    NSLog(@"%s", __FUNCTION__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    GPUImageView *preivewView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:preivewView];
    preivewView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"local" ofType:@"mp4"];
    NSURL *URL = [NSURL fileURLWithPath:path];
    
    // 使用 URL 初始化
    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithURL:URL];
    
//    // 使用 playerItem 初始化，使用 AVPlayerItem 需要搭配 AVPlayer 使用
//    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:URL];
//    GPUImageMovie *movie = [[GPUImageMovie alloc] initWithPlayerItem:playerItem];
//    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
//    [player play];
//    _player = player;
    
    movie.playAtActualSpeed = YES;
    
    [movie addTarget:preivewView];
    [movie startProcessing];
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
