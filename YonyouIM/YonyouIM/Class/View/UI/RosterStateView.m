//
//  RosterStateView.m
//  YonyouIM
//
//  Created by litfb on 15/8/25.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "RosterStateView.h"

@implementation RosterStateView

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setStateColor:(UIColor *)stateColor {
    _stateColor = stateColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 边框颜色
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    // 填充颜色
    CGContextSetFillColorWithColor(context, [self stateColor].CGColor);
    CGContextSetLineWidth(context, 3.0);//线的宽度
    // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
    CGFloat radius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2;
    // 填充圆
    CGContextAddArc(context, CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2, radius, 0, 2*M_PI, 0);
    //绘制路径加填充
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
