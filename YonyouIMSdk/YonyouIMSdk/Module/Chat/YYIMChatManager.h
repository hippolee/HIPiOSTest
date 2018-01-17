//
//  YYIMChatManager.h
//  YonyouIM
//
//  Created by litfb on 14/12/30.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseDataManager.h"
//#import "YYIMChatProtocol.h"
#import "YYIMChatProtocol.h"

@interface YYIMChatManager : YYIMBaseDataManager<YYIMChatProtocol>

// providers
@property (retain, nonatomic) id<YYIMRosterProtocol> rosterProvider;
@property (retain, nonatomic) id<YYIMChatGroupProtocol> chatGroupProvider;
@property (retain, nonatomic) id<YYIMUserProtocol> userProvider;

+ (instancetype)sharedInstance;

@end

