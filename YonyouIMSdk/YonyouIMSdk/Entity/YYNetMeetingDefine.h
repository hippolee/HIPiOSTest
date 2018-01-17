//
//  YYNetMeetingDefine.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/4/26.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#ifndef YonyouIM_YYIMNetMeetingDefs_h
#define YonyouIM_YYIMNetMeetingDefs_h

typedef NS_ENUM(NSInteger, YYIMNetMeetingState) {
    kYYIMNetMeetingStateNew = 0,              // 预约会议
    kYYIMNetMeetingStateIng,                  // 会议进行中
    kYYIMNetMeetingStateEnd,                  // 会议已结束
    kYYIMNetMeetingStateCancelReservation,    // 取消预约
    kYYIMNetMeetingStateReservationInvite,    // 预约邀请
    kYYIMNetMeetingStateReservationKick,      // 预约踢人
    kYYIMNetMeetingStateReservationEdit,      // 预约编辑
    kYYIMNetMeetingStateReservationReady      // 预约准备
};

typedef NS_ENUM(NSInteger, YYIMNetMeetingReservationInvalidReason) {
    YYIMNetMeetingReservationInvalidReasonNONE     = 0,              // 未失效
    YYIMNetMeetingReservationInvalidReasonCancel   = 1,              // 预约会议取消
    YYIMNetMeetingReservationInvalidReasonKick     = 2,              // 预约会议将你移除
    YYIMNetMeetingReservationInvalidReasonBegin    = 3               // 已经开始
};

#endif