//
//  HIPNavigationBar.m
//  litfb_test
//
//  Created by litfb on 16/5/19.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPNavigationBar.h"

@implementation HIPNavigationBar

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize fitSize = [super sizeThatFits:size];
    if ([self hidden]) {
        fitSize.height = 0;
    }
    return fitSize;
}

@end
