//
//  ColorConversion.h
//  RenderVideo
//
//  Created by Bq on 2018/12/7.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

static NSString * const kFragmentShaderStringForYuvFullRanageConversion;
static NSString * const kFragmentShaderStringForYuvVideoRanageConversion;

static GLfloat *kColorConversion601;
static GLfloat *kColorConversion601FullRange;
static GLfloat *kColorConversion709;

@interface ColorConversion : NSObject

@end
