//
//  YYIMJUMPHelper.h
//  YonyouIM
//
//  Created by litfb on 15/1/6.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYToken.h"
#import "YYIMDefs.h"
#import "YYIMError.h"

@class JUMPJID;

@interface YYIMJUMPHelper : NSObject

+ (BOOL)isAdminUser:(NSString *)user;

+ (BOOL)isSelf:(NSString *)str;

+ (NSString *)getAppId;

+ (NSString *)genFullUser:(NSString *)user;

+ (NSString *)genFullJidString:(NSString *) user;

+ (JUMPJID *)genFullJid:(NSString *) user;

+ (NSString *)parseUser:(NSString *) user;

+ (NSString *)genFullGroupJidString:(NSString *) groupId;

+ (JUMPJID *)genFullGroupJid:(NSString *) groupId;

+ (NSString *)genFullPubAccountJidString:(NSString *) accountId;

+ (JUMPJID *)genFullPubAccountJid:(NSString *) accountId;

+ (void)genAvailableTokenWithComplete:(void (^)(BOOL result, YYToken *token, YYIMError *tokenError))complete;

+ (void)genAvailableTokenWithComplete:(void (^)(BOOL result, YYToken *token, YYIMError *tokenError))complete forceLoad:(BOOL)forceLoad;

+ (NSString *)anonymousJidString;

+ (BOOL)isAnonymousUser:(NSString *)user;

+ (YYIMClientType)parseResourceClient:(NSString *)resource;

+ (long long)getCurrentTimeinmillis;

+ (BOOL)isChatGpoupJid:(NSString *)jid;

+ (BOOL)isPubAccountJid:(NSString *)jid;

@end
