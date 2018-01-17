//
//  YYIMNetMeetingProtocol.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/15.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseProtocol.h"
#import "YYNetMeeting.h"
#import "YYNetMeetingMember.h"
#import "YYNetMeetingDetail.h"
#import "YYNetMeetingCalendarEvent.h"

/**
 *  云视频会议接口
 */
@protocol YYIMNetMeetingProtocol <YYIMBaseProtocol>

#pragma mark -
#pragma mark netmeeting

- (void)resetNetMeetingKit;

/**
 *  获取当前是否有会议在进行
 *  调用了创建会议，加入会议和同意邀请成功后就会被认为是成功加入了会议
 *
 *  @return
 */
- (BOOL)isNetMeetingProcessing;

/**
 *  获取还没有处理的网络会议邀请
 *  如果客户端收到了会议请求，但是还没有响应（同意或者拒绝）。
 *
 *  @return 邀请的id（没有返回nil）
 */
- (NSString *)getUntreatedNetMeetingInviting;

/**
 *  标记已经处理了网络会议邀请
 */
- (void)treatNetMeetingInvite;

/**
 *  设置视频采集质量
 *
 *  @param profile 采集质量配置
 *
 *  return 返回0表示成功，负数表示失败。
 */
- (int)setNetMeetingVideoProfile:(YYIMNetMeetingVideoProfile)profile;

/**
 *  设置网络会议的优化配置，可以设置：
    自由模式，大家都可以发送和接收音视频
    主持模式，自己可以发送音视频，不能接收
    观众模式，自己不可以发送音视频，可以接受
 *
 *  @param profile 优化配置
 */
- (void)setNetMeetingProfile:(YYIMNetMeetingProfile)profile;

/**
 *  根据会议id进入会议的频道中（必须使用在创建会议、加入会议、同意邀请成功之后）
 *
 *  @param channelId 频道id
 *
 *  @return
 */
- (void)enterNetMeeting:(NSString *)channelId;

/**
 *  视频可用。将语音模式切换到视频模式.通话过程中或者进入频道之前都可以成功调用。
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)enableNetMeetingVideo;

/**
 *  视频不可用。将视频模式切换到语音模式.通话过程中或者进入频道之前都可以成功调用。
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)disableNetMeetingVideo;

/**
 *  设置是否使用扬声器
 *
 *  @param mute YES: 使用。 NO: 不使用
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)setNetMeetingEnableSpeakerphone:(BOOL)enableSpeaker;

/**
 *  查询当前是否正在使用扬声器
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (BOOL)isNetMeetingSpeakerphoneEnabled;

/**
 *  打开本地预览，这个时候不会发送视频流到服务器。
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)startNetMeetingPreview;

/**
 *  关闭本地预览
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)stopNetMeetingPreview;

/**
 *  设置是否关闭麦克本地静音，禁止上传音频流到服务器
 *
 *  @param mute YES: 静音。 NO: 不静音.
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)muteNetMeetingLocalAudioStream:(BOOL)mute;

/**
 *  设置是否禁止发送本地视频流到服务器。
 *
 *  @param mute YES: 禁止发送。 NO: 不禁止发送.
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)muteNetMeetingLocalVideoStream:(BOOL)mute;

/**
 *  设置暂停播放所有远程音频流
 *
 *  @param mute 是否禁止
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)muteAllNetMeetingRemoteAudioStreams:(BOOL)mute;

/**
 *  设置暂停播放所有远程视频流
 *
 *  @param mute 是否禁止
 *
 *  @return 返回0表示成功，负数表示失败
 */
- (int)muteAllNetMeetingRemoteVideoStreams:(BOOL)mute;

/**
 *  设置本地视频流的绘制。可以在进入频道前设置。
 *
 *  @param view 需要绘制视频流的视图
 *  @param uid  用户id
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)setupNetMeetingLocalVideo:(UIView *)view userId:(NSString *)userId;

/**
 *  设置远程视频流的绘制。
 *
 *  @param view 需要绘制视频流的视图
 *  @param uid  用户id
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)setupNetMeetingRemoteVideo:(UIView *)view userId:(NSString *)userId;

/**
 *  切换前后摄像头
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)switchNetMeetingCamera;

/**
 *  开启网络质量监测。即使没有进行通话也会占用流量。所以建议当应用在前台并且通话中启用。离开通话或者进入后台关闭网络质量监测。
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)enableNetMeetingNetworkTest;

/**
 *  关闭网络质量监测。
 *
 *  @return 返回0表示成功，负数表示失败。
 */
- (int)disableNetMeetingNetworkTest;

/**
 *  设置视频会议日志的打印级别
 *
 *  @param logFilte打印级别
 */
- (void)setNetMeetingLogFilter:(YYIMNetMeetingLogFilter)logFilter;

#pragma mark -
#pragma mark query

/**
 *  获得指定的会议对象
 *
 *  @param channelId 会议id
 *
 *  @return 会议对象
 */
- (YYNetMeeting *)getNetMeetingWithChannelId:(NSString *)channelId;

/**
 *  获得会议主持人
 *
 *  @param channelId 会议id
 *
 *  @return
 */
- (YYNetMeetingMember *)getNetMeetingModerator:(NSString *)channelId;

/**
 *  获得会议的所有成员
 *
 *  @param channelId 会议id
 *
 *  @return 成员集合
 */
- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId;

/**
 *  获得会议的指定数量的成员
 *
 *  @param channelId 会议id
 *  @param limit     数量限制
 *
 *  @return 成员集合
 */
- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId limit:(NSInteger)limit;

/**
 *  获取会议的指定成员
 *
 *  @param channelId 会议id
 *  @param memberId  成员id
 *
 *  @return 成员
 */
- (YYNetMeetingMember *)getNetMeetingMemberWithChannelId:(NSString *)channelId memberId:(NSString *)memberId;

/**
 *  获得会议通知
 *
 *  @param offset 偏移量
 *  @param limit  数量
 *
 *  @return
 */
- (NSArray *)getNetMeetingNoticeWithOffset:(NSInteger)offset limit:(NSInteger)limit;

#pragma mark -
#pragma mark YYNetMeetingCalendarEvent

/**
 *  设置预约会议的日历事件
 *
 *  @param calendarEvent  日历事件的对象
 *
 *  @return
 */
- (void)addNetMeetingCalendarEvent:(YYNetMeetingCalendarEvent *) calendarEvent;

#pragma mark -
#pragma mark jump

/**
 *  开始预约会议
 *
 *  @param channelId 会议id
 *
 *  @return 创建的唯一标示
 */
- (NSString *)startReservationNetMeeting:(NSString *)channelId;

/**
 *  创建一个会议
 *
 *  @param netMeetingType 会议类型（会议或者直播）
 *  @param netMeetingMode 会议模式（视频或者语音）
 *  @param invitees       被邀请人
 *  @param topic          主题
 *
 *  @return 创建的唯一标示
 */
- (NSString *)createNetMeetingWithNetMeetingType:(YYIMNetMeetingType)netMeetingType netMeetingMode:(YYIMNetMeetingMode)netMeetingMode invitees:(NSArray *)invitees topic:(NSString *)topic;

/**
 *  发送会议邀请
 *
 *  @param channelId 会议id
 *  @param invitees  被邀请人集合
 */
- (void)inviteNetMeetingMember:(NSString *)channelId invitees:(NSArray *)invitees;

/**
 *  主动加入会议
 *
 *  @param channelId 会议id
 */
- (void)joinNetMeeting:(NSString *)channelId;

/**
 *  同意加入会议
 *
 *  @param channelId 会议id
 */
- (void)agreeEnterNetMeeting:(NSString *)channelId;

/**
 *  拒绝加入会议
 *
 *  @param channelId 会议id
 */
- (void)refuseEnterNetMeeting:(NSString *)channelId;

/**
 *  通知会议其他人，本人打开摄像头
 *
 *  @param channelId 会议id
 */
- (void)openNetMeetingVideo:(NSString *)channelId;

/**
 *  通知会议其他人，本人关闭摄像头
 *
 *  @param channelId 会议id
 */
- (void)closeNetMeetingVideo:(NSString *)channelId;

/**
 *  通知会议其他人，本人打开麦克
 *
 *  @param channelId 会议id
 */
- (void)openNetMeetingAudio:(NSString *)channelId;

/**
 *  通知会议其他人，本人关闭麦克
 *
 *  @param channelId 会议id
 */
- (void)closeNetMeetingAudio:(NSString *)channelId;

/**
 *  会议上锁。上锁后禁止邀请，禁止加入
 *
 *  @param channelId 会议id
 */
- (void)lockNetMeeting:(NSString *)channelId;

/**
 *  会议解锁
 *
 *  @param channelId 会议id
 */
- (void)unlockNetMeeting:(NSString *)channelId;

/**
 *  会议修改主题
 *
 *  @param channelId 会议id
 */
- (void)editNetMeetingTopic:(NSString *)channelId topic:(NSString *)topic;

/**
 *  离开会议。只有参与者可以离开，而主持人不能调用此方法。
 *
 *  @param channelId 会议id
 */
- (void)exitNetMeeting:(NSString *)channelId;

/**
 *  更换主持人
 *
 *  @param channelId 会议id
 *  @param userId    新的主持人
 */
- (void)roleConversionOfNetMeeting:(NSString *)channelId withUserId:(NSString *)userId;

/**
 *  主持人结束了会议
 *
 *  @param channelId 会议id
 */
- (void)endNetMeeting:(NSString *)channelId;

/**
 *  会议踢出成员
 *
 *  @param channelId   会议id
 *  @param memberArray 成员集合
 */
- (void)kickMemberFromNetMeeting:(NSString *)channelId memberArray:(NSArray *)memberArray;

/**
 *  会议中指定成员禁言
 *
 *  @param channelId   会议id
 *  @param memberArray 成员集合
 */
- (void)disableMemberSpeakFromNetMeeting:(NSString *)channelId userId:(NSString *)userId;

/**
 *  会议中指定成员允许发言
 *
 *  @param channelId   会议id
 *  @param memberArray 成员集合
 */
- (void)enableMemberSpeakFromNetMeeting:(NSString *)channelId userId:(NSString *)userId;

/**
 *  禁言所有人
 *
 *  @param channelId 会议id
 */
- (void)disableAllSpeakFromNetMeeting:(NSString *)channelId;

/**
 *  允许所有人发言
 *
 *  @param channelId 会议id
 */
- (void)enableAllSpeakFromNetMeeting:(NSString *)channelId;

#pragma mark netmeeting service

/**
 *  获得会议详情
 *
 *  @param channelId 会议id
 *  @param complete
 */
- (void)getNetmeetingDetail:(NSString *)channelId complete:(void (^)(BOOL, YYNetMeetingDetail *, NSArray *, YYIMError *))complete;

/**
 *  获取我的会议记录
 *
 *  @param complete
 */
- (void)getMyNetMeetingWithOffset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL result, NSArray *netMeetings, YYIMError *error)) complete;

/**
 *  预约会议
 *
 *  @param netMeetingDetail 预约会议信息
 *  @param members          邀请人
 *  @param complete
 */
- (void)reservationNetMeetingWithNetMeetingDetail:(YYNetMeetingDetail *)netMeetingDetail members:(NSArray *)members complete:(void (^)(BOOL, YYIMError *, NSString *, NSArray *))complete;

/**
 *  删除会议记录
 *
 *  @param channelId 会议ID
 *  @param complete
 */
- (void)removeNetMeetingWithChannelId:(NSString *)channelId complete:(void (^)(BOOL result, YYIMError *error)) complete;

/**
 *  取消预约会议
 *
 *  @param channelId 会议id
 *  @param complete
 */
- (void)cancelReservationNetMeeting:(NSString *)channelId complete:(void (^)(BOOL, YYIMError *))complete;

/**
 *  编辑预约会议
 *
 *  @param netMeetingDetail 会议详情
 *  @param complete
 */
- (void)EditReservationNetMeeting:(YYNetMeetingDetail *)netMeetingDetail complete:(void (^)(BOOL, YYIMError *))complete;

/**
 *  预约会议邀请
 *
 *  @param channelId 会议id
 *  @param members 成员集合
 *  @param complete
 */
- (void)inviteReservationNetMeeting:(NSString *)channelId member:(NSArray *)members complete:(void (^)(BOOL, YYIMError *, NSArray *))complete;

/**
 *  预约会议踢人
 *
 *  @param channelId 会议id
 *  @param members   成员集合
 *  @param complete  
 */
- (void)kickReservationNetMeeting:(NSString *)channelId member:(NSArray *)members complete:(void (^)(BOOL, YYIMError *))complete;

@end
