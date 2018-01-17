//
//  YYIMNetMeetingManager.m
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/15.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingManager.h"
#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>
#import "AgoraRtcEngineKit.h"
#import "YMGCDMulticastDelegate.h"
#import "YYIMConfig.h"
#import "YYIMChat.h"
#import "YYIMLogger.h"
#import "JUMPFramework.h"
#import "YYIMJUMPHelper.h"
#import "YYIMStringUtility.h"
#import "YYIMNetMeetingDBHelper.h"
#import "YYIMStringUtility.h"
#import "JUMPTimer.h"
#import "YMAFNetworking.h"
#import "YYNetMeetingInfo.h"
#import "YYNetMeetingDetail.h"
#import "YYNetMeetingHistory.h"
#import "YYNetMeetingCalendarEvent.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

typedef NS_ENUM(NSInteger, YYIMNetMeetingBillStatus) {
    YYIMNetMeetingBillStatusBegin,
    YYIMNetMeetingBillStatusPay,
    YYIMNetMeetingBillStatusEnd
};

@interface YYIMNetMeetingManager ()<AgoraRtcEngineDelegate, JUMPStreamDelegate>

// 声网的接口类
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;
// 声网的VendorKey
@property (strong, nonatomic) NSString *vendorKey;
// 当前用户所在的频道ID
@property (strong, nonatomic) NSString *currentChannelId;
// 当前的邀请的频道ID
@property (strong, nonatomic) NSString *inviteChannelId;
// 用来定时发送账单信息的timer
@property (retain, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSArray *memberChange;

@property (strong, nonatomic) NSArray *memberStatusChange;

@property (strong, nonatomic) NSArray *netMeetingStatusChange;

@property (retain, nonatomic) UILocalNotification *notification;

@property (retain, nonatomic) NSDate *lastPlaySoundDate;
// 标记位，标记前端已经响应了会议邀请
@property BOOL treatInvite;

@property (strong, nonatomic) EKEventStore *eventStore;

@end

@implementation YYIMNetMeetingManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
    }
    return self;
}

#pragma mark -
#pragma mark NetMeetingProtocol

- (void)resetNetMeetingKit {
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setResponseSerializer:[[YMAFHTTPResponseSerializer alloc] init]];
            [manager setCompletionQueue:[self moduleQueue]];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingKeyServlet];
            
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSString *vendorKey = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                vendorKey = [vendorKey stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                self.vendorKey = vendorKey;
                self.agoraKit = [AgoraRtcEngineKit sharedEngineWithVendorKey:self.vendorKey delegate:self];
                [self.agoraKit setVideoProfile:AgoraRtc_VideoProfile_360P_2];
                
                [[self activeDelegate] didNetMeetingInitSuccess];
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                self.vendorKey = nil;
                self.agoraKit = nil;
                [[self activeDelegate] didNetMeetingInitFaild];
                YYIMLogError(@"load NetMeeting VendorKey error:%@", [error localizedDescription]);
            }];
        }
    }];
}

- (NSString *)getUntreatedNetMeetingInviting {
    if (!self.treatInvite) {
        return self.inviteChannelId;
    }
    
    return nil;
}

- (BOOL)isNetMeetingProcessing {
    if (self.currentChannelId) {
        return YES;
    }
    
    return NO;
}

- (void)treatNetMeetingInvite {
    self.treatInvite = YES;
}

- (int)setNetMeetingVideoProfile:(YYIMNetMeetingVideoProfile)profile {
    return [self.agoraKit setVideoProfile:(AgoraRtcVideoProfile)profile];
}

/**
 *  设置网络会议的优化配置
 *
 *  @param profile 优化配置
 */
- (void)setNetMeetingProfile:(YYIMNetMeetingProfile)profile {
    switch (profile) {
        case kYYIMNetMeetingProfileFree:
            [self.agoraKit setChannelProfile:AgoraRtc_ChannelProfile_Free];
            break;
        case kYYIMNetMeetingProfileBroadcaster:
            [self.agoraKit setChannelProfile:AgoraRtc_ChannelProfile_Broadcaster];
            break;
        case kYYIMNetMeetingProfileAudience:
            [self.agoraKit setChannelProfile:AgoraRtc_ChannelProfile_Audience];
            break;
        default:
            [self.agoraKit setChannelProfile:AgoraRtc_ChannelProfile_Free];
            break;
    }
}

- (void)enterNetMeeting:(NSString *)channelId {
    if (!self.currentChannelId && ![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    // 频道
    YYNetMeeting *channel = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingWithChannelId:self.currentChannelId];
    // 自己
    YYNetMeetingMember *memberSelf = [self getChannelMemberByUserId:[[YYIMConfig sharedInstance] getUser] channelId:self.currentChannelId];
    // 加入频道
    [self.agoraKit joinChannelByKey:channel.dynamicKey channelName:self.currentChannelId info:nil uid:[memberSelf memberUid] joinSuccess:^(NSString *channelId,NSUInteger uid, NSInteger elapsed) {
        [self.activeDelegate didJoinNetMeetingSuccessed:channelId elapsed:elapsed];
        [self sendBillStatus:YYIMNetMeetingBillStatusBegin channelId:channelId];
        
        // 计时器
        self.timer = [NSTimer scheduledTimerWithTimeInterval:60.0f target:self selector:@selector(sendTimingBillStatus:) userInfo:nil repeats:YES];
    }];
}

- (int)enableNetMeetingVideo {
    return [self.agoraKit enableVideo];
}

- (int)disableNetMeetingVideo {
    return [self.agoraKit disableVideo];
}

- (int)setNetMeetingEnableSpeakerphone:(BOOL)enableSpeaker {
    YYIMLogDebug(@"setNetMeetingEnableSpeakerphone-设置扬声器状态：%@", enableSpeaker ? @"YES" : @"NO");
    return [self.agoraKit setEnableSpeakerphone:enableSpeaker];
}

- (BOOL)isNetMeetingSpeakerphoneEnabled {
    return [self.agoraKit isSpeakerphoneEnabled];
}

- (int)startNetMeetingPreview {
    return [self.agoraKit startPreview];
}

- (int)stopNetMeetingPreview {
    return [self.agoraKit stopPreview];
}

- (int)muteNetMeetingLocalAudioStream:(BOOL)mute {
    return [self.agoraKit muteLocalAudioStream:mute];
}

- (int)muteNetMeetingLocalVideoStream:(BOOL)mute {
    return [self.agoraKit muteLocalVideoStream:mute];
}

- (int)muteAllNetMeetingRemoteAudioStreams:(BOOL)mute {
    return [self.agoraKit muteAllRemoteAudioStreams:mute];
}

- (int)muteAllNetMeetingRemoteVideoStreams:(BOOL)mute {
    return [self.agoraKit muteAllRemoteVideoStreams:mute];
}

- (int)setupNetMeetingLocalVideo:(UIView *)view userId:(NSString *)userId {
    YYNetMeetingMember *member = [self getChannelMemberByUserId:userId channelId:self.currentChannelId];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = [member memberUid];
    videoCanvas.view = view;
    videoCanvas.renderMode = AgoraRtc_Render_Hidden;
    
    return [self.agoraKit setupLocalVideo:videoCanvas];
}

- (int)setupNetMeetingRemoteVideo:(UIView *)view userId:(NSString *)userId {
    YYNetMeetingMember *member = [self getChannelMemberByUserId:userId channelId:self.currentChannelId];
    
    AgoraRtcVideoCanvas *videoCanvas = [[AgoraRtcVideoCanvas alloc] init];
    videoCanvas.uid = [member memberUid];
    videoCanvas.view = view;
    videoCanvas.renderMode = AgoraRtc_Render_Hidden;
    
    return [self.agoraKit setupRemoteVideo:videoCanvas];
}

- (int)switchNetMeetingCamera {
    return [self.agoraKit switchCamera];
}

- (int)enableNetMeetingNetworkTest {
    return [self.agoraKit enableNetworkTest];
}

- (int)disableNetMeetingNetworkTest {
    return [self.agoraKit disableNetworkTest];
}

- (void)setNetMeetingLogFilter:(YYIMNetMeetingLogFilter)logFilter {
    switch (logFilter) {
        case kYYIMNetMeetingLogFilterDebug:
            [self.agoraKit setLogFilter:AgoraRtc_LogFilter_Debug];
            break;
        case kYYIMNetMeetingLogFilterInfo:
            [self.agoraKit setLogFilter:AgoraRtc_LogFilter_Info];
            break;
        case kYYIMNetMeetingLogFilterWarn:
            [self.agoraKit setLogFilter:AgoraRtc_LogFilter_Warn];
            break;
        case kYYIMNetMeetingLogFilterError:
            [self.agoraKit setLogFilter:AgoraRtc_LogFilter_Error];
            break;
        case kYYIMNetMeetingLogFilterCritical:
            [self.agoraKit setLogFilter:AgoraRtc_LogFilter_Critical];
            break;
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark query protocol

- (YYNetMeeting *)getNetMeetingWithChannelId:(NSString *)channelId {
    return [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingWithChannelId:channelId];
}

- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId {
    return [self getNetMeetingMembersWithChannelId:channelId limit:0];
}

- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId limit:(NSInteger)limit {
    NSArray *array = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMembersWithChannelId:channelId limit:limit];
    for (YYNetMeetingMember *member in array) {
        [member setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:member.memberId]];
    }
    return array;
}

- (YYNetMeetingMember *)getNetMeetingMemberWithChannelId:(NSString *)channelId memberId:(NSString *)memberId {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:memberId];
    [member setUser:[[YYIMChat sharedInstance].chatManager getUserWithId:member.memberId]];
    return member;
}

- (NSArray *)getNetMeetingNoticeWithOffset:(NSInteger)offset limit:(NSInteger)limit {
    NSArray *array = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingNoticeWithOffset:offset limit:limit];
    for (YYNetMeetingInfo *info in array) {
        [info setModeratorUser:[[YYIMChat sharedInstance].chatManager getUserWithId:[info moderator]]];
    }
    return array;
}

- (YYNetMeetingMember *)getNetMeetingModerator:(NSString *)channelId {
    NSArray *members = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMembersWithChannelId:channelId];
    YYNetMeetingMember *moderator;
    
    for (YYNetMeetingMember *member in members) {
        if (member.isModerator) {
            moderator = member;
            break;
        }
    }
    
    return moderator;
}

#pragma mark -
#pragma mark YYNetMeetingCalendarEvent

- (void)addNetMeetingCalendarEvent:(YYNetMeetingCalendarEvent *) calendarEvent {
    EKEvent *event  = [EKEvent eventWithEventStore:self.eventStore];
    event.title     = calendarEvent.title;
    event.startDate = calendarEvent.startTime;
    event.endDate   = calendarEvent.endTime;
    [event setCalendar:[self.eventStore defaultCalendarForNewEvents]];
    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -5.0f]];
    
    __block NSError *err;
    //ios 6以后开始必须要求判断权限
    if([self.eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                if (granted) {
                    [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                    
                    //绑定会议id和事件id
                    [[YYIMNetMeetingDBHelper sharedInstance] addNetMeetingCalendar:calendarEvent.netMeetingId calendarId:event.eventIdentifier];
                } else {
                    YYIMLogDebug(@"YYIMEventRemindManager--用户没有授权访问日历");
                }
            });
        }];
    } else {
        [self.eventStore saveEvent:event span:EKSpanThisEvent error:&err];
        
        if (err) {
            YYIMLogError(@"YYIMEventRemindManager--设置日历失败，原因：%@", err.userInfo);
        }
    }
}

#pragma mark -
#pragma mark agora delegate

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurWarning:(AgoraRtcWarningCode)warningCode {
    YYIMLogWarn(@"rtcEngine:didOccurWarning:%ld", (long)warningCode);
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didOccurError:(AgoraRtcErrorCode)errorCode {
    YYIMLogError(@"rtcEngine:didOccurError:%ld", (long)errorCode);
    YYIMError *error = [YYIMError errorWithCode:errorCode errorMessage:@""];
    [self.activeDelegate didNetMeetingOccurError:error];
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *)engine {
    [self.activeDelegate didNetMeetingConnectionLost];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didRejoinChannel:(NSString*)channel withUid:(NSUInteger)uid elapsed:(NSInteger) elapsed {
    YYNetMeetingMember *member = [self getChannelMemberByAgoraUid:uid channelId:self.currentChannelId];
    [self.activeDelegate didRejoinNetMeeting:channel withUserId:member.memberId elapsed:elapsed];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine reportRtcStats:(AgoraRtcStats*)stats {
    [self.activeDelegate didNetMeetingReportStats:stats.duration sendBytes:stats.txBytes receiveBytes:stats.rxBytes];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(AgoraRtcQuality)quality {
    YYIMNetMeetingQuality netMeetingQuality;
    
    switch (quality) {
        case AgoraRtc_Quality_Excellent:
            netMeetingQuality = kYYIMNetMeetingQualityExcellent;
            break;
        case AgoraRtc_Quality_Good:
            netMeetingQuality = kYYIMNetMeetingQualityGood;
            break;
        case AgoraRtc_Quality_Poor:
            netMeetingQuality = kYYIMNetMeetingQualityPoor;
            break;
        case AgoraRtc_Quality_Bad:
            netMeetingQuality = kYYIMNetMeetingQualityBad;
            break;
        case AgoraRtc_Quality_VBad:
            netMeetingQuality = kYYIMNetMeetingQualityVBad;
            break;
        case AgoraRtc_Quality_Down:
            netMeetingQuality = kYYIMNetMeetingQualityDown;
            break;
        default:
            netMeetingQuality = kYYIMNetMeetingQualityUnknown;
            break;
    }
    [self.activeDelegate didNetMeetingNetworkQuality:netMeetingQuality];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine mediaEngineEvent:(NSInteger)event {
    YYIMLogDebug(@"mediaEngineEvent-音频初始化完毕");
}

#pragma mark -
#pragma mark packet request

- (NSString *)startReservationNetMeeting:(NSString *)channelId {
     //如果当前正在会议中不允许任何进入会议的操作
    if (self.currentChannelId) {
        return nil;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"init" forKey:@"operationType"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleChanelStartReserationResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
    return packetID;

}

/**
 *  创建一个会议
 *
 *  @param netMeetingType 会议类型（会议或者直播）
 *  @param netMeetingMode 会议模式（视频或者语音）
 *  @param invitees       被邀请人
 *  @param topic
 *
 *  @return 创建的唯一标示
 */
- (NSString *)createNetMeetingWithNetMeetingType:(YYIMNetMeetingType)netMeetingType netMeetingMode:(YYIMNetMeetingMode)netMeetingMode invitees:(NSArray *)invitees topic:(NSString *)topic {
    //如果当前正在会议中不允许任何进入会议的操作
    if (self.currentChannelId) {
        return nil;
    }
    
    // invitees
    NSMutableSet *userIdSet = [NSMutableSet set];
    
    for (NSString *userId in invitees) {
        if ([YYIMStringUtility isEmpty:userId]) {
            continue;
        }
        [userIdSet addObject:[userId lowercaseString]];
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingCreatePacketOpCode) packetID:packetID];
    [iq setObject:[userIdSet allObjects] forKey:@"invitees"];
    
    NSString *mode;
    switch (netMeetingMode) {
        case kYYIMNetMeetingModeAudio:
            mode = @"voice";
            break;
        case kYYIMNetMeetingModeVideo:
            mode = @"video";
            break;
        default:
            mode = @"video";
            break;
    }
    [iq setObject:mode forKey:@"conferenceMode"];
    
    NSString *type;
    switch (netMeetingType) {
        case kYYIMNetMeetingTypeMeeting:
            type = @"conference";
            break;
        case kYYIMNetMeetingTypeLive:
            type = @"live";
            break;
        case kYYIMNetMeetingTypeSingleChat:
            type = @"singleChat";
            break;
        case kYYIMNetMeetingTypeGroupChat:
            type = @"groupChat";
            break;
        default:
            type = @"conference";
            break;
    }
    
    if (netMeetingType != kYYIMNetMeetingTypeSingleChat) {
        if (!topic || topic.length == 0) {
            YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
            
            NSString *genTopic;
            switch (netMeetingType) {
                case kYYIMNetMeetingTypeMeeting:
                    genTopic = @"的会议";
                    break;
                case kYYIMNetMeetingTypeLive:
                    genTopic = @"的直播";
                    break;
                case kYYIMNetMeetingTypeSingleChat:
                    genTopic = @"";
                    break;
                case kYYIMNetMeetingTypeGroupChat:
                    genTopic = @"的会议";
                    break;
                default:
                    genTopic = @"的会议";
                    break;
            }
            
            genTopic = [NSString stringWithFormat:@"%@%@", user.userName, genTopic];
            [iq setObject:genTopic forKey:@"topic"];
        } else {
            [iq setObject:topic forKey:@"topic"];
        }
    }
    
    [iq setObject:type forKey:@"conferenceType"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleChanelCreateResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
    return packetID;
}

- (void)inviteNetMeetingMember:(NSString *)channelId invitees:(NSArray *)invitees {
    // invitees
    NSMutableSet *userIdSet = [NSMutableSet set];
    for (NSString *userId in invitees) {
        if ([YYIMStringUtility isEmpty:userId]) {
            continue;
        }
        [userIdSet addObject:[userId lowercaseString]];
    }
    
    if (userIdSet.count <= 0) {
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"invite" forKey:@"operationType"];
    
    [iq setObject:[userIdSet allObjects] forKey:@"operhand"];
    [[self activeStream] sendPacket:iq];
}


/**
 *  发送加入会议的报文
 *
 *  @param channelId 频道id
 */
- (void)joinNetMeeting:(NSString *)channelId {
    //如果当前正在会议中不允许任何进入会议的操作
    if (self.currentChannelId) {
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"join" forKey:@"operationType"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleJoinNetMeetingResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  发送离开会议的报文
 *
 *  @param channelId 频道id
 */
- (void)exitNetMeeting:(NSString *)channelId {
    if ([channelId isEqualToString:self.currentChannelId]) {
        // packetID
        NSString *packetID = [JUMPStream generateJUMPID];
        // iq
        JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
        [iq setObject:channelId forKey:@"channelId"];
        [iq setObject:@"exit" forKey:@"operationType"];
        
        [[self activeStream] sendPacket:iq];
        
        [self sendBillStatus:YYIMNetMeetingBillStatusEnd channelId:channelId];
        self.currentChannelId = nil;
        
        [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
            // 停止定时器timer
            if (self.timer && self.timer.isValid){
                [self.timer invalidate];
            }
        }];
    }
}

/**
 *  同意加入会议
 *
 *  @param channelId 频道id
 */
- (void)agreeEnterNetMeeting:(NSString *)channelId {
    //如果当前正在会议中不允许任何进入会议的操作
    if (self.currentChannelId) {
        return;
    }
    
    self.inviteChannelId = nil;
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"agree" forKey:@"operationType"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleAgreeNetMeetingResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  拒绝加入会议
 *
 *  @param channelId 频道id
 */
- (void)refuseEnterNetMeeting:(NSString *)channelId {
    self.inviteChannelId = nil;
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"refuse" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  发送正在忙的报文
 *
 *  @param channelId 频道id
 */
- (void)busyNow:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"busy" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  发送会议上上锁报文
 *
 *  @param channelId 频道id
 */
- (void)lockNetMeeting:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"lock" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  发送会议解锁报文
 *
 *  @param channelId 频道id
 */
- (void)unlockNetMeeting:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"unlock" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  会议主题编辑
 *
 *  @param channelId 频道id
 */
- (void)editNetMeetingTopic:(NSString *)channelId topic:(NSString *)topic {
    if (!topic || topic.length == 0) {
        [[self activeDelegate] didNotNetMeetingEditTopic:channelId error:[YYIMError errorWithCode:YMERROR_CODE_MISS_PARAMETER errorMessage:@"主题不能为空"]];
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"editTopic" forKey:@"operationType"];
    [iq setObject:topic forKey:@"topic"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  打开视频通知
 *
 *  @param channelId 频道id
 */
- (void)openNetMeetingVideo:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"openVideo" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  关闭视频通知
 *
 *  @param channelId 频道id
 */
- (void)closeNetMeetingVideo:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"closeVideo" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  打开音频
 *
 *  @param channelId 频道id
 */
- (void)openNetMeetingAudio:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"openMicrophone" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  关闭音频
 *
 *  @param channelId 频道id
 */
- (void)closeNetMeetingAudio:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"closeMicrophone" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  更换主持人
 *
 *  @param channelId 频道id
 *  @param userId    新的主持人
 */
- (void)roleConversionOfNetMeeting:(NSString *)channelId withUserId:(NSString *)userId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@"roleConversion" forKey:@"operationType"];
    [iq setObject:@[userId] forKey:@"operhand"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  主持人结束了会议
 *
 *  @param channelId 频道id
 */
- (void)endNetMeeting:(NSString *)channelId {
    if ([channelId isEqualToString:self.currentChannelId]) {
        [self sendBillStatus:YYIMNetMeetingBillStatusEnd channelId:channelId];
        
        // packetID
        NSString *packetID = [JUMPStream generateJUMPID];
        // iq
        JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
        [iq setObject:channelId forKey:@"channelId"];
        [iq setObject:@"end" forKey:@"operationType"];
        
        [[self activeStream] sendPacket:iq];
        
        self.currentChannelId = nil;
        
        [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
            // 停止定时器timer
            if (self.timer && self.timer.isValid){
                [self.timer invalidate];
            }
        }];
    }
}

/**
 *  从房间踢出成员
 *
 *  @param channelId   频道id
 *  @param memberArray 成员集合
 */
- (void)kickMemberFromNetMeeting:(NSString *)channelId memberArray:(NSArray *)memberArray {
    NSMutableSet *userIdSet = [NSMutableSet set];
    
    for (NSString *userId in memberArray) {
        if ([YYIMStringUtility isEmpty:userId]) {
            continue;
        }
        [userIdSet addObject:[userId lowercaseString]];
    }
    
    if (userIdSet.count <= 0) {
        return;
    }
    
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:[userIdSet allObjects] forKey:@"operhand"];
    [iq setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"operator"];
    [iq setObject:@"kick" forKey:@"operationType"];
    
    [[self tracker] addPacket:iq
                       target:self
                     selector:@selector(handleKickFromChanelResponse:withInfo:)
                      timeout:30];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  频道中指定成员禁言
 *
 *  @param channelId   频道id
 *  @param memberArray 成员集合
 */
- (void)disableMemberSpeakFromNetMeeting:(NSString *)channelId userId:(NSString *)userId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@[userId] forKey:@"operhand"];
    [iq setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"operator"];
    [iq setObject:@"mute" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  频道中指定成员取消禁言
 *
 *  @param channelId   频道id
 *  @param memberArray 成员集合
 */
- (void)enableMemberSpeakFromNetMeeting:(NSString *)channelId  userId:(NSString *)userId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:@[userId] forKey:@"operhand"];
    [iq setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"operator"];
    [iq setObject:@"cancelMute" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}


/**
 *  禁言所有人
 *
 *  @param channelId 频道id
 */
- (void)disableAllSpeakFromNetMeeting:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"operator"];
    [iq setObject:@"muteAll" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  取消禁言所有人
 *
 *  @param channelId 频道id
 */
- (void)enableAllSpeakFromNetMeeting:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingManagePacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    [iq setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"operator"];
    [iq setObject:@"cancelMuteAll" forKey:@"operationType"];
    
    [[self activeStream] sendPacket:iq];
}

/**
 *  发送账单状态
 *
 *  @param status    状态 （begin、pay、end）
 *  @param channelId 频道id
 */
- (void)sendBillStatus:(YYIMNetMeetingBillStatus)status channelId:(NSString *)channelId {
    // packetID
    NSString *packetID = [JUMPStream generateJUMPID];
    // iq
    JUMPIQ *iq = [JUMPIQ iqWithOpData:JUMP_OPDATA(JUMPNetMeetingBillPacketOpCode) packetID:packetID];
    [iq setObject:channelId forKey:@"channelId"];
    
    switch (status) {
        case YYIMNetMeetingBillStatusBegin:
            [iq setObject:@"begin" forKey:@"type"];
            break;
        case YYIMNetMeetingBillStatusPay:
            [iq setObject:@"pay" forKey:@"type"];
            break;
        case YYIMNetMeetingBillStatusEnd:
            [iq setObject:@"end" forKey:@"type"];
            break;
        default:
            break;
    }
    
    [[self activeStream] sendPacket:iq];
}

- (void)getNetmeetingDetail:(NSString *)channelId complete:(void (^)(BOOL, YYNetMeetingDetail *, NSArray *, YYIMError *))complete {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, nil, nil, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingDetailServlet:channelId];
            
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYNetMeetingDetail *detail = [[YYNetMeetingDetail alloc] init];
                // 云会议ID
                [detail setChannelId:[dic objectForKey:@"channelId"]];
                // 云会议主题
                [detail setTopic:[dic objectForKey:@"topic"]];
                // 云会议议程
                [detail setAgenda:[dic objectForKey:@"proceedings"]];
                // 云会议创建者
                [detail setCreator:[YYIMJUMPHelper parseUser:[dic objectForKey:@"moderator"]]];
                
                // 云会议类型
                NSString *netMeetingTypeStr = [dic objectForKey:@"conferenceType"];
                if ([@"conference" isEqualToString:netMeetingTypeStr]) {
                    [detail setNetMeetingType:kYYIMNetMeetingTypeMeeting];
                } else if ([@"live" isEqualToString:netMeetingTypeStr]) {
                    [detail setNetMeetingType:kYYIMNetMeetingTypeLive];
                } else if ([@"singleChat" isEqualToString:netMeetingTypeStr]) {
                    [detail setNetMeetingType:kYYIMNetMeetingTypeSingleChat];
                } else if ([@"groupChat" isEqualToString:netMeetingTypeStr]) {
                    [detail setNetMeetingType:kYYIMNetMeetingTypeGroupChat];
                }
                
                // 云会议状态
                NSString *netMeetingStateStr = [dic objectForKey:@"conferenceState"];
                if ([@"end" isEqualToString:netMeetingStateStr]) {
                    [detail setState:kYYIMNetMeetingStateEnd];
                } else if ([@"continue" isEqualToString:netMeetingStateStr]) {
                    [detail setState:kYYIMNetMeetingStateIng];
                } else if ([@"nostart" isEqualToString:netMeetingStateStr]) {
                    [detail setState:kYYIMNetMeetingStateNew];
                }
                
                // 云预约会议计划时间
                [detail setPlanBeginTime:[[dic objectForKey:@"planBeginTime"] doubleValue]];
                [detail setPlanEndTime:[[dic objectForKey:@"planEndTime"] doubleValue]];
                // 云会议时间
                [detail setCreateTime:[[dic objectForKey:@"createTime"] doubleValue]];
                [detail setEndTime:[[dic objectForKey:@"endTime"] doubleValue]];
                
                //云会议成员
                NSArray *memberArray = [dic objectForKey:@"members"];
                NSMutableArray *memberIds = [NSMutableArray array];
                if (memberArray && memberArray.count > 0) {
                    for (NSString *userId in memberArray) {
                        [memberIds addObject:[YYIMJUMPHelper parseUser:userId]];
                    }
                }
                
                complete(YES, detail, memberIds, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"预约会议失败：%@", error.localizedDescription);
                complete(NO, nil, nil, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, nil, nil, tokenError);
        }
    }];
}

- (void)getMyNetMeetingWithOffset:(NSUInteger)offset limit:(NSUInteger)limit complete:(void (^)(BOOL, NSArray *, YYIMError *))complete {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, nil, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            [params setObject:[NSNumber numberWithInteger:offset] forKey:@"start"];
            [params setObject:[NSNumber numberWithInteger:limit] forKey:@"size"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingInfoServlet];
            
            [manager GET:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                NSArray *items = [dic objectForKey:@"list"];
                
                NSMutableArray *infos = [NSMutableArray array];
                for (NSDictionary *item in items) {
                    YYNetMeetingHistory *netMeetingHistory = [[YYNetMeetingHistory alloc] init];
                    // 云会议ID
                    [netMeetingHistory setChannelId:[item objectForKey:@"channelId"]];
                    // 云会议主题
                    [netMeetingHistory setTopic:[item objectForKey:@"topic"]];
                    // 云会议状态
                    NSString *netMeetingStateStr = [item objectForKey:@"conferenceState"];
                    if ([@"end" isEqualToString:netMeetingStateStr]) {
                        [netMeetingHistory setState:kYYIMNetMeetingStateEnd];
                    } else if ([@"continue" isEqualToString:netMeetingStateStr]) {
                        [netMeetingHistory setState:kYYIMNetMeetingStateIng];
                    } else if ([@"nostart" isEqualToString:netMeetingStateStr]) {
                        [netMeetingHistory setState:kYYIMNetMeetingStateNew];
                    }
                    // 云会议类型
                    NSString *netMeetingTypeStr = [item objectForKey:@"conferenceType"];
                    if ([@"conference" isEqualToString:netMeetingTypeStr]) {
                        [netMeetingHistory setType:kYYIMNetMeetingTypeMeeting];
                    } else if ([@"live" isEqualToString:netMeetingTypeStr]) {
                        [netMeetingHistory setType:kYYIMNetMeetingTypeLive];
                    } else if ([@"singleChat" isEqualToString:netMeetingTypeStr]) {
                        [netMeetingHistory setType:kYYIMNetMeetingTypeSingleChat];
                    } else if ([@"groupChat" isEqualToString:netMeetingTypeStr]) {
                        [netMeetingHistory setType:kYYIMNetMeetingTypeGroupChat];
                    }
                    // 云会议发起人
                    [netMeetingHistory setModerator:[YYIMJUMPHelper parseUser:[item objectForKey:@"moderator"]]];
                    if (netMeetingHistory.state == kYYIMNetMeetingStateNew) {
                        // 云会议时间
                        [netMeetingHistory setDate:[[item objectForKey:@"planBeginTime"] doubleValue]];
                    } else {
                        // 云会议时间
                        [netMeetingHistory setDate:[[item objectForKey:@"createTime"] doubleValue]];
                    }
                    
                    [infos addObject:netMeetingHistory];
                }
                complete(YES, infos, nil);

            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"获取我的会议记录失败：%@", error.localizedDescription);
                complete(NO, nil, [YYIMError errorWithNSError:error]);
            }];
            
        } else {
            complete(NO, nil, tokenError);
        }
    }];
}

- (void)reservationNetMeetingWithNetMeetingDetail:(YYNetMeetingDetail *)netMeetingDetail members:(NSArray *)members complete:(void (^)(BOOL, YYIMError *, NSString *, NSArray *))complete {
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"creator"];
            [params setObject:[YYIMStringUtility notNilString:netMeetingDetail.topic] forKey:@"topic"];
            [params setObject:[YYIMStringUtility notNilString:netMeetingDetail.agenda] forKey:@"proceedings"];
            
            YYIMNetMeetingType type = netMeetingDetail.netMeetingType;
            NSString *typeString;
            
            switch (type) {
                case kYYIMNetMeetingTypeMeeting:
                    typeString = @"conference";
                    break;
                case kYYIMNetMeetingTypeLive:
                    typeString = @"live";
                    break;
                default:
                    typeString = @"conference";
                    break;
            }
            
            [params setObject:typeString forKey:@"conferenceType"];
            [params setObject:[NSNumber numberWithLongLong:netMeetingDetail.planBeginTime] forKey:@"planBeginTime"];
            [params setObject:[NSNumber numberWithLongLong:netMeetingDetail.planEndTime] forKey:@"planEndTime"];
            
            if (members && members.count > 0) {
                [params setObject:members forKey:@"members"];
            }
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setRequestSerializer:[YMAFJSONRequestSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingReservationServlet];
            urlString = [NSString stringWithFormat:@"%@?token=%@", urlString, [token tokenStr]];
            
            [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"预约会议成功：%@", dic);
                NSArray *misMatch = [dic objectForKey:@"netaccountMismatchMember"];
                NSString *channelId = [dic objectForKey:@"channelId"];
                
                if (misMatch && misMatch.count > 0) {
                    [[self activeDelegate] didNetMeetingInviteMisMatchMember:[dic objectForKey:@"channelId"] userArray:misMatch];
                }
                
                complete(YES, nil, channelId, misMatch);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"预约会议失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error], nil, nil);
            }];
        } else {
            complete(NO, tokenError, nil, nil);
        }
    }];
}

- (void)EditReservationNetMeeting:(YYNetMeetingDetail *)netMeetingDetail complete:(void (^)(BOOL, YYIMError *))complete {
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"operator"];
            [params setObject:[YYIMStringUtility notNilString:netMeetingDetail.channelId] forKey:@"channelId"];
            [params setObject:[YYIMStringUtility notNilString:netMeetingDetail.topic] forKey:@"topic"];
            [params setObject:[YYIMStringUtility notNilString:netMeetingDetail.agenda] forKey:@"proceedings"];
            [params setObject:[NSNumber numberWithLongLong:netMeetingDetail.planBeginTime] forKey:@"planBeginTime"];
            [params setObject:[NSNumber numberWithLongLong:netMeetingDetail.planEndTime] forKey:@"planEndTime"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setRequestSerializer:[YMAFJSONRequestSerializer serializer]];
            [manager setResponseSerializer:[YMAFHTTPResponseSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingReservationServlet];
            urlString = [NSString stringWithFormat:@"%@?token=%@", urlString, [token tokenStr]];
            
            [manager PUT:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"预约会议修改成功：%@", dic);
                
                //修改日历事件
                NSString *calendarId = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingCalendarIdByChannelId:netMeetingDetail.channelId];
                EKEvent *event = [self.eventStore eventWithIdentifier:calendarId];
                
                if (event) {
                    event.title = (NSString *)[YYIMStringUtility notNilString:netMeetingDetail.topic];
                    event.startDate = [NSDate dateWithTimeIntervalSince1970:netMeetingDetail.planBeginTime/1000];
                    event.endDate = [NSDate dateWithTimeIntervalSince1970:netMeetingDetail.planEndTime/1000];
                    
                    NSError *err;
                    [self.eventStore saveEvent:event span:EKSpanThisEvent commit:YES error:&err];
                }
                
                
                complete(YES, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"预约会议修改失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);
            }];
        }
    }];
}

- (void)removeNetMeetingWithChannelId:(NSString *)channelId complete:(void (^)(BOOL, YYIMError *))complete {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setResponseSerializer:[YMAFHTTPResponseSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingRemoveServlet:channelId];
            
            [manager DELETE:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"删除会议记录成功：%@", dic);
                
                complete(YES, nil);

            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"删除会议记录失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, tokenError);
        }
    }];
}

- (void)cancelReservationNetMeeting:(NSString *)channelId complete:(void (^)(BOOL, YYIMError *))complete {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setResponseSerializer:[YMAFHTTPResponseSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingCancelReservationServlet:channelId];
            
            [manager DELETE:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"取消预约会议成功：%@", dic);
                
                //删除会议的日历事件
                NSString *calendarId = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingCalendarIdByChannelId:channelId];
                EKEvent *event = [self.eventStore eventWithIdentifier:calendarId];
                
                if (event) {
                    NSError *err;
                    [self.eventStore removeEvent:event span:EKSpanThisEvent commit:YES error:&err];
                    
                    [[YYIMNetMeetingDBHelper sharedInstance] removeNetMeetingCalendar:channelId];
                }
                
                complete(YES, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"取消预约会议失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);
            }];
        } else {
            complete(NO, tokenError);
        }
    }];
}

- (void)inviteReservationNetMeeting:(NSString *)channelId member:(NSArray *)members complete:(void (^)(BOOL, YYIMError *, NSArray *))complete {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"], nil);
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"operator"];
            [params setObject:channelId forKey:@"channelId"];
            [params setObject:members forKey:@"members"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setRequestSerializer:[YMAFJSONRequestSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingReservationInviteServlet];
            urlString = [NSString stringWithFormat:@"%@?token=%@", urlString, [token tokenStr]];
            
            [manager POST:urlString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"预约会议邀请人成功：%@", dic);
                
                NSArray *disMatchUsers = [dic objectForKey:@"netaccountMismatchMember"];
                
                complete(YES, nil, disMatchUsers);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"预约会议邀请人失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error], nil);
            }];
        } else {
            complete(NO, tokenError, nil);
        }
    }];
}

- (void)kickReservationNetMeeting:(NSString *)channelId member:(NSArray *)members complete:(void (^)(BOOL, YYIMError *))complete {
    // 用户ID
    NSString *user = [[YYIMConfig sharedInstance] getUser];
    if ([YYIMStringUtility isEmpty:user]) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"userId not found"]);
        return;
    }
    
    if (!members || members.count == 0) {
        complete(NO, [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"members can not be empty"]);
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result && [token tokenStr]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            
            NSMutableString *kickStr = [NSMutableString stringWithFormat:@"["];
            NSInteger count = 0;
            for (NSString *userId in members) {
                if (count != 0) {
                    [kickStr appendString:@","];
                }
                
                [kickStr appendFormat:@"'%@'",userId];
                count++;
            }
            [kickStr appendString:@"]"];
            
            [params setObject:kickStr forKey:@"usernames"];
            
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setResponseSerializer:[YMAFHTTPResponseSerializer serializer]];
            NSString *urlString = [[YYIMConfig sharedInstance] getNetMeetingReservationKickServlet:channelId];
            
            [manager DELETE:urlString parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
                NSDictionary *dic = (NSDictionary *)responseObject;
                YYIMLogDebug(@"预约会议邀踢人成功：%@", dic);
                
                complete(YES, nil);
            } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
                YYIMLogError(@"预约会议邀踢人失败：%@", error.localizedDescription);
                complete(NO, [YYIMError errorWithNSError:error]);

            }];
        } else {
            complete(NO, tokenError);
        }
    }];
}

#pragma mark -
#pragma mark jumpstream delegate

- (BOOL)jumpStream:(JUMPStream *)sender didReceiveIQ:(JUMPIQ *)iq {
    BOOL result = [[self tracker] invokeForID:[iq packetID] withObject:iq];
    
    if (!result) {
        if ([iq checkOpData:JUMP_OPDATA(JUMPNetMeetingNotifyPacketOpCode)]) {
            [self didReceiveNetMeetingUpdatePush:iq];
        }
        
        return result;
    }
    
    return result;
}

- (void)jumpStream:(JUMPStream *)sender didReceiveError:(JUMPError *)error {
    if ([error packetID]) {
        [[self tracker] invokeForID:[error packetID] withObject:error];
    }
}

- (void)jumpStream:(JUMPStream *)sender didFailToSendIQ:(JUMPIQ *)iq error:(NSError *)error {
    if ([iq packetID]) {
        [[self tracker] invokeForID:[iq packetID] withObject:nil];
    }
}

#pragma mark -
#pragma mark packet response

/**
 *  开始预约会议的响应
 *
 *  @param jumpPacket
 *  @param info       
 */
- (void)handleChanelStartReserationResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPNetMeetingNotifyPacketOpCode)]) {
        YYIMError *error;
        
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        YYIMLogError(@"StartReserationError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        if (traceIQ) {
            [[self activeDelegate] didNotStartReservationNetMeetingWithSeriId:[traceIQ packetID] error:error];
        }
        
        return;
    }
    
    [self didReceiveNetMeetingUpdatePush:(JUMPIQ *)jumpPacket];
}

- (void)handleChanelCreateResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPNetMeetingNotifyPacketOpCode)]) {
        YYIMError *error;
        
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        YYIMLogError(@"ChanelCreateError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        if (traceIQ) {
            NSString *netMeetingTypeStr = [traceIQ objectForKey:@"conferenceType"];
            YYIMNetMeetingType netMeetingType;
            if ([netMeetingTypeStr isEqualToString:@"conference"]) {
                netMeetingType = kYYIMNetMeetingTypeMeeting;
            } else if ([netMeetingTypeStr isEqualToString:@"live"]) {
                netMeetingType = kYYIMNetMeetingTypeLive;
            } else if ([netMeetingTypeStr isEqualToString:@"singleChat"]) {
                netMeetingType = kYYIMNetMeetingTypeSingleChat;
            } else if ([netMeetingTypeStr isEqualToString:@"groupChat"]) {
                netMeetingType = kYYIMNetMeetingTypeGroupChat;
            } else {
                netMeetingType = kYYIMNetMeetingTypeMeeting;
            }
            
            // 会议模式
            NSString *conferencModeStr = [traceIQ objectForKey:@"conferenceMode"];
            YYIMNetMeetingMode conferencMode;
            if ([conferencModeStr isEqualToString:@"voice"]) {
                conferencMode = kYYIMNetMeetingModeAudio;
            } else if ([netMeetingTypeStr isEqualToString:@"video"]) {
                conferencMode = kYYIMNetMeetingModeVideo;
            } else {
                conferencMode = kYYIMNetMeetingModeVideo;
            }
            
            [[self activeDelegate] didNotNetMeetingCreateWithSeriId:[traceIQ packetID] netMeetingType:netMeetingType netMeetingMode:conferencMode error:error];
        }
        
        return;
    }
    
    [self didReceiveNetMeetingUpdatePush:(JUMPIQ *)jumpPacket];
}

- (void)handleJoinNetMeetingResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPNetMeetingNotifyPacketOpCode)]) {
        YYIMError *error;
        
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        YYIMLogError(@"JoinNetMeetingError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        NSString *channelId = [traceIQ objectForKey:@"channelId"];
        
        if (traceIQ) {
            [[self activeDelegate] didNotJoinNetMeeting:channelId error:error];
        }
        
        return;
    }
    
    [self didReceiveNetMeetingUpdatePush:(JUMPIQ *)jumpPacket];
}

- (void)handleAgreeNetMeetingResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPNetMeetingNotifyPacketOpCode)]) {
        YYIMError *error;
        
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        YYIMLogError(@"AgreeNetMeetingError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        NSString *channelId = [traceIQ objectForKey:@"channelId"];
        
        if (traceIQ) {
            [[self activeDelegate] didNotAgreeNetMeeting:channelId error:error];
        }
        
        return;
    }
    
    [self didReceiveNetMeetingUpdatePush:(JUMPIQ *)jumpPacket];
}

- (void)handleKickFromChanelResponse:(JUMPPacket *)jumpPacket withInfo:(id <JUMPTrackingInfo>)info {
    if (!jumpPacket || ![jumpPacket checkOpData:JUMP_OPDATA(JUMPNetMeetingNotifyPacketOpCode)]) {
        YYIMError *error;
        
        if (!jumpPacket) {
            error = [YYIMError errorWithCode:YMERROR_CODE_RESPONSE_NOT_RECEIVED errorMessage:@"response not received"];
        } else if ([jumpPacket isErrorPacket]) {
            error = [YYIMError errorWithCode:[[jumpPacket objectForKey:@"code"] integerValue] errorMessage:[jumpPacket objectForKey:@"message"]];
        } else {
            error = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"];
        }
        
        YYIMLogError(@"KickFromChanelError:%ld:%@", (long)[error errorCode], [error errorMsg]);
        
        JUMPIQ *traceIQ = (JUMPIQ *)[info packet];
        
        if (traceIQ) {
            [[self activeDelegate] didNotKickMemberFromNetMeeting];
        }
        
        return;
    }
    
    [self didReceiveNetMeetingUpdatePush:(JUMPIQ *)jumpPacket];
}

#pragma mark -
#pragma mark packet notify

/**
 *  房间和成员变化的报文
 *
 *  @param iq iq包
 */
- (void)didReceiveNetMeetingUpdatePush:(JUMPIQ *)iq {
    if (![iq checkOpData:JUMP_OPDATA(JUMPNetMeetingNotifyPacketOpCode)]) {
        return ;
    }
    
    NSString *operationType = [iq objectForKey:@"operationType"];
    if ([self.memberChange containsObject:operationType]) {
        [self didReceiveNetMeetingMemberChange:iq];
    } else if ([self.memberStatusChange containsObject:operationType]) {
        [self didReceiveNetMeetingMemberStatusChange:iq];
    } else if ([self.netMeetingStatusChange containsObject:operationType]) {
        [self didReceiveNetMeetingStatusChange:iq];
    } else {
        return;
    }
}

/**
 *  视频会议成员变更
 *
 *  @param iq
 */
- (void)didReceiveNetMeetingMemberChange:(JUMPIQ *)iq {
    // 频道ID
    NSString *channelId = [iq objectForKey:@"channelId"];
    // 会议创建者
    NSString *creator = [YYIMJUMPHelper parseUser:[iq objectForKey:@"creator"]];
    
    // 操作人
    NSString *operator = [YYIMJUMPHelper parseUser:[iq objectForKey:@"operator"]];
    // 被操作人
    NSArray *operhand = [iq objectForKey:@"operhand"];
    NSMutableArray *operhandArray = [NSMutableArray array];
    for (NSString *oper in operhand) {
        [operhandArray addObject:[YYIMJUMPHelper parseUser:oper]];
    }
    [operhandArray removeObject:operator];
    operhand = operhandArray;
    
    // 操作类型
    NSString *operationType = [iq objectForKey:@"operationType"];
    //优先处理一下单聊离开房间的事件
    if ([operationType isEqualToString:@"exit"]) {
        YYNetMeeting *oldMeeting = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingWithChannelId:channelId];
        if (oldMeeting && oldMeeting.netMeetingType == kYYIMNetMeetingTypeSingleChat) {
            if (![operator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                [[self activeDelegate] didNetMeetingMemberExit:operator];
            }
            
            [self autoLeaveChannel];
            return;
        }
    }
    
    // 会议类型
    NSString *netMeetingTypeStr = [iq objectForKey:@"conferenceType"];
    YYIMNetMeetingType netMeetingType;
    if ([netMeetingTypeStr isEqualToString:@"conference"]) {
        netMeetingType = kYYIMNetMeetingTypeMeeting;
    } else if ([netMeetingTypeStr isEqualToString:@"live"]) {
        netMeetingType = kYYIMNetMeetingTypeLive;
    } else if ([netMeetingTypeStr isEqualToString:@"singleChat"]) {
        netMeetingType = kYYIMNetMeetingTypeSingleChat;
    } else if ([netMeetingTypeStr isEqualToString:@"groupChat"]) {
        netMeetingType = kYYIMNetMeetingTypeGroupChat;
    } else {
        netMeetingType = kYYIMNetMeetingTypeMeeting;
    }
    
    // 会议模式
    NSString *conferencModeStr = [iq objectForKey:@"conferenceMode"];
    YYIMNetMeetingMode conferencMode;
    if ([conferencModeStr isEqualToString:@"voice"]) {
        conferencMode = kYYIMNetMeetingModeAudio;
    } else if ([netMeetingTypeStr isEqualToString:@"video"]) {
        conferencMode = kYYIMNetMeetingModeVideo;
    } else {
        conferencMode = kYYIMNetMeetingModeVideo;
    }
    
    // 组装会议
    YYNetMeeting *channel = [[YYNetMeeting alloc] init];
    [channel setChannelId:channelId];
    [channel setNetMeetingMode:conferencMode];
    [channel setNetMeetingType:netMeetingType];
    [channel setInviterId:operator];
    [channel setDynamicKey:[iq objectForKey:@"token"]];
    [channel setLock:NO];
    [channel setMuteAll:NO];
    [channel setTopic:[iq objectForKey:@"topic"]];
    [channel setCreateTime:[[iq objectForKey:@"createTime"] longLongValue]];
    [channel setCreator:creator];
    
    
    BOOL isNetMeetingMuteAll = NO;
    // 会议状态
    NSArray *conferenceState = [iq objectForKey:@"conferenceState"];
    if (conferenceState && conferenceState.count > 0) {
        for (NSString *state in conferenceState) {
            if ([state isEqualToString:@"lock"]) {
                [channel setLock:YES];
            } else if ([state isEqualToString:@"muteAll"]) {
                [channel setMuteAll:YES];
                isNetMeetingMuteAll = YES;
            }
        }
    }
    
    // 会议成员
    NSArray *members = [iq objectForKey:@"members"];
    
    NSMutableArray *memberArray = [NSMutableArray array];
    if (members && members.count > 0) {
        for (NSDictionary *item in members) {
            // 组装成员
            YYNetMeetingMember *member = [[YYNetMeetingMember alloc] init];
            [member setChannelId:channelId];
            [member setMemberId:[YYIMJUMPHelper parseUser:[item objectForKey:@"jid"]]];
            [member setMemberRole:[item objectForKey:@"role"]];
            [member setMemberName:[item objectForKey:@"name"]];
            [member setMemberUid:[[item objectForKey:@"soundChannelId"] unsignedIntegerValue]];
            [member setEnableVideo:YES];
            [member setEnableAudio:YES];
            [member setForbidAudio:NO];
            
            // 成员状态
            NSArray *memberStatusArray = [item objectForKey:@"memberState"];
            if (memberStatusArray && memberStatusArray.count > 0) {
                for (NSString *memberStatus in memberStatusArray) {
                    if ([memberStatus isEqualToString:@"videoClosed"]) {
                        [member setEnableVideo:NO];
                    } else if ([memberStatus isEqualToString:@"mute"]) {
                        [member setEnableAudio:NO];
                    } else if ([memberStatus isEqualToString:@"muzzled"]) {
                        [member setForbidAudio:YES];
                    }
                }
            }
            
            //如果房间状态被设置了全部禁言，个人需要强制设置状态
            if (isNetMeetingMuteAll) {
                [member setForbidAudio:YES];
            }
            
            // 参会状态
            NSString *participansState = [item objectForKey:@"participansState"];
            if ([participansState isEqualToString:@"init"]) {
                [member setInviteState:kYYIMNetMeetingInviteStateInit];
            } else if ([participansState isEqualToString:@"inviting"]) {
                [member setInviteState:kYYIMNetMeetingInviteStateInviting];
            } else if ([participansState isEqualToString:@"joined"]) {
                [member setInviteState:kYYIMNetMeetingInviteStateJoined];
            } else if ([participansState isEqualToString:@"timeout"]) {
                [member setInviteState:kYYIMNetMeetingInviteStateTimeout];
            } else if ([participansState isEqualToString:@"busy"]) {
                [member setInviteState:kYYIMNetMeetingInviteStateBusy];
            } else if ([participansState isEqualToString:@"refuse"]) {
                [member setInviteState:kYYIMNetMeetingInviteStateRefuse];
            } else if ([participansState isEqualToString:@"exit"]) {
                [member setInviteState:kYYIMNetMeetingInviteStateExit];
            } else {
                [member setInviteState:kYYIMNetMeetingInviteStateRefuse];
            }
            
            [memberArray addObject:member];
        }
    }
    
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeeting:channel];
    [[YYIMNetMeetingDBHelper sharedInstance] batchUpdateNetMeetingMember:channelId members:memberArray];
    
    // 会议成员
    NSArray *misMatchMemberIds = [iq objectForKey:@"netaccountMismatchMember"];
    NSMutableArray *misMatchMembers = [NSMutableArray array];
    
    if (misMatchMemberIds && misMatchMemberIds.count > 0) {
        for (NSString *member in misMatchMemberIds) {
            NSString *memberId = [YYIMJUMPHelper parseUser:member];
            YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:memberId];
            
            if (user) {
                [misMatchMembers addObject:user];
            }
        }
    }
    
    if ([operationType isEqualToString:@"create"]) {// 创建
        [self didOperatorTypeCreate:channelId creator:creator misMatchMembers:misMatchMembers operhand:operhand packetId:[iq packetID]];
    } else if ([operationType isEqualToString:@"init"]) {// 开始预约会议
        [self didOperatorTypeStartReservation:channelId creator:creator misMatchMembers:misMatchMembers operhand:operhand packetId:[iq packetID]];
    }else if ([operationType isEqualToString:@"invite"]) {// 邀请
        [self didOperatorTypeInvite:channelId operator:operator misMatchMembers:misMatchMembers operhand:operhand];
    } else if ([operationType isEqualToString:@"agree"] ) {// 同意邀请
        [self didOperatorTypeAgree:channelId operator:operator netMeetingType:netMeetingType];
    } else if ([operationType isEqualToString:@"join"]) {// 加入会议
        [self didOperatorTypeJoin:channelId operator:operator];
    }
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    if ([operationType isEqualToString:@"kick"]) {// 踢出
        if ([operhand containsObject:[[YYIMConfig sharedInstance] getUser]]) {
            [self autoLeaveChannel];
        }
        
        [[self activeDelegate] didNetMeetingMemberkicked:operhand];
    } else if ([operationType isEqualToString:@"exit"]) {// 退出会议
        if (![operator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            [[self activeDelegate] didNetMeetingMemberExit:operator];
        }
    } else if ([operationType isEqualToString:@"offline"]) {
        
    }
}

/**
 *  指定状态发生更改的报文
 *
 *  @param iq
 */
- (void)didReceiveNetMeetingMemberStatusChange:(JUMPIQ *)iq {
    NSString *channelId = [iq objectForKey:@"channelId"];
    NSString *operator = [YYIMJUMPHelper parseUser:[iq objectForKey:@"operator"]];
    NSString *operationType = [iq objectForKey:@"operationType"];
    
    NSArray *operhand = [iq objectForKey:@"operhand"];
    NSMutableArray *operhandArray = [NSMutableArray array];
    
    for (NSString *oper in operhand) {
        [operhandArray addObject:[YYIMJUMPHelper parseUser:oper]];
    }
    
    [operhandArray removeObject:operator];
    operhand = operhandArray;
    
    if ([operationType isEqualToString:@"mute"]) {
        if (operhand && operhand.count > 0) {
            [self didOperatorTypeMute:channelId operhand:operhand[0]];
        }
    } else if ([operationType isEqualToString:@"cancelMute"]) {
        if (operhand && operhand.count > 0) {
            [self didOperatorTypeCancelMute:channelId operhand:operhand[0]];
        }
    } else if ([operationType isEqualToString:@"hand"]) {
        [self didOperatorTypeHand];
    }else if ([operationType isEqualToString:@"openVideo"]) {
        [self didOperatorTypeOpenVideo:channelId operator:operator];
    } else if ([operationType isEqualToString:@"closeVideo"]) {
        [self didOperatorTypeCloseVideo:channelId operator:operator];
    } else if ([operationType isEqualToString:@"openMicrophone"]) {
        [self didOperatorTypeOpenMicrophone:channelId operator:operator];
    } else if ([operationType isEqualToString:@"closeMicrophone"]) {
        [self didOperatorTypeCloseMicrophone:channelId operator:operator];
    } else if ([operationType isEqualToString:@"timeout"]) {
        [self didOperatorTypeTimeOut:channelId operator:operator];
    } else if ([operationType isEqualToString:@"busy"]) {
        [self didOperatorTypeBusy:channelId operator:operator];
    } else if ([operationType isEqualToString:@"refuse"]) {
        [self didOperatorTypeRefuse:channelId operator:operator];
    }
}

/**
 *  全部状态发生更改的报文
 *
 *  @param iq
 */
- (void)didReceiveNetMeetingStatusChange:(JUMPIQ *)iq {
    NSString *channelId = [iq objectForKey:@"channelId"];
    NSString *operator = [YYIMJUMPHelper parseUser:[iq objectForKey:@"operator"]];
    NSString *operationType = [iq objectForKey:@"operationType"];
    NSString *topic = [iq objectForKey:@"topic"];
    
    NSArray *operhand = [iq objectForKey:@"operhand"];
    NSMutableArray *operhandArray = [NSMutableArray array];
    
    for (NSString *oper in operhand) {
        [operhandArray addObject:[YYIMJUMPHelper parseUser:oper]];
    }
    
    [operhandArray removeObject:operator];
    operhand = operhandArray;
    
    
    YYNetMeeting *channel = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingWithChannelId:channelId];
    
    if (!channelId) {
        return;
    }
    
    if ([operationType isEqualToString:@"muteAll"]
        || [operationType isEqualToString:@"cancelMuteAll"]
        || [operationType isEqualToString:@"lock"]
        || [operationType isEqualToString:@"unlock"]) {
        [channel setLock:NO];
        [channel setMuteAll:NO];
        
        NSArray *conferenceState = [iq objectForKey:@"conferenceState"];
        if (conferenceState && conferenceState.count > 0) {
            for (NSString *state in conferenceState) {
                if ([state isEqualToString:@"lock"]) {
                    [channel setLock:YES];
                } else if ([state isEqualToString:@"muteAll"]) {
                    [channel setMuteAll:YES];
                }
            }
        }
    }
    
    if ([operationType isEqualToString:@"editTopic"]) {
        [channel setTopic:topic];
    }
    
    if (![operationType isEqualToString:@"end"]) {
        [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeeting:channel];
    }
    
    if ([operationType isEqualToString:@"roleConversion"]) {
        if (!operhand || operhand.count == 0) {
            return;
        }
        
        YYNetMeetingMember *oldModerator = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
        YYNetMeetingMember *newModerator = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:[operhand objectAtIndex:0]];
        
        oldModerator.memberRole = @"participans";
        newModerator.memberRole = @"moderator";
        
        [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:oldModerator channelId:channelId];
        [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:newModerator channelId:channelId];
        
        if ([self.currentChannelId isEqualToString:channelId]) {
            [[self activeDelegate] didNetMeetingModeratorChange:oldModerator.memberId to:newModerator.memberId];
        }
    }
    
    if ([operationType isEqualToString:@"muteAll"] || [operationType isEqualToString:@"cancelMuteAll"]) {
        NSArray *memberArray = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMembersWithChannelId:channelId];
        
        if (memberArray && memberArray.count > 0) {
            for (YYNetMeetingMember *member in memberArray) {
                if ([operationType isEqualToString:@"muteAll"]) {
                    member.forbidAudio = YES;
                } else {
                    member.forbidAudio = NO;
                }
                
                [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
                
                if (member.forbidAudio) {
                    [[self activeDelegate] didNetMeetingDisableSpeak:member.memberId];
                } else {
                    [[self activeDelegate] didNetMeetingEnableSpeak:member.memberId];
                }
            }
        }
        
        if ([operationType isEqualToString:@"muteAll"]) {
            [[self activeDelegate] didNetMeetingAllDisableSpeak];
        } else {
            [[self activeDelegate] didNetMeetingAllEnableSpeak];
        }
    }
    
    //因为在进入房间之前也需要end回调，所以不做是否是当前会议的控制。
    if ([operationType isEqualToString:@"end"]) {
        if ([self.inviteChannelId isEqualToString:channelId]) {
            [self cancelChannelInviteNotification];
            self.inviteChannelId = nil;
            [[self activeDelegate] didNetMeetingEndChannel:channelId];
        } else if (![self.currentChannelId isEqualToString:channelId]) {
            [[self activeDelegate] didNetMeetingEndChannel:channelId];
        }
    }
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    if ([operationType isEqualToString:@"end"]) {
        if (![operator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            //不是自己结束的会议，需要自己自动退出会议
            [self autoLeaveChannel];
        }
        
        [[self activeDelegate] didNetMeetingEndChannel:channelId];
    } else if ([operationType isEqualToString:@"lock"]) {
        [[self activeDelegate] didLockNetMeeting];
    } else if ([operationType isEqualToString:@"unlock"]) {
        [[self activeDelegate] didUnLockNetMeeting];
    } else if ([operationType isEqualToString:@"editTopic"]) {
        [[self activeDelegate] didNetMeetingEditTopic:topic channelId:channelId];
    }
}

#pragma mark -
#pragma mark operate method

- (void)didOperatorTypeStartReservation:(NSString *)channelId creator:(NSString *)creator misMatchMembers:(NSArray *)misMatchMembers operhand:(NSArray *)operhand packetId:(NSString *)packetId {
    // 自己开始的预约会议
    if ([creator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        if (self.currentChannelId) {
            YYIMLogDebug(@"无法开始预约会议，因为当前正在会议中：%@", self.currentChannelId);
            return;
        }
        
        self.currentChannelId = channelId;
        
        if (misMatchMembers.count > 0) {
            [[self activeDelegate] didNetMeetingInviteMisMatchMember:channelId userArray:misMatchMembers];
        }
        
        [[self activeDelegate] didStartReservationNetMeetingWithSeriId:packetId channelId:channelId];
    } else {// 别人创建的会议
        if (![operhand containsObject:[[YYIMConfig sharedInstance] getUser]]) {
            return;
        }
        
        if (self.currentChannelId) {
            YYIMLogDebug(@"无法加入会议，因为当前正在会议中：%@", self.currentChannelId);
            // 发送busy报文
            [self busyNow:channelId];
            return;
        }
        
        if ([self isBusy]) {
            [self busyNow:channelId];
            return;
        }
        
        self.inviteChannelId = channelId;
        self.treatInvite = NO;
        [[self activeDelegate] didNetMeetingInvited:channelId userArray:operhand];
        [self localNotifyChannel:channelId];
    }
}

- (void)didOperatorTypeCreate:(NSString *)channelId creator:(NSString *)creator misMatchMembers:(NSArray *)misMatchMembers operhand:(NSArray *)operhand packetId:(NSString *)packetId {
    // 自己创建的会议
    if ([creator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        if (self.currentChannelId) {
            YYIMLogDebug(@"无法创建会议，因为当前正在会议中：%@", self.currentChannelId);
            return;
        }
        
        self.currentChannelId = channelId;
        
        if (misMatchMembers.count > 0) {
            [[self activeDelegate] didNetMeetingInviteMisMatchMember:channelId userArray:misMatchMembers];
        }
        
        [[self activeDelegate] didNetMeetingCreate:packetId channelId:channelId];
    } else {// 别人创建的会议
        if (![operhand containsObject:[[YYIMConfig sharedInstance] getUser]]) {
            return;
        }
        
        if (self.currentChannelId) {
            YYIMLogDebug(@"无法加入会议，因为当前正在会议中：%@", self.currentChannelId);
            return;
        }
        
        if ([self isBusy]) {
            [self busyNow:channelId];
            return;
        }
        
        self.inviteChannelId = channelId;
        self.treatInvite = NO;
        [[self activeDelegate] didNetMeetingInvited:channelId userArray:operhand];
        [self localNotifyChannel:channelId];
    }
}

- (void)didOperatorTypeInvite:(NSString *)channelId operator:(NSString *)operator misMatchMembers:(NSArray *)misMatchMembers operhand:(NSArray *)operhand {
    if ([operhand containsObject:[[YYIMConfig sharedInstance] getUser]]) {
        if (self.currentChannelId) {
            YYIMLogDebug(@"无法响应会议邀请，因为当前正在会议中：%@", self.currentChannelId);
            return;
        }
        
        if ([self isBusy]) {
            [self busyNow:channelId];
            return;
        }
        
        self.inviteChannelId = channelId;
        self.treatInvite = NO;
        [[self activeDelegate] didNetMeetingInvited:channelId userArray:operhand];
        [self localNotifyChannel:channelId];
    } else if ([self.currentChannelId isEqualToString:channelId] && operhand.count > 0) {
        // 如果被邀请者没有自己并且在频道中，则提示别人被邀请
        [[self activeDelegate] didNetMeetingInvited:channelId userArray:operhand];
    }
    
    if ([operator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        //如果自己发送需要检查是否有没有通信权限的用户
        if (misMatchMembers.count > 0) {
            [[self activeDelegate] didNetMeetingInviteMisMatchMember:channelId userArray:misMatchMembers];
        }
    }
}

- (void)didOperatorTypeJoin:(NSString *)channelId operator:(NSString *)operator {
    // 如果是自己加入的，进入房间。如果是别人加入并且是当前频道的，提示人员有更新
    if ([operator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        if (self.currentChannelId) {
            YYIMLogDebug(@"无法加入会议，因为当前正在会议中：%@", self.currentChannelId);
            return;
        }
        
        self.currentChannelId = channelId;
        [[self activeDelegate] didNetMeetingJoin:channelId];
    } else if ([self.currentChannelId isEqualToString:channelId]) {
        [[self activeDelegate] didNetMeetingMemberEnter:operator];
    }
}

- (void)didOperatorTypeAgree:(NSString *)channelId operator:(NSString *)operator netMeetingType:(YYIMNetMeetingType)netMeetingType {
    // 如果是自己同意的并且不在频道中，进入房间。如果是别人同意并且是当前频道的，提示人员有更新
    if ([operator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        if (self.currentChannelId) {
            YYIMLogDebug(@"无法同意会议邀请，因为当前正在会议中：%@", self.currentChannelId);
            return;
        }
        
        self.currentChannelId = channelId;
        [[self activeDelegate] didNetMeetingAgree:channelId netMeetingType:netMeetingType];
    } else if ([self.currentChannelId isEqualToString:channelId]) {
        [[self activeDelegate] didNetMeetingMemberEnter:operator];
    }
}

- (void)didOperatorTypeRefuse:(NSString *)channelId operator:(NSString *)operator {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
    
    if (!member) {
        return;
    }
    
    [member setInviteState:kYYIMNetMeetingInviteStateRefuse];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    [[self activeDelegate] didNetMeetingMemberRefuse:operator];
    
    YYNetMeeting *channel = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingWithChannelId:channelId];
    
    if (channel.netMeetingType == kYYIMNetMeetingTypeSingleChat) {
        [self autoLeaveChannel];
    }
}

- (void)didOperatorTypeTimeOut:(NSString *)channelId operator:(NSString *)operator {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
    
    if (!member) {
        return;
    }
    
    [member setInviteState:kYYIMNetMeetingInviteStateTimeout];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    [self invitedExpired:channelId userId:operator];
    
    [[self activeDelegate] didNetMeetingInviteTimeout:channelId userId:operator];
    
    YYNetMeeting *channel = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingWithChannelId:channelId];
    
    if ([self.currentChannelId isEqualToString:channelId] && channel.netMeetingType == kYYIMNetMeetingTypeSingleChat) {
        [self autoLeaveChannel];
    }
}

- (void)didOperatorTypeBusy:(NSString *)channelId operator:(NSString *)operator {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
    
    if (!member) {
        return;
    }
    
    [member setInviteState:kYYIMNetMeetingInviteStateBusy];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    if (![operator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        [[self activeDelegate] didNetMeetingMemberBusy:operator];
    }
    
    YYNetMeeting *channel = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingWithChannelId:channelId];
    
    if (channel.netMeetingType == kYYIMNetMeetingTypeSingleChat) {
        [self autoLeaveChannel];
    }
}

- (void)didOperatorTypeMute:(NSString *)channelId operhand:(NSString *)operhand {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operhand];
    
    if (!member) {
        return;
    }
    
    [member setForbidAudio:YES];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    [[self activeDelegate] didNetMeetingDisableSpeak:operhand];
}

- (void)didOperatorTypeCancelMute:(NSString *)channelId operhand:(NSString *)operhand {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operhand];
    
    if (!member) {
        return;
    }
    
    [member setForbidAudio:NO];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    [[self activeDelegate] didNetMeetingEnableSpeak:operhand];
}

- (void)didOperatorTypeHand {
    
}

- (void)didOperatorTypeOpenVideo:(NSString *)channelId operator:(NSString *)operator {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
    
    if (!member) {
        return;
    }
    
    [member setEnableVideo:YES];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    
    [[self activeDelegate] didNetMeetingMembersEnableVideo:YES userId:operator];
}

- (void)didOperatorTypeCloseVideo:(NSString *)channelId operator:(NSString *)operator {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
    
    if (!member) {
        return;
    }
    
    [member setEnableVideo:NO];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    [[self activeDelegate] didNetMeetingMembersEnableVideo:NO userId:operator];
}

- (void)didOperatorTypeOpenMicrophone:(NSString *)channelId operator:(NSString *)operator {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
    
    if (!member) {
        return;
    }
    
    [member setEnableAudio:YES];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    [[self activeDelegate] didNetMeetingMembersEnableAudio:YES userId:operator];
}

- (void)didOperatorTypeCloseMicrophone:(NSString *)channelId operator:(NSString *)operator {
    YYNetMeetingMember *member = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:operator];
    
    if (!member) {
        return;
    }
    
    [member setEnableAudio:NO];
    [[YYIMNetMeetingDBHelper sharedInstance] updateNetMeetingMember:member channelId:channelId];
    
    
    if (![self.currentChannelId isEqualToString:channelId]) {
        return;
    }
    
    [[self activeDelegate] didNetMeetingMembersEnableAudio:NO userId:operator];
}


#pragma mark -
#pragma mark private method

- (void)sendTimingBillStatus:(id)sender {
    [self sendBillStatus:YYIMNetMeetingBillStatusPay channelId:self.currentChannelId];
}

/**
 *  通过声网uid获取对应的member
 *
 *  @param uid 声网uid
 *
 *  @return IM的userId
 */
- (YYNetMeetingMember *)getChannelMemberByAgoraUid:(NSUInteger)uid channelId:(NSString *)channelId {
    if (!channelId) {
        YYIMLogError(@"没有channelId");
        return nil;
    }
    
    NSArray *channelMemberArray = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMembersWithChannelId:channelId];
    
    for (YYNetMeetingMember *member in channelMemberArray) {
        if ([member memberUid] == uid) {
            return member;
        }
    }
    
    return nil;
}

- (void)autoLeaveChannel {
    [self sendBillStatus:YYIMNetMeetingBillStatusEnd channelId:self.currentChannelId];
    self.currentChannelId = nil;
    
    [self.agoraKit leaveChannel:^(AgoraRtcStats *stat) {
        
        // 停止定时器timer
        if (self.timer && self.timer.isValid){
            [self.timer invalidate];
        }
    }];
}

/**
 *  通过IM的userId获取member
 *
 *  @param userId IM的userId
 *
 *  @return uid 声网uid
 */
- (YYNetMeetingMember *)getChannelMemberByUserId:(NSString *)userId channelId:(NSString *)channelId {
    if (!channelId) {
        YYIMLogError(@"没有channelId");
        return nil;
    }
    
    NSArray *channelMemberArray = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMembersWithChannelId:channelId];
    
    for (YYNetMeetingMember *member in channelMemberArray) {
        if ([member.memberId isEqualToString:userId]) {
            return member;
        }
    }
    
    return nil;
}

- (NSArray *)memberChange {
    if (!_memberChange) {
        NSMutableArray *array = [NSMutableArray array];
        
        [array addObject:@"init"];
        [array addObject:@"create"];
        [array addObject:@"invite"];
        [array addObject:@"offline"];
        [array addObject:@"join"];
        [array addObject:@"exit"];
        [array addObject:@"kick"];
        [array addObject:@"agree"];
        
        _memberChange = [NSArray arrayWithArray:array];
    }
    
    return _memberChange;
}

- (NSArray *)memberStatusChange {
    if (!_memberStatusChange) {
        NSMutableArray *array = [NSMutableArray array];
        
        [array addObject:@"hand"];
        [array addObject:@"mute"];
        [array addObject:@"cancelMute"];
        [array addObject:@"openVideo"];
        [array addObject:@"closeVideo"];
        [array addObject:@"openMicrophone"];
        [array addObject:@"closeMicrophone"];
        [array addObject:@"timeout"];
        [array addObject:@"busy"];
        [array addObject:@"refuse"];
        
        _memberStatusChange = [NSArray arrayWithArray:array];
    }
    
    return _memberStatusChange;
}

- (NSArray *)netMeetingStatusChange {
    if (!_netMeetingStatusChange) {
        NSMutableArray *array = [NSMutableArray array];
        
        [array addObject:@"roleConversion"];
        [array addObject:@"muteAll"];
        [array addObject:@"cancelMuteAll"];
        [array addObject:@"end"];
        [array addObject:@"lock"];
        [array addObject:@"unlock"];
        [array addObject:@"editTopic"];
        
        _netMeetingStatusChange = [NSArray arrayWithArray:array];
    }
    
    return _netMeetingStatusChange;
}

/**
 *  超时报文的逻辑处理
 *
 *  @param channelId 频道id
 *  @param userId    用户id
 */
- (void)invitedExpired:(NSString *)channelId userId:(NSString *)userId {
    if ([self.inviteChannelId isEqualToString:channelId] && [userId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        //如果是自己正在被邀请的时候超时了，有本地通知的需要清除本地通知
        [self cancelChannelInviteNotification];
        self.inviteChannelId = nil;
    }
    
    [[self activeDelegate] didNetMeetingInviteTimeout:channelId userId:userId];
}

#pragma mark -
#pragma mark local notify

/**
 *  收到进入房间的邀请
 *
 *  @param channelId 频道id
 */
- (void)localNotifyChannel:(NSString *)channelId {
    //优先级比较高不做是否开启消息提示的判断，而且会议邀请同一时间段内只可能有一条，就不做时间间隔的判断了。
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    
    if (!isAppActivity) {
        YYSettings *settings = [[YYIMConfig sharedInstance] getSettings];
        
        if ([settings newMsgRemind]) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
            
            if (!self.lastPlaySoundDate || timeInterval > kDefaultPlaySoundInterval) {
                if ([settings playSound]) {
                    [self playSound];
                }
                
                if ([settings playVibrate]) {
                    [self playVibrate];
                }
                // 保存最后一次响铃时间
                self.lastPlaySoundDate = [NSDate date];
            }
        }
        
        // 发送本地推送
        self.notification = [[UILocalNotification alloc] init];
        // 触发通知的时间
        self.notification.fireDate = [NSDate date];
        self.notification.soundName = @"netmeeting.wav";
        self.notification.alertAction = @"打开邀请页面";
        self.notification.timeZone = [NSTimeZone defaultTimeZone];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        [dic setObject:@"netmeeting" forKey:@"yyim_notification_type"];
        [dic setObject:channelId forKey:@"yyim_channelid"];
        
        self.notification.userInfo = dic;
        
        YYNetMeeting *channel = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:channelId];
        
        if (!channel) {
            return;
        }
        
        NSString *inviterId = channel.inviterId;
        YYNetMeetingMember *inviter = [[YYIMNetMeetingDBHelper sharedInstance] getNetMeetingMemberWithChannelId:channelId memberId:inviterId];
        NSString *notificationBody;
        
        if (channel.netMeetingType == kYYIMNetMeetingTypeSingleChat) {
            switch (channel.netMeetingMode) {
                case kYYIMNetMeetingModeAudio:{
                    notificationBody = [NSString stringWithFormat:@"%@邀请您进行语音聊天", inviter.memberName];
                    break;
                }
                case kYYIMNetMeetingModeVideo:{
                    notificationBody = [NSString stringWithFormat:@"%@邀请您进行视频聊天", inviter.memberName];
                    break;
                }
                default:
                    notificationBody = [NSString stringWithFormat:@"%@邀请您进行视频聊天", inviter.memberName];
                    break;
            }
        } else if (channel.netMeetingType == kYYIMNetMeetingTypeGroupChat) {
            notificationBody = [NSString stringWithFormat:@"%@邀请您进行视频聊天", inviter.memberName];
        }
        else {
            notificationBody = [NSString stringWithFormat:@"%@邀请您进行视频会议", inviter.memberName];
        }
        
        self.notification.alertBody = notificationBody;
        // 发送通知
        [[UIApplication sharedApplication] scheduleLocalNotification:self.notification];
    }
}

- (void)cancelChannelInviteNotification {
    if (self.notification) {
        [[UIApplication sharedApplication] cancelLocalNotification:self.notification];
        self.notification = nil;
    }
}

#pragma mark -
#pragma mark telephone

- (BOOL)isBusy {
    // 邀请相应中
    if (self.inviteChannelId) {
        YYIMLogDebug(@"当前正在忙：%@", self.inviteChannelId);

        return YES;
    }
    
    return NO;
}

@end
