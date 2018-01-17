//
//  YKJBubbleView.m
//  YonyouIM
//
//  Created by litfb on 15/6/19.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YKJBubbleView.h"

@implementation YKJBubbleView

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

- (void)setDirection:(YKJBubbleDirection)direction {
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
    
    CGFloat cornerRadius = 20.0f;
    CGFloat sharpUpRadius = 70.0f;
    CGFloat sharpPoingRadius = 3.0f;
    CGFloat sharpDownRadius = 50.0f;
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // 尖角下基点
    CGPathMoveToPoint(path, NULL, [self getPointX:10.0f inRect:rect], 40);
    // 尖角下弧度
    CGPathAddArcToPoint(path, NULL, [self getPointX:10.0f inRect:rect], 23.0f, [self getPointX:1.0f inRect:rect], 10.0f, sharpDownRadius);
    // 尖角顶弧度
    CGPathAddArcToPoint(path, NULL, [self getPointX:0.0f inRect:rect], 8.0f, [self getPointX:3.0f inRect:rect], 6.0f, sharpPoingRadius);
    // 尖角上弧度
    CGPathAddArcToPoint(path, NULL, [self getPointX:8.0f inRect:rect], 7.0f, [self getPointX:15.0f inRect:rect], 9.0f, sharpUpRadius);
    // 左上角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:19.0f inRect:rect], 0, [self getPointX:30.0f inRect:rect], 0, cornerRadius);
    // 右上角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:CGRectGetWidth(rect) inRect:rect], 0, [self getPointX:CGRectGetWidth(rect) inRect:rect], 20.0f, cornerRadius);
    // 右下角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:CGRectGetWidth(rect) inRect:rect], CGRectGetHeight(rect), [self getPointX:CGRectGetWidth(rect) - cornerRadius inRect:rect], CGRectGetHeight(rect), cornerRadius);
    // 左下角弧
    CGPathAddArcToPoint(path, NULL, [self getPointX:10.0f inRect:rect], CGRectGetHeight(rect), [self getPointX:10.0f inRect:rect], CGRectGetHeight(rect) - cornerRadius, cornerRadius);
    
    CGPathCloseSubpath(path);
    return path;
}

- (CGFloat)getPointX:(CGFloat)x inRect:(CGRect)rect {
    switch (self.direction) {
        case YKJBubbleDirectionLeft:
            return x;
        case YKJBubbleDirectionRight:
            return CGRectGetWidth(rect) - x;
    }
    return 0;
}

@end

