//
//  HIPSliderPopover.m
//  litfb_test
//
//  Created by litfb on 16/5/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPSliderPopover.h"

#define HIP_SLIDER_POPOVER_ARROWSIZE 6.0f
#define HIP_SLIDER_POPOVER_RADIUS    4.0f

@interface HIPSliderPopover () {
    
    UIColor *_bgColor;
    
    UIColor *_lineColor;
    
}

@property (weak, nonatomic) UILabel *textLabel;

@end

@implementation HIPSliderPopover

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.opaque = NO;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(HIP_SLIDER_POPOVER_RADIUS, HIP_SLIDER_POPOVER_RADIUS, CGRectGetWidth(frame) - HIP_SLIDER_POPOVER_RADIUS * 2, CGRectGetHeight(frame) - HIP_SLIDER_POPOVER_ARROWSIZE - HIP_SLIDER_POPOVER_RADIUS * 2)];
        [textLabel setBackgroundColor:[UIColor clearColor]];
        [textLabel setFont:[UIFont boldSystemFontOfSize:13]];
        [textLabel setTextAlignment:NSTextAlignmentCenter];
        [textLabel setAdjustsFontSizeToFitWidth:YES];
        [textLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [self addSubview:textLabel];
        self.textLabel = textLabel;
    }
    return self;
}

- (void)setText:(NSString *)text {
    [self.textLabel setText:text];
}

- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = [UIColor blackColor];
    }
    return _lineColor;
}

- (void)setLineColor:(UIColor *)lineColor {
    _lineColor = lineColor;
}

- (UIColor *)bgColor {
    if (!_bgColor) {
        _bgColor = [UIColor whiteColor];
    }
    return _bgColor;
}

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = bgColor;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 线的宽度
    CGContextSetLineWidth(context, 0.4);
    // 填充颜色
    CGContextSetFillColorWithColor(context, [self.bgColor CGColor]);
    // 线框颜色
    CGContextSetStrokeColorWithColor(context, [self.lineColor CGColor]);
    
    // 尖角左基点
    CGContextMoveToPoint(context, CGRectGetWidth(rect) / 2 - HIP_SLIDER_POPOVER_ARROWSIZE / 2, CGRectGetHeight(rect) - HIP_SLIDER_POPOVER_ARROWSIZE);
    // 尖角顶点
    CGContextAddLineToPoint(context, CGRectGetWidth(rect) / 2, CGRectGetHeight(rect));
    // 连接尖角右基点
    CGContextAddLineToPoint(context, CGRectGetWidth(rect) / 2 + HIP_SLIDER_POPOVER_ARROWSIZE / 2, CGRectGetHeight(rect) - HIP_SLIDER_POPOVER_ARROWSIZE);
    // 右下角弧
    CGContextAddArcToPoint(context, CGRectGetWidth(rect), CGRectGetHeight(rect) - HIP_SLIDER_POPOVER_ARROWSIZE, CGRectGetWidth(rect), 0, HIP_SLIDER_POPOVER_RADIUS);
    // 右上角弧
    CGContextAddArcToPoint(context, CGRectGetWidth(rect), 0, 0, 0, HIP_SLIDER_POPOVER_RADIUS);
    // 左上角弧
    CGContextAddArcToPoint(context, 0, 0, 0, CGRectGetHeight(rect) - HIP_SLIDER_POPOVER_ARROWSIZE, HIP_SLIDER_POPOVER_RADIUS);
    // 左下角弧
    CGContextAddArcToPoint(context, 0, CGRectGetHeight(rect) - HIP_SLIDER_POPOVER_ARROWSIZE, CGRectGetWidth(rect) / 2 - HIP_SLIDER_POPOVER_ARROWSIZE / 2, CGRectGetHeight(rect) - HIP_SLIDER_POPOVER_ARROWSIZE, HIP_SLIDER_POPOVER_RADIUS);
    // colsePath
    CGContextClosePath(context);
    // 根据坐标绘制路径
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end
