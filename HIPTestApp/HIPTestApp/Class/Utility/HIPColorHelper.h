//
//  HIPColorHelper.h
//  YonyouIM
//
//  Created by litfb on 15/6/17.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaValue]

#define HIP_THEME_RED UIColorFromRGB(0xff3333)

#define HIP_THEME_ORANGE UIColorFromRGB(0xff9933)

#define HIP_THEME_YELLOW UIColorFromRGB(0xffff33)

#define HIP_THEME_GREEN UIColorFromRGB(0x33ff33)

#define HIP_THEME_BLUE UIColorFromRGB(0x3399ff)

#define HIP_THEME_PURPLE UIColorFromRGB(0x9933ff)

#define HIP_THEME_GRAY UIColorFromRGB(0xefefef)

@interface HIPColorHelper : NSObject

+ (instancetype)sharedInstance;

- (UIColor *)colorForLetter:(NSString *)letterString;

@end
