//
//  MeViewController.m
//  YonyouIM
//
//  Created by litfb on 14/12/18.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "MeViewController.h"

#import "UIViewController+HUDCategory.h"
#import "SingleLineCell.h"
#import "YYIMUIDefs.h"
#import "ChatViewController.h"
#import "YYIMUtility.h"
#import "UserSettingViewController.h"
#import "SettingViewController.h"
#import "YYIMColorHelper.h"
#import "MyNetMeetingViewController.h"

@interface MeViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) YYUser *user;

@property NSInteger unreadMsgCountMyOtherClient;

@end

@implementation MeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 加载数据
    self.user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
    self.unreadMsgCountMyOtherClient = [[YYIMChat sharedInstance].chatManager getUnreadMsgCountMyOtherClient];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 78;
        case 1:
            return 48;
        case 2:
            return 48;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        case 2:
            return 1;
        default:
            return 0;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 16)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    if (section > 0) {
        UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
        [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        [sectionView addSubview:sepView];
    }
    UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 16, tableView.bounds.size.width, 0.5)];
    [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView2];
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell";
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    [cell reuse];
    switch (indexPath.section) {
        case 0:
            // 为cell设置数据
            if (self.user) {
                [cell setHeadImageWithUrl:[self.user getUserPhoto] placeholderName:[self.user userName]];
                [cell setName:[self.user userName]];
            } else {
                [cell setHeadIcon:@"icon_head"];
                [cell setName:[[YYIMConfig sharedInstance] getUser]];
            }
            [cell setImageRadius:31];
            break;
        case 1:
            [cell setLabelFont:[UIFont systemFontOfSize:14]];
            switch (indexPath.row) {
                case 0:
                    [cell setHeadIcon:@"icon_mynetmeeting"];
                    [cell setName:@"我的会议"];
                    break;
                case 1:
                    [cell setHeadIcon:@"icon_computer"];
                    [cell setName:@"我的电脑"];
                    if (self.unreadMsgCountMyOtherClient > 99) {
                        [cell setBadge:@"..."];
                    } else if (self.unreadMsgCountMyOtherClient > 0) {
                        [cell setBadge:[NSString stringWithFormat:@"%ld", (long)self.unreadMsgCountMyOtherClient]];
                    } else {
                        [cell setBadge:nil];
                    }
                    break;
                default:
                    break;
            }
            [cell setImageRadius:0];
            break;
        case 2:
            [cell setLabelFont:[UIFont systemFontOfSize:14]];
            // 为cell设置数据
            switch (indexPath.row) {
                case 0:
                    [cell setHeadIcon:@"icon_setting"];
                    [cell setName:@"设置"];
                    break;
                default:
                    break;
            }
            [cell setImageRadius:0];
            break;
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            UserSettingViewController *userSettingViewController = [[UserSettingViewController alloc] initWithNibName:@"UserSettingViewController" bundle:nil];
            [self.navigationController pushViewController:userSettingViewController animated:YES];
            break;
        }
        case 1:
            switch (indexPath.row) {
                case 0:
                    [self openMyNetMeeting];
                    break;
                case 1:
                    [self openMyChat];
                    break;
                default:
                    break;
            }
            break;
        case 2: {
            SettingViewController *settingViewController = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
            [self.navigationController pushViewController:settingViewController animated:YES];
            break;
        }
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)openMyNetMeeting {
    MyNetMeetingViewController *myNetMeetingViewController = [[MyNetMeetingViewController alloc] initWithNibName:@"MyNetMeetingViewController" bundle:nil];
    [self.navigationController pushViewController:myNetMeetingViewController animated:YES];
}

- (void)openMyChat {
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    chatViewController.chatId = [[YYIMConfig sharedInstance] getUser];
    chatViewController.chatType = YM_MESSAGE_TYPE_CHAT;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

#pragma mark chatdelegate

- (void)didUserInfoUpdate:(YYUser *)user {
    if ([[user userId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        self.user = user;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMessage:(YYMessage *)message {
    [self resetUnreadCount];
}

- (void)didMessageStateChange:(YYMessage *)message {
    [self resetUnreadCount];
}

- (void)didMessageStateChangeWithChatId:(NSString *)chatId {
    [self resetUnreadCount];
}

- (void)didMessageDelete:(NSDictionary *)info {
    [self resetUnreadCount];
}

- (void)resetUnreadCount {
    self.unreadMsgCountMyOtherClient = [[YYIMChat sharedInstance].chatManager getUnreadMsgCountMyOtherClient];
    [self.tableView reloadData];
}

@end
