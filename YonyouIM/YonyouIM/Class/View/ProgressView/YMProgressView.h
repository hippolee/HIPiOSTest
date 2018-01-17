//
//  YMProgressView.h
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMProgressLayer.h"

@interface YMProgressView : UIView

@property (nonatomic) CGFloat progress;

@property (nonatomic, readonly) YMProgressLayer *progressLayer;

@property (nonatomic, strong) UIColor *progressTintColor;
@property (nonatomic, strong) UIColor *progressBackColor;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
