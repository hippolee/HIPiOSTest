//
//  YYSettings.m
//  YonyouIMSdk
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYSettings.h"

@implementation YYSettings

+ (instancetype)defaultSettings {
    YYSettings *settings = [[YYSettings alloc] init];
    [settings setNewMsgRemind:YES];
    [settings setPlaySound:YES];
    [settings setPlayVibrate:YES];
    [settings setShowDetail:YES];
    return settings;
}

@end
