//
//  GLShaderProgram.h
//  RenderImage
//
//  Created by bqlin on 2018/11/16.
//  Copyright © 2018年 Bq. All rights reserved.
//

#import <GLKit/GLKit.h>

@interface GLShaderProgram : NSObject

@property (nonatomic, assign, readonly) BOOL linked;

- (instancetype)initWithVertexShaderString:(NSString *)vShaderString fragmentShaderString:(NSString *)fShaderString;
- (void)addAttribute:(NSString *)attributeName;
- (GLuint)indexOfAttribute:(NSString *)attributeName;
- (GLuint)indexOfUniform:(NSString *)uniformName;
- (BOOL)link;
- (void)use;
- (BOOL)validate;

@end
