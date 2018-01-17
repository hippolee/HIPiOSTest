//
//  YYChatGroupExt.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYChatGroupExt.h"

@implementation YYChatGroupExt

+ (instancetype)defaultChatGroupExt:(NSString *)groupId {
    YYChatGroupExt *groupExt = [[YYChatGroupExt alloc] init];
    [groupExt setGroupId:groupId];
    [groupExt setNoDisturb:NO];
    [groupExt setStickTop:NO];
    [groupExt setShowName:YES];
    return groupExt;
}

@end
