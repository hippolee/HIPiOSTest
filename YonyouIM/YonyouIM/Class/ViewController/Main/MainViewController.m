//
//  MainViewController.m
//  YonyouIM
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "MainViewController.h"
#import "YYIMChatHeader.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "YYIMColorHelper.h"
#import "UIColor+YYIMTheme.h"
#import "RecentViewController.h"
#import "RecentRosterViewController.h"
#import "MeViewController.h"
#import "SDImageCache.h"
#import <PgyUpdate/PgyUpdateManager.h>

@interface MainViewController()<YYIMChatDelegate>

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册委托
    [[YYIMChat sharedInstance].chatManager addDelegate:self];
    // 清除返回按钮文字
    [YYIMUtility clearBackButtonText:self];
    // ios7+适配
    [YYIMUtility adapterIOS7ViewController:self];
    
    [self setupSubviews];
    
    // 右侧navItem
    self.navigationItem.rightBarButtonItem = [self.recentViewController rightBarButtonItem];
    
    [[PgyUpdateManager sharedPgyManager] checkUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetTitle];
    [self resetRecentBudget];
    [self resetRosterBudget];
}

- (void)setupSubviews {
    [self addChildViewController:self.recentViewController];
    [self addChildViewController:self.recentRosterViewController];
    [self addChildViewController:self.meViewController];
    if (YYIM_iOS7) {
        [self.tabBar setBarTintColor:UIColorFromRGB(0xf7f7f7)];
    }
    [self.tabBar setTintColor:UIColorFromRGB(0xf7f7f7)];
    [self.tabBar setShadowImage:[YYIMUtility imageWithColor:[UIColor clearColor]]];
}

#pragma mark UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    switch (item.tag) {
        case 1:
            [self resetTitle];
            self.navigationItem.rightBarButtonItem = [self.recentViewController rightBarButtonItem];
            break;
        case 2:
            self.title = @"联系人";
            self.navigationItem.rightBarButtonItem = [self.recentRosterViewController rightBarButtonItem];
            break;
        case 3:
            self.title = @"我";
            self.navigationItem.rightBarButtonItem = [self.meViewController rightBarButtonItem];
            break;
        default:
            break;
    }
}

#pragma mark yyimchat delegate

- (void)didReceiveMessage:(YYMessage *)message {
    [self resetRecentBudget];
    [self resetMeBudget];
}

- (void)didReceiveOfflineMessages {
    [self resetRecentBudget];
    [self resetMeBudget];
}

- (void)didMessageStateChange:(YYMessage *)message {
    [self resetRecentBudget];
    [self resetMeBudget];
}

- (void)didMessageStateChangeWithChatId:(NSString *)chatId {
    [self resetRecentBudget];
    [self resetMeBudget];
}

- (void)didMessageDelete:(NSDictionary *)info {
    [self resetRecentBudget];
    [self resetMeBudget];
}

- (void)didRosterChange {
    [self resetRosterBudget];
}

- (void)didChatGroupInfoUpdate:(YYChatGroup *)group {
    [[SDImageCache sharedImageCache] removeImageForKey:[group groupId]];
}

- (void)willConnect {
    if ([self selectedIndex] == 0) {
        self.title = @"消息(连接中...)";
    }
}

- (void)didAuthenticate {
    if ([self selectedIndex] == 0) {
        self.title = @"消息";
    }
}

- (void)didDisconnect {
    if ([self selectedIndex] == 0) {
        self.title = @"消息(未连接)";
    }
}

- (void)resetTitle {
    YYIMConnectState connectState = [[YYIMChat sharedInstance].chatManager connectState];
    switch (connectState) {
        case kYYIMConnectStateDisconnect:
            self.title = @"消息(未连接)";
            break;
        case kYYIMConnectStateConnecting:
            self.title = @"消息(连接中...)";
            break;
        default:
            self.title = @"消息";
            break;
    }
}

#pragma mark private func

- (void)resetRecentBudget {
    NSInteger unreadMsgCount = [[YYIMChat sharedInstance].chatManager getUnreadMsgCount];
    if (unreadMsgCount > 0) {
        if (unreadMsgCount > 99) {
            [[[self recentViewController] tabBarItem] setBadgeValue:@"..."];
        } else {
            [[[self recentViewController] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)unreadMsgCount]];
        }
    } else {
        [[[self recentViewController] tabBarItem] setBadgeValue:nil];
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadMsgCount];
}

- (void)resetRosterBudget {
    NSInteger newRosterInviteCount = [[YYIMChat sharedInstance].chatManager getNewRosterInviteCount];
    if (newRosterInviteCount > 0) {
        if (newRosterInviteCount > 99) {
            [[[self recentRosterViewController] tabBarItem] setBadgeValue:@"..."];
        } else {
            [[[self recentRosterViewController] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)newRosterInviteCount]];
        }
    } else {
        [[[self recentRosterViewController] tabBarItem] setBadgeValue:nil];
    }
}

- (void)resetMeBudget {
    NSInteger unreadMsgCount = [[YYIMChat sharedInstance].chatManager getUnreadMsgCountMyOtherClient];
    if (unreadMsgCount > 0) {
        if (unreadMsgCount > 99) {
            [[[self meViewController] tabBarItem] setBadgeValue:@"..."];
        } else {
            [[[self meViewController] tabBarItem] setBadgeValue:[NSString stringWithFormat:@"%ld", (long)unreadMsgCount]];
        }
    } else {
        [[[self meViewController] tabBarItem] setBadgeValue:nil];
    }
}

- (RecentViewController *)recentViewController {
    if (!_recentViewController) {
        // 消息
        RecentViewController *recentViewController = [[RecentViewController alloc] initWithNibName:@"RecentViewController" bundle:nil];
        UITabBarItem *item = [YYIMUtility tabBarItemWithTitle:@"消息" image:[UIImage imageNamed:@"main_recent"] selectedImage:[UIImage imageNamed:@"main_recent_hl"] tag:1];
        [recentViewController setTabBarItem:item];
        
        _recentViewController = recentViewController;
    }
    return _recentViewController;
}

- (RecentRosterViewController *)recentRosterViewController {
    if (!_recentRosterViewController) {
        // 联系人
        RecentRosterViewController *recentRosterViewController = [[RecentRosterViewController alloc] initWithNibName:@"RecentRosterViewController" bundle:nil];
        UITabBarItem *item = [YYIMUtility tabBarItemWithTitle:@"联系人" image:[UIImage imageNamed:@"main_roster"] selectedImage:[UIImage imageNamed:@"main_roster_hl"] tag:2];
        [recentRosterViewController setTabBarItem:item];
        
        _recentRosterViewController = recentRosterViewController;
    }
    return _recentRosterViewController;
}

- (MeViewController *)meViewController {
    if (!_meViewController) {
        // 我
        MeViewController *meViewController = [[MeViewController alloc] initWithNibName:@"MeViewController" bundle:nil];
        UITabBarItem *item = [YYIMUtility tabBarItemWithTitle:@"我" image:[UIImage imageNamed:@"main_me"] selectedImage:[UIImage imageNamed:@"main_me_hl"] tag:3];
        [meViewController setTabBarItem:item];
        
        _meViewController = meViewController;
    }
    return _meViewController;
}

#pragma mark UIResponder bubble

- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo {
    NSInteger type = [[userInfo objectForKey:kYMSearchPressedType] intValue];
    NSInteger index = [[userInfo objectForKey:kYMSearchPressedIndex] intValue];
    
    [self.recentViewController responseCellClick:type index:index];
}

@end
