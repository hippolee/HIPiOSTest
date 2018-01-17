//
//  YYUser.m
//  YonyouIM
//
//  Created by litfb on 15/1/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYUser.h"

#import "YYIMStringUtility.h"

@implementation YYUser

- (NSString *)getUserPhoto {
    return [YYIMStringUtility genFullPathRes:[self userPhoto]];
}

@end
