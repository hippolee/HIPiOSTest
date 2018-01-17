//
//  HIPBubbleView.m
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "HIPBubbleView.h"

@implementation HIPBubbleView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setContentMode:UIViewContentModeRedraw];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initShapeLayer];
    }
    return self;
}

- (void)setDirection:(HIPBubbleDirection)direction {
    if (_direction != direction) {
        _direction = direction;
        [self initShapeLayer];
    }
}

- (void)initShapeLayer {
    CGMutablePathRef path = [self bubblePath];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    [maskLayer setPath:path];
    [self.layer setMask:maskLayer];
    
    CFRelease(path);
}

- (CGMutablePathRef)bubblePath {
    CGRect rect = self.frame;
    CGFloat arrowWidth = 8.0f;
    CGFloat radius = 4.0f;
    
    CGMutablePathRef path = CGPathCreateMutable();
    // 尖角下基点
    CGPathMoveToPoint(path, NULL, [self getPointX:arrowWidth inRect:rect], 27);
    // 连接尖角顶点
    CGPathAddLineToPoint(path, NULL, [self getPointX:0 inRect:rect], 21);
    // 连接尖角上基点
    CGPathAddLineToPoint(path, NULL, [self getPointX:arrowWidth inRect:rect], 15);
    // 左上角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:arrowWidth inRect:rect], 0, [self getPointX:CGRectGetWidth(rect) - radius inRect:rect], 0, radius);
    // 右上角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:CGRectGetWidth(rect) inRect:rect], 0, [self getPointX:CGRectGetWidth(rect) inRect:rect], CGRectGetHeight(rect) - radius, radius);
    // 右下角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:CGRectGetWidth(rect) inRect:rect], CGRectGetHeight(rect), [self getPointX:arrowWidth + radius inRect:rect], CGRectGetHeight(rect), radius);
    // 左下角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:arrowWidth inRect:rect], CGRectGetHeight(rect), [self getPointX:arrowWidth inRect:rect], 27, radius);
    // colsePath
    CGPathCloseSubpath(path);
    return path;
}

- (CGFloat)getPointX:(CGFloat)x inRect:(CGRect)rect {
    switch (self.direction) {
        case HIPBubbleDirectionLeft:
            return x;
        case HIPBubbleDirectionRight:
            return CGRectGetWidth(rect) - x;
    }
    return 0;
}

@end
