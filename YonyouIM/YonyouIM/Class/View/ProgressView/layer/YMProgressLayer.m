//
//  YMProgressLayer.m
//  YonyouIM
//
//  Created by litfb on 15/8/3.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YMProgressLayer.h"

@implementation YMProgressLayer

@dynamic progressTintColor;
@dynamic progressBackColor;

+ (BOOL)needsDisplayForKey:(NSString *)key {
    return [key isEqualToString:@"progress"] ? YES : [super needsDisplayForKey:key];
}

@end
