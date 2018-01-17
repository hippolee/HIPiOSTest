//
//  YYIMChatGroupDelegate.h
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYChatGroup.h"

/**
 *  群组代理
 */
@protocol YYIMChatGroupDelegate <NSObject>

@optional

/**
 *  lazy delegate
 *  群组信息变更
 */
- (void)didChatGroupInfoUpdate;

/**
 *  lazy delegate
 *  群组成员信息变更
 */
- (void)didChatGroupMemberUpdate;

/**
 *  群组创建成功
 *
 *  @param seriId 创建群返回的seriId
 *  @param group  群组
 */
- (void)didChatGroupCreateWithSeriId:(NSString *)seriId group:(YYChatGroup *)group;

/**
 *  群组创建失败
 *
 *  @param seriId 创建群返回的seriId
 */
- (void)didNotChatGroupCreateWithSeriId:(NSString *)seriId;

/**
 *  群组信息变更
 *
 *  @param group 群组
 */
- (void)didChatGroupInfoUpdate:(YYChatGroup *)group;

/**
 *  群组成员信息变更
 *
 *  @param groupId 群组ID
 */
- (void)didChatGroupMemberUpdate:(NSString *)groupId;

/**
 *  加入群组成功
 *
 *  @param groupId 群组ID
 */
- (void)didJoinChatGroup:(NSString *)groupId;

/**
 *  加入群组失败
 *
 *  @param group 群组ID
 *  @param error 错误
 */
- (void)didNotJoinChatGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  退出群组
 *
 *  @param groupId 群组ID
 */
- (void)didLeaveChatGroup:(NSString *)groupId;

/**
 *  退出群组失败
 *
 *  @param groupId 群组ID
 *  @param error   错误
 */
- (void)didNotLeaveChatGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  群组踢人失败
 *
 *  @param groupId 群组ID
 */
- (void)didNotKickGroupMemberFromGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  群组更改管理员失败
 *
 *  @param groupId 群组id
 *  @param error   错误
 */
- (void)didNotChangeAdminFromGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  群组邀请成员失败
 *
 *  @param groupId 群组ID
 */
- (void)didNotInviteRosterIntoChatGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  群组搜索结果
 *
 *  @param groupArray NSArray<YYChatGroup>
 */
- (void)didReceiveChatGroupSearchResult:(NSArray *)groupArray;

/**
 *  群组搜索失败
 *
 *  @param error 错误
 */
- (void)didNotReceiveChatGroupSearchResult:(YYIMError *)error;

/**
 *  保存群组到通讯录成功
 *
 *  @param groupId 群组ID
 */
- (void)didCollectChatGroup:(NSString *)groupId;

/**
 *  保存群组到通讯录失败
 *
 *  @param groupId 群组ID
 *  @param error
 */
- (void)didNotCollectChatGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  取消保存群组到通讯录成功
 *
 *  @param groupId 群组ID
 */
- (void)didUnCollectChatGroup:(NSString *)groupId;

/**
 *  取消保存群组到通讯录失败
 *
 *  @param groupId 群组ID
 *  @param error
 */
- (void)didNotUnCollectChatGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  解散群组成功
 *
 *  @param groupId 群组ID
 */
- (void)didDismissChatGroup:(NSString *)groupId;

/**
 *  解散群组失败
 *
 *  @param groupId 群组ID
 *  @param error
 */
- (void)didNotDismissChatGroup:(NSString *)groupId error:(YYIMError *)error;

/**
 *  加载群组信息失败
 *
 *  @param error
 */
- (void)didNotLoadChatGroupWithError:(YYIMError *)error;

/**
 *  参加面对面建群成功
 *
 *  @param faceId        faceId
 *  @param cipher        4位数字密码
 *  @param memberIdArray 成员ID列表
 */
- (void)didParticipateInFaceGrop:(NSString *)faceId cipher:(NSString *)cipher members:(NSArray *)memberIdArray;

/**
 *  参加面对面建群失败
 *
 *  @param cipher 4位数字密码
 */
- (void)didNotParticipateInFaceGropWithCipher:(NSString *)cipher error:(YYIMError *)error;

/**
 *  加入面对面建群成功
 *
 *  @param faceId  faceId
 *  @param groupId 群组ID
 */
- (void)didJoinFaceGroupWithFaceId:(NSString *)faceId groupId:(NSString *)groupId;

/**
 *  加入面对面建群失败
 *
 *  @param faceId faceId
 */
- (void)didNotJoinFaceGroupWithFaceId:(NSString *)faceId error:(YYIMError *)error;

/**
 *  离开面对面建群成功
 *
 *  @param faceId faceId
 */
- (void)didQuitFaceGroupWithFaceId:(NSString *)faceId;

/**
 *  离开面对面建群失败
 *
 *  @param faceId faceId
 */
- (void)didNotQuitFaceGroupWithFaceId:(NSString *)faceId error:(YYIMError *)error;

/**
 *  用户参加面对面建群通知
 *
 *  @param faceId  faceId
 *  @param cipher  4位数字密码
 *  @param userId  用户ID
 *  @param members 成员ID列表
 */
- (void)didUserParticipateInFaceGroupWithFaceId:(NSString *)faceId cipher:(NSString *)cipher userId:(NSString *)userId members:(NSArray *)members;

/**
 *  用户离开面对面建群通知
 *
 *  @param faceId  faceId
 *  @param cipher  4位数字密码
 *  @param userId  用户ID
 *  @param members 成员ID列表
 */
- (void)didUserQuitFaceGroupWithFaceId:(NSString *)faceId cipher:(NSString *)cipher userId:(NSString *)userId members:(NSArray *)members;

@end
