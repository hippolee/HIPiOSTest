//
//  UIButton+HIPCategory.m
//  litfb_test
//
//  Created by litfb on 16/7/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "UIButton+HIPCategory.h"
#import "HIPImageUtility.h"

@implementation UIButton (HIPCategory)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[HIPImageUtility imageWithColor:backgroundColor] forState:state];
}

@end
