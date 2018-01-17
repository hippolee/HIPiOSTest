//
//  GroupInfoViewController.m
//  YonyouIM
//
//  Created by litfb on 15/3/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "GroupInfoViewController.h"
#import "SingleLineCell2.h"
#import "UserCollectionViewCell.h"
#import "YYIMChatHeader.h"
#import "YYIMUtility.h"
#import "UserViewController.h"
#import "ChatGroupViewController.h"
#import "UIViewController+HUDCategory.h"
#import "GlobalInviteViewController.h"
#import "ChatViewController.h"
#import "YYIMColorHelper.h"
#import "GroupQRCodeViewController.h"
#import "UINavigationController+YMInvite.h"
#import "MemberSelViewController.h"
#import "GroupMemberViewController.h"

#define TAG_DELETE_MESSAGE      10
#define TAG_QUIT_GROUP          11
#define TAG_UPDATE_GROUPNAME    12
#define TAG_DISMISS_GROUP      13

#define TAG_SWITCH_CONTROL_STICKTOP     100
#define TAG_SWITCH_CONTROL_NODISTURB    101
#define TAG_SWITCH_CONTROL_COLLECT      102
#define TAG_SWITCH_CONTROL_SHOWNAME     201

const CGFloat kYMGroupInfoCellWidth = 60.0f;

@interface GroupInfoViewController ()<UIAlertViewDelegate, UIActionSheetDelegate, UIGestureRecognizerDelegate, GlobalInviteViewControllerDelegate, YMMemberSelDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UICollectionView *collectionView;
@property (strong, nonatomic) UICollectionViewFlowLayout *collectionFlowLayout;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;

@property (strong, nonatomic) UIView *footerView;

@property (retain, nonatomic) YYChatGroup *group;
@property (retain, nonatomic) YYChatGroupExt *groupExt;
@property (retain, nonatomic) NSArray *groupMemberArray;

@property BOOL isOwner;
@property BOOL isMemberEditing;

@property (nonatomic) NSInteger cellNumberPerRow;

@property (retain, nonatomic) NSString *seriChatGroupId;

@end

@implementation GroupInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 加载数据
    [self loadData];
    // Collection每行Cell数量
    self.cellNumberPerRow = floor(CGRectGetWidth([UIScreen mainScreen].bounds) / kYMGroupInfoCellWidth);
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell2" bundle:nil] forCellReuseIdentifier:@"SingleLineCell2"];
    [self.tableView setTableFooterView:[self footerView]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isOwner]) {
        [self.collectionView addGestureRecognizer:self.longPressGestureRecognizer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldKeepDelegate {
    return YES;
}

- (void)quitGroupAction:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"删除并退出后，您将不再接收此群消息" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    actionSheet.tag = TAG_QUIT_GROUP;
    [actionSheet showInView:self.view];
}

#pragma mark collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self numberOfCollectionViewItems];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // cell
    UserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    [cell setRoundCorner:(kYMGroupInfoCellWidth - 20) / 2 - 1];
    
    if (indexPath.row == self.groupMemberArray.count) {
        [cell setHeadIcon:@"icon_addmember"];
        [cell setName:@"增加成员"];
    } else if (indexPath.row == self.groupMemberArray.count + 1) {
        [cell setHeadIcon:@"icon_delmember"];
        [cell setName:@"删除成员"];
    } else {
        YYChatGroupMember *member = [self.groupMemberArray objectAtIndex:indexPath.row];
        [cell setHeadImageWithUrl:[member getMemberPhoto] placeholderName:[member memberName]];
        [cell setName:[member memberName]];
        if (self.isMemberEditing) {
            if (![[member memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                [cell.delView setHidden:NO];
            }
        }
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.groupMemberArray.count) {
        GlobalInviteViewController *globalInviteViewController = [[GlobalInviteViewController alloc] initWithNibName:@"GlobalInviteViewController" bundle:nil];
        
        globalInviteViewController.groupId = self.groupId;
        globalInviteViewController.delegate = self;
        globalInviteViewController.actionName = @"发起邀请";
        
        [self.navigationController pushViewController:globalInviteViewController animated:YES];
    } else if (indexPath.row == self.groupMemberArray.count + 1) {
        self.isMemberEditing = YES;
        [self.collectionView reloadData];
    } else {
        YYChatGroupMember *member = [self.groupMemberArray objectAtIndex:indexPath.row];
        if (self.isMemberEditing) {
            if (![[member memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                [[YYIMChat sharedInstance].chatManager kickGroupMemberFromGroup:self.groupId member:[member memberId]];
            }
        } else {
            UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
            userViewController.userId = [member memberId];
            [self.navigationController pushViewController:userViewController animated:YES];
        }
    }
}

#pragma mark table delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 0.0f;
        default:
            return 16.0f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    return [self collectionViewHeight] + 1;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    return 46.0f;
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 2;
        case 1:
            if ([self isOwner]) {
                return 3;
            }
            return 2;
        case 2:
            return 3;
        case 3:
            return 1;
        case 4:
            if ([self isOwner]) {
                return 2;
            }
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell2";
    SingleLineCell2 *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    [cell.detailLabel setTextAlignment:NSTextAlignmentLeft];
    if ([[cell subviews] containsObject:[self collectionView]]) {
        [[self collectionView] removeFromSuperview];
    }
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    [self.collectionView setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), [self collectionViewHeight])];
                    [cell addSubview:self.collectionView];
                    break;
                case 1:
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell setName:[NSString stringWithFormat:@"全部群成员(%ld)", (long)[self.group memberCount]]];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell setName:@"群聊名称"];
                    [cell setDetail:[self.group groupName]];
                    [cell.detailLabel setTextAlignment:NSTextAlignmentRight];
                    break;
                case 1:
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell setName:@"群二维码"];
                    [cell setImageWithName:@"icon_qrcode"];
                    break;
                case 2:
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    [cell setName:@"群组权限转让"];
                    break;
                default:
                    break;
            }
            break;
        case 2:
            switch (indexPath.row) {
                case 0:
                    [cell setName:@"置顶聊天"];
                    [cell setSwitchState:[self.groupExt stickTop]];
                    [cell.switchControl setTag:TAG_SWITCH_CONTROL_STICKTOP];
                    break;
                case 1:
                    [cell setName:@"消息免打扰"];
                    [cell setSwitchState:[self.groupExt noDisturb]];
                    [cell.switchControl setTag:TAG_SWITCH_CONTROL_NODISTURB];
                    break;
                case 2:
                    [cell setName:@"保存到通讯录"];
                    [cell setSwitchState:[self.group isCollect]];
                    [cell.switchControl setTag:TAG_SWITCH_CONTROL_COLLECT];
                    break;
                default:
                    break;
            }
            break;
        case 3:
            switch (indexPath.row) {
                case 0:
                    [cell setName:@"显示成员名称"];
                    [cell setSwitchState:[self.groupExt showName]];
                    [cell.switchControl setTag:TAG_SWITCH_CONTROL_SHOWNAME];
                    break;
                default:
                    break;
            }
            break;
        case 4:
            switch (indexPath.row) {
                case 0:
                    [cell setName:@"清空聊天记录"];
                    break;
                case 1:
                    [cell setName:@"解散群组"];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
    
    [cell.switchControl addTarget:self action:@selector(didSwitch:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 1: {
                    GroupMemberViewController *groupMemberVC = [[GroupMemberViewController alloc] init];
                    [groupMemberVC setGroupId:self.groupId];
                    [self.navigationController pushViewController:groupMemberVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        case 1:
            switch (indexPath.row) {
                case 0: {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"修改群名称" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
                    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                    UITextField *textField = [alertView textFieldAtIndex:0];
                    [textField setClearButtonMode:UITextFieldViewModeWhileEditing];
                    [textField setText:[self.group groupName]];
                    alertView.tag = TAG_UPDATE_GROUPNAME;
                    [alertView show];
                    break;
                }
                case 1: {
                    GroupQRCodeViewController *qrCodeViewController = [[GroupQRCodeViewController alloc] initWithNibName:@"GroupQRCodeViewController" bundle:nil];
                    [qrCodeViewController setGroupId:self.groupId];
                    [self.navigationController pushViewController:qrCodeViewController animated:YES];
                    break;
                }
                case 2: {
                    //权限转移调用群组列表
                    MemberSelViewController *memberSelViewController = [[MemberSelViewController alloc] initWithNibName:@"MemberSelViewController" bundle:nil];
                    memberSelViewController.groupId = self.groupId;
                    memberSelViewController.delegate = self;
                    memberSelViewController.identifiy = @"at";
                    UINavigationController *memberSelNavController = [YYIMUtility themeNavController:memberSelViewController];
                    
                    [self presentViewController:memberSelNavController animated:YES completion:nil];
                    
                    break;
                }
                default:
                    break;
            }
            break;
        case 4: {
            switch (indexPath.row) {
                case 0: {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"清空聊天记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
                    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                    actionSheet.tag = TAG_DELETE_MESSAGE;
                    [actionSheet showInView:self.view];
                    break;
                }
                case 1: {
                    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"解散群组" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
                    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
                    actionSheet.tag = TAG_DISMISS_GROUP;
                    [actionSheet showInView:self.view];
                    break;
                }
                default:
                    break;
            }
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
        case TAG_SWITCH_CONTROL_STICKTOP:
            [[YYIMChat sharedInstance].chatManager updateGroupStickTop:[switchControl isOn] groupId:self.groupId];
            break;
        case TAG_SWITCH_CONTROL_NODISTURB:
            [[YYIMChat sharedInstance].chatManager updateGroupNoDisturb:[switchControl isOn] groupId:self.groupId];
            break;
        case TAG_SWITCH_CONTROL_COLLECT:
            [self.group setIsCollect:[switchControl isOn]];
            if ([self.group isCollect]) {
                [[YYIMChat sharedInstance].chatManager collectChatGroup:self.groupId];
            } else {
                [[YYIMChat sharedInstance].chatManager unCollectChatGroup:self.groupId];
            }
            break;
        case TAG_SWITCH_CONTROL_SHOWNAME:
            [[YYIMChat sharedInstance].chatManager setChatGroupShowName:[switchControl isOn] groupId:self.groupId];
            break;
        default:
            break;
    }
}

#pragma mark alertview delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            switch ([alertView tag]) {
                case TAG_UPDATE_GROUPNAME: {
                    UITextField *textField=[alertView textFieldAtIndex:0];
                    NSString *newName = textField.text;
                    if (![YYIMUtility isEmptyString:newName]) {
                        [[YYIMChat sharedInstance].chatManager renameChatGroup:self.groupId name:newName];
                    }
                    break;
                }
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark actionsheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            switch ([actionSheet tag]) {
                case TAG_QUIT_GROUP:
                    [[YYIMChat sharedInstance].chatManager leaveChatGroup:self.groupId];
                    [self showThemeHudInView:self.view];
                    break;
                case TAG_DISMISS_GROUP:
                    [[YYIMChat sharedInstance].chatManager dismissChatGroup:self.groupId];
                    [self showThemeHudInView:self.view];
                    break;
                case TAG_DELETE_MESSAGE:
                    [[YYIMChat sharedInstance].chatManager deleteMessageWithId:self.groupId];
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark YMMemberSelDelegate
- (BOOL)allowMultipleMemberSelect:(MemberSelViewController *)controller {
    return NO;
}

- (void)memberSelController:(MemberSelViewController *)controller identifiy:(NSString *)identifiy didSelMember:(YYChatGroupMember *)member {
    //转移群组管理权限
    [[YYIMChat sharedInstance].chatManager changeChatGroupAdminForGroup:self.groupId to:member.memberId];
}

#pragma mark chat delegate

- (void)didChatGroupInfoUpdate:(YYChatGroup *)group {
    if ([[group groupId] isEqualToString:self.groupId]) {
        [self reloadData];
    }
}

- (void)didUserInfoUpdate {
    [self reloadData];
}

- (void)didChatGroupMemberUpdate:(NSString *)groupId {
    if (groupId && [groupId isEqualToString:self.groupId]) {
        [self reloadData];
    }
}

- (void)didNotKickGroupMemberFromGroup:(NSString *)groupId error:(YYIMError *)error {
    if ([self.groupId isEqualToString:groupId]) {
        [self showHint:@"删除群组成员失败"];
    }
}

- (void)didNotInviteRosterIntoChatGroup:(NSString *)groupId error:(YYIMError *)error {
    if ([self.groupId isEqualToString:groupId]) {
        NSString *errMsg = [error errorMsg];
        if (errMsg) {
            NSRange rangeEn = [errMsg rangeOfString:@"limit"];
            NSRange rangeCh = [errMsg rangeOfString:@"最大人数"];
            
            if (rangeEn.location != NSNotFound || rangeCh.location != NSNotFound) {
                [self showHint:@"邀请成员超过群组成员数量上限"];
                return;
            }
        }
        [self showHint:@"增加群组成员失败"];
    }
}

- (void)didNotRenameChatGroup:(NSString *)groupId error:(YYIMError *)error {
    if ([self.groupId isEqualToString:groupId]) {
        [self showHint:@"重命名群组失败"];
    }
}

- (void)didLeaveChatGroup:(NSString *)groupId {
    if ([self.groupId isEqualToString:groupId]) {
        ChatGroupViewController *chatGroupViewControler;
        NSArray *viewControllers = [self.navigationController viewControllers];
        for (UIViewController *vc in viewControllers) {
            if ([vc isKindOfClass:[ChatGroupViewController class]]) {
                chatGroupViewControler = (ChatGroupViewController *)vc;
                break;
            }
        }
        if (chatGroupViewControler) {
            [self.navigationController popToViewController:chatGroupViewControler animated:YES];
        } else {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
    }
}

- (void)didNotLeaveChatGroup:(NSString *)groupId error:(YYIMError *)error {
    if ([self.groupId isEqualToString:groupId]) {
        [self showHint:@"退出群组失败"];
    }
}

- (void)didDismissChatGroup:(NSString *)groupId {
    NSLog(@"解散群组成功");
    [self didLeaveChatGroup:groupId];
}

- (void)didNotDismissChatGroup:(NSString *)groupId error:(YYIMError *)error {
    if ([self.groupId isEqualToString:groupId]) {
        [self showHint:@"解散群组失败"];
    }
}

- (void)didCollectChatGroup:(NSString *)groupId {
    NSLog(@"didCollectChatGroup:%@", groupId);
}

- (void)didNotCollectChatGroup:(NSString *)groupId error:(YYIMError *)error {
    NSLog(@"didNotCollectChatGroup:%@, %ld, %@, %@", groupId, (long)[error errorCode], [error errorMsg], [[error srcError] localizedDescription]);
}

- (void)didUnCollectChatGroup:(NSString *)groupId {
    NSLog(@"didUnCollectChatGroup:%@", groupId);
}

- (void)didNotUnCollectChatGroup:(NSString *)groupId error:(YYIMError *)error {
    NSLog(@"didNotUnCollectChatGroup:%@, %ld, %@, %@", groupId, (long)[error errorCode], [error errorMsg], [[error srcError] localizedDescription]);
}

- (void)didChatGroupExtUpdate:(YYChatGroupExt *)groupExt {
    if ([[groupExt groupId] isEqualToString:self.groupId]) {
        self.groupExt = groupExt;
        [self.tableView reloadData];
    }
}

- (void)didNotUpdateGroupStickTop:(NSString *)groupId error:(YYIMError *)error {
    if ([groupId isEqualToString:self.groupId]) {
        NSLog(@"设置群组置顶失败:%ld,%@", (long)[error errorCode], [error errorMsg]);
        [self.tableView reloadData];
    }
}

- (void)didNotUpdateGroupNoDisturb:(NSString *)groupId error:(YYIMError *)error {
    if ([groupId isEqualToString:self.groupId]) {
        NSLog(@"设置群组免打扰失败:%ld,%@", (long)[error errorCode], [error errorMsg]);
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
    
    if ([userIdArray count] <= 0) {
        [self showHint:@"请选择群组成员"];
        return;
    }
    
    [[YYIMChat sharedInstance].chatManager inviteRosterIntoChatGroup:self.groupId user:userIdArray];
    
    [self.navigationController popToViewController:self animated:YES];
    [self.navigationController clearData];
}

#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (self.isMemberEditing) {
            return YES;
        }
        return NO;
    } else {
        if (self.isMemberEditing) {
            return NO;
        }
        return YES;
    }
}

- (void)collectionViewTap:(id)sender {
    self.isMemberEditing = NO;
    [self.collectionView reloadData];
}

- (void)memberLongTap:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (!self.isOwner) {
            return;
        }
        
        CGPoint point = [sender locationInView:self.collectionView];
        NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:point];
        if (indexPath.row < [self.groupMemberArray count]) {
            self.isMemberEditing = YES;
            [self.collectionView reloadData];
        }
    }
}

#pragma mark util

- (void)loadData {
    self.group = [[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:self.groupId];
    self.groupExt = [[YYIMChat sharedInstance].chatManager getChatGroupExtWithId:self.groupId];
    self.groupMemberArray = [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:self.groupId limit:39];
    self.isOwner = [[YYIMChat sharedInstance].chatManager isGroupOwner:self.groupId];
    
    if (self.group) {
        self.title = [NSString stringWithFormat:@"聊天信息(%lu)", (long)[self.group memberCount]];
    } else {
        self.title = @"聊天信息";
    }
}

- (void)reloadData {
    [self loadData];
    
    if ([self isOwner]) {
        [self.collectionView addGestureRecognizer:self.longPressGestureRecognizer];
    }
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (NSInteger)numberOfCollectionViewItems {
    if (self.isOwner) {
        return [self.groupMemberArray count] + 2;
    }
    return [self.groupMemberArray count] + 1;
}

- (CGFloat)collectionViewHeight {
    CGFloat count = [self numberOfCollectionViewItems];
    CGFloat line = ceil(count / self.cellNumberPerRow);
    CGFloat height = line * kYMGroupInfoCellWidth + (line - 1) * 8.0f + 16.0f;
    return height;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), [self collectionViewHeight]) collectionViewLayout:[self collectionFlowLayout]];
        [collectionView setDataSource:self];
        [collectionView setDelegate:self];
        // 注册Cell nib
        [collectionView registerNib:[UINib nibWithNibName:@"UserCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"UserCollectionViewCell"];
        
        UIView *bgView = [[UIView alloc] init];
        [bgView setBackgroundColor:[UIColor whiteColor]];
        [bgView addGestureRecognizer:[self tapGestureRecognizer]];
        [collectionView setBackgroundView:bgView];
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)collectionFlowLayout {
    if (!_collectionFlowLayout) {
        UICollectionViewFlowLayout *collectionFlowLayout = [[UICollectionViewFlowLayout alloc] init];
        [collectionFlowLayout setItemSize:CGSizeMake(kYMGroupInfoCellWidth, kYMGroupInfoCellWidth)];
        CGFloat offsetX = CGRectGetWidth([UIScreen mainScreen].bounds) - self.cellNumberPerRow * kYMGroupInfoCellWidth;
        [collectionFlowLayout setSectionInset:UIEdgeInsetsMake(8.0f, offsetX / 2.0f, 8.0f, offsetX / 2.0f)];
        [collectionFlowLayout setMinimumLineSpacing:8.0f];
        [collectionFlowLayout setMinimumInteritemSpacing:0.0f];
        _collectionFlowLayout = collectionFlowLayout;
    }
    return _collectionFlowLayout;
}

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        // 单击
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collectionViewTap:)];
        tapGestureRecognizer.delegate = self;
        [tapGestureRecognizer setCancelsTouchesInView:YES];
        _tapGestureRecognizer = tapGestureRecognizer;
    }
    return _tapGestureRecognizer;
}

- (UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if (!_longPressGestureRecognizer) {
        // 长按
        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(memberLongTap:)];
        longPressGestureRecognizer.delegate = self;
        [longPressGestureRecognizer setCancelsTouchesInView:YES];
        _longPressGestureRecognizer = longPressGestureRecognizer;
    }
    return _longPressGestureRecognizer;
}

- (UIView *)footerView {
    if (!_footerView) {
        CGFloat footerWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, 70.0f)];
        [footerView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
        
        UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, footerWidth, 0.5)];
        [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        [footerView addSubview:sepView];
        // 退出群组
        UIButton *quitGroupBtn = [[UIButton alloc] initWithFrame:CGRectMake(16, 16, footerWidth - 32.0f, 46.0f)];
        [quitGroupBtn setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
        [quitGroupBtn setBackgroundColor:[UIColor redColor]];
        [quitGroupBtn setTitle:@"删除并退出" forState:UIControlStateNormal];
        [quitGroupBtn addTarget:self action:@selector(quitGroupAction:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:quitGroupBtn];
        _footerView = footerView;
    }
    return _footerView;
}

@end
