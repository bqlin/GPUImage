//
//  UINavigationController+Rotate.m
//  LYGLViewExp
//
//  Created by Bq on 2018/12/10.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "UINavigationController+Rotate.h"

@implementation UINavigationController (Rotate)

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

@end
