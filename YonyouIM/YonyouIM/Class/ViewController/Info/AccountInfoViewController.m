//
//  AccountInfoViewController.m
//  YonyouIM
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "AccountInfoViewController.h"
#import "PubAccountViewController.h"
#import "YYIMUtility.h"
#import "UserCollectionViewCell.h"
#import "InviteViewController.h"
#import "UserViewController.h"
#import "SingleLineCell2.h"

@interface AccountInfoViewController ()<UIActionSheetDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *unFollowBtn;

@property (retain, nonatomic) YYPubAccount *account;
@property (retain, nonatomic) YYPubAccountExt *accountExt;

- (IBAction)unFollowAction:(id)sender;

@end

@implementation AccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)unFollowAction:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"取消关注后，您将不再接收此公共号消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
}

#pragma mark table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell2";
    SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell.switchControl setTag:0];
    [cell setNameLabelWidth:120];
    
    switch (indexPath.row) {
        case 0:
            [cell setName:@"置顶聊天"];
            [cell setSwitchState:[self.accountExt stickTop]];
            [cell.switchControl setTag:1];
            break;
        case 1:
            [cell setName:@"消息免打扰"];
            [cell setSwitchState:[self.accountExt noDisturb]];
            [cell.switchControl setTag:2];
            break;
        case 2:
            [cell setName:@"清空聊天记录"];
            break;
        default:
            break;
    }
    [cell.switchControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 2: {
            UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"清空聊天记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
            actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
            [actionSheet showInView:self.view];
            break;
        }
        default:
            break;
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark switch target

- (void)didSwitch:(UISwitch *)switchControl {
    switch ([switchControl tag]) {
        case 1:
            [[YYIMChat sharedInstance].chatManager updatePubAccountStickTop:[switchControl isOn] accountId:self.accountId];
            break;
        case 2:
            [[YYIMChat sharedInstance].chatManager updatePubAccountNoDisturb:[switchControl isOn] accountId:self.accountId];
            break;
        default:
            break;
    }
}

#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1: {
            [[YYIMChat sharedInstance].chatManager unFollowPubAccount:self.accountId];
            PubAccountViewController *pubAccountViewController;
            NSArray *viewControllers = [self.navigationController viewControllers];
            for (UIViewController *vc in viewControllers) {
                if ([vc isKindOfClass:[PubAccountViewController class]]) {
                    pubAccountViewController = (PubAccountViewController *)vc;
                    break;
                }
            }
            if (pubAccountViewController) {
                [self.navigationController popToViewController:pubAccountViewController animated:YES];
            } else {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[YYIMChat sharedInstance].chatManager deleteMessageWithId:self.accountId];
            break;
        default:
            break;
    }
}

#pragma marn YYIMChatDelegate

- (void)didPubAccountExtUpdate:(YYPubAccountExt *)accountExt {
    if ([[accountExt accountId] isEqualToString:self.accountId]) {
        self.accountExt = accountExt;
        [self.tableView reloadData];
    }
}

- (void)didNotUpdatePubAccountStickTop:(NSString *)accountId error:(YYIMError *)error {
    if ([accountId isEqualToString:self.accountId]) {
        NSLog(@"设置公共号置顶失败:%ld,%@", (long)[error errorCode], [error errorMsg]);
        [self.tableView reloadData];
    }
}

- (void)didNotUpdatePubAccountNoDisturb:(NSString *)accountId error:(YYIMError *)error {
    if ([accountId isEqualToString:self.accountId]) {
        NSLog(@"设置公共号免打扰失败:%ld,%@", (long)[error errorCode], [error errorMsg]);
        [self.tableView reloadData];
    }
}

#pragma mark util

- (void)reloadData {
    self.account = [[YYIMChat sharedInstance].chatManager getPubAccountWithAccountId:self.accountId];
    self.accountExt = [[YYIMChat sharedInstance].chatManager getPubAccountExtWithId:self.accountId];
    
    [self.tableView reloadData];
    
    if (self.account) {
        self.title = [self.account accountName];
    } else {
        self.title = @"公共号设置";
    }
    
    if ([self.account accountType] == YYIM_ACCOUNT_TYPE_SUBSCRIBE) {
        [self.unFollowBtn setHidden:NO];
    } else {
        [self.unFollowBtn setHidden:YES];
    }
}

@end
