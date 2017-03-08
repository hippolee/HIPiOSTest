//
//  HIPColorStackMenuItem.h
//  litfb_test
//
//  Created by litfb on 16/5/23.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "HIPStackMenuItem.h"

@interface HIPColorStackMenuItem : HIPStackMenuItem

- (instancetype)initWithColor:(UIColor *)color power:(NSUInteger)power;

- (void)setPower:(NSUInteger)power;

@end
