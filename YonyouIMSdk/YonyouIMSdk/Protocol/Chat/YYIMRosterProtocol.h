//
//  YYIMRosterProtocol.h
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseProtocol.h"
#import "YYIMDefs.h"

@protocol YYIMRosterProtocol <YYIMBaseProtocol>

@optional

- (void)activeYYIMDelegate:(id<YYIMChatDelegate>)delegate;

- (void)updateRosterState:(NSInteger)state roster:(NSString *)rosterId clientType:(YYIMClientType)clientType;

@required

/**
 *  获得所有好友对象
 *
 *  @return NSArray<YYRoster>
 */
- (NSArray *)getAllRoster;

- (NSArray *)getAllRosterWithAsk;

/**
 *  根据好友ID获得好友对象
 *
 *  @param rosterId 好友ID
 *
 *  @return YYRoster
 */
- (YYRoster *)getRosterWithId:(NSString *)rosterId;

- (void)loadRoster;

/**
 *  添加好友
 *
 *  @param userId 用户ID
 */
- (void)addRoster:(NSString *)userId;

/**
 *  获得所有好友邀请
 *
 *  @return NSArray<YYRoster>
 */
- (NSArray *)getAllRosterInvite;

/**
 *  获得未处理的好友邀请数量
 *
 *  @return NSInteger
 */
- (NSInteger)getNewRosterInviteCount;

/**
 *  同意好友邀请
 *
 *  @param userId 用户ID
 */
- (void)acceptRosterInvite:(NSString *)userId;

/**
 *  拒绝好友邀请
 *
 *  @param userId 用户ID
 */
- (void)refuseRosterInvite:(NSString *)userId;

/**
 *  删除好友
 *
 *  @param rosterId 好友ID
 */
- (void)deleteRoster:(NSString *)rosterId;

/**
 *  重命名好友
 *
 *  @param rosterId 好友ID
 *  @param name     备注名
 */
- (void)renameRoster:(NSString *)rosterId name:(NSString *)name;

/**
 *  设置好友的tag
 *
 *  @param rosterTags tag集合
 *  @param rosterId   好友Id
 *  @param complete   执行的回调
 */
- (void)addRosterTags:(NSArray *)rosterTags rosterId:(NSString *)rosterId complete:(void (^)(BOOL result, YYIMError *error))complete;

/**
 *  删除好友的tag
 *
 *  @param rosterTags tag集合
 *  @param rosterId   好友Id
 *  @param complete   执行的回调
 */
- (void)deleteRosterTags:(NSArray *)rosterTags rosterId:(NSString *)rosterId complete:(void (^)(BOOL result, YYIMError *error))complete;

/**
 *  通过tag获取好友集合
 *
 *  @param tag tag
 *
 *  @return 好友集合
 */
- (NSArray *)getRostersWithTag:(NSString *)tag;

@end
