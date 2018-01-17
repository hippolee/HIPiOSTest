//
//  YYIMNotificationDelegate.h
//  YonyouIMSdk
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYSettings.h"

@protocol YYIMNotificationDelegate <NSObject>

@optional

- (void)didSettingUpdate:(YYSettings *)settings;

- (void)notificationNoDetail:(YYMessage *)message complete:(void (^)(BOOL result, NSString* notificationBody))completeBlock;

- (void)notificationWithDetail:(YYMessage *)message complete:(void (^)(BOOL result, NSString* notificationBody))completeBlock;

@end
