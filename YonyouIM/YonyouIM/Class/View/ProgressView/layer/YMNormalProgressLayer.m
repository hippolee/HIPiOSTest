//
//  YMNormalProgressLayer.m
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMNormalProgressLayer.h"

static const CGFloat kBorderWidth = 1.0f;

@implementation YMNormalProgressLayer

- (void)drawInContext:(CGContextRef)context {
    CGRect rect = CGRectInset(self.bounds, kBorderWidth, kBorderWidth);
    CGFloat radius = CGRectGetHeight(rect) / 2.0f;
    CGContextSetLineWidth(context, kBorderWidth);
    CGContextSetStrokeColorWithColor(context, self.progressBackColor.CGColor);
    [self drawRectangleInContext:context inRect:rect withRadius:radius];
    CGContextStrokePath(context);
    
    
    CGContextSetFillColorWithColor(context, self.progressTintColor.CGColor);
    CGRect progressRect = CGRectInset(rect, 2 * kBorderWidth, 2 * kBorderWidth);
    CGFloat progressRadius = CGRectGetHeight(progressRect) / 2.0f;
    progressRect.size.width = fmaxf(self.progress * progressRect.size.width, 2.0f * progressRadius);
    [self drawRectangleInContext:context inRect:progressRect withRadius:progressRadius];
    CGContextFillPath(context);
}

- (void)drawRectangleInContext:(CGContextRef)context inRect:(CGRect)rect withRadius:(CGFloat)radius {
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, radius, M_PI, M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, radius, 0.0f, -M_PI / 2, 1);
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, -M_PI / 2, M_PI, 1);
}

@end
