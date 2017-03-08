//
//  HIPImageUtility.h
//  litfb_test
//
//  Created by litfb on 16/1/15.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HIPImageUtility : NSObject

/**
 *  根据颜色生成Image
 *
 *  @param color 颜色
 *
 *  @return UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  缩略图
 *
 *  @param srcImage 原图
 *  @param maxSide  最大边长
 *
 *  @return 缩略图UIImage
 */
+ (UIImage *)thumbImage:(UIImage *)srcImage maxSide:(CGFloat)maxSide;

/**
 *  UIView转UIImage
 *
 *  @param view UIView
 *
 *  @return UIImage
 */
+ (UIImage *)convertViewToImage:(UIView*)view;

/**
 *  根据名字生成Image
 *
 *  @param name 名字
 *
 *  @return UIImage
 */
+ (UIImage *)imageWithDispName:(NSString *)name;

+ (UIImage *)imageWithDispName2:(NSString *)name;

/**
 *  根据名字和中心图标生成Image
 *
 *  @param name      名字
 *  @param imageName 图标名字
 *
 *  @return UIImage
 */
+ (UIImage *)imageWithDispName:(NSString *)name coreIcon:(NSString *)imageName;

/**
 *  高斯模糊
 *
 *  @param image UIImage
 *
 *  @return 高斯模糊UIImage
 */
+ (UIImage *)gaussBlurWithImage:(UIImage *)image;

/**
 *  根据颜色和尺寸及比例生成图片
 *
 *  @param color 颜色
 *  @param size  尺寸
 *  @param power 比例
 *
 *  @return UIImage
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGFloat)size power:(CGFloat)power;

@end
