//
//  YYIMNetMeetingDelegate.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/20.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMError.h"
#import <UIKit/UIKit.h>
#import "YYIMDefs.h"
#import "YYNetMeetingMember.h"

@protocol YYIMNetMeetingDelegate <NSObject>

@optional

#pragma mark -
#pragma mark sdk delegate

/**
 *  视频会议服务初始化成功
 */
- (void)didNetMeetingInitSuccess;

/**
 *  视频会议服务初始化失败
 */
- (void)didNetMeetingInitFaild;

/**
 *  当前用户加入会议频道成功的回调（实际可以开始进行会议）
 *
 *  @param channel 会议id
 *  @param elapsed 加入频道延迟（毫秒）
 */
- (void)didJoinNetMeetingSuccessed:(NSString *)channelId elapsed:(NSInteger)elapsed;

/**
 *  sdk中出现错误。并且不能够恢复到正常状态，需要用户自己处理错误。
 *
 *  @param 错误
 */
- (void)didNetMeetingOccurError:(YYIMError *)error;

/**
 *  网络连接丢失的回调
 *
 */
- (void)didNetMeetingConnectionLost;

/**
 *  其他用户重连加入频道的回调
 *
 *  @param channel 会议id
 *  @param userId  用户id
 *  @param elapsed 加入频道延迟（毫秒）
 */
- (void)didRejoinNetMeeting:(NSString*)channelId withUserId:(NSString *)userId elapsed:(NSInteger) elapsed;

/**
 *  报告当前的统计数据，一秒钟执行一次
 *
 *  @param duration     累计通话时间
 *  @param sendBytes    累计发送流量字节数量
 *  @param receiveBytes 累计接收流量字节数量
 */
- (void)didNetMeetingReportStats:(NSUInteger)duration sendBytes:(NSUInteger)sendBytes receiveBytes:(NSUInteger)receiveBytes;


/**
 *  报告本地的网络质量的回调
 *
 *  @param 网络质量
 */
- (void)didNetMeetingNetworkQuality:(YYIMNetMeetingQuality)quality;

#pragma mark -
#pragma mark jump delegate

/**
 *  开始预约会议失败
 *
 *  @param seriId 请求id
 */
- (void)didNotStartReservationNetMeetingWithSeriId:(NSString *)seriId error:(YYIMError *)error;

/**
 *  创建一个会议失败
 *
 *  @param seriId 请求id
 */
- (void)didNotNetMeetingCreateWithSeriId:(NSString *)seriId netMeetingType:(YYIMNetMeetingType)netMeetingType netMeetingMode:(YYIMNetMeetingMode)netMeetingMode error:(YYIMError *)error;

/**
 *  加入会议失败
 */
- (void)didNotJoinNetMeeting:(NSString *)channelId error:(YYIMError *)error;

/**
*  接受会议邀请失败
*/
- (void)didNotAgreeNetMeeting:(NSString *)channelId error:(YYIMError *)error;

/**
 *  踢人失败
 */
- (void)didNotKickMemberFromNetMeeting;

/**
 *  编辑主题失败
 *
 *  @param channeId 会议id
 *  @param error    错误
 */
- (void)didNotNetMeetingEditTopic:(NSString *)channeId error:(YYIMError *)error;

/**
 *  收到会议邀请
 *
 *  @param channelId 会议id
 *  @param userArray  成员数组
 */
- (void)didNetMeetingInvited:(NSString *)channelId userArray:(NSArray *)userArray;

/**
 *  开始预约会议失败
 *
 *  @param seriId 请求id
 */
- (void)didStartReservationNetMeetingWithSeriId:(NSString *)seriId channelId:(NSString *)channelId;

/**
 *  创建会议成功
 *
 *  @param seriId 请求id
 *  @param channelId 频道id
 */
- (void)didNetMeetingCreate:(NSString *)seriId channelId:(NSString *)channelId;

/**
 *  同意加入会议
 *
 *  @param channelId 会议id
 */
- (void)didNetMeetingAgree:(NSString *)channelId netMeetingType:(YYIMNetMeetingType)netMeetingType;

/**
 *  主动加入会议（加入会议的要求被服务器同意，需要调用enterNetMeeting:执行真正的进入）
 *
 *  @param channelId 会议id
 */
- (void)didNetMeetingJoin:(NSString *)channelId;

/**
 *  被要求在会议内禁言
 */
- (void)didNetMeetingDisableSpeak:(NSString *)userId;

/**
 *  被要求在会议内允许发言
 */
- (void)didNetMeetingEnableSpeak:(NSString *)userId;

/**
 *  全体被要求在会议内禁言
 */
- (void)didNetMeetingAllDisableSpeak;

/**
 *  全体被要求在会议内允许
 */
- (void)didNetMeetingAllEnableSpeak;

/**
 *  通知会议成员改变语音状态
 *
 *  @param enable  是否开启
 *  @param userIds 成员id集合
 */
- (void)didNetMeetingMembersEnableAudio:(BOOL)enable userId:(NSString *)userId;

/**
 *  通知会议成员改变视频状态
 *
 *  @param enable  是否开启
 *  @param userIds 成员id集合
 */
- (void)didNetMeetingMembersEnableVideo:(BOOL)enable userId:(NSString *)userId;

/**
 *  会议被结束
 */
- (void)didNetMeetingEndChannel:(NSString *)channelId;

/**
 *  会议被锁定
 */
- (void)didLockNetMeeting;

/**
 *  会议被解锁
 */
- (void)didUnLockNetMeeting;

/**
 *  会议主题更改
 *
 *  @param topic    新主题
 *  @param channeId 会议id
 */
- (void)didNetMeetingEditTopic:(NSString *)topic channelId:(NSString *)channeId;

/**
 *  会议中有人主持人发生变更
 *
 *  @param oldUserId 旧主持人id
 *  @param newUserId 新主持人id
 */
- (void)didNetMeetingModeratorChange:(NSString *)oldUserId to:(NSString *)newUserId;

/**
 *  会议中有成员加入
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberEnter:(NSString *)userId;

/**
 *  会议中有成员被踢
 *
 *  @param userArray 成员数组
 */
- (void)didNetMeetingMemberkicked:(NSArray *)userArray;

/**
 *  会议中有成员退出
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberExit:(NSString *)userId;

/**
 *   成员因为忙而不能接听
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberBusy:(NSString *)userId;

/**
 *  成员拒绝参加会议
 *
 *  @param userId 成员id
 */
- (void)didNetMeetingMemberRefuse:(NSString *)userId;

/**
 *  成员邀请超时的回调
 *
 *  @param channelId 会议id
 *  @param userId    用户id
 */
- (void)didNetMeetingInviteTimeout:(NSString *)channelId userId:(NSString *)userId;

/**
 *  收到新的会议通知
 */
- (void)didNetMeetingNoticeReceive;

/**
 *  邀请了没有通信权限的用户
 *
 *  @param channelId 会议id
 *  @param userArray 用户数组
 */
- (void)didNetMeetingInviteMisMatchMember:(NSString *)channelId userArray:(NSArray *)userArray;

@end
