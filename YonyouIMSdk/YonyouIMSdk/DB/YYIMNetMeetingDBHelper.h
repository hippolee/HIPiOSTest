//
//  YYIMNetMeetingDBHelper.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/27.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseDBHelper.h"
#import "YYNetMeeting.h"
#import "YYNetMeetingMember.h"
#import "YYNetMeetingInfo.h"

@interface YYIMNetMeetingDBHelper : YYIMBaseDBHelper

+ (instancetype) sharedInstance;

/**
 *  更新频道信息，没有则创建
 *
 *  @param channel 频道
 */
- (void)updateNetMeeting:(YYNetMeeting *)netMeeting;

/**
 *  获得指定的频道
 *
 *  @param channelId 频道id
 *
 *  @return 频道对象
 */
- (YYNetMeeting *)getNetMeetingWithChannelId:(NSString *)channelId;

/**
 *  批量更新频道的成员
 *
 *  @param channel     频道id
 *  @param memberArray 成员集合
 */
- (void)batchUpdateNetMeetingMember:(NSString *)channel members:(NSArray *)memberArray;

/**
 *  获得频道下的所有成员
 *
 *  @param channelId 频道id
 *
 *  @return 成员集合
 */
- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId;

/**
 *  获得频道下的指定数量的成员
 *
 *  @param channelId 频道id
 *  @param limit     数量限制
 *
 *  @return 成员集合
 */
- (NSArray *)getNetMeetingMembersWithChannelId:(NSString *)channelId limit:(NSInteger)limit;

/**
 *  获取频道下的指定成员
 *
 *  @param channelId 频道id
 *  @param memberId  成员id
 *
 *  @return 成员
 */
- (YYNetMeetingMember *)getNetMeetingMemberWithChannelId:(NSString *)channelId memberId:(NSString *)memberId;

/**
 *  更新指定的成员状态
 *
 *  @param member    成员
 *  @param channelId 频道id
 */
- (void)updateNetMeetingMember:(YYNetMeetingMember *)member channelId:(NSString *)channelId;

/**
 * 根据会议的id获取会议通知
 *
 *  @return
 */
- (NSArray *)getNetMeetingNoticeWithMeetingId:(NSString *)channelId;

/**
 * 根据会议的id和通知类型获取会议通知
 *
 *  @return
 */
- (NSArray *)getNetMeetingNoticeWithMeetingId:(NSString *)channelId state:(YYIMNetMeetingState)state;

/**
 *  分页获取网络会议通知
 *
 *  @param offset 偏移量
 *  @param limit  数量
 *
 *  @return
 */
- (NSArray *)getNetMeetingNoticeWithOffset:(NSInteger)offset limit:(NSInteger)limit;

/**
*  更新通知
*
*  @param netMeetingInfo 通知对象
*/
- (void)updateOrInsertNetMeetingCommonNotice:(YYNetMeetingInfo *)netMeetingInfo;

/**
 *  插入预约会议的信息
 *
 *  @param netMeetingInfo 预约会议信息
 */
- (void)insertNetMeetingReservationNotice:(YYNetMeetingInfo *)netMeetingInfo;

/**
 *  使预约会议无效
 *
 *  @param channelId 会议id
 */
- (void)updateNetMeetingReservationNotice:(NSString *)channelId wait:(BOOL)wait reason:(YYIMNetMeetingReservationInvalidReason)reason;

/**
 *  清空会议通知
 */
- (void)cleanNetMeetingNotice;

/**
 *  通过会议id获取日历事件的id
 *
 *  @param channelId 会议id
 *
 *  @return 事件id
 */
- (NSString *)getNetMeetingCalendarIdByChannelId:(NSString *)channelId;

/**
 *  设置会议和日历事件的映射
 *
 *  @param channelId  会议id
 *  @param calendarId 日历事件id
 */
- (void)addNetMeetingCalendar:(NSString *)channelId calendarId:(NSString *)calendarId;

/**
 *  更新会议和日历事件的映射
 *
 *  @param channelId  会议id
 *  @param calendarId 日历事件id
 */
- (void)updateNetMeetingCalendar:(NSString *)channelId calendarId:(NSString *)calendarId;

/**
 *  删除会议和日历事件的映射
 *
 *  @param channelId 会议id
 */
- (void)removeNetMeetingCalendar:(NSString *)channelId;

@end
