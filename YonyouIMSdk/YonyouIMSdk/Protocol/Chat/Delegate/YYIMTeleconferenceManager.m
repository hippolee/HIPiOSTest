//
//  YYIMTeleconferenceManager.m
//  YonyouIMSdk
//
//  Created by litfb on 15/6/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMTeleconferenceManager.h"
#import "YYIMConfig.h"
#import "YYIMChat.h"
#import "YYIMError.h"
#import "YYIMHttpUtility.h"
#import "YYIMStringUtility.h"
#import "YMGCDMulticastDelegate.h"
#import "YYIMHttpUtility.h"
#import "YYIMJUMPHelper.h"
#import "YMAFNetworking.h"
#import "YYIMLogger.h"
#import "YYIMConfig.h"

@implementation YYIMTeleconferenceManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)registerDuduWithAccountIdentify:(NSString *)accountIdentify appkeyTemp:(NSString *)appkeyTemp {
    NSParameterAssert(accountIdentify != nil);
    NSParameterAssert(appkeyTemp != nil);
    [[YYIMConfig sharedInstance] setDuduAccountIdentify:accountIdentify];
    [[YYIMConfig sharedInstance] setDuduAppkeytemp:appkeyTemp];
}

- (void)createDuduConferenceWithCaller:(NSString *)userId participants:(NSArray *)participants {
    // user
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:userId];
    if (!user) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_USER_NOT_FOUND errorMessage:@"发起人未找到"]];
        return;
    }
    
    NSMutableArray *phones = [NSMutableArray array];
    for (NSString *partUserId in participants) {
        YYUser *partUser = [[YYIMChat sharedInstance].chatManager getUserWithId:partUserId];
        if (![YYIMStringUtility isEmpty:[partUser userMobile]]) {
            [phones addObject:[partUser userMobile]];
        }
    }
    
    [self createDuduConferenceWithCallerPhone:[user userMobile] participantPhones:phones];
}

- (void)createDuduConferenceWithCallerPhone:(NSString *)phoneNumber participantPhones:(NSArray *)phoneNumbers {
    if ([YYIMStringUtility isEmpty:phoneNumber]) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_USER_MOBILE_NOT_FOUND errorMessage:@"发起人号码未设置"]];
        return;
    }
    
    NSMutableString *phones = [NSMutableString string];
    for (NSString *number in phoneNumbers) {
        if (![YYIMStringUtility isEmpty:number]) {
            if (phones.length > 0) {
                [phones appendString:@","];
            }
            [phones appendString:number];
        }
    }
    if (phones.length <= 0) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_USER_MOBILE_NOT_FOUND errorMessage:@"参会人号码未设置"]];
        return;
    }
    
    NSString *accountIdentify = [[YYIMConfig sharedInstance] getDuduAccountIdentify];
    if ([YYIMStringUtility isEmpty:accountIdentify]) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"accountIdentify not found"]];
        return;
    }
    
    NSString *appkeyTemp = [[YYIMConfig sharedInstance] getDuduAppkeytemp];
    if ([YYIMStringUtility isEmpty:appkeyTemp]) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"appkeyTemp not found"]];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // 主叫号码
    [parameters setObject:phoneNumber forKey:@"caller"];
    // 多方通话参与者
    [parameters setObject:phones forKey:@"phones"];
    // 组织账号标识
    [parameters setObject:accountIdentify forKey:@"account_identify"];
    // 用户id
    [parameters setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"userId"];
    // 时间戳
    NSString *timestamp = [NSString stringWithFormat:@"%lld", [YYIMJUMPHelper getCurrentTimeinmillis]];
    [parameters setObject:timestamp forKey:@"timestamp"];
    YYIMLogDebug(@"createDuduConferenceWithCallerPhone:timestamp:%@", timestamp);
    // SHA1 (appidentify+ appkey_temp +timestamp)
    NSString *str = [NSString stringWithFormat:@"%@%@%@", accountIdentify, appkeyTemp, timestamp];
    [parameters setObject:[YYIMStringUtility sha1Encode:str] forKey:@"sign"];
    YYIMLogDebug(@"createDuduConferenceWithCallerPhone:sha1:%@", [YYIMStringUtility sha1Encode:str]);
    
    YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
    [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [manager GET:[[YYIMConfig sharedInstance] getDuduCreateConferenceServlet] parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        if (dic) {
            NSInteger result = [[dic objectForKey:@"result"] integerValue];
            if (result == 0) {
                NSString *sessionId = [dic objectForKey:@"sessionId"];
                if ([YYIMStringUtility isEmpty:sessionId]) {
                    sessionId = [dic objectForKey:@"sessionid"];
                }
                [[self activeDelegate] didConferenceStartWithSessionId:sessionId];
                return;
            } else {
                [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:result errorMessage:[dic objectForKey:@"describe"]]];
                return;
            }
        } else {
            [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"]];
            return;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, id responseObject, NSError * _Nonnull error) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithNSError:error]];
    }];
}

- (void)createTeleConferenceWithCaller:(NSString *)userId participants:(NSArray *)participants {
    // user
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:userId];
    if (!user) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_USER_NOT_FOUND errorMessage:@"发起人未找到"]];
        return;
    }
    
    NSMutableArray *phones = [NSMutableArray array];
    for (NSString *partUserId in participants) {
        YYUser *partUser = [[YYIMChat sharedInstance].chatManager getUserWithId:partUserId];
        if (![YYIMStringUtility isEmpty:[partUser userMobile]]) {
            [phones addObject:[partUser userMobile]];
        }
    }
    
    [self createTeleConferenceWithCallerPhone:[user userMobile] participantPhones:phones];
}

- (void)createTeleConferenceWithCallerPhone:(NSString *)phoneNumber participantPhones:(NSArray *)phoneNumbers {
    if ([YYIMStringUtility isEmpty:phoneNumber]) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_USER_MOBILE_NOT_FOUND errorMessage:@"发起人号码未设置"]];
        return;
    }
    
    NSMutableArray *phones = [NSMutableArray array];
    for (NSString *number in phoneNumbers) {
        if (![YYIMStringUtility isEmpty:number] && ![phones containsObject:number]) {
            [phones addObject:number];
        }
    }
    
    if ([phones count] <= 0) {
        [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_USER_MOBILE_NOT_FOUND errorMessage:@"参会人号码未设置"]];
        return;
    }
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    // 主叫号码
    [parameters setObject:phoneNumber forKey:@"caller"];
    // 多方通话参与者
    [parameters setObject:phones forKey:@"phones"];
    // 用户id
    [parameters setObject:[[YYIMConfig sharedInstance] getUser] forKey:@"username"];
    // appId
    [parameters setObject:[[YYIMConfig sharedInstance] getAppKey] forKey:@"appId"];
    // etpId
    [parameters setObject:[[YYIMConfig sharedInstance] getEtpKey] forKey:@"etpId"];
    
    __block NSString *urlString = [[YYIMConfig sharedInstance] getTeleConfereneServlet];
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        // 拼装token
        urlString = [NSString stringWithFormat:@"%@?token=%@", urlString, [token tokenStr]];
        
        YYIMLogDebug(@"createTeleConferenceWithCallerPhone:url:%@", urlString);
        
        YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
        [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        [manager setRequestSerializer:[YMAFJSONRequestSerializer serializer]];
        
        [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            YYIMLogDebug(@"createTeleConferenceWithCallerPhone:success");
            NSDictionary *dic = (NSDictionary *)responseObject;
            // sessionId
            NSString *sessionId = [dic objectForKey:@"sessionId"];
            if (sessionId) {
                [[self activeDelegate] didConferenceStartWithSessionId:sessionId];
            } else {
                // message
                NSString *message = [dic objectForKey:@"message"];
                
                if (message) {
                    [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:message]];
                } else {
                    [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"unknown error"]];
                }
            }
        } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
            YYIMLogError(@"createTeleConferenceWithCallerPhone:faild:%@", [error localizedDescription]);
            [[self activeDelegate] didNotConferenceStartWithError:[YYIMError errorWithNSError:error]];
            // response dic
            NSDictionary *dic = (NSDictionary *)responseObject;
            // message
            NSString *message = [dic objectForKey:@"message"];
            
            YYIMError *ymError;
            if ([YYIMStringUtility isEmpty:message]) {
                ymError = [YYIMError errorWithNSError:error];
            } else {
                NSInteger errCode = YMERROR_CODE_UNEXPECT_STATE;
                if ([@"This user has not got a account_identify" isEqualToString:message]) {
                    message = @"没有权限";
                }
                ymError = [YYIMError errorWithCode:errCode errorMessage:message];
            }
            [[self activeDelegate] didNotConferenceStartWithError:ymError];

        }];
    }];
    
}

@end
