//
//  YYIMNotificationManager.m
//  YonyouIMSdk
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMNotificationManager.h"
#import "YYIMConfig.h"
#import "YYUserExt.h"
#import "YYChatGroupExt.h"
#import "YYPubAccountExt.h"
#import "YYIMDBHelper.h"
#import "YYIMChat.h"
#import "YYIMStringUtility.h"
#import "JUMPTimer.h"
#import "YMGCDMulticastDelegate.h"
#import "YYIMChatDelegate.h"
#import "YYIMConfig.h"

//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;

@interface YYIMNotificationManager ()

@property BOOL enabelNotification;

@property (retain, nonatomic) id<YYIMNotificationDelegate> notificationDelegate;

@property (retain, nonatomic) NSDate *lastPlaySoundDate;

@property (retain, nonatomic) JUMPTimer *timer;

@property BOOL idChatGroupInfoUpdate;
@property BOOL isUserInfoUpdate;
@property BOOL isChatGroupMemberUpdate;
@property BOOL isReceiveOfflineMessage;

@end

@implementation YYIMNotificationManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (void)startLazyNotify {
    if (self.timer) {
        [self.timer cancel];
        self.timer = nil;
    }
    self.timer = [[JUMPTimer alloc] initWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) eventHandler:^{
        [self notifyLazyDelegate];
    }];
    [[self timer] startWithTimeout:0 interval:0.5];
}

- (void)stopLazyNotify {
    [[self timer] cancel];
    self.timer = nil;
}

- (void)setEnableLocalNotification:(BOOL)enable {
    self.enabelNotification = enable;
}

- (YYSettings *)getSettings {
    return [[YYIMConfig sharedInstance] getSettings];
}

- (void)updateSettings:(YYSettings *)settings {
    [[YYIMConfig sharedInstance] setSettings:settings];
    [self.notificationDelegate didSettingUpdate:settings];
}

- (void)registerNotificationDelegate:(id<YYIMNotificationDelegate>) delegate {
    self.notificationDelegate = delegate;
}

- (void)didReceiveOfflineMessage {
    self.isReceiveOfflineMessage = YES;
}

- (void)didReceiveMessage:(YYMessage *)message {
    if (!message) {
        return;
    }
    if ([message type] == YM_MESSAGE_CONTENT_PROMPT) {
        return;
    }
    
    YYSettings *settings = [self getSettings];
    if (![self noDisturb:message] && [settings newMsgRemind]) {
        // isAppActivity
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
            if (!self.lastPlaySoundDate || timeInterval > kDefaultPlaySoundInterval) {
                if ([settings playSound]) {
                    [self playSound];
                }
                
                if ([settings playVibrate]) {
                    [self playVibrate];
                }
                // 保存最后一次响铃时间
                self.lastPlaySoundDate = [NSDate date];
            }
        } else {
            if (self.enabelNotification) {
                [self showNotificationWithMessage:message showDetail:[settings showDetail]];
            }
        }
    }
}

- (BOOL)noDisturb:(YYMessage *)message {
    BOOL noDisturb = NO;
    if ([YM_MESSAGE_TYPE_CHAT isEqualToString:[message chatType]]) {
        YYUserExt *userExt = [[YYIMDBHelper sharedInstance] getUserExtWithId:[message fromId]];
        noDisturb = [userExt noDisturb];
    } else if ([YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:[message chatType]]) {
        YYChatGroupExt *groupExt = [[YYIMDBHelper sharedInstance] getChatGroupExtWithId:[message fromId]];
        noDisturb = [groupExt noDisturb];
    } else if ([YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:[message chatType]]) {
        YYPubAccountExt *accountExt = [[YYIMDBHelper sharedInstance] getPubAccountExtWithId:[message fromId]];
        noDisturb = [accountExt noDisturb];
    }
    if (noDisturb) {
        return YES;
    }
    return NO;
}

- (void)showNotificationWithMessage:(YYMessage *)message showDetail:(BOOL)showDetail {
    // 发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 触发通知的时间
    notification.fireDate = [NSDate date];
    if ([[self getSettings] playSound]) {
        notification.soundName = @"sms-received1.wav";
    }
    notification.alertAction = @"打开";
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *extendValue = [[message getMessageContent] extendValue];
    
    if (extendValue) {
        [dic setObject:extendValue forKey:@"yyim_extend"];
    }
    
    [dic setObject:@"message" forKey:@"yyim_notification_type"];
    [dic setObject:[message fromId] forKey:@"yyim_from"];
    [dic setObject:[message chatType] forKey:@"yyim_chattype"];
    [dic setObject:[message pid] forKey:@"yyim_msgid"];
    [dic setObject:[NSNumber numberWithInteger:[message type]] forKey:@"yyim_contenttype"];
    notification.userInfo = dic;
    if (showDetail) {
        if (self.notificationDelegate && [self.notificationDelegate respondsToSelector:@selector(notificationWithDetail:complete:)]) {
            [self.notificationDelegate notificationWithDetail:message complete:^(BOOL result, NSString *notificationBody) {
                if (result && ![YYIMStringUtility isEmpty:notificationBody]) {
                    notification.alertBody = notificationBody;
                    // 发送通知
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
            }];
        } else {
            NSString *notificationBody = [self defaultNotificationBodyWithDetail:message];
            if (![YYIMStringUtility isEmpty:notificationBody]) {
                notification.alertBody = notificationBody;
                // 发送通知
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    } else {
        if (self.notificationDelegate && [self.notificationDelegate respondsToSelector:@selector(notificationNoDetail:complete:)]) {
            [self.notificationDelegate notificationNoDetail:message complete:^(BOOL result, NSString *notificationBody) {
                if (result && ![YYIMStringUtility isEmpty:notificationBody]) {
                    notification.alertBody = notificationBody;
                    // 发送通知
                    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                }
            }];
        } else {
            notification.alertBody = @"您收到了一条新消息";
            // 发送通知
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
}

- (NSString *)defaultNotificationBodyWithDetail:(YYMessage *)message {
    NSString *notificationBody;
    
    if ([message isSystemMessage]) {
        return @"您收到了一条系统消息";
    }
    
    NSString *fromName;
    if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT]) {
        YYPubAccount *account = [[YYIMChat sharedInstance].chatManager getPubAccountWithAccountId:[message fromId]];
        if (account) {
            fromName = [account accountName];
        }
    } else {
        if ([[message chatType] isEqualToString:YM_MESSAGE_TYPE_CHAT]) {
            YYRoster *roster = [[YYIMChat sharedInstance].chatManager getRosterWithId:[message rosterId]];
            if (roster) {
                fromName = [roster rosterAlias];
            }
        }
        
        if ([YYIMStringUtility isEmpty:fromName]) {
            YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:[message rosterId]];
            if (user) {
                fromName = [user userName];
            }
        }
    }
    if ([YYIMStringUtility isEmpty:fromName]) {
        return @"您收到了一条新消息";
    }
    
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_TEXT:
        case YM_MESSAGE_CONTENT_CUSTOM: {
            NSString *messageStr = [[message getMessageContent] message];
            if (![YYIMStringUtility isEmpty:messageStr]) {
                notificationBody = [NSString stringWithFormat:@"%@:%@", fromName, messageStr];
            } else {
                notificationBody = [NSString stringWithFormat:@"%@发来一个消息", fromName];
            }
            break;
        }
        case YM_MESSAGE_CONTENT_NETMEETING: {
            YYNetMeetingContent *netMeeting = [[message getMessageContent] netMeetingContent];
            notificationBody = [NSString stringWithFormat:@"%@:%@", fromName, [netMeeting getSimpleMessage]];
            break;
        }
        case YM_MESSAGE_CONTENT_IMAGE:
            notificationBody = [NSString stringWithFormat:@"%@发来一个图片", fromName];
            break;
        case YM_MESSAGE_CONTENT_MICROVIDEO:
            notificationBody = [NSString stringWithFormat:@"%@发来一个小视频", fromName];
            break;
        case YM_MESSAGE_CONTENT_AUDIO:
            notificationBody = [NSString stringWithFormat:@"%@发来一段语音", fromName];
            break;
        case YM_MESSAGE_CONTENT_FILE:
            notificationBody = [NSString stringWithFormat:@"%@发来一个文件", fromName];
            break;
        case YM_MESSAGE_CONTENT_LOCATION:
            notificationBody = [NSString stringWithFormat:@"%@发来一个位置", fromName];
            break;
        case YM_MESSAGE_CONTENT_SINGLE_MIXED:
        case YM_MESSAGE_CONTENT_BATCH_MIXED:
            notificationBody = [NSString stringWithFormat:@"%@发来一个图文消息", fromName];
            break;
        case YM_MESSAGE_CONTENT_SHARE:
            notificationBody = [NSString stringWithFormat:@"%@发来一个链接", fromName];
            break;
        default:
            notificationBody = [NSString stringWithFormat:@"%@发来一个消息", fromName];
            break;
    }
    return notificationBody;
}

#pragma mark lazy notify

- (void)didChatGroupInfoUpdate:(YYChatGroup *)group {
    self.idChatGroupInfoUpdate = YES;
}

- (void)didChatGroupMemberUpdate:(NSString *)groupId {
    self.isChatGroupMemberUpdate = YES;
}

- (void)didUserInfoUpdate:(YYUser *)user {
    self.isUserInfoUpdate = YES;
}

- (void)notifyLazyDelegate {
    if (self.idChatGroupInfoUpdate) {
        self.idChatGroupInfoUpdate = NO;
        [[self activeDelegate] didChatGroupInfoUpdate];
    }
    if (self.isChatGroupMemberUpdate) {
        self.isChatGroupMemberUpdate = NO;
        [[self activeDelegate] didChatGroupMemberUpdate];
    }
    if (self.isUserInfoUpdate) {
        self.isUserInfoUpdate = NO;
        [[self activeDelegate] didUserInfoUpdate];
    }
    if (self.isReceiveOfflineMessage) {
        self.isReceiveOfflineMessage = NO;
        [[self activeDelegate] didReceiveOfflineMessages];
    }
}

@end
