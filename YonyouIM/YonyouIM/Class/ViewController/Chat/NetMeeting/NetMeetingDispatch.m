//
//  NetMeetingDispatch.m
//  YonyouIM
//
//  Created by yanghaoc on 16/4/8.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "NetMeetingDispatch.h"
#import "YYIMNetMeetingInviteConfirmViewController.h"
#import "YYIMNetMeetingAudienceViewController.h"
#import "YYIMNetMeetingConferenceViewController.h"
#import "YYIMNetMeetingChatViewController.h"
#import "YYIMUtility.h"
#import "AppDelegate.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMNetMeetingBroadcasterViewController.h"
#import "YYIMNetMeetingWindowView.h"
#import "YYIMUIDefs.h"

#define kScreenWidth [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight [[UIScreen mainScreen] bounds].size.height

@interface  NetMeetingDispatch() <YYIMChatDelegate>

@property (strong, nonatomic) UIWindow *netMeetingWindow;

@property (strong, nonatomic) UITapGestureRecognizer *reFullGestureRecognizer;

@property (strong, nonatomic) UIPanGestureRecognizer *moveGestureRecognizer;

@property (strong, nonatomic) UINavigationController *zoomNetMeetingViewController;

@property (strong, nonatomic) YYIMNetMeetingWindowView *minimizeView;

//创建的回执id
@property (strong, nonatomic) NSString *createNetMeetingseriId;
//创建的类型
@property YYIMNetMeetingType createNetMeetingType;
//创建的模式
@property YYIMNetMeetingMode createNetMeetingMode;

//当前窗口化的用户
@property (strong, nonatomic) YYNetMeetingMember *windowUser;

//当前持有页面的channelId（如果是会议等，就是会议id。如果是邀请页面就是邀请id）
@property (strong, nonatomic) NSString *currentChannelId;


//当前会议页面是否是主页面
@property BOOL netMeetingVisible;

@end

@implementation NetMeetingDispatch

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
        
        [[YYIMChat sharedInstance].chatManager addDelegate:(id<YYIMChatDelegate>)_sharedObject];
    });
    return _sharedObject;
}

- (UIWindow *)netMeetingWindow {
    if (!_netMeetingWindow) {
        _netMeetingWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _netMeetingWindow.backgroundColor = [UIColor clearColor];
        _netMeetingWindow.windowLevel = UIWindowLevelNormal;
        [_netMeetingWindow makeKeyAndVisible];
        
        self.reFullGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickWindow:)];
        self.moveGestureRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(locationChange:)];
        self.moveGestureRecognizer.delaysTouchesBegan = YES;
    }
    
    return _netMeetingWindow;
}

#pragma mark -
#pragma mark NetMeetingDispatchDelegate

- (void)showHint:(NSString *)hint from:(UIViewController *)from {
    if (self.netMeetingVisible) {
        [from showHint:hint view:self.netMeetingWindow];
    } else {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [from showHint:hint view:appDelegate.window];
    }
}

/**
 *  需要关闭
 */
- (void)didNetMeetingDispatchNeedClose {
    [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE object:@NO];
    
    if (self.durationTimer) {
        [self.durationTimer invalidate];
        self.durationTimer = nil;
    }
    
    if (self.minimizeView) {
        [self.minimizeView removeFromSuperview];
        self.minimizeView = nil;
        self.windowUser = nil;
    }
    
    if (self.reFullGestureRecognizer) {
        [self.netMeetingWindow removeGestureRecognizer:self.reFullGestureRecognizer];
    }
    
    if (self.moveGestureRecognizer) {
        [self.netMeetingWindow removeGestureRecognizer:self.moveGestureRecognizer];
    }
    
    //当前控制页面的会议id需要清空
    self.currentChannelId = nil;
    
    //清空dispatch持有的导航视图
    self.zoomNetMeetingViewController = nil;
    
    //清空window的根视图
    self.netMeetingWindow.rootViewController = nil;
    [self.netMeetingWindow setFrame:CGRectZero];
    
    //主视图可见
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeKeyAndVisible];
    self.netMeetingVisible = NO;
}

/**
 *  需要缩小
 */
- (void)didNetMeetingDispatchNeedMinimize {
    //记录当前的导航视图
    self.zoomNetMeetingViewController = (UINavigationController *)[self.netMeetingWindow rootViewController];
    
    //清空window的根视图
    self.netMeetingWindow.rootViewController = nil;
    //提高等级，否则在主window的visible的情况下会显示不出来。
    self.netMeetingWindow.windowLevel = UIWindowLevelAlert;
    
    //缩放并添加手势
    [self.netMeetingWindow setFrame:CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - 100, 80, 80, 120)];
    [self.netMeetingWindow addGestureRecognizer:self.reFullGestureRecognizer];
    [self.netMeetingWindow addGestureRecognizer:self.moveGestureRecognizer];
    
    self.minimizeView = [YYIMNetMeetingWindowView initNetMeetingWindowView];
    [self.minimizeView setNeedsLayout];
    [self.netMeetingWindow addSubview:self.minimizeView];
    
    //主视图可见
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window makeKeyAndVisible];
    self.netMeetingVisible = NO;
}

- (void)showWindowDetail:(NSString *)userId channelId:(NSString *)channelId{
    if (self.minimizeView) {
        self.windowUser = [[YYIMChat sharedInstance].chatManager getNetMeetingMemberWithChannelId:channelId memberId:userId];
        [self.minimizeView setNetMeetingMember:self.windowUser];
    }
}

#pragma mark -
#pragma mark yyimnetmeeting delegate

/**
 *  收到进入房间的邀请
 *
 *  @param channelId 频道id
 *  @param userArray  成员数组
 */
- (void)didNetMeetingInvited:(NSString *)channelId userArray:(NSArray *)userArray {
    if (![userArray containsObject:[[YYIMConfig sharedInstance] getUser]]) {
        return;
    }
    
    BOOL isAppActivity = [[UIApplication sharedApplication] applicationState] == UIApplicationStateActive;
    
    if (isAppActivity && [[YYIMChat sharedInstance].chatManager getUntreatedNetMeetingInviting]) {
        [[YYIMChat sharedInstance].chatManager treatNetMeetingInvite];
        
        [self needShowFullScreenWindow];
        self.currentChannelId = channelId;
        
        YYIMNetMeetingInviteConfirmViewController *netMeetingInviteConfirmViewController = [[YYIMNetMeetingInviteConfirmViewController alloc] init];
        netMeetingInviteConfirmViewController.channelId = channelId;
        self.delegate = netMeetingInviteConfirmViewController;
        
        self.netMeetingWindow.rootViewController = netMeetingInviteConfirmViewController;
    }
}

- (void)didNetMeetingAgree:(NSString *)channelId netMeetingType:(YYIMNetMeetingType)netMeetingType{
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notifyTimerChange) userInfo:nil repeats:YES];
    [self needShowFullScreenWindow];
    self.currentChannelId = channelId;
    [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE object:@YES];
    
    if (netMeetingType == kYYIMNetMeetingTypeLive) {
        // 进入会议页面
        YYIMNetMeetingAudienceViewController *netMeetingAudienceViewController = [[YYIMNetMeetingAudienceViewController alloc] initWithNibName:nil bundle:nil];
        // 设置频道号
        netMeetingAudienceViewController.channelId = channelId;
        self.delegate = netMeetingAudienceViewController;
        
        UINavigationController *netMeetingAudienceNavController = [YYIMUtility themeNavController:netMeetingAudienceViewController];
        self.netMeetingWindow.rootViewController = netMeetingAudienceNavController;
    } else if (netMeetingType == kYYIMNetMeetingTypeSingleChat) {
        //进入会议页面
        YYIMNetMeetingChatViewController *netMeetingChatViewController = [[YYIMNetMeetingChatViewController alloc] initWithNibName:nil bundle:nil];
        //设置频道号
        netMeetingChatViewController.channelId = channelId;
        self.delegate = netMeetingChatViewController;
        
        UINavigationController *netMeetingChatNavController = [YYIMUtility themeNavController:netMeetingChatViewController];
        self.netMeetingWindow.rootViewController = netMeetingChatNavController;
    } else {
        //进入会议页面
        YYIMNetMeetingConferenceViewController *netMeetingConferenceViewController = [[YYIMNetMeetingConferenceViewController alloc] initWithNibName:nil bundle:nil];
        //设置频道号
        netMeetingConferenceViewController.channelId = channelId;
        self.delegate = netMeetingConferenceViewController;
        
        UINavigationController *netMeetingConferenceNavController = [YYIMUtility themeNavController:netMeetingConferenceViewController];
        self.netMeetingWindow.rootViewController = netMeetingConferenceNavController;
    }
}

- (void)didNotStartReservationNetMeetingWithSeriId:(NSString *)seriId error:(YYIMError *)error {
    if ([seriId isEqualToString:self.createNetMeetingseriId]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window.rootViewController showHint:@"开始预约会议失败"];
    }
}

- (void)didStartReservationNetMeetingWithSeriId:(NSString *)seriId channelId:(NSString *)channelId {
    if ([seriId isEqualToString:self.createNetMeetingseriId]) {
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notifyTimerChange) userInfo:nil repeats:YES];
        [self needShowFullScreenWindow];
        self.currentChannelId = channelId;
        [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE object:@YES];
        
        YYNetMeeting *netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:channelId];
        
        if (netMeeting.netMeetingType == kYYIMNetMeetingTypeLive) {
            YYIMNetMeetingBroadcasterViewController *netMeetingBroadcasterViewController = [[YYIMNetMeetingBroadcasterViewController alloc] initWithNibName:nil bundle:nil];
            // 设置频道号
            netMeetingBroadcasterViewController.channelId = channelId;
            self.delegate = netMeetingBroadcasterViewController;
            
            UINavigationController *netMeetingBroadcasterNavController = [YYIMUtility themeNavController:netMeetingBroadcasterViewController];
            self.netMeetingWindow.rootViewController = netMeetingBroadcasterNavController;
        } else {
            // 进入会议页面
            YYIMNetMeetingConferenceViewController *netMeetingConferenceViewController = [[YYIMNetMeetingConferenceViewController alloc] initWithNibName:nil bundle:nil];
            // 设置频道号
            netMeetingConferenceViewController.channelId = channelId;
            self.delegate = netMeetingConferenceViewController;
            
            UINavigationController *netMeetingConferenceNavController = [YYIMUtility themeNavController:netMeetingConferenceViewController];
            self.netMeetingWindow.rootViewController = netMeetingConferenceNavController;
        }
    }
}

/**
 *  创建一个会议失败
 *
 *  @param seriId 请求id
 */
- (void)didNotNetMeetingCreateWithSeriId:(NSString *)seriId {
    if ([seriId isEqualToString:self.createNetMeetingseriId]) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        switch (self.createNetMeetingType) {
            case kYYIMNetMeetingTypeGroupChat:
            case kYYIMNetMeetingTypeMeeting:
                [appDelegate.window.rootViewController showHint:@"创建视频会议失败"];
                break;
            case kYYIMNetMeetingTypeLive:
                [appDelegate.window.rootViewController showHint:@"创建视频直播失败"];
                break;
            case kYYIMNetMeetingTypeSingleChat:
                if (self.createNetMeetingMode == kYYIMNetMeetingModeAudio) {
                    [appDelegate.window.rootViewController showHint:@"创建音频聊天失败"];
                } else {
                    [appDelegate.window.rootViewController showHint:@"创建视频聊天失败"];
                }
                break;
            default:
                break;
        }
    }
}

/**
 *  创建频道成功
 *
 *  @param seriId 请求id
 *  @param voipId 频道成员id
 */
- (void)didNetMeetingCreate:(NSString *)seriId channelId:(NSString *)channelId {
    if ([seriId isEqualToString:self.createNetMeetingseriId]) {
        YYNetMeeting *netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:channelId];
        self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notifyTimerChange) userInfo:nil repeats:YES];
        [self needShowFullScreenWindow];
        self.currentChannelId = channelId;
        [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE object:@YES];
        
        if (netMeeting.netMeetingType == kYYIMNetMeetingTypeLive) {
            YYIMNetMeetingBroadcasterViewController *netMeetingBroadcasterViewController = [[YYIMNetMeetingBroadcasterViewController alloc] initWithNibName:nil bundle:nil];
            // 设置频道号
            netMeetingBroadcasterViewController.channelId = channelId;
            self.delegate = netMeetingBroadcasterViewController;
            
            UINavigationController *netMeetingBroadcasterNavController = [YYIMUtility themeNavController:netMeetingBroadcasterViewController];
            self.netMeetingWindow.rootViewController = netMeetingBroadcasterNavController;
        } else if (netMeeting.netMeetingType == kYYIMNetMeetingTypeSingleChat) {
            //进入会议页面
            YYIMNetMeetingChatViewController *netMeetingChatViewController = [[YYIMNetMeetingChatViewController alloc] initWithNibName:nil bundle:nil];
            //设置频道号
            netMeetingChatViewController.channelId = channelId;
            self.delegate = netMeetingChatViewController;
            
            UINavigationController *netMeetingChatNavController = [YYIMUtility themeNavController:netMeetingChatViewController];
            self.netMeetingWindow.rootViewController = netMeetingChatNavController;
        } else {
            // 进入会议页面
            YYIMNetMeetingConferenceViewController *netMeetingConferenceViewController = [[YYIMNetMeetingConferenceViewController alloc] initWithNibName:nil bundle:nil];
            // 设置频道号
            netMeetingConferenceViewController.channelId = channelId;
            self.delegate = netMeetingConferenceViewController;
            
            UINavigationController *netMeetingConferenceNavController = [YYIMUtility themeNavController:netMeetingConferenceViewController];
            self.netMeetingWindow.rootViewController = netMeetingConferenceNavController;
        }
    }
}

/**
 *  加入会议失败
 */
- (void)didNotJoinNetMeeting:(NSString *)channelId error:(YYIMError *)error{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    YYNetMeeting *netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:channelId];
    NSString *type;
    
    switch (netMeeting.netMeetingType) {
        case kYYIMNetMeetingTypeGroupChat:
            type = @"视频聊天";
            break;
        case kYYIMNetMeetingTypeMeeting:
            type = @"视频会议";
            break;
        case kYYIMNetMeetingTypeLive:
            type = @"视频直播";
            break;
        default:
            break;
    }
    
    if (error && error.errorCode == YMERROR_CODE_NETMEETING_HAS_END) {
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"%@已经结束", type]];
    } else if (error && error.errorCode == YMERROR_CODE_NETMEETING_HAS_LOCK){
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"%@已锁定", type]];
    } else if (error && error.errorCode == YMERROR_CODE_NETMEETING_OVER_LIMIT_COUNT){
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"%@已达最大人数限制", type]];
    } else {
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"加入%@失败", type]];
    }
}

- (void)didNotAgreeNetMeeting:(NSString *)channelId error:(YYIMError *)error {
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    YYNetMeeting *netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:channelId];
    NSString *type;
    
    switch (netMeeting.netMeetingType) {
        case kYYIMNetMeetingTypeGroupChat:
            type = @"视频聊天";
            break;
        case kYYIMNetMeetingTypeMeeting:
            type = @"视频会议";
            break;
        case kYYIMNetMeetingTypeLive:
            type = @"视频直播";
            break;
        case kYYIMNetMeetingTypeSingleChat:
            if (netMeeting.netMeetingMode == kYYIMNetMeetingModeAudio) {
                type = @"语音聊天";
            } else {
                type = @"视频聊天";
            }
            break;
        default:
            break;
    }
    
    if (error && error.errorCode == YMERROR_CODE_NETMEETING_HAS_END) {
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"%@已经结束", type]];
    } else if (error && error.errorCode == YMERROR_CODE_NETMEETING_HAS_LOCK){
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"%@已锁定", type]];
    } else if (error && error.errorCode == YMERROR_CODE_NETMEETING_OVER_LIMIT_COUNT){
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"%@已达最大人数限制", type]];
    } else {
        [appDelegate.window.rootViewController showHint:[NSString stringWithFormat:@"加入%@失败", type]];
    } 
}


/**
 *  主动加入频道
 *
 *  @param channelId 频道id
 */
- (void)didNetMeetingJoin:(NSString *)channelId {
    YYNetMeeting *netMeeting = [[YYIMChat sharedInstance].chatManager getNetMeetingWithChannelId:channelId];
    self.currentChannelId = channelId;
    self.durationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(notifyTimerChange) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE object:@YES];
    
    switch (netMeeting.netMeetingType) {
        case kYYIMNetMeetingTypeGroupChat:
        case kYYIMNetMeetingTypeMeeting: {
            [self needShowFullScreenWindow];
            
            //进入会议页面
            YYIMNetMeetingConferenceViewController *netMeetingConferenceViewController = [[YYIMNetMeetingConferenceViewController alloc] initWithNibName:nil bundle:nil];
            //设置频道号
            netMeetingConferenceViewController.channelId = channelId;
            self.delegate = netMeetingConferenceViewController;
            
            UINavigationController *netMeetingConferenceNavController = [YYIMUtility themeNavController:netMeetingConferenceViewController];
            self.netMeetingWindow.rootViewController = netMeetingConferenceNavController;
            
            break;
        }
        case kYYIMNetMeetingTypeLive: {
            [self needShowFullScreenWindow];
            // 进入直播页面
            YYIMNetMeetingAudienceViewController *netMeetingAudienceViewController = [[YYIMNetMeetingAudienceViewController alloc] initWithNibName:nil bundle:nil];
            // 设置频道号
            netMeetingAudienceViewController.channelId = channelId;
            self.delegate = netMeetingAudienceViewController;

            UINavigationController *netMeetingAudienceNavController = [YYIMUtility themeNavController:netMeetingAudienceViewController];
             self.netMeetingWindow.rootViewController = netMeetingAudienceNavController;
            break;
        }
        default:
            break;
    }
}

/**
 *  会议被关闭
 */
- (void)didNetMeetingEndChannel:(NSString *)channelId {
    if ([self.currentChannelId isEqualToString:channelId]) {
        [self didNetMeetingDispatchNeedClose];
    }
}

#pragma mark -
#pragma mark public method

- (void)startReservationNetMeeting:(NSString *)channelId {
    self.createNetMeetingseriId = [[YYIMChat sharedInstance].chatManager startReservationNetMeeting:channelId];
}

- (void)createNetMeetingWithNetMeetingType:(YYIMNetMeetingType)netMeetingType netMeetingMode:(YYIMNetMeetingMode)netMeetingMode invitees:(NSArray *)invitees topic:(NSString *)topic {
    self.createNetMeetingType = netMeetingType;
    self.createNetMeetingMode = netMeetingMode;
    
    self.createNetMeetingseriId = [[YYIMChat sharedInstance].chatManager createNetMeetingWithNetMeetingType:netMeetingType netMeetingMode:netMeetingMode invitees:invitees topic:topic];
}

- (void)showNetMeetingInviteConfirmView:(NSString *) channelId {
    [self needShowFullScreenWindow];
    
    self.currentChannelId = channelId;
    YYIMNetMeetingInviteConfirmViewController *netMeetingInviteConfirmViewController = [[YYIMNetMeetingInviteConfirmViewController alloc] initWithNibName:nil bundle:nil];
    netMeetingInviteConfirmViewController.channelId = channelId;
    self.delegate = netMeetingInviteConfirmViewController;
    
    self.netMeetingWindow.rootViewController = netMeetingInviteConfirmViewController;
}

#pragma mark -
#pragma mark UITapGestureRecognizer
- (void)clickWindow:(UITapGestureRecognizer*)gestureRecognizer {
    [self needShowFullScreenWindow];
    
    [self.netMeetingWindow removeGestureRecognizer:self.reFullGestureRecognizer];
    [self.netMeetingWindow removeGestureRecognizer:self.moveGestureRecognizer];
    self.netMeetingWindow.rootViewController = self.zoomNetMeetingViewController;
}

#pragma mark -
#pragma mark private method

- (void)needShowFullScreenWindow {
    //需要取消主页面的键盘弹出
   [[UIApplication sharedApplication].keyWindow endEditing:YES];
    
    if (self.minimizeView) {
        [self.minimizeView removeFromSuperview];
        self.minimizeView = nil;
        self.windowUser = nil;
    }
    
    self.netMeetingWindow.windowLevel = UIWindowLevelNormal;
    [self.netMeetingWindow setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), CGRectGetHeight([UIScreen mainScreen].bounds))];
    [self.netMeetingWindow makeKeyAndVisible];
    self.netMeetingVisible = YES;
}

//改变位置
-(void)locationChange:(UIPanGestureRecognizer*)p {
    //[[UIApplication sharedApplication] keyWindow]
    CGPoint panPoint = [p locationInView:[[UIApplication sharedApplication] keyWindow]];
    
    if (p.state == UIGestureRecognizerStateBegan) {
    } else if (p.state == UIGestureRecognizerStateEnded) {
    }
    
    if (p.state == UIGestureRecognizerStateChanged) {
        self.netMeetingWindow.center = CGPointMake(panPoint.x, panPoint.y);
    }
    else if(p.state == UIGestureRecognizerStateEnded) {
        CGFloat resulty = panPoint.y;
        //上面越界需要收回
        if (panPoint.y < 10 + CGRectGetHeight(self.netMeetingWindow.frame)/2) {
            resulty = 10 + CGRectGetHeight(self.netMeetingWindow.frame)/2;
        }
        //下面越界需要收回
        if (panPoint.y > kScreenHeight - 10 - CGRectGetHeight(self.netMeetingWindow.frame)/2) {
            resulty = kScreenHeight - 10 - CGRectGetHeight(self.netMeetingWindow.frame)/2;
        }

        
        if (panPoint.x <= kScreenWidth/2) {
            [UIView animateWithDuration:0.2 animations:^{
                self.netMeetingWindow.center = CGPointMake(10 + CGRectGetWidth(self.netMeetingWindow.frame)/2, resulty);
            }];
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                self.netMeetingWindow.center = CGPointMake(kScreenWidth - 10 - CGRectGetWidth(self.netMeetingWindow.frame)/2, resulty);
            }];
        }
    }
}

- (void)notifyTimerChange {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didNetMeetingTimerChange)]) {
        [self.delegate didNetMeetingTimerChange];
    }
}

@end
