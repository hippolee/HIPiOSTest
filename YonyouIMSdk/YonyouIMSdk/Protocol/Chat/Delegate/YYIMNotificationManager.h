//
//  YYIMNotificationManager.h
//  YonyouIMSdk
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//
#import <Foundation/Foundation.h>

#import "YYIMBaseDataManager.h"
#import "YYIMNotificationProtocol.h"

@interface YYIMNotificationManager : YYIMBaseDataManager<YYIMNotificationProtocol, YYIMChatDelegate>

+ (instancetype)sharedInstance;

- (void)startLazyNotify;

- (void)stopLazyNotify;

- (void)didReceiveOfflineMessage;

@end
