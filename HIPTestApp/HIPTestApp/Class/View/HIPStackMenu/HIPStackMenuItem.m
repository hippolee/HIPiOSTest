//
//  HIPStackMenuItem.m
//  litfb_test
//
//  Created by litfb on 16/5/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPStackMenuItem.h"

@implementation HIPStackMenuItem

- (instancetype)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if (self = [self initWithFrame:CGRectZero]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        [self setImage:image forState:UIControlStateNormal];
        [self setImage:highlightedImage forState:UIControlStateHighlighted];
        [self setImage:highlightedImage forState:UIControlStateSelected];
        
        CALayer *layer = [self layer];
        [layer setMasksToBounds:YES];
        [layer setBorderColor:[UIColor grayColor].CGColor];
        [layer setBorderWidth:1.0f];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [[self layer] setCornerRadius:(fmin(CGRectGetWidth(frame), CGRectGetHeight(frame)) - 1) / 2];
}

@end
