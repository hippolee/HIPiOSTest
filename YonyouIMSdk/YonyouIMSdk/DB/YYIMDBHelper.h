//
//  YYIMDBHelper.h
//  YonyouIM
//
//  Created by litfb on 15/1/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDBHelper.h"
#import "YYFMDB.h"
#import "YYRoster.h"
#import "YYMessage.h"
#import "YYRecentMessage.h"
#import "YYChatGroup.h"
#import "YYChatGroupMember.h"
#import "YYUser.h"
#import "YYUserExt.h"
#import "YYChatGroupExt.h"
#import "YYPubAccount.h"
#import "YYPubAccountExt.h"
#import "YYPubAccountMenu.h"
#import "YYIMDefs.h"

@interface YYIMDBHelper : YYIMBaseDBHelper

+ (YYIMDBHelper *) sharedInstance;

#pragma mark roster

- (NSArray *)getAllRoster;

- (NSArray *)getAllRosterWithAsk;

- (void)insertOrUpdateRoster:(YYRoster *) roster;

- (void)deleteRoster:(NSString *)rosterId;

- (void)batchUpdateRoster:(NSArray *) rosterArray;

- (YYRoster *)getRosterWithId:(NSString *) rosterId;

- (void)updateRosterState:(NSInteger)state roster:(NSString *)rosterId clientType:(YYIMClientType)clientType;

- (NSInteger)newInviteCount;

- (NSArray *)getAllRosterInvite;

/**
 *  增加好友的tag（会自动去重）
 *
 *  @param tagArray tag集合
 *  @param rosterId 好友Id
 */
- (void)insertRosterTags:(NSArray *)tagArray rosterId:(NSString *)rosterId;

/**
 *  删除好友的tag
 *
 *  @param tagArray tag集合
 *  @param rosterId 好友Id
 */
- (void)deleteRosterTags:(NSArray *)tagArray rosterId:(NSString *)rosterId;

/**
 *  通过tag获取好友集合
 *
 *  @param tag tag
 *
 *  @return 好友集合
 */
- (NSArray *)getRostersWithTag:(NSString *)tag;

#pragma mark message

- (BOOL)isMessageReceived:(NSString *)pid fromId:(NSString *)fromId;

- (YYMessage *)insertMessage:(YYMessage *)message;

- (BOOL)updateMessage:(YYMessage *)message;

- (YYMessage *)getMessageWithPid:(NSString *)pid;

- (NSArray *)getReceivedFileMessage;

- (NSArray *)getRecentMessage;

- (NSArray *)getRecentMessage2;

- (NSInteger)getUnreadMsgCount;

- (NSInteger)getUnreadMsgCount:(NSString *)chatId;

- (NSInteger)getUnreadMsgCountMyOtherClient;

- (NSArray *)getMessageWithId:(NSString *)chatId;

- (NSArray *)getMessageWithId:(NSString *)chatId beforePid:(NSString *)pid pageSize:(NSInteger)pageSize;

- (NSArray *)getMessageWithId:(NSString *)chatId afterPid:(NSString *)pid;

- (NSArray *)getCustomMessageWithId:(NSString *)chatId customType:(NSInteger)customType beforePid:(NSString *)pid pageSize:(NSInteger)pageSize;

- (NSArray *)getMessageWithId:(NSString *)chatId contentType:(NSInteger) contentType;

- (NSArray *)getMessageWithKey:(NSString *)key limit:(NSInteger)limit;

- (NSArray *)getMessageWithKey:(NSString *)key chatId:(NSString *)chatId;

- (NSArray *)getRosterIdArrayWithChatId:(NSString *)chatId;

- (void)deleteMessageWithId:(NSString *)chatId;

- (void)deleteMessageWithPid:(NSString *)packetId;

- (void)deleteAllMessage;

- (void)updateMessageDateline:(NSTimeInterval)dateline pid:(NSString *)packetId;

- (void)updateMessageState:(NSInteger)state pid:(NSString *)packetId;

- (void)updateMessageState:(NSInteger)state pid:(NSString *)packetId force:(BOOL)force;

- (void)updateMessageReadedWithPid:(NSString *)packetId;

- (void)updateMessageReadedWithId:(NSString *)chatId;

- (void)updateMessageDeliveredWithId:(NSString *)chatId;

- (void)updateMessageSpecState:(NSInteger)state pid:(NSString *)packetId;

- (void)updateFaildMessage;

- (NSInteger)getGroupVersionWithId:(NSString *)groupId;

- (YYMessage *)revokeMessageWithPid:(NSString *)pid;

#pragma mark chatgroup

- (void)insertChatGroup:(YYChatGroup *) group;

- (YYChatGroup *)getChatGroupWithId:(NSString *) groupId;

- (NSArray *)getAllGroup;

- (NSArray *)getAllCollectGroup;

- (NSArray *)getAllSuperGroup;

- (void)batchUpdateChatGroup:(NSArray *)chatGroupArray;

- (void)batchUpdateChatGroup:(NSArray *)chatGroupArray allGroups:(NSArray *)groupIds collectedGroups:(NSArray *) collectedGroupIds;

- (void)updateChatGroup:(YYChatGroup *)chatGroup;

- (void)deleteChatGroup:(NSString *)groupId;

- (void)updateChatGroupCollect:(NSString *)groupId collect:(BOOL)isCollect;

/**
 *  通过tag获取群组集合
 *
 *  @param tag tag
 *
 *  @return 群组集合
 */
- (NSArray *)getChatGroupsWithTag:(NSString *)tag;

#pragma mark user

- (YYUser *)getUserWithId:(NSString *)userId;

- (void)insertOrUpdateUser:(YYUser *)user;

- (void)deleteUnExistUser:(NSString *)userId;

/**
 *  增加用户的tag（会自动去重）
 *
 *  @param tagArray tag集合
 *  @param rosterId 用户Id
 */
- (void)insertUserTags:(NSArray *)tagArray userId:(NSString *)userId;

/**
 *  删除用户的tag
 *
 *  @param tagArray tag集合
 *  @param rosterId 用户Id
 */
- (void)deletetUserTags:(NSArray *)tagArray userId:(NSString *)userId;

#pragma mark ext

- (YYUserExt *)getUserExtWithId:(NSString *)userId;

- (void)updateUserExt:(YYUserExt *)userExt;

- (YYChatGroupExt *)getChatGroupExtWithId:(NSString *)groupId;

- (void)updateChatGroupExt:(YYChatGroupExt *)chatGroupExt;

- (YYPubAccountExt *)getPubAccountExtWithId:(NSString *)accountId;

- (void)updatePubAccountExt:(YYPubAccountExt *)accountExt;

- (void)clearNoDisturb;

- (void)clearStickTop;

- (void)updateUserProfile:(NSDictionary<NSString *, NSString *> *)profileDic;

- (NSDictionary<NSString *, NSString *> *)getUserProfiles;

#pragma mark pub account

- (NSArray *)getAllPubAccount;

- (void)insertOrUpdatePubAccount:(YYPubAccount *)account;

- (void)deletePubAccount:(NSString *)accountId;

- (void)batchUpdatePubAccount:(NSArray *)accountArray;

- (YYPubAccount *)getPubAccountWithId:(NSString *)accountId;

/**
 *  通过tag获取公共号集合
 *
 *  @param tag tag
 *
 *  @return公共号集合
 */
- (NSArray *)getPubAccountsWithTag:(NSString *)tag;

/**
 *  获得公共号菜单
 *
 *  @param accountId公共号id
 *
 *  @return
 */
- (YYPubAccountMenu *)getPubAccountMenu:(NSString *)accountId;

/**
 *  插入公共号菜单
 *
 *  @param menu      菜单json
 *  @param accountId公共号id
 */
- (void)insertOrUpdatePubAccountMenu:(YYPubAccountMenu *)menu accountId:(NSString *)accountId;

/**
 *  删除公共号菜单
 *
 *  @param accountId公共号id
 */
- (void)deletePubAccountMenu:(NSString *)accountId;

@end
