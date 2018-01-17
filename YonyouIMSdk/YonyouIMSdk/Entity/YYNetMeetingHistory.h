//
//  YYNetMeetingRecord.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/4/26.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYNetMeetingDefine.h"
#import "YYNetMeeting.h"
#import "YYUser.h"

@interface YYNetMeetingHistory : NSObject

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
 *  云会议主持人名字
 */
@property (nonatomic) NSString *moderatorName;

/**
 *  云会议主持人用户
 */
@property (strong, nonatomic) YYUser *moderatorUser;


@end
