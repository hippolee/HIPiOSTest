//
//  YYIMChat.m
//  YonyouIM
//
//  Created by litfb on 14/12/25.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "YYIMChat.h"

#import "YYIMChatManager.h"
#import "YYIMConfig.h"
#import "YYIMStringUtility.h"
#import "YYIMLogger.h"
#import "YMAFNetworking.h"
#import "YYIMDBHelper.h"
#import "YYIMPanDBHelper.h"

@interface YYIMChat ()

@property (nonatomic) UIBackgroundTaskIdentifier backgroundTaskIdentifier;

@end

@implementation YYIMChat

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    if ((self = [super init])) {
        // chatManager
        _chatManager = [YYIMChatManager sharedInstance];
        
        // 网络状态监测
        [[YMAFNetworkReachabilityManager sharedManager] startMonitoring];
        // 日志
        [YYIMLogger initLogger];
#if defined(DEBUG) && DEBUG
        [YYIMLogger setLogLevel:YYIM_LOG_LEVEL_VERBOSE];
#else
        [YYIMLogger setLogLevel:YYIM_LOG_LEVEL_ERROR];
#endif
    }
    return self;
}

- (NSString *)getSdkVersion {
    return YM_CLIENT_CURRENT_VERSION;
}

- (YYIMError *)registerApp:(NSString *)appKey etpKey:(NSString *)etpKey {
    if ([YYIMStringUtility isEmpty:appKey] || [YYIMStringUtility isEmpty:etpKey]) {
        return [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"appKey and etpKey should not empty"];
    }
    [[YYIMConfig sharedInstance] setAppKey:appKey];
    [[YYIMConfig sharedInstance] setEtpKey:etpKey];
    return nil;
}

- (void)registerApnsCerName:(NSString *)apnsCerName {
    [[YYIMConfig sharedInstance] setApnsCerName:apnsCerName];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    YYIMLogDebug(@"didFinishLaunchingWithOptions");
    [self.chatManager doAutoLogin];
    [[YYIMDBHelper sharedInstance] updateFaildMessage];
    [[YYIMPanDBHelper sharedInstance] updateFaildAttach];
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    YYIMLogDebug(@"didRegisterForRemoteNotificationsWithDeviceToken:%@", deviceToken);
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *oldDt = [[YYIMConfig sharedInstance] getDeviceToken];
    if ([YYIMStringUtility isEmpty:oldDt] || ![oldDt isEqualToString:dt]) {
        [[YYIMConfig sharedInstance] setDeviceToken:dt];
    }
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    YYIMLogDebug(@"application:didRegisterUserNotificationSettings:%@", notificationSettings);
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    YYIMLogDebug(@"application:didFailToRegisterForRemoteNotificationsWithError:%@", error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    YYIMLogDebug(@"application:didReceiveRemoteNotification:%@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    YYIMLogDebug(@"application:didReceiveRemoteNotification:fetchCompletionHandler, %@", userInfo);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    YYIMLogDebug(@"application:didReceiveLocalNotification:%@", notification.userInfo);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    YYIMLogDebug(@"applicationDidBecomeActive");
}

- (void)applicationWillResignActive:(UIApplication *)application {
    YYIMLogDebug(@"applicationWillResignActive");
    
    if (![self isVOIP]) {
        
    }
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    YYIMLogDebug(@"applicationDidReceiveMemoryWarning");
}

- (void)applicationWillTerminate:(UIApplication *)application {
    YYIMLogDebug(@"applicationWillTerminate");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    YYIMLogDebug(@"applicationDidEnterBackground");
    if ([self isVOIP]) {
        [[UIApplication sharedApplication] setKeepAliveTimeout:600 handler:^{
            [[YYIMChat sharedInstance].chatManager doAutoLogin];
        }];
    } else {
        self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^( void) {
            [[YYIMChat sharedInstance].chatManager goOffline];
            
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    YYIMLogDebug(@"applicationWillEnterForeground");
    if ([self isVOIP]) {
        [[UIApplication sharedApplication] clearKeepAliveTimeout];
    }
    [[YYIMChat sharedInstance].chatManager doAutoLogin];
}

#pragma mark providers

- (void)regisgerRosterProvider:(id<YYIMRosterProtocol>)rosterProvider {
    [_chatManager regisgerRosterProvider:rosterProvider];
}

- (void)registerChatGroupProvider:(id<YYIMChatGroupProtocol>)chatGroupProvider {
    [_chatManager registerChatGroupProvider:chatGroupProvider];
}

- (void)registerUserProvider:(id<YYIMUserProtocol>)userProvider {
    [_chatManager registerUserProvider:userProvider];
}

#pragma mark log

- (void)setLogLevel:(int)logLevel {
    [YYIMLogger setLogLevel:logLevel];
}

#pragma mark check background mode

- (BOOL)isVOIP {
    NSArray *backgroundModes = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"UIBackgroundModes"];
    return [backgroundModes containsObject:@"voip"];
}

@end
