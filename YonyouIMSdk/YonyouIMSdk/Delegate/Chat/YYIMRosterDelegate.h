//
//  YYIMRosterDelegate.h
//  YonyouIM
//
//  Created by litfb on 15/1/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YYIMRosterDelegate <NSObject>

@optional

/**
 *  好友信息变化
 */
- (void)didRosterChange;

/**
 *  好友信息变化
 *
 *  @param roster 好友
 */
- (void)didRosterUpdate:(YYRoster *)roster;

/**
 *  好友删除
 *
 *  @param rosterId 好友ID
 */
- (void)didRosterDelete:(NSString *)rosterId;

/**
 *  好友在线状态变化
 *
 *  @param rosterId 好友ID
 */
- (void)didRosterStateChange:(NSString *)rosterId;

/**
 *  收到好友邀请
 *
 *  @param roster 好友
 */
- (void)didRosterInviteReceived:(YYRoster *)roster;

/**
 *  好友邀请变化
 */
- (void)didRosterInviteChange;

/**
 *  加载好友信息失败
 *
 *  @param error
 */
- (void)didNotLoadRostersWithError:(YYIMError *)error;

@end
