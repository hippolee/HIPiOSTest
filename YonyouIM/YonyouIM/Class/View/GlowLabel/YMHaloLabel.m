//
//  YMHaloLabel.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YMHaloLabel.h"

@implementation YMHaloLabel

//@dynamic shadowOffset, shadowAmount, shadowColor;

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self initialize];
}

- (void)initialize {
    self.haloOffset = CGSizeMake(0.0, 0.0);
    self.haloAmount = 0.0;
    self.haloColor = [UIColor clearColor];
}

- (void)drawTextInRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetShadowWithColor(context, self.haloOffset, self.haloAmount, self.haloColor.CGColor);
    if (self.text && [self.text length] > 0) {
        [super drawTextInRect:rect];
    } else {
        CGContextSetShadowWithColor(context, CGSizeMake(0.0f, 1.0f), 1.0f, self.haloColor.CGColor);
        
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        // 添加一个圆
        CGContextAddArc(context, (CGRectGetWidth(self.frame) - 6) / 2, (CGRectGetHeight(self.frame) - 6) / 2, 6, 0, 2 * M_PI, 0);
        // 绘制路径
        CGContextDrawPath(context, kCGPathFill);
    }
    CGContextRestoreGState(context);
}

@end
