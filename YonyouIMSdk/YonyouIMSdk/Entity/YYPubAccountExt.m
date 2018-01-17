//
//  YYPubAccountExt.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/14.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYPubAccountExt.h"

@implementation YYPubAccountExt

+ (instancetype)defaultPubAccountExt:(NSString *)accountId {
    YYPubAccountExt *accountExt = [[YYPubAccountExt alloc] init];
    [accountExt setAccountId:accountId];
    [accountExt setNoDisturb:NO];
    [accountExt setStickTop:NO];
    return accountExt;
}

@end
