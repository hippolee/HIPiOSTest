//
//  ConfigManager.m
//  YonyouIM
//
//  Created by litfb on 16/4/13.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ConfigManager.h"
#import "YYIMUtility.h"
#import "YYIMChatHeader.h"

/** default im server */
#define DEBUG_IM_SERVER                     @"172.20.5.10"//@"172.20.8.189"//@"10.2.112.188"//@"10.2.112.58"//
/** default im server port */
#define DEBUG_IM_SERVER_PORT                5222
#define DEBUG_IM_SERVER_SSLPORT             5223
/** default im rest server */
#define DEBUG_IM_REST_SERVER                @"172.20.5.10:9090"//@"172.20.8.189"//@"10.2.112.188:9090"//@"10.2.112.58:9090"//
/** default resource server */
#define DEBUG_RESOURCE_UPLOAD_SERVER        DEBUG_IM_REST_SERVER
#define DEBUG_RESOURCE_DOWNLOAD_SERVER      DEBUG_IM_REST_SERVER

/** default im server */
#define DEFAULT_IM_SERVER                   @"stellar.yyuap.com"
/** default im server port */
#define DEFAULT_IM_SERVER_PORT              5227
#define DEFAULT_IM_SERVER_SSLPORT           5223
/** default im rest server */
#define DEFAULT_IM_REST_SERVER              @"im.yyuap.com"
/** default resource server */
#define DEFAULT_RESOURCE_UPLOAD_SERVER      @"up.im.yyuap.com"
#define DEFAULT_RESOURCE_DOWNLOAD_SERVER    @"down.im.yyuap.com"

/** gray im server */
#define GRAY_IM_SERVER                      @"im01.yyuap.com"
/** gray im server port */
#define GRAY_IM_SERVER_PORT                 5227
#define GRAY_IM_SERVER_SSLPORT              5223
/** gray im rest server */
#define GRAY_IM_REST_SERVER                 @"im01.yyuap.com"
/** gray resource server */
#define GRAY_RESOURCE_UPLOAD_SERVER         @"im01.yyuap.com"
#define GRAY_RESOURCE_DOWNLOAD_SERVER       @"im01.yyuap.com"

// server propties
#define YMSETTING_IM_SERVER                        @"YMSETTING_IM_SERVER"
#define YMSETTING_IM_SERVER_PORT                   @"YMSETTING_IM_SERVER_PORT"
#define YMSETTING_IM_SERVER_SSLPORT                @"YMSETTING_IM_SERVER_SSLPORT"
// enable ssl
#define YMSETTING_IM_SERVER_ENABLESSL              @"YMSETTING_IM_SERVER_ENABLESSL"
// rest server
#define YMSETTING_IM_REST_SERVER                   @"YMSETTING_IM_REST_SERVER"
#define YMSETTING_IM_REST_SERVER_HTTPS             @"YMSETTING_IM_REST_SERVER_HTTPS"
#define YMSETTING_IM_UPLOAD_SERVER                 @"YMSETTING_IM_UPLOAD_SERVER"
#define YMSETTING_IM_DOWNLOAD_SERVER               @"YMSETTING_IM_DOWNLOAD_SERVER"
// is roster collect
#define YMSETTING_IS_ROSTER_COLLECT                @"YMSETTING_IS_ROSTER_COLLECT"

@implementation ConfigManager

+ (instancetype)sharedManager {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (instancetype)init {
    if (self = [super init]) {
        if ([YYIMUtility isEmptyString:[self getSettingIMServer]]) {
            [self alphaSettings];
        }
    }
    return self;
}

- (void)sdkConfig {
    [[YYIMConfig sharedInstance] setIMServer:[self getSettingIMServer]];
    [[YYIMConfig sharedInstance] setIMServerPort:[self getSettingIMServerPort]];
    [[YYIMConfig sharedInstance] setIMServerSSLPort:[self getSettingIMServerSSLPort]];
    [[YYIMConfig sharedInstance] setIMServerEnableSSL:[self isSettingIMServerEnableSSL]];
    [[YYIMConfig sharedInstance] setIMRestServer:[self getSettingIMRestServer]];
    [[YYIMConfig sharedInstance] setIMRestServerHTTPS:[self isSettingIMRestServerHTTPS]];
    [[YYIMConfig sharedInstance] setRosterCollect:[self isSettingRosterCollect]];
    [[YYIMConfig sharedInstance] setResourceUploadServer:[self getSettingResourceUploadServer]];
    [[YYIMConfig sharedInstance] setResourceDownloadServer:[self getSettingResourceDownloadServer]];
}

- (void)alphaSettings {
    [self setSettingIMServer:DEBUG_IM_SERVER];
    [self setSettingIMServerPort:DEBUG_IM_SERVER_PORT];
    [self setSettingIMServerSSLPort:DEBUG_IM_SERVER_SSLPORT];
    [self setSettingIMServerEnableSSL:NO];
    [self setSettingIMRestServer:DEBUG_IM_REST_SERVER];
    [self setSettingIMRestServerHTTPS:NO];
    [self setSettingResourceUploadServer:DEBUG_RESOURCE_UPLOAD_SERVER];
    [self setSettingResourceDownloadServer:DEBUG_RESOURCE_DOWNLOAD_SERVER];
    [self setSettingRosterCollect:NO];
}

- (void)graySettings {
    [self setSettingIMServer:GRAY_IM_SERVER];
    [self setSettingIMServerPort:GRAY_IM_SERVER_PORT];
    [self setSettingIMServerSSLPort:GRAY_IM_SERVER_SSLPORT];
    [self setSettingIMServerEnableSSL:YES];
    [self setSettingIMRestServer:GRAY_IM_REST_SERVER];
    [self setSettingIMRestServerHTTPS:NO];
    [self setSettingResourceUploadServer:GRAY_RESOURCE_UPLOAD_SERVER];
    [self setSettingResourceDownloadServer:GRAY_RESOURCE_DOWNLOAD_SERVER];
    [self setSettingRosterCollect:NO];
}

- (void)betaSettings {
    [self setSettingIMServer:DEFAULT_IM_SERVER];
    [self setSettingIMServerPort:DEFAULT_IM_SERVER_PORT];
    [self setSettingIMServerSSLPort:DEFAULT_IM_SERVER_SSLPORT];
    [self setSettingIMServerEnableSSL:YES];
    [self setSettingIMRestServer:DEFAULT_IM_REST_SERVER];
    [self setSettingIMRestServerHTTPS:YES];
    [self setSettingResourceUploadServer:DEFAULT_RESOURCE_UPLOAD_SERVER];
    [self setSettingResourceDownloadServer:DEFAULT_RESOURCE_DOWNLOAD_SERVER];
    [self setSettingRosterCollect:NO];
}

#pragma mark settings

- (NSString *)getSettingIMServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YMSETTING_IM_SERVER];
}

- (void)setSettingIMServer:(NSString *) imServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:imServer forKey:YMSETTING_IM_SERVER];
    [userDefaults synchronize];
}

- (NSInteger)getSettingIMServerPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:YMSETTING_IM_SERVER_PORT];
}

- (void)setSettingIMServerPort:(NSInteger) serverPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:serverPort forKey:YMSETTING_IM_SERVER_PORT];
    [userDefaults synchronize];
}

// IM Server SSL端口
- (NSInteger)getSettingIMServerSSLPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults integerForKey:YMSETTING_IM_SERVER_SSLPORT];
}

- (void)setSettingIMServerSSLPort:(NSInteger)serverPort {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setInteger:serverPort forKey:YMSETTING_IM_SERVER_SSLPORT];
    [userDefaults synchronize];
}

// Enable ssl
- (BOOL)isSettingIMServerEnableSSL {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YMSETTING_IM_SERVER_ENABLESSL];
}

- (void)setSettingIMServerEnableSSL:(BOOL)enable {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:enable forKey:YMSETTING_IM_SERVER_ENABLESSL];
    [userDefaults synchronize];
}

- (NSString *)getSettingIMRestServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults stringForKey:YMSETTING_IM_REST_SERVER];
}

- (void)setSettingIMRestServer:(NSString *)server {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:server forKey:YMSETTING_IM_REST_SERVER];
    [userDefaults synchronize];
}

- (BOOL)isSettingIMRestServerHTTPS {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YMSETTING_IM_REST_SERVER_HTTPS];
}

- (void)setSettingIMRestServerHTTPS:(BOOL)isHTTPS {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isHTTPS forKey:YMSETTING_IM_REST_SERVER_HTTPS];
    [userDefaults synchronize];
}

// 资源上传Server
- (NSString *)getSettingResourceUploadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:YMSETTING_IM_UPLOAD_SERVER];
}

- (void)setSettingResourceUploadServer:(NSString *)uploadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:uploadServer forKey:YMSETTING_IM_UPLOAD_SERVER];
    [userDefaults synchronize];
}

// 资源下载Server
- (NSString *)getSettingResourceDownloadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:YMSETTING_IM_DOWNLOAD_SERVER];
}

- (void)setSettingResourceDownloadServer:(NSString *)downloadServer {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:downloadServer forKey:YMSETTING_IM_DOWNLOAD_SERVER];
    [userDefaults synchronize];
}

- (BOOL)isSettingRosterCollect {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:YMSETTING_IS_ROSTER_COLLECT];
}

- (void)setSettingRosterCollect:(BOOL)isCollect {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:isCollect forKey:YMSETTING_IS_ROSTER_COLLECT];
    [userDefaults synchronize];
}

@end
