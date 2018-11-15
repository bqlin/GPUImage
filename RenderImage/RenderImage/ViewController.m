//
//  ViewController.m
//  RenderImage
//
//  Created by bqlin on 2018/11/15.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "GPUImageRenderController.h"
#import "GLRenderViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)GPUImageAction:(id)sender {
    [self.navigationController pushViewController:[GPUImageRenderController new] animated:YES];
}
- (IBAction)GLAction:(id)sender {
    [self.navigationController pushViewController:[GLRenderViewController new] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
