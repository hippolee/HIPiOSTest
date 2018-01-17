//
//  YMProgressLayer.h
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface YMProgressLayer : CALayer

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *progressBackColor;

@property (nonatomic) CGFloat progress;

@end
