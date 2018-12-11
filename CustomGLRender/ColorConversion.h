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

extern GLfloat *kColorConver601;
extern GLfloat *kColorConver601FullRange;
extern GLfloat *kColorConver709;

@interface ColorConversion : NSObject

@end
