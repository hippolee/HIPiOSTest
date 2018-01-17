//
//  YYUserExt.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYUserExt.h"

@implementation YYUserExt

+ (instancetype)defaultUserExt:(NSString *)userId {
    YYUserExt *userExt = [[YYUserExt alloc] init];
    [userExt setUserId:userId];
    [userExt setNoDisturb:NO];
    [userExt setStickTop:NO];
    return userExt;
}

@end
