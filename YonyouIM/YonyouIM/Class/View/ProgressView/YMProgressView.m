//
//  YMProgressView.m
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMProgressView.h"

@implementation YMProgressView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.backgroundColor = [UIColor clearColor];
}

- (void)didMoveToWindow {
    self.progressLayer.contentsScale = self.window.screen.scale;
}

- (YMProgressLayer *)progressLayer {
    return (YMProgressLayer *)self.layer;
}

- (CGFloat)progress {
    return self.progressLayer.progress;
}

- (void)setProgress:(CGFloat)progress {
    [self setProgress:progress animated:NO];    
}

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated {
    [self.progressLayer removeAnimationForKey:@"progress"];
    CGFloat pinnedProgress = MIN(MAX(progress, 0.0f), 1.0f);
    
    if (animated) {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"progress"];
        animation.duration = fabs(self.progress - pinnedProgress) + 0.1f;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.fromValue = [NSNumber numberWithFloat:self.progress];
        animation.toValue = [NSNumber numberWithFloat:pinnedProgress];
        [self.progressLayer addAnimation:animation forKey:@"progress"];
    } else {
        [self.progressLayer setNeedsDisplay];
    }
    
    self.progressLayer.progress = pinnedProgress;
}

- (UIColor *)progressTintColor {
    return self.progressLayer.progressTintColor;
}

- (void)setProgressTintColor:(UIColor *)progressTintColor {
    self.progressLayer.progressTintColor = progressTintColor;
    [self.progressLayer setNeedsDisplay];
}

- (UIColor *)progressBackColor {
    return self.progressLayer.progressBackColor;
}

- (void)setProgressBackColor:(UIColor *)progressBackColor {
    self.progressLayer.progressBackColor = progressBackColor;
    [self.progressLayer setNeedsDisplay];
}

@end
