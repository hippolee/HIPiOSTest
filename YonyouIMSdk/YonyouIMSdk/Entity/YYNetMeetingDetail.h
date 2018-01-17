//
//  YYNetMeetingDetail.h
//  YonyouIM
//
//  Created by yanghaoc on 16/4/21.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYNetMeeting.h"
#import "YYNetMeetingDefine.h"

@interface YYNetMeetingDetail : YYNetMeeting

/**
 *  会议结束时间
 */
@property NSTimeInterval endTime;

/**
 *  会议结束时间
 */
@property NSTimeInterval planBeginTime;

/**
 *  会议结束时间
 */
@property NSTimeInterval planEndTime;

/**
 *  会议议程
 */
@property NSString* agenda;

/**
 *  会议详情状态
 */
@property YYIMNetMeetingState state;


@end
