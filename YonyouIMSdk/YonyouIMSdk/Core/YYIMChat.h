//
//  YYIMChat.h
//  YonyouIM
//
//  Created by litfb on 14/12/25.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "YYIMError.h"
#import "YYIMChatProtocol.h"

@interface YYIMChat : NSObject<UIApplicationDelegate>

@property (nonatomic, readonly, strong) id<YYIMChatProtocol> chatManager;

+ (instancetype)sharedInstance;

- (NSString *)getSdkVersion;

- (YYIMError *)registerApp:(NSString *)appKey etpKey:(NSString *)etpKey;

- (void)registerApnsCerName:(NSString *)apnsCerName;

- (void)regisgerRosterProvider:(id<YYIMRosterProtocol>)rosterProvider;

- (void)registerChatGroupProvider:(id<YYIMChatGroupProtocol>)chatGroupProvider;

- (void)registerUserProvider:(id<YYIMUserProtocol>)userProvider;

- (void)setLogLevel:(int)logLevel;

@end
