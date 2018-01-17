//
//  AppDelegate.m
//  YonyouIM
//
//  Created by litfb on 14/12/15.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "AppDelegate.h"
#import "YYIMUIDefs.h"
#import "LoginViewController.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "YYToken.h"
#import "YYIMUtility.h"
#import "MainViewController.h"
#import "UIColor+YYIMTheme.h"
#import "YMAFNetworking.h"
#import "ConfigManager.h"
#import "MainViewController.h"
#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "MBProgressHUD+Add.h"
#import "NetMeetingDispatch.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <PgyUpdate/PgyUpdateManager.h>
#import <Bugly/Bugly.h>
#import "WXApi.h"
#import "YYIMHeadPhonesManager.h"

@interface AppDelegate ()<YYIMChatDelegate, UIAlertViewDelegate, YYIMTokenDelegate, WXApiDelegate>

@property (retain, nonatomic) UINavigationController *mainNavController;
@property (retain, nonatomic) MainViewController *mainViewController;

@property (retain, nonatomic) UINavigationController *loginNavController;
@property (retain, nonatomic) LoginViewController *loginViewController;
@property (retain, nonatomic) RegisterViewController *registerViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    YYIMLogInfo(@"didFinishLaunchingWithOptions:%ld", (long)[application applicationState]);
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    [YYIMUtility initNavigationBarStyle];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginChange:) name:YYIM_NOTIFICATION_LOGINCHANGE object:nil];
    
    [application cancelAllLocalNotifications];
    
    // 服务配置
    [[ConfigManager sharedManager] sdkConfig];
    // 注册多方通话
    [[YYIMChat sharedInstance].chatManager registerDuduWithAccountIdentify:@"676272C9DBB7EB768883CFF4CC77EDAF" appkeyTemp:@"28BA35730731FC56D008ABD545D56608"];
    
    // 添加代理
    [[YYIMChat sharedInstance].chatManager addDelegate:self];
    // 注册token代理
    [[YYIMChat sharedInstance].chatManager registerTokenDelegate:self];
    // 注册推送证书
#if defined(DEBUG) && DEBUG
    [[YYIMChat sharedInstance] registerApnsCerName:@"yyimtest_dev"];
#else
    [[YYIMChat sharedInstance] registerApnsCerName:@"yyimtest_dis"];
#endif
    
    // 设置日志级别
    [[YYIMChat sharedInstance] setLogLevel:YYIM_LOG_LEVEL_VERBOSE];
    // 本地推送
    [[YYIMChat sharedInstance].chatManager setEnableLocalNotification:YES];
    // 注册远程推送
    [self registerRemoteNotification];
    
    // 设置高德地图key，参见高德地图官网
    [[MAMapServices sharedServices] setApiKey:@"dc8b66f5ad4dce8a78de6f5d9e9f344a"];
    [[AMapSearchServices sharedServices] setApiKey:@"dc8b66f5ad4dce8a78de6f5d9e9f344a"];
    // 设置蒲公英appId，参见蒲公英官网
    [[PgyUpdateManager sharedPgyManager] startManagerWithAppId:@"50220478d2c5808cb1c658bafd586c66"];
    // Bugly
    BuglyConfig *config = [[BuglyConfig alloc] init];
    [config setBlockMonitorEnable:YES];
    [Bugly startWithAppId:@"900019502" config:config];
    // 微信
    [WXApi registerApp:@"wx10a1a190f885a09e"];
    
    // image cache path
    NSString *bundledPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"YMImages"];
    [[SDImageCache sharedImageCache] addReadOnlyCachePath:bundledPath];
    [[SDWebImageManager sharedManager] setCacheKeyFilter:^(NSURL *url) {
        return [YYIMUtility cacheKeyForYMImageUrl:url];
    }];
    
    [NetMeetingDispatch sharedInstance];
    [YYIMHeadPhonesManager sharedInstance];
    
    [[YYIMChat sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [self.window makeKeyAndVisible];
    [self loginChange:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[YYIMChat sharedInstance] applicationWillResignActive:application];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[YYIMChat sharedInstance] applicationDidEnterBackground:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[YYIMChat sharedInstance] applicationWillEnterForeground:application];
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[YYIMChat sharedInstance] applicationDidBecomeActive:application];
    
    NSString *untreatedChannelId = [[YYIMChat sharedInstance].chatManager getUntreatedNetMeetingInviting];
    
    if (untreatedChannelId) {
        [[YYIMChat sharedInstance].chatManager treatNetMeetingInvite];
        
        [[NetMeetingDispatch sharedInstance] showNetMeetingInviteConfirmView:untreatedChannelId];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[YYIMChat sharedInstance] applicationWillTerminate:application];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[YYIMChat sharedInstance] application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[YYIMChat sharedInstance] application:application didFailToRegisterForRemoteNotificationsWithError:error];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [[YYIMChat sharedInstance] application:application didReceiveRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler {
    [[YYIMChat sharedInstance] application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
    completionHandler(UIBackgroundFetchResultNoData);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[YYIMChat sharedInstance] application:application didReceiveLocalNotification:notification];
    [self.mainNavController popToRootViewControllerAnimated:YES];
    [self.mainNavController dismissViewControllerAnimated:YES completion:nil];
    [self.mainViewController setSelectedIndex:0];
}

-(void)onReq:(BaseReq*)req {
    YYIMLogDebug(@"%@",req);
}

-(void)onResp:(BaseResp*)resp {
    YYIMLogDebug(@"%@",resp);
    
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        SendMessageToWXResp *message = (SendMessageToWXResp *)resp;
        
        YYIMLogDebug(@"onResp--微信发送消息完成%d",message.errCode);
    }
}

- (void)registerRemoteNotification {
    UIApplication *application = [UIApplication sharedApplication];
    
    // 注册推送通知
    if (YYIM_iOS8) {
        [application registerForRemoteNotifications];
        UIUserNotificationType notificationTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
        UIRemoteNotificationType notificationTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:notificationTypes];
    }
}

-(void)loginChange:(NSNotification *)notification {
    // is can auto login
    BOOL isAutoLogin = [[[YYIMChat sharedInstance] chatManager] isAutoLogin];
    // is login success
    BOOL loginSuccess = [notification.object boolValue];
    
    if (isAutoLogin || loginSuccess) {
        self.window.rootViewController = self.mainNavController;
        _loginNavController = nil;
    } else {
        self.window.rootViewController = self.loginNavController;
        _mainNavController = nil;
    }
}

- (UINavigationController *)mainNavController {
    if (!_mainNavController) {
        MainViewController *mainViewController = [[MainViewController alloc] init];
        // UINavigationController
        _mainNavController = [YYIMUtility themeNavController:mainViewController];
        self.mainViewController = mainViewController;
    }
    return _mainNavController;
}

- (UINavigationController *)loginNavController {
    if (!_loginNavController) {
        LoginViewController *loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
        _loginNavController = [YYIMUtility themeNavController:loginViewController];
        [_loginNavController setNavigationBarHidden:YES];
        self.loginViewController = loginViewController;
    }
    return _loginNavController;
}

#pragma mark yyimchat delegate

- (void)didConnect {
    YYIMLogInfo(@"didConnect");
}

- (void)didAuthenticate {
    YYIMLogInfo(@"didAuthenticate");
    [Bugly setUserIdentifier:[[YYIMConfig sharedInstance] getFullUser]];
}

- (void)didConnectFailure:(YYIMError *)error {
    YYIMLogInfo(@"连接IM服务器失败:%ld|%@", (long)[error errorCode], [error errorMsg]);
}

- (void)didAuthenticateFailure:(YYIMError *)error {
    YYIMLogInfo(@"IM服务器认证失败:%ld|%@", (long)[error errorCode], [error errorMsg]);
}

- (void)didLoginConflictOccurred {
    [[NetMeetingDispatch sharedInstance] didNetMeetingDispatchNeedClose];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"警告" message:@"您的帐号在其他客户端登陆" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (void)didNetMeetingInitFaild {
    [MBProgressHUD showHint:@"视频服务初始化失败" toView:nil];
}

- (void)didNotLoadRosterUsersWithError:(YYIMError *)error {
    [MBProgressHUD showHint:[NSString stringWithFormat:@"加载好友用户信息失败:%ld|%@", (long)[error errorCode], [error errorMsg]] toView:nil];
}

- (void)didNotLoadRostersWithError:(YYIMError *)error {
    [MBProgressHUD showHint:[NSString stringWithFormat:@"加载好友信息失败:%ld|%@", (long)[error errorCode], [error errorMsg]] toView:nil];
}

- (void)didNotLoadChatGroupWithError:(YYIMError *)error {
    [MBProgressHUD showHint:[NSString stringWithFormat:@"加载群组信息失败:%ld|%@", (long)[error errorCode], [error errorMsg]] toView:nil];
}

- (void)didNotLoadPubAccountWithError:(YYIMError *)error {
    [MBProgressHUD showHint:[NSString stringWithFormat:@"加载公共号信息失败:%ld|%@", (long)[error errorCode], [error errorMsg]] toView:nil];
}

- (void)didPresenceOnline {
    [MBProgressHUD showHint:@"Presence OK" toView:nil];
}

- (void)didNetMeetingInitSuccess {
#if defined(DEBUG) && DEBUG
    [[YYIMChat sharedInstance].chatManager setNetMeetingLogFilter:kYYIMNetMeetingLogFilterError];
#else
    [[YYIMChat sharedInstance].chatManager setNetMeetingLogFilter:kYYIMNetMeetingLogFilterDebug];
#endif
}

#pragma mark alert delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_LOGINCHANGE object:@NO];
}

#pragma mark YYIMTokenDelegate

- (void)getAppTokenWithComplete:(void (^)(BOOL, id))complete {
    YYIMLogInfo(@"getAppTokenWithComplete");
    NSDictionary *parameters = [self prepareParameters];
    if (!parameters) {
        complete(YES, [YYToken tokenWithExpiration:@"123456" expiration:@"0"]);
        return;
    }
    NSString *urlString = [[YYIMConfig sharedInstance] getDemoTokenServlet];
    
    YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
    [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    [manager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *dic = (NSDictionary *)responseObject;
        YYToken *token = [YYToken tokenWithExpiration:[dic objectForKey:@"token"] expiration:[dic objectForKey:@"expiration"]];
        YYIMLogInfo(@"getAppTokenWithComplete$succ:%@|%f", [token tokenStr], [token expirationTimeInterval]);
        complete(YES, token);
    } failure:^(NSURLSessionDataTask *task, id responseObject, NSError *error) {
        NSHTTPURLResponse *response = error.userInfo[YMAFNetworkingOperationFailingURLResponseErrorKey];
        YYIMLogError(@"getAppTokenWithComplete$fail:%@|%@", response, [error localizedDescription]);
        
        NSDictionary *dic = (NSDictionary *)responseObject;
        NSString *message;
        NSInteger statusCode = [response statusCode];
        switch (statusCode) {
            case 400:
            case 401:
                message = @"用户名或密码错误";
                break;
            default:
                message = [dic objectForKey:@"message"];
                break;
        }
        if (!message) {
            message = @"未知错误";
        }
        YYIMError *ymError = [YYIMError errorWithCode:statusCode errorMessage:message];
        [ymError setSrcError: error];
        complete(NO, ymError);
    }];
}

- (YYToken *)getAppToken {
    return nil;
}

- (NSDictionary *)prepareParameters {
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [parameters setObject:[userDefaults objectForKey:YYIM_ACCOUNT] forKey:@"username"];
    [parameters setObject:[userDefaults objectForKey:YYIM_PASSWORD] forKey:@"password"];
    [parameters setObject:[userDefaults objectForKey:YYIM_APPKEY] forKey:@"app"];
    [parameters setObject:[userDefaults objectForKey:YYIM_ETPKEY] forKey:@"etp"];
    return parameters;
}

@end
