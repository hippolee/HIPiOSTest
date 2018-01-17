//
//  YYNetMeetingMember.h
//  YonyouIMSdk
//
//  Created by yanghaoc on 16/1/27.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYUser.h"
#import "YYNetMeeting.h"

@interface YYNetMeetingMember : NSObject

/**
 *  频道Id
 */
@property (nonatomic) NSString *channelId;

/**
 *  频道成员的IM的Id
 */
@property (nonatomic) NSString *memberId;

/**
 *  频道成员的视频会议的Id
 */
@property (nonatomic) NSUInteger memberUid;

/**
 *  频道成员名称
 */
@property (nonatomic) NSString *memberName;

/**
 *  频道成员角色
 */
@property (nonatomic) NSString *memberRole;

/**
 *  频道成员用户对象
 */
@property (retain, nonatomic) YYUser *user;

/**
 *  是否开启视频
 */
@property BOOL enableVideo;

/**
 *  是否开启语音
 */
@property BOOL enableAudio;

/**
 *  是否被禁言
 */
@property BOOL forbidAudio;

/**
 *  获取头像
 *
 *  @return 头像地址
 */
- (NSString *)getMemberPhoto;

/**
 *  是否是主持人
 *
 *  @return 
 */
- (BOOL)isModerator;

/**
 *  用户的邀请状态
 */
@property YYIMNetMeetingInviteState inviteState;

@property NSString *firstLetter;

- (NSString *)getFirstLetter;

@end
