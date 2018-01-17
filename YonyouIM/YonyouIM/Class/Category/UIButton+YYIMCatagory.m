//
//  UIButton+YYIMCatagory.m
//  YonyouIM
//
//  Created by litfb on 15/6/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "UIButton+YYIMCatagory.h"
#import "YYIMUtility.h"
#import "YYIMColorHelper.h"

@implementation UIButton (YYIMCatagory)

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    [self setBackgroundImage:[YYIMUtility imageWithColor:backgroundColor] forState:state];
}

@end
