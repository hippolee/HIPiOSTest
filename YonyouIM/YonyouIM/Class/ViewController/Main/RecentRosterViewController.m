//
//  RecentRosterViewController.m
//  YonyouIM
//
//  Created by litfb on 15/6/18.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "RecentRosterViewController.h"
#import "YYIMChatHeader.h"
#import "MenuView.h"
#import "YYIMUtility.h"
#import "SingleLineCell.h"
#import "ChatViewController.h"
#import "UserViewController.h"
#import "RosterInviteViewController.h"
#import "ChatGroupViewController.h"
#import "RosterViewController.h"
#import "PubAccountViewController.h"
#import "AddRosterViewController.h"
#import "JoinChatGroupViewController.h"
#import "FollowPubAccountController.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMColorHelper.h"
#import "GlobalInviteViewController.h"
#import "ScanViewController.h"
#import "MyNetMeetingViewController.h"
#import "UIViewController+HUDCategory.h"
#import "UINavigationController+YMInvite.h"

@interface RecentRosterViewController ()<UITableViewDataSource, UITableViewDelegate, MenuViewDelegate, UIGestureRecognizerDelegate, GlobalInviteViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MenuView *menuView;

@property (retain, nonatomic) NSArray *rosterArray;
@property (retain, nonatomic) NSArray *menuArray;

@property NSInteger newRosterInviteCount;

@property (retain, nonatomic) NSString *seriChatGroupId;

/**
 *  当前正在创建群组的视图
 */
@property (retain, nonatomic) UIViewController *createViewController;

@end

@implementation RecentRosterViewController

@synthesize rightBarButtonItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTap:)];
    tapGestureRecognizer.delegate = self;
    [tapGestureRecognizer setCancelsTouchesInView:YES];
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
    
    // 菜单处理
    [self.menuView setMenuDelegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 最近联系人列表
    [self reload];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.menuView setHidden:YES];
}

- (BOOL)shouldKeepDelegate {
    return YES;
}

- (UIBarButtonItem *)rightBarButtonItem {
    if (!rightBarButtonItem) {
        UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuAction:)];
        rightBarButtonItem = menuBtn;
    }
    return rightBarButtonItem;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return @"最近联系人";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 5;
    }
    return [self.rosterArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    
    UILabel * label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 320, 32);
    label.font = [UIFont systemFontOfSize:14];
    [label setTextColor:UIColorFromRGB(0xa3a3a3)];
    label.text = sectionTitle;
    [sectionView addSubview:label];
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView];
    
    UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 32, tableView.bounds.size.width, 0.5)];
    [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView2];
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell";
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setImageRadius:16];
    if ([indexPath section] == 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        switch (indexPath.row) {
            case 0:
                [cell setHeadIcon:@"icon_rosterinvite"];
                [cell setName:@"新的朋友"];
                if (self.newRosterInviteCount > 0) {
                    [cell setBadge:[NSString stringWithFormat:@"%ld", (long)self.newRosterInviteCount]];
                }
                break;
            case 1:
                [cell setHeadIcon:@"icon_chatgroup"];
                [cell setName:@"群组聊天"];
                break;
            case 2:
                [cell setHeadIcon:@"icon_roster"];
                [cell setName:@"好友列表"];
                break;
            case 3:
                [cell setHeadIcon:@"icon_pubaccount"];
                [cell setName:@"公共号"];
                break;
        }
        return cell;
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        // 取数据
        NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
        
        NSString *name;
        NSString *photo;
        if ([obj isKindOfClass:[YYRoster class]]) {
            name = [(YYRoster *)obj rosterAlias];
            photo = [(YYRoster *)obj getRosterPhoto];
        } else if ([obj isKindOfClass:[YYUser class]]) {
            name = [(YYUser *)obj userName];
            photo = [(YYUser *)obj getUserPhoto];
        }
        [cell setName:name];
        [cell setHeadImageWithUrl:photo placeholderName:name];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        switch (indexPath.row) {
            case 0: {
                RosterInviteViewController *rosterInviteViewController = [[RosterInviteViewController alloc] initWithNibName:@"RosterInviteViewController" bundle:nil];
                [self.navigationController pushViewController:rosterInviteViewController animated:YES];
                break;
            }
            case 1: {
                ChatGroupViewController *chatGroupViewController = [[ChatGroupViewController alloc] initWithNibName:@"ChatGroupViewController" bundle:nil];
                [self.navigationController pushViewController:chatGroupViewController animated:YES];
                break;
            }
            case 2:{
                RosterViewController *rosterViewController = [[RosterViewController alloc] initWithNibName:@"RosterViewController" bundle:nil];
                [self.navigationController pushViewController:rosterViewController animated:YES];
                break;
            }
            case 3:{
                PubAccountViewController *pubAccountViewController = [[PubAccountViewController alloc] initWithNibName:@"PubAccountViewController" bundle:nil];
                [self.navigationController pushViewController:pubAccountViewController animated:YES];
                break;
            }
        }
    } else {
        // 取数据
        NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
        
        NSString *chatId;
        if ([obj isKindOfClass:[YYRoster class]]) {
            chatId = [(YYRoster *)obj rosterId];
        } else if ([obj isKindOfClass:[YYUser class]]) {
            chatId = [(YYUser *)obj userId];
        }
        
        UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
        userViewController.userId = chatId;
        [self.navigationController pushViewController:userViewController animated:YES];
    }
    // 取消行选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.menuView setHidden:YES];
}

#pragma mark YYIMChatDelegate

- (void)didReceiveMessage:(YYMessage *)message {
    // 收到消息，刷新界面
    [self reload];
}

- (void)didSendMessage:(YYMessage *)message error:(YYIMError *)error {
    // 发出消息，刷新界面
    [self reload];
}

- (void)didMessageDelete:(NSDictionary *)info {
    [self reload];
}

- (void)didRosterChange {
    [self reload];
}

- (void)didUserInfoUpdate {
    [self reload];
}

- (void)didChatGroupInfoUpdate {
    [self reload];
}

- (void)didChatGroupCreateWithSeriId:(NSString *)seriId group:(YYChatGroup *)group {
    if ([self.seriChatGroupId isEqualToString:seriId]) {
        NSLog(@"didChatGroupCreate-%@", [group groupName]);
        [self hideHud];
        self.createViewController = nil;
        
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

#pragma mark -
#pragma mark MenuViewDelegate

- (NSArray *)menuDataDicArray {
    if (!self.menuArray) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_creategroup", @"icon", @"发起群聊", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_addroster", @"icon", @"添加好友", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_joingroup", @"icon", @"加入群组", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_followpa", @"icon", @"关注公共号", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_netmeeting", @"icon", @"视频会议", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_scan", @"icon", @"扫一扫", @"name", nil]];
        self.menuArray = array;
    }
    return self.menuArray;
}

- (void)didSelectMenuAtIndex:(NSUInteger)index {
    switch (index) {
        case 0: {
            GlobalInviteViewController *globalInviteViewController = [[GlobalInviteViewController alloc] initWithNibName:@"GlobalInviteViewController" bundle:nil];
            
            globalInviteViewController.delegate = self;
            globalInviteViewController.actionName = @"创建群组";
            [self.navigationController pushViewController:globalInviteViewController animated:YES];
            break;
        }
        case 1: {
            AddRosterViewController *addRosterViewController = [[AddRosterViewController alloc] initWithNibName:@"AddRosterViewController" bundle:nil];
            [self.navigationController pushViewController:addRosterViewController animated:YES];
            break;
        }
        case 2: {
            JoinChatGroupViewController *joinChatGroupViewController = [[JoinChatGroupViewController alloc] initWithNibName:@"JoinChatGroupViewController" bundle:nil];
            [self.navigationController pushViewController:joinChatGroupViewController animated:YES];
            break;
        }
        case 3: {
            FollowPubAccountController *followPubAccountController = [[FollowPubAccountController alloc] initWithNibName:@"FollowPubAccountController" bundle:nil];
            [self.navigationController pushViewController:followPubAccountController animated:YES];
            break;
        }
        case 4: {
            MyNetMeetingViewController *myNetMeetingViewController = [[MyNetMeetingViewController alloc] initWithNibName:@"MyNetMeetingViewController" bundle:nil];
            [self.navigationController pushViewController:myNetMeetingViewController animated:YES];
            break;
        }
        case 5: {
            ScanViewController *scanViewController = [[ScanViewController alloc] init];
            [self.navigationController pushViewController:scanViewController animated:YES];
            break;
        }
        default:
            break;
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
    
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:[[YYIMConfig sharedInstance] getUser]];
    NSString *name = [YYIMUtility genGroupName:user invites:inviteUserArray];
    NSString *seriId = [[YYIMChat sharedInstance].chatManager createChatGroupWithName:name user:userIdArray];
    self.seriChatGroupId = seriId;
    
    self.createViewController = viewController;
    [self showThemeHudInView:viewController.view];
}

#pragma mark -
#pragma mark UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (![self.menuView isHidden]) {
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark private

- (void)reload {
    self.rosterArray = [[YYIMChat sharedInstance].chatManager getRecentRoster];
    self.newRosterInviteCount = [[YYIMChat sharedInstance].chatManager getNewRosterInviteCount];
    [self.tableView reloadData];
}

- (void)menuAction:(id)sender {
    if ([self.menuView isHidden]) {
        [self.menuView setHidden:NO];
    } else {
        [self.menuView setHidden:YES];
    }
}

- (void)tableTap:(UITapGestureRecognizer *)tapRecognizer {
    [self.menuView setHidden:YES];
}

@end
