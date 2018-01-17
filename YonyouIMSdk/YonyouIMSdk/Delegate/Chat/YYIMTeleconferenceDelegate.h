//
//  YYIMTeleconferenceDelegate.h
//  YonyouIMSdk
//
//  Created by litfb on 15/6/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMError.h"

@protocol YYIMTeleconferenceDelegate <NSObject>

@optional

/**
 *  电话会议发起成功
 *
 *  @param sessionId 电话会议SessionID
 */
- (void)didConferenceStartWithSessionId:(NSString *)sessionId;

/**
 *  电话会议发起失败
 *
 *  @param error 错误
 */
- (void)didNotConferenceStartWithError:(YYIMError *)error;

@end
