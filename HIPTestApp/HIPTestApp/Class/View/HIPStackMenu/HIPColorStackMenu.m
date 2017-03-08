//
//  HIPColorStackMenu.m
//  litfb_test
//
//  Created by litfb on 16/5/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPColorStackMenu.h"
#import "HIPColorStackMenuItem.h"

@implementation HIPColorStackMenu

- (void)setPower:(NSUInteger)power {
    [_items enumerateObjectsUsingBlock:^(HIPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        if (![item isKindOfClass:[HIPColorStackMenuItem class]]) {
            return;
        }
        [(HIPColorStackMenuItem *)item setPower:power];
    }];
}

@end
