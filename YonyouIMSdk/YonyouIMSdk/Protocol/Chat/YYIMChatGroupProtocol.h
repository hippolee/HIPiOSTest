//
//  YYIMChatGroupProtocol.h
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseProtocol.h"
#import "YYChatGroup.h"
#import "YYChatGroupInfo.h"

/**
 *  群组相关业务接口
 */
@protocol YYIMChatGroupProtocol <YYIMBaseProtocol>

@optional

/**
 *  用于开发者自行实现群组业务时的回调通知
 *
 *  @param delegate 回调的delegate
 */
- (void)activeYYIMDelegate:(id<YYIMChatDelegate>)delegate;

@required

/**
 *  加载所有已加入群/群成员
 */
- (void)loadChatGroupAndMembers;

/**
 *  创建群组
 *  default maxUsers 200
 *
 *  @param groupName   群组名称
 *  @param userIdArray 群组成员userIDs
 *
 *  @return seriId
 */
- (NSString *)createChatGroupWithName:(NSString *)groupName user:(NSArray *)userIdArray;

/**
 *  创建群组
 *
 *  @param groupName   群组名称
 *  @param userIdArray 群组成员userIDs
 *  @param maxUsers    最大人数 <=1000
 *
 *  @return seriId
 */
- (NSString *)createChatGroupWithName:(NSString *)groupName user:(NSArray *)userIdArray maxUsers:(NSUInteger)maxUsers;

/**
 *  邀请用户加入群组
 *
 *  @param groupId     群组ID
 *  @param userIdArray 邀请加入的userIDs
 */
- (void)inviteRosterIntoChatGroup:(NSString *)groupId user:(NSArray *)userIdArray;

/**
 *  根据群组Id获取群组对象
 *
 *  @param groupId 群组ID
 *
 *  @return YYChatGroup
 */
- (YYChatGroup *)getChatGroupWithGroupId:(NSString *)groupId;

/**
 *  获得已加入的所有群组
 *
 *  @return NSArray<YYChatGroup>
 */
- (NSArray *)getAllChatGroups;

/**
 *  根据群组ID获得所有群组成员
 *
 *  @param groupId 群组ID
 *
 *  @return NSArray<YYChatGroupMember>
 */
- (NSArray *)getGroupMembersWithGroupId:(NSString *)groupId;

/**
 *  根据群组ID获得群组成员
 *
 *  @param groupId 群组ID
 *  @param limit   指定个数
 *
 *  @return NSArray<YYChatGroupMember>
 */
- (NSArray *)getGroupMembersWithGroupId:(NSString *)groupId limit:(NSInteger)limit;


/**
 *  分页获取群成员列表
 *
 *  @param groupId  群组ID
 *  @param offset   偏移量
 *  @param limit    数量
 *  @param complete  成功的回调
 */
- (void)getGroupMembersWithGroupId:(NSString *)groupId complete:(void (^)(BOOL, NSArray *, YYIMError *))complete;

/**
 *  分页获取群成员列表
 *
 *  @param groupId  群组ID
 *  @param joinDate 加入时间（只查此时间之前加入的人员）
 *  @param offset   偏移量
 *  @param limit    数量
 *  @param complete  成功的回调
 */
- (void)getGroupMembersWithGroupId:(NSString *)groupId joinDate:(NSTimeInterval)joinDate complete:(void (^)(BOOL, NSArray *, YYIMError *))complete;

/**
 *  根据群组ID获得当前用户是否该群组所有者
 *
 *  @param groupId 群组ID
 *
 *  @return 是否群组所有者
 */
- (BOOL)isGroupOwner:(NSString *)groupId;

/**
 *  退出群组
 *
 *  @param groupId 群组ID
 */
- (void)leaveChatGroup:(NSString *)groupId;

/**
 *  重命名群组
 *
 *  @param groupId   群组ID
 *  @param groupName 群组新名称
 */
- (void)renameChatGroup:(NSString *)groupId name:(NSString *)groupName;

/**
 *  根据关键字模糊搜索群组
 *
 *  @param keyword 关键字
 */
- (void)searchChatGroupWithKeyword:(NSString *)keyword;

/**
 *  加入群组
 *
 *  @param groupId 群组ID
 */
- (void)joinChatGroup:(NSString *)groupId;

/**
 *  将群组成员踢出群组
 *
 *  @param groupId  群组ID
 *  @param memberId 要踢出的成员ID
 */
- (void)kickGroupMemberFromGroup:(NSString *)groupId member:(NSString *)memberId;

/**
 *  更改管理员
 *
 *  @param groupId  群组ID
 *  @param memberId 新的管理员
 */
- (void)changeChatGroupAdminForGroup:(NSString *)groupId to:(NSString *)memberId;

/**
 *  获得保存到通讯录的群组列表
 *
 *  @return NSArray<YYChatGroup>
 */
- (NSArray *)getCollectChatGroups;

/**
 *  群组保存到通讯录
 *
 *  @param groupId 群组ID
 */
- (void)collectChatGroup:(NSString *)groupId;

/**
 *  群组取消保存在通讯录
 *
 *  @param groupId 群组ID
 */
- (void)unCollectChatGroup:(NSString *)groupId;

/**
 *  解散群组
 *
 *  @param groupId 群组ID
 */
- (void)dismissChatGroup:(NSString *)groupId;

/**
 *  生成群组二维码文本
 *
 *  @param groupId  群组ID
 *  @param complete
 */
- (void)genChatGroupQrCodeWithGroupId:(NSString *)groupId complete:(void (^)(BOOL result, NSDictionary *qrCodeInfo, YYIMError *error)) complete;

/**
 *  根据群组二维码文本获取群组信息
 *
 *  @param qrCodeText 二维码文本
 *  @param complete
 */
- (void)getChatGroupInfoWithQrCode:(NSString *)qrCodeText complete:(void (^)(BOOL result, YYChatGroupInfo * groupInfo, YYIMError *error)) complete;

/**
 *  通过tag获取群组集合
 *
 *  @param tag tag
 *
 *  @return 群组集合
 */
- (NSArray *)getChatGroupsWithTag:(NSString *)tag;

/**
 *  参加面对面建群
 *  默认有效距离1000米
 *  默认有效时间1800秒
 *
 *  @param cipher    四位数字密码
 *  @param longitude 经度
 *  @param latitude  纬度
 */
- (void)participateFaceGroupWithCipher:(NSString *)cipher longitude:(float)longitude latitude:(float)latitude;

/**
 *  参加面对面建群
 *
 *  @param cipher     四位数字密码
 *  @param longitude  经度
 *  @param latitude   纬度
 *  @param distance   有效距离（米）
 *  @param expireTime 有效时间（秒）
 */
- (void)participateFaceGroupWithCipher:(NSString *)cipher longitude:(float)longitude latitude:(float)latitude distance:(NSInteger)distance expireTime:(NSInteger)expireTime;

/**
 *  加入面对面建群
 *
 *  @param cipher 四位数字密码
 *  @param faceId 面对面建群标识
 */
- (void)joinFaceGroupWithCipher:(NSString *)cipher faceId:(NSString *)faceId;

/**
 *  离开面对面建群
 *
 *  @param cipher 四位数字密码
 *  @param faceId 面对面建群标识
 */
- (void)quitFaceGroupWithCipher:(NSString *)cipher faceId:(NSString *)faceId;

@end
