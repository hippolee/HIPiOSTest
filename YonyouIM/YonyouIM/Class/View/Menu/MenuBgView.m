//
//  MenuBgView.m
//  YonyouIM
//
//  Created by litfb on 15/6/16.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "MenuBgView.h"
#import "UIColor+YYIMTheme.h"

@implementation MenuBgView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *aColor = [UIColor themeColor];
//    aColor = [aColor colorWithAlphaComponent:0.96f];
    CGContextSetLineWidth(context, 0.0);//线的宽度
    CGContextSetFillColorWithColor(context, aColor.CGColor);//填充颜色
    CGContextAddRect(context,CGRectMake(0, 8, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - 8));//画方框
    CGContextDrawPath(context, kCGPathFillStroke);//绘画路径
    
    // 画三角形
    CGPoint sPoints[3];//坐标点
    sPoints[0] = CGPointMake(CGRectGetWidth(self.frame) - 20, 2);//坐标1
    sPoints[1] = CGPointMake(CGRectGetWidth(self.frame) - 16, 8);//坐标2
    sPoints[2] = CGPointMake(CGRectGetWidth(self.frame) - 24, 8);//坐标3
    CGContextAddLines(context, sPoints, 3);//添加线
    CGContextClosePath(context);//封起来
    CGContextDrawPath(context, kCGPathFillStroke); //根据坐标绘制路径
}

@end
