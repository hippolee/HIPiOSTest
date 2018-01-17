//
//  ChatBubbleView.m
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatBubbleView.h"
#import "YYIMColorHelper.h"

@implementation ChatBubbleView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    self.showArrow = YES;
    [self setContentMode:UIViewContentModeRedraw];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setShowArrow:(BOOL)showArrow {
    BOOL isChange = _showArrow ^ showArrow;
    _showArrow = showArrow;
    if (isChange) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1);//线的宽度
    switch (self.direction) {
        case kYMChatBubbleDirectionLeft:
            // 填充颜色
            CGContextSetFillColorWithColor(context, UIColorFromRGB(kYMChatBackgroundColorLeft).CGColor);
            // 线框颜色
            CGContextSetStrokeColorWithColor(context, UIColorFromRGB(kYMChatBorderColorLeft).CGColor);
            break;
        case kYMChatBubbleDirectionRight:
            // 填充颜色
            CGContextSetFillColorWithColor(context, UIColorFromRGB(kYMChatBackgroundColorRight).CGColor);
            // 线框颜色
            CGContextSetStrokeColorWithColor(context, UIColorFromRGB(kYMChatBorderColorRight).CGColor);
            break;
        default:
            return;
    }
    
    CGFloat arrowWidth = 8.0f;
    
    // 尖角下基点
    CGContextMoveToPoint(context, [self getPointX:arrowWidth inRect:rect], 27);
    if (self.showArrow) {
        // 连接尖角顶点
        CGContextAddLineToPoint(context, [self getPointX:0 inRect:rect], 21);
    }
    // 连接尖角上基点
    CGContextAddLineToPoint(context, [self getPointX:arrowWidth inRect:rect], 15);
    
    CGFloat radius = 4.0f;
    // 左上角弧
    CGContextAddArcToPoint(context, [self getPointX:arrowWidth inRect:rect], 0, [self getPointX:CGRectGetWidth(rect) - radius inRect:rect], 0, radius);
    // 右上角弧
    CGContextAddArcToPoint(context, [self getPointX:CGRectGetWidth(rect) inRect:rect], 0, [self getPointX:CGRectGetWidth(rect) inRect:rect], CGRectGetHeight(rect) - radius, radius);
    // 右下角弧
    CGContextAddArcToPoint(context, [self getPointX:CGRectGetWidth(rect) inRect:rect], CGRectGetHeight(rect), [self getPointX:arrowWidth + radius inRect:rect], CGRectGetHeight(rect), radius);
    // 左下角弧
    CGContextAddArcToPoint(context, [self getPointX:arrowWidth inRect:rect], CGRectGetHeight(rect), [self getPointX:arrowWidth inRect:rect], 27, radius);
    // colsePath
    CGContextClosePath(context);
    // 根据坐标绘制路径
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (CGFloat)getPointX:(CGFloat)x inRect:(CGRect)rect {
    switch (self.direction) {
        case kYMChatBubbleDirectionLeft:
            return x;
        case kYMChatBubbleDirectionRight:
            return CGRectGetWidth(rect) - x;
    }
    return 0;
}

@end
