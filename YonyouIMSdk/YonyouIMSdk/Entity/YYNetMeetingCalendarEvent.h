//
//  YYCalendarEvent.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/5/24.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YYNetMeetingCalendarEvent : NSObject

//会议id
@property (strong, nonatomic) NSString *netMeetingId;
//会议标题
@property (strong, nonatomic) NSString *title;
//会议开始时间
@property (strong, nonatomic) NSDate *startTime;
//会议结束时间
@property (strong, nonatomic) NSDate *endTime;

@end
