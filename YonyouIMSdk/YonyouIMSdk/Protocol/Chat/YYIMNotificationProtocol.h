//
//  YYIMNotificationProtocol.h
//  YonyouIMSdk
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMNotificationDelegate.h"
#import "YYSettings.h"

@protocol YYIMNotificationProtocol <NSObject>

@required

/**
 *  开启/关闭本地通知
 *
 *  @param enable 开启/关闭
 */
- (void)setEnableLocalNotification:(BOOL)enable;

/**
 *  用户设置
 *
 *  @return 用户设置
 */
- (YYSettings *)getSettings;

/**
 *  更新用户设置
 *
 *  @param settings 用户设置
 */
- (void)updateSettings:(YYSettings *)settings;

- (void)registerNotificationDelegate:(id<YYIMNotificationDelegate>) delegate;

@end
