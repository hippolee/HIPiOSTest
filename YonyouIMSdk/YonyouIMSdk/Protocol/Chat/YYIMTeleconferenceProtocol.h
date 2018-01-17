//
//  YYIMTeleconferenceProtocol.h
//  YonyouIMSdk
//
//  Created by litfb on 15/6/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseProtocol.h"

/**
 *  电话会议（嘟嘟）接口
 */
@protocol YYIMTeleconferenceProtocol <YYIMBaseProtocol>

/**
 *  注册嘟嘟账号和临时密钥
 *
 *  @param accountIdentify 嘟嘟accountIdentify
 *  @param appkeyTemp      嘟嘟临时密钥
 */
- (void)registerDuduWithAccountIdentify:(NSString *)accountIdentify appkeyTemp:(NSString *)appkeyTemp;

/**
 *  开始嘟嘟电话会议
 *
 *  @param userId       会议发起人ID
 *  @param participants 会议参与人ID
 */
- (void)createDuduConferenceWithCaller:(NSString *)userId participants:(NSArray *)participants;

/**
 *  开始嘟嘟电话会议
 *
 *  @param phoneNumber  会议发起人电话号码
 *  @param phoneNumbers 会议参与人电话号码
 */
- (void)createDuduConferenceWithCallerPhone:(NSString *)phoneNumber participantPhones:(NSArray *)phoneNumbers;

/**
 *  开始电话会议（在im.yyuap.com后台开通的）
 *
 *  @param userId       会议发起人ID
 *  @param participants 会议参与人ID
 */
- (void)createTeleConferenceWithCaller:(NSString *)userId participants:(NSArray *)participants;

/**
 *  开始电话会议（在im.yyuap.com后台开通的）
 *
 *  @param phoneNumber  会议发起人电话号码
 *  @param phoneNumbers 会议参与人电话号码
 */
- (void)createTeleConferenceWithCallerPhone:(NSString *)phoneNumber participantPhones:(NSArray *)phoneNumbers;

@end
