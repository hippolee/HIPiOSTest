//
//  YYIMJUMPHelper.m
//  YonyouIM
//
//  Created by litfb on 15/1/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMJUMPHelper.h"
#import "YYIMConfig.h"
#import "YYIMJUMPHelper.h"
#import "YYIMDefs.h"
#import "YYIMStringUtility.h"
#import "JUMPFramework.h"
#import "YYToken.h"
#import "YYIMChat.h"
#import "YYIMLogger.h"
#import "YYIMConfig.h"
#import "YYIMError.h"

#define YM_TOKEM_EXPIRATION_THRESHOLD 3600

@implementation YYIMJUMPHelper

+ (BOOL)isAdminUser:(NSString *)user {
    return [YM_ADMIN_USER isEqualToString:user];
}

+ (BOOL)isSelf:(NSString *)str {
    return [[[YYIMConfig sharedInstance] getJid] isEqualToString:str] ||
    [[[YYIMConfig sharedInstance] getUser] isEqualToString:str] ||
    [[[YYIMConfig sharedInstance] getFullUser] isEqualToString:str];
}

+ (NSString *)getAppId {
    NSString *appKey = [[YYIMConfig sharedInstance] getAppKey];
    NSString *etpKey = [[YYIMConfig sharedInstance] getEtpKey];
    
    NSAssert(![YYIMStringUtility isEmpty:appKey], @"appKey not set");
    NSAssert(![YYIMStringUtility isEmpty:etpKey], @"etpKey not set");
    
    return [NSString stringWithFormat:@"%@.%@", appKey, etpKey];
}

+ (NSString *)genFullUser:(NSString *)user {
    // 处理anonymous
    if ([self isAnonymousUser:user]) {
        return [self genFullJidString:user];
    }
    
    NSString *appKey = [[YYIMConfig sharedInstance] getAppKey];
    NSString *etpKey = [[YYIMConfig sharedInstance] getEtpKey];
    
    NSAssert(![YYIMStringUtility isEmpty:appKey], @"appKey not set");
    NSAssert(![YYIMStringUtility isEmpty:etpKey], @"etpKey not set");
    
    return [NSString stringWithFormat:@"%@.%@.%@",user, appKey, etpKey];
}

+ (NSString *)genFullJidString:(NSString *) user {
    // serverName
    NSString *serverName = [[YYIMConfig sharedInstance] getIMServerName];
    
    NSAssert(![YYIMStringUtility isEmpty:serverName], @"serverName not set");
    
    // 处理anonymous
    NSRange slashRange = [user rangeOfString:@"/"];
    if (slashRange.location != NSNotFound) {
        NSString *bareUser = [user substringToIndex:slashRange.location];
        NSString *resource = [user substringFromIndex:slashRange.location + 1];
        if ([YM_ANONYMOUS_RESOURCE isEqualToString:resource]) {
            return [NSString stringWithFormat:@"%@@%@/ANONYMOUS",bareUser,serverName];
        }
    }
    
    NSString *appKey = [[YYIMConfig sharedInstance] getAppKey];
    NSString *etpKey = [[YYIMConfig sharedInstance] getEtpKey];
    
    NSAssert(![YYIMStringUtility isEmpty:appKey], @"appKey not set");
    NSAssert(![YYIMStringUtility isEmpty:etpKey], @"etpKey not set");
    
    return [NSString stringWithFormat:@"%@.%@.%@@%@",user,appKey,etpKey,serverName];
}

+ (JUMPJID *)genFullJid:(NSString *)user {
    return [JUMPJID jidWithString:[YYIMJUMPHelper genFullJidString:user]];
}

+ (NSString *)parseUser:(NSString *)user {
    NSRange atRange = [user rangeOfString:@"@"];
    if (atRange.location > 0 && atRange.location < user.length) {
        user = [user substringToIndex:atRange.location];
    }
    
    NSRange range = [user rangeOfString:@"."];
    if (range.location > 0 && range.location < user.length) {
        return [user substringToIndex:range.location];
    }
    return user;
}

+ (NSString *)genFullGroupJidString:(NSString *) groupId {
    NSString *appKey = [[YYIMConfig sharedInstance] getAppKey];
    NSString *etpKey = [[YYIMConfig sharedInstance] getEtpKey];
    NSString *serverName = [[YYIMConfig sharedInstance] getConferenceServerName];
    
    NSAssert(![YYIMStringUtility isEmpty:appKey], @"appKey not set");
    NSAssert(![YYIMStringUtility isEmpty:etpKey], @"etpKey not set");
    NSAssert(![YYIMStringUtility isEmpty:serverName], @"serverName not set");
    
    return [NSString stringWithFormat:@"%@.%@.%@@%@",groupId,appKey,etpKey,serverName];
}

+ (JUMPJID *)genFullGroupJid:(NSString *) groupId {
    return [JUMPJID jidWithString:[YYIMJUMPHelper genFullGroupJidString:groupId]];
}

+ (NSString *)genFullPubAccountJidString:(NSString *) accountId {
    NSString *appKey = [[YYIMConfig sharedInstance] getAppKey];
    NSString *etpKey = [[YYIMConfig sharedInstance] getEtpKey];
    NSString *serverName = [[YYIMConfig sharedInstance] getPubAccountServerName];
    
    NSAssert(![YYIMStringUtility isEmpty:appKey], @"appKey not set");
    NSAssert(![YYIMStringUtility isEmpty:etpKey], @"etpKey not set");
    NSAssert(![YYIMStringUtility isEmpty:serverName], @"serverName not set");
    
    return [NSString stringWithFormat:@"%@.%@.%@@%@",accountId,appKey,etpKey,serverName];
}

+ (JUMPJID *)genFullPubAccountJid:(NSString *) accountId {
    return [JUMPJID jidWithString:[YYIMJUMPHelper genFullPubAccountJidString:accountId]];
}

+ (void)genAvailableTokenWithComplete:(void (^)(BOOL, YYToken *, YYIMError *))complete {
    [[self class] genAvailableTokenWithComplete:complete forceLoad:NO];
}

+ (void)genAvailableTokenWithComplete:(void (^)(BOOL, YYToken *, YYIMError *))complete forceLoad:(BOOL)forceLoad {
    YYIMLogInfo(@"genAvailableTokenWithComplete");
    NSTimeInterval tokenExpiration = [[YYIMConfig sharedInstance] getTokenExpiration];
    NSTimeInterval currectTime = [[NSDate date] timeIntervalSince1970];
    if (forceLoad || tokenExpiration - currectTime <= YM_TOKEM_EXPIRATION_THRESHOLD) {
        [[YYIMChat sharedInstance].chatManager getAppTokenWithComplete:^(BOOL result, id resultObject) {
            if (resultObject && [resultObject isKindOfClass:[YYToken class]] && ![YYIMStringUtility isEmpty:[(YYToken *)resultObject tokenStr]]) {
                YYToken *token = (YYToken *)resultObject;
                [[YYIMConfig sharedInstance] setToken:[token tokenStr]];
                [[YYIMConfig sharedInstance] setTokenExpiration:[token expirationTimeInterval]];
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    YYIMLogInfo(@"genAvailableTokenWithComplete$succ1:%@|%f", [token tokenStr], [token expirationTimeInterval]);
                    complete(YES, token, nil);
                });
            } else {
                [[YYIMConfig sharedInstance] setToken:@""];
                [[YYIMConfig sharedInstance] setTokenExpiration:0];
                
                YYIMError *tokenError;
                if (result) {
                    tokenError = [YYIMError errorWithCode:YMERROR_CODE_GET_TOKEN_FAILD errorMessage:@"token数据错误"];
                } else {
                    if ([resultObject isKindOfClass:[YYIMError class]]) {
                        tokenError = (YYIMError *)resultObject;
                    } else if ([resultObject isKindOfClass:[NSError class]]) {
                        tokenError = [YYIMError errorWithNSError:(NSError *)resultObject];
                    } else {
                        tokenError = [YYIMError errorWithCode:YMERROR_CODE_GET_TOKEN_FAILD errorMessage:@"用户token请求失败，未知错误"];
                    }
                }
                YYIMLogError(@"getTokenError:%ld|%@|%@", (long)[tokenError errorCode], [tokenError errorMsg], [[tokenError srcError] localizedDescription]);
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    complete(NO, nil, tokenError);
                });
            }
            
        }];
    } else {
        YYToken *token = [YYToken tokenWithExpiration:[[YYIMConfig sharedInstance] getToken] expiration:[NSString stringWithFormat:@"%f", tokenExpiration]];
        YYIMLogInfo(@"genAvailableTokenWithComplete$succ2:%@|%f", [token tokenStr], [token expirationTimeInterval]);
        complete(YES, token, nil);
    }
}

+ (NSString *)anonymousJidString {
    NSString *serverName = [[YYIMConfig sharedInstance] getIMServerName];
    
    NSAssert(![YYIMStringUtility isEmpty:serverName], @"serverName not set");
    
    return [NSString stringWithFormat:@"anonymous@%@",serverName];
}

+ (BOOL)isAnonymousUser:(NSString *)user {
    NSString *resource = [YYIMJUMPHelper userResource:user];
    if ([YM_ANONYMOUS_RESOURCE isEqualToString:resource]) {
        return YES;
    }
    return NO;
}

+ (NSString *)userResource:(NSString *)user {
    NSRange slashRange = [user rangeOfString:@"/"];
    
    NSString *resource = nil;
    if (slashRange.location != NSNotFound) {
        resource = [user substringFromIndex:slashRange.location + 1];
    }
    return resource;
}

+ (YYIMClientType)parseResourceClient:(NSString *)resource {
    NSRange lineRange = [resource rangeOfString:@"-"];
    if (lineRange.location > 0 && lineRange.location < resource.length) {
        resource = [resource substringToIndex:lineRange.location];
        if ([YM_CLIENT_ANDROID isEqualToString:resource]) {
            return kYYIMClientTypeAndroid;
        } else if ([YM_CLIENT_IOS isEqualToString:resource]) {
            return kYYIMClientTypeIOS;
        } else if ([YM_CLIENT_DESKTOP isEqualToString:resource]) {
            return kYYIMClientTypePC;
        } else if ([YM_CLIENT_WEBIM isEqualToString:resource]) {
            return kYYIMClientTypeWeb;
        }
    } else {
        if ([YM_CLIENT_ANDROID isEqualToString:resource]) {
            return kYYIMClientTypeAndroid;
        } else if ([YM_CLIENT_IOS isEqualToString:resource]) {
            return kYYIMClientTypeIOS;
        } else if ([@"desktop" isEqualToString:resource]) {
            return kYYIMClientTypePC;
        } else if ([@"webim" isEqualToString:resource]) {
            return kYYIMClientTypeWeb;
        }
    }
    return kYYIMClientTypeUnknown;
}

+ (long long)getCurrentTimeinmillis {
    return [[NSNumber numberWithLongLong:[[NSDate date] timeIntervalSince1970] * 1000] longLongValue];
}

+ (BOOL)isChatGpoupJid:(NSString *)jid {
    NSString *groupJid = [[YYIMConfig sharedInstance] getConferenceServerName];
    if ([jid rangeOfString:groupJid].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isPubAccountJid:(NSString *)jid {
    NSString *accountJid = [[YYIMConfig sharedInstance] getPubAccountServerName];
    if ([jid rangeOfString:accountJid].location != NSNotFound) {
        return YES;
    }
    
    return NO;
}

@end
