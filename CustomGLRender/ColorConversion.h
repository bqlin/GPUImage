//
//  ColorConversion.h
//  RenderVideo
//
//  Created by Bq on 2018/12/7.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

extern NSString * const kFragmentShaderStringForYuvFullRanageConversion;
extern NSString * const kFragmentShaderStringForYuvVideoRanageConversion;

extern GLfloat *kColorConversion601;
extern GLfloat *kColorConversion601FullRange;
extern GLfloat *kColorConversion709;

@interface ColorConversion : NSObject

@end
