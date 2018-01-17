//
//  YYIMResourceUtility.h
//  YonyouIM
//
//  Created by litfb on 15/2/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "YYIMDefs.h"

#define YYIM_RESOURCE_DIRECTORY         @"yonyouim"
#define YYIM_RESOURCE_TYPE_IMAGE        @"image"
#define YYIM_RESOURCE_TYPE_MICROVIDEO   @"microvideo"
#define YYIM_RESOURCE_TYPE_AUDIO        @"audio"
#define YYIM_RESOURCE_TYPE_FILE         @"file"
#define YYIM_RESOURCE_TYPE_LOCATION     @"location"
#define YYIM_RESOURCE_TYPE_ATTACH       @"attach"

@interface YYIMResourceUtility : NSObject

+ (AVAudioRecorder *)createAudioRecorder;

// 资源全路径
+ (NSString *)fullPathWithResourceRelaPath:(NSString *)resRelaPath;

// 获得资源根目录
+ (NSString *)resourceRootDirectory;

// 获得资源在对应目录下的新文件名
+ (NSString *)resourceRelaPathWithResType:(NSString *)resType ext:(NSString *)ext;

// 检查文件是否在对应资源目录，不在则拷贝
+ (NSString *)resourceRelaPathWithResType:(NSString *)resType filePath:(NSString *)filePath;

// 生成attach文件路径
+ (NSString *)resourceAttachRelaPathWithId:(NSString *)attachId ext:(NSString *)ext;

// 保存image
+ (NSString *)saveImage:(UIImage *)image;
+ (NSString *)saveAssets:(ALAsset *)asset;
// thumb
+ (NSString *)thumbImagePath:(NSString *)srcImagePath maxSide:(CGFloat)maxSide;
+ (UIImage *)thumbImage:(UIImage *)srcImage maxSide:(CGFloat)maxSide;

// image
+ (UIImage *)fixOrientation:(UIImage *)image;

// wav格式转换amr
+ (NSString *)wavToAmr:(NSString *)wavPath;
// amr格式转换wav
+ (NSString *)amrToWav:(NSString *)amrPath;

+ (NSString *)getThumbAttachKey:(NSString *)attachId;

+ (NSString *)getAttachKey:(NSString *)attachId imageType:(YYIMImageType)imageType;

+ (NSString *)getFileMD5WithPath:(NSString*)path;

@end
