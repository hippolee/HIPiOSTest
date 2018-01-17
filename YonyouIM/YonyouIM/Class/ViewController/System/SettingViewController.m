//
//  SettingViewController.m
//  YonyouIM
//
//  Created by litfb on 15/5/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "SettingViewController.h"
#import "SingleLineCell2.h"
#import "YYIMChatHeader.h"
#import "YYIMUtility.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "AboutViewController.h"
#import "PwdViewController.h"

@interface SettingViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) YYSettings *settings;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    self.settings = [[YYIMChat sharedInstance].chatManager getSettings];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark tableview delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 4;
        case 2:
            return 1;
        case 3:
            return 1;
        default:
            return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 16;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
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
    static NSString *CellIndentifier = @"SingleLineCell2";
    SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell.switchControl setTag:0];
    
    switch (indexPath.section) {
        case 0:
            [cell setNameLabelWidth:140];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setName:@"修改密码"];
            break;
        case 1:
            [cell setNameLabelWidth:140];
            switch (indexPath.row) {
                case 0:
                    [cell setName:@"新消息提醒"];
                    [cell setSwitchState:[self.settings newMsgRemind]];
                    [cell.switchControl setTag:1];
                    break;
                case 1:
                    [cell setName:@"铃声"];
                    [cell setSwitchState:[self.settings playSound]];
                    [cell.switchControl setTag:2];
                    break;
                case 2:
                    [cell setName:@"振动"];
                    [cell setSwitchState:[self.settings playVibrate]];
                    [cell.switchControl setTag:3];
                    break;
                case 3:
                    [cell setName:@"显示新消息详情"];
                    [cell setSwitchState:[self.settings showDetail]];
                    [cell.switchControl setTag:4];
                    break;
                default:
                    break;
            }
            [cell.switchControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
            break;
        case 2:
            [cell setNameLabelWidth:140];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setName:@"关于用友IM"];
            break;
        case 3:
            [cell setNameLabelWidth:CGRectGetWidth(self.view.frame) - 32];
            [cell setName:@"退出"];
            [cell.nameLabel setTextAlignment:NSTextAlignmentCenter];
            break;
        default:
            break;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            PwdViewController *pwdViewController = [[PwdViewController alloc] initWithNibName:@"PwdViewController" bundle:nil];
            [self.navigationController pushViewController:pwdViewController animated:YES];
            break;
        }
        case 2: {
            AboutViewController *aboutViewController = [[AboutViewController alloc] initWithNibName:@"AboutViewController" bundle:nil];
            [self.navigationController pushViewController:aboutViewController animated:YES];
            break;
        }
        case 3:
            [[YYIMChat sharedInstance].chatManager logoff];
            [[UIApplication sharedApplication] cancelAllLocalNotifications];
            [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:YYIM_NOTIFICATION_LOGINCHANGE object:@NO];
            break;
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark switch target

- (void)didSwitch:(UISwitch *)switchControl {
    switch ([switchControl tag]) {
        case 1:
            [self.settings setNewMsgRemind:[switchControl isOn]];
            [[YYIMChat sharedInstance].chatManager updateSettings:self.settings];
            break;
        case 2:
            [self.settings setPlaySound:[switchControl isOn]];
            [[YYIMChat sharedInstance].chatManager updateSettings:self.settings];
            break;
        case 3:
            [self.settings setPlayVibrate:[switchControl isOn]];
            [[YYIMChat sharedInstance].chatManager updateSettings:self.settings];
            break;
        case 4:
            [self.settings setShowDetail:[switchControl isOn]];
            [[YYIMChat sharedInstance].chatManager updateSettings:self.settings];
            break;
        default:
            break;
    }
}

#pragma mark yyimchat delegate

- (void)didSettingUpdate:(YYSettings *)settings {
    self.settings = settings;
    [self.tableView reloadData];
}

@end
