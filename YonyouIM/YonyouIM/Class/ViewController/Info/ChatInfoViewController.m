//
//  ChatInfoViewController.m
//  YonyouIM
//
//  Created by litfb on 15/4/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatInfoViewController.h"
#import "YYIMUtility.h"
#import "UserCollectionViewCell.h"
#import "UserViewController.h"
#import "SingleLineCell2.h"
#import "GlobalInviteViewController.h"
#import "ChatViewController.h"
#import "UIViewController+HUDCategory.h"
#import "UINavigationController+YMInvite.h"

const CGFloat kYMChatInfoCellWidth = 60.0f;

@interface ChatInfoViewController ()<UIActionSheetDelegate, GlobalInviteViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionFlowLayout;

@property (retain, nonatomic) YYUser *user;
@property (retain, nonatomic) YYUserExt *userExt;

@property (retain, nonatomic) YYRoster *roster;

@property (nonatomic) NSInteger cellNumberPerRow;

/**
 *  当前正在创建群组的视图
 */
@property (retain, nonatomic) UIViewController *createViewController;

/**
 * 群组序列表
 */
@property (retain, nonatomic) NSString *seriChatGroupId;

@end

@implementation ChatInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    
    // 注册Cell nib
    [self.collectionView registerNib:[UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
    
    [self initLayoutAttribute];
    
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldKeepDelegate {
    return YES;
}

#pragma mark -
#pragma mark collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // cell
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    [cell setRoundCorner:(kYMChatInfoCellWidth - 20) / 2 - 1];
    
    if (indexPath.row == 1) {
        [cell setHeadIcon:@"icon_addmember"];
        [cell setName:@"转为群聊"];
    } else {
        if (self.roster) {
            [cell setHeadImageWithUrl:[self.user getUserPhoto] placeholderName:[self.roster rosterAlias]];
            [cell setName:[self.roster rosterAlias]];
        } else {
            [cell setHeadImageWithUrl:[self.user getUserPhoto] placeholderName:[self.user userName]];
            [cell setName:[self.user userName]];
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        GlobalInviteViewController *globalInviteViewController = [[GlobalInviteViewController alloc] initWithNibName:@"GlobalInviteViewController" bundle:nil];
        
        globalInviteViewController.userId = self.userId;
        globalInviteViewController.delegate = self;
        globalInviteViewController.actionName = @"创建群组";
        globalInviteViewController.defaultCount = 1;
        
        [self.navigationController pushViewController:globalInviteViewController animated:YES];
    } else {
        UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
        userViewController.userId = self.userId;
        [self.navigationController pushViewController:userViewController animated:YES];
    }
}

#pragma mark -
#pragma mark table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.roster) {
        return 4;
    }
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell2";
    SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell.switchControl setTag:0];
    [cell setNameLabelWidth:120];
    
    if (self.roster) {
        switch (indexPath.row) {
            case 0:
                [cell setName:@"备注名"];
                [cell setDetail:[self.roster rosterAlias]];
                break;
            case 1:
                [cell setName:@"置顶聊天"];
                [cell setSwitchState:[self.userExt stickTop]];
                [cell.switchControl setTag:1];
                break;
            case 2:
                [cell setName:@"消息免打扰"];
                [cell setSwitchState:[self.userExt noDisturb]];
                [cell.switchControl setTag:2];
                break;
            case 3:
                [cell setName:@"清空聊天记录"];
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                [cell setName:@"置顶聊天"];
                [cell setSwitchState:[self.userExt stickTop]];
                [cell.switchControl setTag:1];
                break;
            case 1:
                [cell setName:@"消息免打扰"];
                [cell setSwitchState:[self.userExt noDisturb]];
                [cell.switchControl setTag:2];
                break;
            case 2:
                [cell setName:@"清空聊天记录"];
                break;
            default:
                break;
        }
    }
    
    [cell.switchControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.roster) {
        switch (indexPath.row) {
            case 0: {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改备注名" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField *textField = [alertView textFieldAtIndex:0];
                [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                [textField setText:[self.roster rosterAlias]];
                [alertView show];
                break;
            }
            case 3: {
                UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"清空聊天记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
                actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
                [actionSheet showInView:self.view];
                break;
            }
            default:
                break;
        }
    } else {
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
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark switch target

- (void)didSwitch:(UISwitch *)switchControl {
    switch ([switchControl tag]) {
        case 1:
            [[YYIMChat sharedInstance].chatManager updateUserStickTop:[switchControl isOn] userId:self.userId];
            break;
        case 2:
            [[YYIMChat sharedInstance].chatManager updateUserNoDisturb:[switchControl isOn] userId:self.userId];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [[YYIMChat sharedInstance].chatManager deleteMessageWithId:self.userId];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:{
            UITextField *textField=[alertView textFieldAtIndex:0];
            NSString *newName = textField.text;
            [[YYIMChat sharedInstance].chatManager renameRoster:self.userId name:newName];
            break;
        }
        default:
            break;
    }
}

#pragma mark -
#pragma mark yyimchat delegate

- (void)didRosterUpdate:(YYRoster *)roster {
    if ([self.userId isEqualToString:[roster rosterId]]) {
        [self reloadData];
    }
}

- (void)didUserInfoUpdate:(YYUser *)user {
    if ([self.userId isEqualToString:[user userId]]) {
        [self reloadData];
    }
}

- (void)didChatGroupCreateWithSeriId:(NSString *)seriId group:(YYChatGroup *)group {
    if ([self.seriChatGroupId isEqualToString:seriId]) {
        NSLog(@"didChatGroupCreate-%@", [group groupName]);
        
        [self.createViewController hideHud];
        self.createViewController = nil;
        
        [self.navigationController popToViewController:self animated:YES];
        [self.navigationController clearData];
        
        ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
        chatViewController.chatId = [group groupId];
        chatViewController.chatType = YM_MESSAGE_TYPE_GROUPCHAT;
        chatViewController.backToMain = YES;
        
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
}

- (void)didNotChatGroupCreateWithSeriId:(NSString *)seriId {
    if ([self.seriChatGroupId isEqualToString:seriId]) {
        [self hideHud];
        self.createViewController = nil;
        
        [self showHint:@"群组创建失败"];
    }
}

- (void)didUserExtUpdate:(YYUserExt *)userExt {
    if ([[userExt userId] isEqualToString:self.userId]) {
        self.userExt = userExt;
        [self.tableView reloadData];
    }
}

- (void)didNotUpdateUserStickTop:(NSString *)userId error:(YYIMError *)error {
    if ([userId isEqualToString:self.userId]) {
        NSLog(@"设置用户置顶失败:%ld,%@", (long)[error errorCode], [error errorMsg]);
        [self.tableView reloadData];
    }
}

- (void)didNotUpdateUserNoDisturb:(NSString *)userId error:(YYIMError *)error {
    if ([userId isEqualToString:self.userId]) {
        NSLog(@"设置用户免打扰失败:%ld,%@", (long)[error errorCode], [error errorMsg]);
        [self.tableView reloadData];
    }
}

#pragma mark -
#pragma mark GlobalInviteViewControllerDelegate

- (void)didGlobalInviteViewController:(UIViewController *)viewController InviteUsers:(NSArray *)userArray {
    NSMutableArray *inviteUserArray = [NSMutableArray arrayWithArray:userArray];
    NSMutableArray *userIdArray = [NSMutableArray array];
    
    for (id user in inviteUserArray) {
        if ([user isKindOfClass:[YYUser class]]) {
            [userIdArray addObject:[(YYUser *)user userId]];
        } else if ([user isKindOfClass:[YYRoster class]]) {
            [userIdArray addObject:[(YYRoster *)user rosterId]];
        } else if ([user isKindOfClass:[YYChatGroupMember class]]) {
            [userIdArray addObject:[(YYChatGroupMember *)user memberId]];
        }
    }
    
    if (self.userId) {
        if (![userIdArray containsObject:self.userId]) {
            [userIdArray addObject:self.userId];
            YYUser *inviteUser = [[YYIMChat sharedInstance].chatManager getUserWithId:self.userId];
            [inviteUserArray addObject:inviteUser];
        }
    }
    
    if ([userIdArray count] <= 0) {
        [self showHint:@"请选择群组成员"];
        return;
    }
    
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
    NSString *name = [YYIMUtility genGroupName:user invites:inviteUserArray];
    NSString *seriId = [[YYIMChat sharedInstance].chatManager createChatGroupWithName:name user:userIdArray];
    self.seriChatGroupId = seriId;
    
    self.createViewController = viewController;
    [self showThemeHudInView:viewController.view];
}

#pragma mark -
#pragma mark util

- (void)changeCollectionHeight:(CGFloat)height {
    [self.collectionView removeConstraints:[self.collectionView constraints]];
    [self.collectionView addConstraint:[NSLayoutConstraint constraintWithItem:self.collectionView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:height]];
}

- (void)reloadData {
    self.user = [[YYIMChat sharedInstance].chatManager getUserWithId:self.userId];
    self.userExt = [[YYIMChat sharedInstance].chatManager getUserExtWithId:self.userId];
    
    self.roster = [[YYIMChat sharedInstance].chatManager getRosterWithId:self.userId];
    
    CGFloat line = 1;
    CGFloat height = line * kYMChatInfoCellWidth + 16.0f;
    [self changeCollectionHeight: height];
    
    [self.collectionView reloadData];
    [self.tableView reloadData];
    
    if (self.roster) {
        self.title = [self.roster rosterAlias];
    } else if (self.user) {
        self.title = [self.user userName];
    } else {
        self.title = @"聊天详情";
    }
}

- (void)initLayoutAttribute {
    self.cellNumberPerRow = floor(CGRectGetWidth([UIScreen mainScreen].bounds) / kYMChatInfoCellWidth);
    [self.collectionFlowLayout setItemSize:CGSizeMake(kYMChatInfoCellWidth, kYMChatInfoCellWidth)];
    CGFloat offsetX = CGRectGetWidth([UIScreen mainScreen].bounds) - self.cellNumberPerRow * kYMChatInfoCellWidth;
    [self.collectionFlowLayout setSectionInset:UIEdgeInsetsMake(8.0f, offsetX / 2.0f, 8.0f, offsetX / 2.0f)];
    [self.collectionFlowLayout setMinimumLineSpacing:8.0f];
    [self.collectionFlowLayout setMinimumInteritemSpacing:0.0f];
}

@end
