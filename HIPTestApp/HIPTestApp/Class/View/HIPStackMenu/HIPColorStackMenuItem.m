//
//  HIPColorStackMenuItem.m
//  litfb_test
//
//  Created by litfb on 16/5/23.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPColorStackMenuItem.h"
#import "HIPImageUtility.h"
#import "UIButton+HIPCategory.h"

@interface HIPColorStackMenuItem ()

@property (strong, nonatomic) UIColor *color;

@property (nonatomic) NSUInteger power;

@end

@implementation HIPColorStackMenuItem

- (instancetype)initWithColor:(UIColor *)color power:(NSUInteger)power {
    if (self = [super init]) {
        self.color = color;
        self.power = power;
        [self setBackgroundColor:[UIColor lightGrayColor]];
        
        CALayer *layer = [self layer];
        [layer setMasksToBounds:YES];
        [layer setBorderColor:[self.color CGColor]];
        [layer setBorderWidth:0.5f];
    }
    return self;
}

- (void)setPower:(NSUInteger)power {
    _power = power;
    [self resetImage];
}

- (void)resetImage {
    [self setImage:[HIPImageUtility imageWithColor:_color size:120.0f power:_power] forState:UIControlStateNormal];
}

@end
