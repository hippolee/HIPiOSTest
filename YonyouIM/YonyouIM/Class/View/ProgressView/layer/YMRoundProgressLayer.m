//
//  YMRoundProgressLayer.m
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMRoundProgressLayer.h"

static const CGFloat kBorderWidth = 1.0f;

@implementation YMRoundProgressLayer

- (void)drawInContext:(CGContextRef)context {
    
    CGPoint center = CGPointMake(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2);
    
    CGRect rect = CGRectInset(self.bounds, kBorderWidth, kBorderWidth);
    CGFloat radius = CGRectGetHeight(rect) / 2.0f;
    CGContextSetLineWidth(context, kBorderWidth);
    CGContextSetStrokeColorWithColor(context, self.progressBackColor.CGColor);
    CGContextAddArc(context, center.x, center.y, radius, M_PI, -M_PI, 1);
    CGContextStrokePath(context);
    
    float angle = 2 * M_PI * self.progress;
    CGRect rect2 = CGRectInset(rect, 4, 4);
    CGFloat radius2 = CGRectGetHeight(rect2) / 2.0f;
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, self.progressTintColor.CGColor);
    CGContextAddArc(context, center.x, center.y, radius2, - M_PI / 2, angle - M_PI / 2, 0);
    CGContextStrokePath(context);
    
    CGRect rect3 = CGRectInset(self.bounds, 9, 9);
    CGFloat radius3 = CGRectGetHeight(rect3) / 2.0f;
    CGContextSetLineWidth(context, kBorderWidth);
    CGContextSetStrokeColorWithColor(context, self.progressBackColor.CGColor);
    CGContextAddArc(context, center.x, center.y, radius3, M_PI, -M_PI, 1);
    CGContextStrokePath(context);
    
    
    
    UIGraphicsPushContext(context);
    CGContextSetStrokeColorWithColor(context, self.progressTintColor.CGColor);
    NSString *percent = [NSString stringWithFormat:@"%0.2f%%", self.progress * 100];
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.alignment = NSTextAlignmentCenter;
    
    float fontSize = 16.0f;
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont boldSystemFontOfSize:fontSize], NSFontAttributeName, self.progressTintColor, NSForegroundColorAttributeName, [UIColor clearColor], NSBackgroundColorAttributeName, paragraph, NSParagraphStyleAttributeName, nil];
    
    [percent drawInRect:CGRectMake(5, (CGRectGetHeight(self.bounds) - fontSize)/2, CGRectGetWidth(self.bounds) - 10, fontSize) withAttributes:attributes];
    
    UIGraphicsPopContext();
}

@end
