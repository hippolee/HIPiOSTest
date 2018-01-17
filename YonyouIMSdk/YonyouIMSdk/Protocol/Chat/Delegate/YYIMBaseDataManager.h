//
//  YYIMBaseDataManager.h
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseProtocol.h"
#import "YYIMChatDelegate.h"

@class JUMPStream;
@class JUMPIDTracker;
@class YMGCDMulticastDelegate;

@interface YYIMBaseDataManager : NSObject<YYIMBaseProtocol>

- (BOOL)activateWithJUMPStream:(JUMPStream *)aJumpStream delegate:(YMGCDMulticastDelegate<YYIMChatDelegate> *)aDelegate;

- (void)didActivate;

- (void)addDelegate:(id<YYIMChatDelegate>)delegate;

- (void)removeDelegate:(id<YYIMChatDelegate>)delegate;

- (NSString *)moduleName;

- (dispatch_queue_t)moduleQueue;

- (JUMPStream *)activeStream;

- (YMGCDMulticastDelegate<YYIMChatDelegate> *)activeDelegate;

- (JUMPIDTracker *)tracker;

- (void)playSoundAndVibrate;

- (void)playSound;

- (void)playVibrate;

@end
