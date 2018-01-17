//
//  NetMeetingDispatch.h
//  YonyouIM
//
//  Created by yanghaoc on 16/4/8.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

@protocol NetMeetingDispatchDelegate;

@interface NetMeetingDispatch : NSObject

//更新会话时间的定时器
@property (strong, nonatomic) NSTimer *durationTimer;

// delegate
@property (nonatomic, weak) id<NetMeetingDispatchDelegate> delegate;

+ (instancetype)sharedInstance;

- (void)showNetMeetingInviteConfirmView:(NSString *) channelId;

- (void)createNetMeetingWithNetMeetingType:(YYIMNetMeetingType)netMeetingType netMeetingMode:(YYIMNetMeetingMode)netMeetingMode invitees:(NSArray *)invitees topic:(NSString *)topic;

- (void)startReservationNetMeeting:(NSString *)channelId;

/**
 *  需要显示提示，会自动判断显示在哪个window上
 *
 *  @param hint 提示信息
 *  @param from 申请的视图
 */
- (void)showHint:(NSString *)hint from:(UIViewController *)from;

/**
 *  需要关闭
 */
- (void)didNetMeetingDispatchNeedClose;

/**
 *  需要缩小
 */
- (void)didNetMeetingDispatchNeedMinimize;

/**
 *  显示对应的用户界面
 *
 *  @param userId    用户id
 *  @param channelId 会议id
 */
- (void)showWindowDetail:(NSString *)userId channelId:(NSString *)channelId;

@end

@protocol NetMeetingDispatchDelegate <NSObject>

@optional

- (void)didNetMeetingTimerChange;

@end
