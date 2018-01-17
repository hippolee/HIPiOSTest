//
//  YYToken.m
//  YonyouIMSdk
//
//  Created by litfb on 15/3/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYToken.h"

@interface YYToken ()

@property NSTimeInterval expiration;

@end

@implementation YYToken

+ (instancetype)tokenWithExpiration:(NSString *)tokenStr expiration:(NSString *)expirationStr {
    YYToken *token = [[YYToken alloc] init];
    token.tokenStr = tokenStr;
    token.expiration = [expirationStr doubleValue] / 1000;
    return token;
}

- (NSTimeInterval)expirationTimeInterval {
    return self.expiration;
}

@end
