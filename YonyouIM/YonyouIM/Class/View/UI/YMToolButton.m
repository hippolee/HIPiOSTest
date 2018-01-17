//
//  YMToolButton.m
//  YonyouIM
//
//  Created by litfb on 15/7/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMToolButton.h"

@implementation YMToolButton

- (void)setImage:(UIImage *)image title:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)state {
    [self setImage:image forState:state];
    [self setTitle:title forState:state];
    [self setTitleColor:color forState:state];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // Center image
    CGPoint center = self.imageView.center;
    center.x = self.frame.size.width / 2;
    center.y = self.imageView.frame.size.height / 2 + 4;
    self.imageView.center = center;
    
    //Center text
    CGRect newFrame = [self titleLabel].frame;
    newFrame.origin.x = 0;
    newFrame.origin.y = self.imageView.frame.size.height + 8;
    newFrame.size.width = self.frame.size.width;
    self.titleLabel.frame = newFrame;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

@end
