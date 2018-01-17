//
//  YYIMQRCodeUtility.h
//  YonyouIM
//
//  Created by litfb on 16/1/13.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ZXingObjC.h"

@interface YYIMQRCodeUtility : NSObject

/**
 *  根据文字生成二维码
 *
 *  @param source 文字
 *
 *  @return CIImage
 */
+ (CIImage *)createQRCodeImageWithSource:(NSString *)source;

/**
 *  二维码从新上色
 *
 *  @param image  CIImage
 *  @param fColor 前景色
 *  @param bColor 背景色
 *
 *  @return CIImage
 */
+ (CIImage *)recolorQRCodeImage:(CIImage *)image withForegroundColor:(UIColor *)fColor backgroundColor:(UIColor *)bColor;

/**
 *  调整二维码大小
 *
 *  @param image image
 *  @param dimension  dimension
 *
 *  @return UIImage
 */
+ (UIImage *)resizeQRCodeImage:(CIImage *)image withDimension:(CGFloat)dimension;

/**
 *  根据文字及边长生成二维码
 *
 *  @param source    文字
 *  @param dimension 边长
 *
 *  @return UIImage
 */
+ (UIImage *)createQRCodeImageWithSource:(NSString *)source dimension:(CGFloat)dimension;

/**
 *  根据文字，前景色，背景色，边长生成二维码
 *
 *  @param source    文字
 *  @param fColor    前景色
 *  @param bColor    背景色
 *  @param dimension 边长
 *
 *  @return UIImage
 */
+ (UIImage *)createQRCodeImageWithSource:(NSString *)source foregroundColor:(UIColor *)fColor backgroundColor:(UIColor *)bColor dimension:(CGFloat)dimension;

/**
 *  在二维码上添加图标
 *
 *  @param image    image
 *  @param icon     图标
 *  @param iconSize 图标尺寸
 *
 *  @return UIImage
 */
+ (UIImage *)decorateQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon iconSize:(CGSize)iconSize;

/**
 *  在二维码上添加图标
 *
 *  @param image    image
 *  @param icon     图标
 *  @param scale    图标比例
 *
 *  @return UIImage
 */
+ (UIImage *)decorateQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon scale:(CGFloat)scale;

/**
 *  扫描图像二维码（多次尝试）
 *
 *  @param image image
 *
 *  @return 扫描结果
 */
+ (ZXResult *)attemptScanQRCodeImage:(UIImage *)image;

/**
 *  扫描图像二维码
 *
 *  @param image image
 *
 *  @return 扫描结果
 */
+ (ZXResult *)scanQRCodeImage:(UIImage *)image;

/**
 *  处理二维码
 *
 *  @param qrCodeText 二维码文本
 *  @param controller 当前界面
 *  @param isClose    是否关闭当前界面
 */
+ (void)dealQrCodeWithText:(NSString *)qrCodeText atVC:(UIViewController *)controller closeVC:(BOOL)isClose;

@end
