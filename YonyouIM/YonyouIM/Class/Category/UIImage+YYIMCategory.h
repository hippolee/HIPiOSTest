//
//  UIImage+YYIMCategory.h
//  YonyouIM
//
//  Created by litfb on 15/6/17.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (YYIMCategory)

+ (UIImage *)convertViewToImage:(UIView*)view;

+ (UIImage *)imageWithColor:(UIColor *)color coreIcon:(NSString *)imageName;

// default 60 * 60
+ (UIImage *)imageWithDispName:(NSString *)name;

+ (UIImage *)imageWithDispName:(NSString *)name coreIcon:(NSString *)imageName;

// gauss blur
+ (UIImage *)gaussBlurWithImage:(UIImage *)image;

@end
