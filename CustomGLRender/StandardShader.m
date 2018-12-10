//
//  StandardShader.m
//  RenderVideo
//
//  Created by Bq on 2018/12/7.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import "StandardShader.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

/// 标准顶点着色器
NSString *const kStandardVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );

/// 标准片元着色器
NSString *const kStandardPassthroughFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

@implementation StandardShader

@end
