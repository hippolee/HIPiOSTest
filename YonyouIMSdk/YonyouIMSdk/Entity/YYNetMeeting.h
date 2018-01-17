//
//  YYNetMeeting.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/27.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMDefs.h"


#define YM_NETMETTING_BOTTOM_HEIGHT   160
#define YM_NETMETTING_VIEW_WIDTH      60
#define YM_NETMETTING_VIEW_HEIGHT     80
#define YM_NETMETTING_IMAGE_SIZE      60
#define YM_NETMETTING_VIEW_MARGIN     20
#define YM_NETMETTING_HANGUP_SIZE     50

typedef NS_ENUM(NSUInteger, YYIMNetMeetingProfile) {
    kYYIMNetMeetingProfileFree         = 0,  //自由模式，大家都可以发送和接收音视频
    kYYIMNetMeetingProfileBroadcaster  = 1,  //主持模式，自己可以发送音视频，不能接收
    kYYIMNetMeetingProfileAudience     = 2,  //观众模式，自己不可以发送音视频，可以接受
};

typedef NS_ENUM(NSUInteger, YYIMNetMeetingQuality) {
    kYYIMNetMeetingQualityUnknown = 0,  //未知
    kYYIMNetMeetingQualityExcellent = 1,  //非常好
    kYYIMNetMeetingQualityGood = 2,  //好
    kYYIMNetMeetingQualityPoor = 3,  //一般
    kYYIMNetMeetingQualityBad = 4,  //不好
    kYYIMNetMeetingQualityVBad = 5,  //非常不好
    kYYIMNetMeetingQualityDown = 6,  //中断
};

typedef NS_ENUM(NSInteger, YYIMNetMeetingType) {
    kYYIMNetMeetingTypeMeeting,        //会议模式
    kYYIMNetMeetingTypeLive,           //直播模式
    kYYIMNetMeetingTypeSingleChat,     //单聊模式
    kYYIMNetMeetingTypeGroupChat       //群聊模式
};

typedef NS_ENUM(NSInteger, YYIMNetMeetingMode) {
    kYYIMNetMeetingModeVideo,
    kYYIMNetMeetingModeAudio,
    kYYIMNetMeetingModeDefault = kYYIMNetMeetingModeVideo
};

typedef NS_ENUM(NSInteger, YYIMNetMeetingContentType) {
    kYYIMNetMeetingContentTypeCreate,     //创建状态
    kYYIMNetMeetingContentTypeEnd,        //结束状态
    kYYIMNetMeetingContentTypeCancel,     //取消状态
    kYYIMNetMeetingContentTypeRefuse,      //拒绝状态
    kYYIMNetMeetingContentTypeTimeout,     //超时状态
    kYYIMNetMeetingContentTypeBusy        //忙状态
};

typedef NS_ENUM(NSInteger, YYIMNetMeetingMessageType) {
    kYYIMNetMeetingMessageTypeConferenceNotify       = 1, //会议或者是直播的通知
    kYYIMNetMeetingMessageTypeSingelChatNotify       = 2, //单聊的通知
    kYYIMNetMeetingMessageTypeConferenceShare        = 3 //会议或者是直播的分享
};

typedef NS_ENUM(NSInteger, YYIMNetMeetingInviteState) {
    kYYIMNetMeetingInviteStateInit,      //用于会议的预约
    kYYIMNetMeetingInviteStateInviting,  //成员被邀请，还未加入会议
    kYYIMNetMeetingInviteStateJoined,    //已在会议中
    kYYIMNetMeetingInviteStateTimeout,   //规定时间内，未同意加入会议
    kYYIMNetMeetingInviteStateBusy,      //当前成员在接电话，忙状态
    kYYIMNetMeetingInviteStateRefuse,    //拒绝
    kYYIMNetMeetingInviteStateExit       //成员退出，退出状态
};

typedef NS_ENUM(NSUInteger, YYIMNetMeetingLogFilter) {
    kYYIMNetMeetingLogFilterDebug,
    kYYIMNetMeetingLogFilterInfo,
    kYYIMNetMeetingLogFilterWarn,
    kYYIMNetMeetingLogFilterError,
    kYYIMNetMeetingLogFilterCritical
};

typedef NS_ENUM(NSInteger, YYIMNetMeetingVideoProfile) {
                                           // width x height fps  kbps
    kYYIMNetMeetingVideoProfileInvalid = -1,
    kYYIMNetMeetingVideoProfile120P    = 0,      // 160x120   15   80
    kYYIMNetMeetingVideoProfile120P_2  = 1,		// 120x160   15   80
    kYYIMNetMeetingVideoProfile120P_3  = 2,		// 120x120   15   60
    kYYIMNetMeetingVideoProfile180P    = 10,		// 320x180   15   160
    kYYIMNetMeetingVideoProfile180P_2  = 11,		// 180x320   15   160
    kYYIMNetMeetingVideoProfile180P_3  = 12,		// 180x180   15   120
    kYYIMNetMeetingVideoProfile240P    = 20,		// 320x240   15   200
    kYYIMNetMeetingVideoProfile240P_2  = 21,		// 240x320   15   200
    kYYIMNetMeetingVideoProfile240P_3  = 22,		// 240x240   15   160
    kYYIMNetMeetingVideoProfile360P    = 30,		// 640x360   15   400
    kYYIMNetMeetingVideoProfile360P_2  = 31,		// 360x640   15   400
    kYYIMNetMeetingVideoProfile360P_3  = 32,		// 360x360   15   300
    kYYIMNetMeetingVideoProfile360P_4  = 33,		// 640x360   30   680
    kYYIMNetMeetingVideoProfile360P_5  = 34,		// 360x640   30   680
    kYYIMNetMeetingVideoProfile360P_6  = 35,		// 360x360   30   500
    kYYIMNetMeetingVideoProfile480P    = 40,		// 640x480   15   500
    kYYIMNetMeetingVideoProfile480P_2  = 41,		// 480x640   15   500
    kYYIMNetMeetingVideoProfile480P_3  = 42,		// 480x480   15   400
    kYYIMNetMeetingVideoProfile480P_4  = 43,		// 640x480   30   750
    kYYIMNetMeetingVideoProfile480P_5  = 44,		// 480x640   30   750
    kYYIMNetMeetingVideoProfile480P_6  = 45,		// 480x480   30   680
    kYYIMNetMeetingVideoProfile720P    = 50,		// 1280x720  15   1000
    kYYIMNetMeetingVideoProfile720P_2  = 51,		// 720x1280  15   1000
    kYYIMNetMeetingVideoProfile720P_3  = 52,		// 1280x720  30   1700
    kYYIMNetMeetingVideoProfile720P_4  = 53,		// 720x1280  30   1700
    kYYIMNetMeetingVideoProfile1080P   = 60,		// 1920x1080 15   1500
    kYYIMNetMeetingVideoProfile1080P_2 = 61,		// 1080x1920 15   1500
    kYYIMNetMeetingVideoProfile1080P_3 = 62,		// 1920x1080 30   2550
    kYYIMNetMeetingVideoProfile1080P_4 = 63,		// 1080x1920 30   2550
    kYYIMNetMeetingVideoProfile1080P_5 = 64,		// 1920x1080 60   4300
    kYYIMNetMeetingVideoProfile1080P_6 = 65,		// 1080x1920 60   4300
    kYYIMNetMeetingVideoProfile4K      = 70,		// 3840x2160 30   8000
    kYYIMNetMeetingVideoProfile4K_2    = 71,		// 2160x3080 30   8000
    kYYIMNetMeetingVideoProfile4K_3    = 72,		// 3840x2160 60   13600
    kYYIMNetMeetingVideoProfile4K_4    = 73,		// 2160x3840 60   13600
    kYYIMNetMeetingVideoProfileDEFAULT = kYYIMNetMeetingVideoProfile360P_5,
};

@interface YYNetMeeting : NSObject

/**
 *  频道Id
 */
@property (nonatomic) NSString *channelId;

/**
 *  主题
 */
@property (nonatomic) NSString *topic;

/**
 *  邀请发起者id
 */
@property (nonatomic) NSString *inviterId;

/**
 *  会议模式：会议、直播
 */
@property YYIMNetMeetingType netMeetingType;

/**
 *  会议方式：视频、语音
 */
@property YYIMNetMeetingMode netMeetingMode;

/**
 *  房间上锁
 */
@property BOOL lock;

/**
 *  房间禁言
 */
@property BOOL muteAll;

/**
 *  会议的动态key
 */
@property (nonatomic) NSString *dynamicKey;

/**
 *  会议创建时间
 */
@property NSTimeInterval createTime;

/**
 *  会议创建者
 */
@property NSString* creator;


@end
