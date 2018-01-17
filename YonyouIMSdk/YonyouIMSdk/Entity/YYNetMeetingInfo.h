//
//  YYNetMeetingInfo.h
//  YonyouIMSdk
//
//  Created by litfb on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYNetMeeting.h"
#import "YYUser.h"
#import "YYNetMeetingDefine.h"

@interface YYNetMeetingInfo : NSObject

/**
 *  云会议频道ID
 */
@property (strong, nonatomic) NSString *channelId;

/**
 *  云会议主题
 */
@property (strong, nonatomic) NSString *topic;

/**
 *  云会议状态
 */
@property (assign, nonatomic) YYIMNetMeetingState state;

/**
 *  云会议类型
 */
@property (assign, nonatomic) YYIMNetMeetingType type;

/**
 *  云会议时间
 */
@property (assign, nonatomic) NSTimeInterval date;

/**
 *  云会议通知时间
 */
@property (assign, nonatomic) NSTimeInterval notifyDate;

/**
 *  云会议主持人
 */
@property (strong, nonatomic) NSString *moderator;

/**
 *  云会议创建人
 */
@property (strong, nonatomic) NSString *creator;

/**
 *  云会议时长(S)
 */
@property (assign, nonatomic) NSInteger duration;

/**
 *  云会议主持人名字
 */
@property (nonatomic) NSString *moderatorName;

/**
 *  云会议主持人用户
 */
@property (strong, nonatomic) YYUser *moderatorUser;

/**
 *  云会议是否等待开始
 */
@property (assign, nonatomic) BOOL waitBegin;

/**
 *  云预约会议是否已经与本人无关（取消了或者自己被移除了）
 */
@property (assign, nonatomic) YYIMNetMeetingReservationInvalidReason reservationInvalidReason;

@property (assign, nonatomic) BOOL isReservationNotice;

@end
