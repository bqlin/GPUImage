//
//  ViewController.m
//  RenderVideo
//
//  Created by Bq on 2018/11/30.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "ViewController.h"
#import "GPUImageRenderController.h"
#import "GLRenderController.h"
#import "ReaderImageViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:{
            [self.navigationController pushViewController:[GPUImageRenderController new] animated:YES];
        } break;
        case 1:{
            [self.navigationController pushViewController:[ReaderImageViewController new] animated:YES];
        } break;
        case 2:{
            [self.navigationController pushViewController:[GLRenderController new] animated:YES];
        } break;
        case 3:{
            
        } break;
        case 4:{
            
        } break;
        case 5:{
            
        } break;
        default:{} break;
    }
}

@end
