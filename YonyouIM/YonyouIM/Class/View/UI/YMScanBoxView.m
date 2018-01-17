//
//  YMScanBoxView.m
//  YonyouIM
//
//  Created by litfb on 16/1/13.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YMScanBoxView.h"
#import "YYIMColorHelper.h"
#import "UIColor+YYIMTheme.h"

@interface YMScanBoxView ()

@property CGRect scanRect;

@end

@implementation YMScanBoxView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initView];
}

- (instancetype)initWithFrame:(CGRect)frame scanRect:(CGRect)rect {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        self.scanRect = rect;
    }
    return self;
}

- (void)initView {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setContentMode:UIViewContentModeRedraw];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, UIColorFromRGBA(0x000000, 0.3).CGColor);
    
    CGContextAddRect(context, self.frame);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGRect centerRect =  CGRectMake(self.scanRect.origin.x - 1, self.scanRect.origin.y - 1, CGRectGetWidth(self.scanRect) + 2, CGRectGetHeight(self.scanRect) + 2);
    
    CGContextClearRect(context, centerRect);
    
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    CGContextSetLineWidth(context, 0.5);
    
    CGContextAddRect(context, centerRect);
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextSetLineWidth(context, 3.0);
    
    CGFloat lineLength = CGRectGetWidth(self.scanRect) / 16;
    
    CGContextSetStrokeColorWithColor(context, [UIColor themeBlueColor].CGColor);
    
    CGContextMoveToPoint(context, self.scanRect.origin.x, self.scanRect.origin.y + lineLength);
    CGContextAddLineToPoint(context, self.scanRect.origin.x, self.scanRect.origin.y);
    CGContextAddLineToPoint(context, self.scanRect.origin.x + lineLength, self.scanRect.origin.y);
    
    CGContextMoveToPoint(context, self.scanRect.origin.x + CGRectGetWidth(self.scanRect) - lineLength, self.scanRect.origin.y);
    CGContextAddLineToPoint(context, self.scanRect.origin.x + CGRectGetWidth(self.scanRect), self.scanRect.origin.y);
    CGContextAddLineToPoint(context, self.scanRect.origin.x + CGRectGetWidth(self.scanRect), self.scanRect.origin.y + lineLength);
    
    CGContextMoveToPoint(context, self.scanRect.origin.x + CGRectGetWidth(self.scanRect), self.scanRect.origin.y + CGRectGetHeight(self.scanRect) - lineLength);
    CGContextAddLineToPoint(context, self.scanRect.origin.x + CGRectGetWidth(self.scanRect), self.scanRect.origin.y + CGRectGetHeight(self.scanRect));
    CGContextAddLineToPoint(context, self.scanRect.origin.x + CGRectGetWidth(self.scanRect) - lineLength, self.scanRect.origin.y + CGRectGetHeight(self.scanRect));
    
    CGContextMoveToPoint(context, self.scanRect.origin.x + lineLength, self.scanRect.origin.y + CGRectGetHeight(self.scanRect));
    CGContextAddLineToPoint(context, self.scanRect.origin.x, self.scanRect.origin.y + CGRectGetHeight(self.scanRect));
    CGContextAddLineToPoint(context, self.scanRect.origin.x, self.scanRect.origin.y + CGRectGetHeight(self.scanRect) - lineLength);
    CGContextDrawPath(context, kCGPathStroke);
}

@end
