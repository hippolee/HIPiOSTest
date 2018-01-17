//
//  YYIMChatProtocol.h
//  YonyouIM
//
//  Created by litfb on 14/12/30.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMLoginProtocol.h"
#import "YYIMMessageProtocol.h"
#import "YYIMRosterProtocol.h"
#import "YYIMChatGroupProtocol.h"
#import "YYIMUserProtocol.h"
#import "YYIMTokenProtocol.h"
#import "YYIMConnectProtocol.h"
#import "YYIMExtProtocol.h"
#import "YYIMPubAccountProtocol.h"
#import "YYIMNotificationProtocol.h"
#import "YYIMTeleconferenceProtocol.h"
#import "YYIMAttachProtocol.h"
#import "YYIMNetMeetingProtocol.h"

@protocol YYIMChatProtocol<YYIMBaseProtocol, YYIMLoginProtocol, YYIMMessageProtocol, YYIMRosterProtocol, YYIMChatGroupProtocol, YYIMUserProtocol, YYIMTokenProtocol, YYIMConnectProtocol, YYIMExtProtocol, YYIMPubAccountProtocol, YYIMNotificationProtocol, YYIMTeleconferenceProtocol, YYIMAttachProtocol, YYIMNetMeetingProtocol>

@required

- (void)addDelegate:(id<YYIMChatDelegate>)delegate;

- (void)removeDelegate:(id<YYIMChatDelegate>)delegate;

- (void)regisgerRosterProvider:(id<YYIMRosterProtocol>)rosterProvider;

- (void)registerChatGroupProvider:(id<YYIMChatGroupProtocol>) chatGroupProvider;

- (void)registerUserProvider:(id<YYIMUserProtocol>)userProvider;

@end
