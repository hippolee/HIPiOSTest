//
//  RecentViewController.m
//  YonyouIM
//
//  Created by litfb on 14/12/18.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "RecentViewController.h"
#import "NormalTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "ChatViewController.h"
#import "ChatViewController.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "MenuView.h"
#import "AddRosterViewController.h"
#import "JoinChatGroupViewController.h"
#import "FollowPubAccountController.h"
#import "RosterViewController.h"
#import "ChatViewController.h"
#import "YYIMColorHelper.h"
#import "TableBackgroundView.h"
#import "YMAFNetworking.h"
#import "NetworkViewController.h"
#import "YYMessage+YYIMCatagory.h"
#import "UIImage+YYIMCategory.h"
#import "GlobalInviteViewController.h"
#import "SingleLineCell.h"
#import "SearchMixedTableViewCell.h"
#import "SearchViewCompleteController.h"
#import "SearchDetailViewController.h"
#import "UserViewController.h"
#import "YYSearchMessage.h"
#import "UIResponder+YYIMCategory.h"
#import "ScanViewController.h"
#import "MyNetMeetingViewController.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMNetMeetingNotifyViewController.h"
#import "UIViewController+HUDCategory.h"
#import "UINavigationController+YMInvite.h"
#import "FaceGroupViewController.h"

#define YM_SEARCH_LIMIT 3

@interface RecentViewController ()<UIGestureRecognizerDelegate, MenuViewDelegate, GlobalInviteViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *recentTableView;
@property (weak, nonatomic) IBOutlet MenuView *menuView;
@property (retain, nonatomic) TableBackgroundView *emptyBgView;
@property (weak, nonatomic) IBOutlet UIView *networkView;

@property (retain, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;

@property (retain, nonatomic) NSArray *messageArray;
@property (retain, nonatomic) NSArray *menuArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *networkConstraint;

@property (strong, nonatomic) UISearchBar *searchBar;

@property (strong, nonatomic) UIImage * dimImage;

@property (retain, nonatomic) NSMutableArray *searchRosterArray;

@property (retain, nonatomic) NSMutableArray *searchMessageArray;

@property (retain, nonatomic) NSMutableArray *searchChatGroupArray;

@property (retain, nonatomic) NSString *searchKey;

@property UISearchDisplayController *searchDisplayController;

@property (retain, nonatomic) NSString *seriChatGroupId;

/**
 *  当前正在创建群组的视图
 */
@property (retain, nonatomic) UIViewController *createViewController;

@end

@implementation RecentViewController

@synthesize rightBarButtonItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchRosterArray = [[NSMutableArray alloc] initWithCapacity:4];
    self.searchMessageArray = [[NSMutableArray alloc] initWithCapacity:4];
    self.searchChatGroupArray = [[NSMutableArray alloc] initWithCapacity:4];
    
    // 注册Cell nib
    [self.recentTableView registerNib:[UINib nibWithNibName:@"NormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalTableViewCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.recentTableView];
    
    [self.recentTableView addGestureRecognizer:self.tapGestureRecognizer];
    
    // 菜单处理
    [self.menuView setMenuDelegate:self];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(networkDidChange:) name:YMAFNetworkingReachabilityDidChangeNotification object:nil];
    
    // 搜索框，仅用于出发uisearchdisplaycontroller
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.recentTableView.frame), 44.0f)];
    self.searchBar.delegate = self;
    [self.searchBar setTintColor:[UIColor themeBlueColor]];
    [self.searchBar setBarTintColor:UIColorFromRGB(0xefeff4)];
    [self.searchBar setTranslucent:NO];
    // searchBar背景色
    [YYIMUtility searchBar:self.searchBar setBackgroundColor:UIColorFromRGB(0xefeff4)];
    
    self.recentTableView.tableHeaderView = self.searchBar;
    self.recentTableView.contentOffset = CGPointMake(0, 44);
    
    //初始化uisearchdisplaycontroller
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self.tabBarController];
    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];
    
    [searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SearchMixedTableViewCell" bundle:nil] forCellReuseIdentifier:@"SearchMixedTableViewCell"];
    
    [YYIMUtility setExtraCellLineHidden:searchDisplayController.searchResultsTableView];
    [searchDisplayController.searchResultsTableView setBackgroundColor:UIColorFromRGB(0xf0eff5)];
    searchDisplayController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.searchDisplayController = searchDisplayController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self resetNetworkConstraint:[[YMAFNetworkReachabilityManager sharedManager] networkReachabilityStatus]];
    // 消息列表
    [self loadData];
    
    if ([self.searchDisplayController isActive]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.menuView setHidden:YES];
}

- (BOOL)shouldKeepDelegate {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIBarButtonItem *)rightBarButtonItem {
    if (!rightBarButtonItem) {
        UIBarButtonItem *menuBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(menuAction:)];
        rightBarButtonItem = menuBtn;
    }
    return rightBarButtonItem;
}

- (void)networkDidChange:(NSNotification *)notification {
    NSDictionary *userInfo = [notification userInfo];
    NSNumber *number = [userInfo objectForKey:YMAFNetworkingReachabilityNotificationStatusItem];
    YMAFNetworkReachabilityStatus status = (YMAFNetworkReachabilityStatus)[number intValue];
    [self resetNetworkConstraint:status];
}

- (void)resetNetworkConstraint:(YMAFNetworkReachabilityStatus)status {
    CGFloat constantOld = self.networkConstraint.constant;
    CGFloat constantNew;
    if (status == YMAFNetworkReachabilityStatusNotReachable) {
        constantNew = 36.0f;
    } else {
        constantNew = 0.0f;
    }
    if (constantOld != constantNew) {
        self.networkConstraint.constant = constantNew;
        [self.view setNeedsLayout];
    }
}

- (IBAction)networkSetAction:(id)sender {
    NetworkViewController *networkViewController = [[NetworkViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:networkViewController animated:YES];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        NSInteger count = 0;
        
        if (self.searchRosterArray.count > 0) {
            count++;
        }
        
        if (self.searchChatGroupArray.count > 0) {
            count++;
        }
        
        if (self.searchMessageArray.count > 0) {
            count++;
        }
        
        return count;
    } else {
        return [self.messageArray count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        YMSearchType searchType = [self getCellType:indexPath.row];
        SearchMixedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SearchMixedTableViewCell"];
        
        switch (searchType) {
            case kYMSearchTypeRoster:
                [cell setActiveType:searchType array:self.searchRosterArray limit:YM_SEARCH_LIMIT searchKey:self.searchKey];
                break;
            case kYMSearchTypeChatGroup:
                [cell setActiveType:searchType array:self.searchChatGroupArray limit:YM_SEARCH_LIMIT searchKey:self.searchKey];
                break;
            case kYMSearchTypeMessage:
                [cell setActiveType:searchType array:self.searchMessageArray limit:YM_SEARCH_LIMIT searchKey:self.searchKey];
                break;
                
            default:
                break;
        }
        return cell;
    } else {
        // 取cell
        static NSString *CellIndentifier = @"NormalTableViewCell";
        NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
        [cell reuse];
        // 取数据
        YYRecentMessage *message = [self.messageArray objectAtIndex:indexPath.row];
        
        // 为cell设置数据
        if ([YM_MESSAGE_TYPE_CHAT isEqualToString:[message chatType]]) {
            if ([message isSystemMessage]) {
                [cell setName:@"系统消息"];
                [cell setHeadIcon:@"icon_system"];
            } else {
                NSString *name;
                if ([message roster]) {
                    name = [[message roster] rosterAlias];
                } else {
                    name = [[message user] userName];
                }
                [cell setName:name];
                [cell setHeadImageWithUrl:[[message user] getUserPhoto] placeholderName:name];
            }
        } else if ([YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:[message chatType]]) {
            YYChatGroup *group = [message group];
            [cell setName:[group groupName]];
            [cell setGroupIcon:[group groupId]];
        } else if ([YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:[message chatType]]) {
            YYPubAccount *account = [message account];
            [cell setName:[account accountName]];
            
            if ([account.accountId isEqualToString:YM_NETCONFERENCE_PUBACCOUNT]) {
                [cell.headImage setImage:[UIImage imageWithColor:UIColorFromRGB(0x63b954)  coreIcon:@"icon_netmeeting_notify"]];
            } else {
                [cell.headImage setImage:[UIImage imageWithDispName:[account accountName] coreIcon:@"icon_pubaccount_core"]];
            }
        }
        // 置顶
        if ([[message chatExt] stickTop]) {
            [cell setBackgroundColor:UIColorFromRGBA(0xececec, 0.25f)];
        } else {
            [cell setBackgroundColor:[UIColor whiteColor]];
        }
        // 免打扰、
        if ([[message chatExt] noDisturb]) {
            [cell setStateImageWithImageName:@"icon_nodisturb"];
        }
        
        [cell setDetail:[YYIMUtility getSimpleMessage:message] isAt:[message atCount] > 0];
        [cell setTime:[YYIMUtility genTimeString:[message date]]];
        if ([message newMessageCount] > 0) {
            if ([message newMessageCount] > 99) {
                [cell setBadge:@"..."];
            } else {
                [cell setBadge:[NSString stringWithFormat:@"%ld", (long)[message newMessageCount]]];
            }
        } else {
            [cell setBadge:nil];
        }
        
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        YMSearchType searchType = [self getCellType:indexPath.row];
        
        NSArray *array;
        switch (searchType) {
            case kYMSearchTypeRoster:
                array = self.searchRosterArray;
                break;
            case kYMSearchTypeChatGroup:
                array = self.searchChatGroupArray;
                break;
            case kYMSearchTypeMessage:
                array = self.searchMessageArray;
                break;
                
            default:
                break;
        }
        return [SearchMixedTableViewCell getHeightOfCell:array limit:YM_SEARCH_LIMIT];
    } else {
        return 68;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!(tableView == self.searchDisplayController.searchResultsTableView)) {
        // 消息
        YYMessage *messageSelected = [self.messageArray objectAtIndex:[indexPath row]];
        NSString *chatId;
        // 传参到聊天controller
        if ([messageSelected direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
            chatId = [messageSelected fromId];
        } else {
            chatId = [messageSelected toId];
        }
        NSString *chatType = [messageSelected chatType];
        
        if ([chatId isEqualToString:YM_NETCONFERENCE_PUBACCOUNT] && [chatType isEqualToString:YM_MESSAGE_TYPE_PUBACCOUNT]) {
            YYIMNetMeetingNotifyViewController *netMeetingNotifyViewController = [[YYIMNetMeetingNotifyViewController alloc] initWithNibName:@"YYIMNetMeetingNotifyViewController" bundle:nil];
            [self.navigationController pushViewController:netMeetingNotifyViewController animated:YES];
        } else {
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
            [chatViewController setValue:chatId forKey:@"chatId"];
            [chatViewController setValue:chatType forKey:@"chatType"];
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
    }
    
    // 取消行选中状态
    [self.recentTableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YYMessage *messageSelected = [self.messageArray objectAtIndex:[indexPath row]];
        NSString *chatId;
        if ([messageSelected direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
            chatId = [messageSelected fromId];
        } else {
            chatId = [messageSelected toId];
        }
        [[YYIMChat sharedInstance].chatManager deleteMessageWithId:chatId];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.menuView setHidden:YES];
    
    [self.searchDisplayController.searchBar resignFirstResponder];
}

#pragma mark UISearchDisplayDelegate

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    // 处理statusbar的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    // 处理背景显示
    [self performSelector:@selector(dealSearchDisplay) withObject:nil afterDelay:0.01];
}

- (void)dealSearchDisplay {
    UIView *dimmingView = [YYIMUtility findSubviewWithClassName:@"_UISearchDisplayControllerDimmingView" inView:self.tabBarController.view];
    if (dimmingView) {
        [dimmingView setAlpha:1.0f];
        [dimmingView setBackgroundColor:[UIColor whiteColor]];
        [self updateDimmingViewChilds:dimmingView];
    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    // 处理statusbar的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // 屏蔽默认的没有结果的提示
    UILabel *label = (UILabel *)[YYIMUtility findSubviewWithClassName:@"UILabel" inView:controller.searchResultsTableView];
    if (label) {
        [label setText:@""];
    }
    
    if ([YYIMUtility isEmptyString:searchString]) {
        [self.searchRosterArray removeAllObjects];
        [self.searchChatGroupArray removeAllObjects];
        [self.searchMessageArray removeAllObjects];
        return YES;
    }
    
    [self doSearch:searchString];
    return YES;
}

#pragma mark yyimchat delegate

- (void)didReceiveMessage:(YYMessage *)message {
    [self reload];
}

- (void)didReceiveOfflineMessages {
    [self reload];
}

- (void)willSendMessage:(YYMessage *)message {
    [self reload];
}

- (void)didSendMessage:(YYMessage *)message {
    [self reload];
}

- (void)didSendMessageFaild:(YYMessage *)message error:(YYIMError *)error {
    [self reload];
}

- (void)didMessageStateChange:(YYMessage *)message {
    [self reload];
}

- (void)didMessageStateChangeWithChatId:(NSString *)chatId {
    [self reload];
}

- (void)didMessageDelete:(NSDictionary *)info {
    [self reload];
}

- (void)didMessageRevoked:(YYMessage *)message {
    [self reload];
}

- (void)didUserInfoUpdate {
    [self reload];
}

- (void)didChatGroupInfoUpdate {
    [self reload];
}

- (void)didChatGroupMemberUpdate {
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

- (void)didUserExtUpdate:(YYUserExt *)userExt {
    [self reload];
}

- (void)didChatGroupExtUpdate:(YYChatGroupExt *)groupExt {
    [self reload];
}

- (void)didPubAccountExtUpdate:(YYPubAccountExt *)accountExt {
    [self reload];
}

- (void)didUserProfileUpdate:(NSDictionary *)userProfiles {
    [self reload];
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
#pragma mark menu

- (NSArray *)menuDataDicArray {
    if (!self.menuArray) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:2];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_creategroup", @"icon", @"发起群聊", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_addroster", @"icon", @"添加好友", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_joingroup", @"icon", @"加入群组", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_followpa", @"icon", @"关注公共号", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_netmeeting", @"icon", @"视频会议", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_scan", @"icon", @"扫一扫", @"name", nil]];
        [array addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"icon_creategroup", @"icon", @"面对面建群", @"name", nil]];
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
        case 6:{
            FaceGroupViewController *faceGroupViewController = [[FaceGroupViewController alloc] init];
            [self.navigationController pushViewController:faceGroupViewController animated:YES];
        }
        default:
            break;
    }
}

- (void)rosterAction:(id)sender {
    RosterViewController *rosterViewController = [[RosterViewController alloc] initWithNibName:@"RosterViewController" bundle:nil];
    [self.navigationController pushViewController:rosterViewController animated:YES];
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

- (void)loadData {
    NSArray *messages = [[YYIMChat sharedInstance].chatManager getRecentMessage];
    [self initData:messages];
}

- (void)reload {
    [[YYIMChat sharedInstance].chatManager getRecentMessageWithBlock:^(NSArray *messages) {
        [self initData:messages];
    }];
}

- (void)initData:(NSArray *)messages {
    self.messageArray = messages;
    [self.recentTableView reloadData];
    
    if (self.messageArray.count > 0) {
        if (self.emptyBgView) {
            [self.emptyBgView removeFromSuperview];
        }
    } else {
        if (!self.emptyBgView) {
            TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:self.view.frame title:@"在这里您可以快速添加新成员聊天\n创建群组会议发送文件及拨打VOIP电话" type:kYYIMTableBackgroundTypeChat];
            [self.view insertSubview:emptyBgView aboveSubview:self.recentTableView];
            
            [emptyBgView addBtnTarget:self action:@selector(rosterAction:) forControlEvents:UIControlEventTouchUpInside];
            self.emptyBgView = emptyBgView;
            [self.emptyBgView addGestureRecognizer:self.tapGestureRecognizer];
        }
    }
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

- (UITapGestureRecognizer *)tapGestureRecognizer {
    if (!_tapGestureRecognizer) {
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tableTap:)];
        tapGestureRecognizer.delegate = self;
        [tapGestureRecognizer setCancelsTouchesInView:YES];
        _tapGestureRecognizer = tapGestureRecognizer;
    }
    return _tapGestureRecognizer;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:YMAFNetworkingReachabilityDidChangeNotification object:nil];
    [[YMAFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark method for searchdisplaycontroller

/**
 *  执行搜索
 *
 *  @param text 搜索内容
 */
- (void)doSearch:(NSString *)text {
    self.searchKey = text;
    
    //query roster
    NSArray *rosterArray = [[YYIMChat sharedInstance].chatManager getAllRosterWithAsk];
    
    NSPredicate *preRoster = [NSPredicate predicateWithFormat:@"rosterAlias CONTAINS[cd] %@", self.searchKey];
    [self.searchRosterArray removeAllObjects];
    [self.searchRosterArray addObjectsFromArray:[rosterArray filteredArrayUsingPredicate:preRoster]];
    
    //query chagroup
    NSArray *groupArray = [[YYIMChat sharedInstance].chatManager getAllChatGroups];
    
    NSPredicate *preGroup = [NSPredicate predicateWithFormat:@"groupName CONTAINS[cd] %@", self.searchKey];
    [self.searchChatGroupArray removeAllObjects];
    [self.searchChatGroupArray addObjectsFromArray:[groupArray filteredArrayUsingPredicate:preGroup]];
    
    //query message
    NSArray *messageArray = [[YYIMChat sharedInstance].chatManager getMessageWithKey:self.searchKey limit:YM_SEARCH_LIMIT + 1];
    [self.searchMessageArray removeAllObjects];
    [self.searchMessageArray addObjectsFromArray:messageArray];
}

/**
 *  通过行数获得对应内容类型
 *
 *  @param row 行数
 *
 *  @return type
 */
- (YMSearchType)getCellType:(NSInteger)row {
    if (row == 0) {
        if (self.searchRosterArray.count > 0) {
            return kYMSearchTypeRoster;
        } else if (self.searchChatGroupArray.count > 0) {
            return kYMSearchTypeChatGroup;
        } else if (self.searchMessageArray.count > 0) {
            return kYMSearchTypeMessage;
        }
    } else if (row == 1) {
        if (self.searchRosterArray.count > 0) {
            if (self.searchChatGroupArray.count > 0) {
                return kYMSearchTypeChatGroup;
            } else {
                return kYMSearchTypeMessage;
            }
        } else if (self.searchChatGroupArray.count > 0) {
            return kYMSearchTypeMessage;
        }
    } else if (row == 2) {
        return kYMSearchTypeMessage;
    }
    return 0;
}

/**
 *  处理tablecell的子控件的响应
 *
 *  @param type  内容类型
 *  @param index 索引
 */
- (void)responseCellClick:(YMSearchType)searchType index:(NSInteger)index {
    if (index >= YM_SEARCH_LIMIT) {
        SearchViewCompleteController *searchViewCompleteController = [[SearchViewCompleteController alloc] initWithNibName:@"SearchViewCompleteController" bundle:nil];
        
        searchViewCompleteController.searchKey = self.searchKey;
        searchViewCompleteController.searchType = searchType;
        
        [self.navigationController pushViewController:searchViewCompleteController animated:YES];
        return;
    }
    
    switch (searchType) {
        case kYMSearchTypeRoster: {
            // 取数据
            YYRoster *roster = [self.searchRosterArray objectAtIndex:index];
            
            UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
            userViewController.userId = roster.rosterId;
            [self.navigationController pushViewController:userViewController animated:YES];
            break;
        }
        case kYMSearchTypeChatGroup: {
            YYChatGroup *groupSelected = [self.searchChatGroupArray objectAtIndex:index];
            
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
            [chatViewController setValue:[groupSelected groupId] forKey:@"chatId"];
            [chatViewController setValue:YM_MESSAGE_TYPE_GROUPCHAT forKey:@"chatType"];
            
            [self.navigationController pushViewController:chatViewController animated:YES];
            break;
        }
        case kYMSearchTypeMessage: {
            // 消息
            YYSearchMessage *messageSelected = [self.searchMessageArray objectAtIndex:index];
            
            // 如果是合并信息需要跳转到详细条目页面，如果不是直接打开对话
            if (messageSelected.mergeCount > 1) {
                SearchDetailViewController *searchDetailViewController = [[SearchDetailViewController alloc] initWithNibName:@"SearchDetailViewController" bundle:nil];
                
                searchDetailViewController.searchKey = self.searchKey;
                
                if ([messageSelected direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                    searchDetailViewController.chatId = [messageSelected fromId];
                } else {
                    searchDetailViewController.chatId = [messageSelected toId];
                }
                
                [self.navigationController pushViewController:searchDetailViewController animated:YES];
            } else {
                NSString *chatId;
                // 传参到聊天controller
                if ([messageSelected direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                    chatId = [messageSelected fromId];
                } else {
                    chatId = [messageSelected toId];
                }
                NSString *chatType = [messageSelected chatType];
                
                ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
                [chatViewController setValue:chatId forKey:@"chatId"];
                [chatViewController setValue:chatType forKey:@"chatType"];
                chatViewController.pid = messageSelected.pid;
                [self.navigationController pushViewController:chatViewController animated:YES];
            }
            break;
        }
        default:
            break;
    }
}

/**
 *  重新设置searchdisplaycontroller的默认背景
 *
 *  @param dimmingView
 */
- (void)updateDimmingViewChilds:(UIView *)dimmingView {
    if ([dimmingView.subviews count] == 0) {
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
        CGFloat itemWidth = screenWidth / 5.0f;
        CGFloat itemSpace = 10.0f;
        
        CGFloat width = dimmingView.frame.size.width;
        
        CGFloat contentWidth = 3 * itemWidth + 2 * itemSpace;
        CGFloat contentHeight = itemWidth;
        CGFloat imageWidth = itemWidth - 20;
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake((width - contentWidth) / 2, 40, contentWidth, contentHeight)];
        
        [dimmingView addSubview:contentView];
        
        UIView *rosterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, itemWidth, contentHeight)];
        
        UIView *chatGroupView = [[UIView alloc] initWithFrame:CGRectMake(itemWidth + itemSpace, 0, itemWidth, contentHeight)];
        
        UIView *messageView = [[UIView alloc] initWithFrame:CGRectMake(2 *itemWidth + 2 *itemSpace, 0, itemWidth, contentHeight)];
        
        [contentView addSubview:rosterView];
        [contentView addSubview:chatGroupView];
        [contentView addSubview:messageView];
        
        UIImageView *rosterImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, imageWidth, imageWidth)];
        [rosterImageView setImage:[UIImage imageNamed:@"search_roster"]];
        UILabel *rosterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageWidth, itemWidth, 20)];
        [rosterLabel setText:@"好友"];
        [rosterLabel setFont:[UIFont systemFontOfSize:12]];
        [rosterLabel setTextColor:UIColorFromRGB(0xdddddd)];
        [rosterLabel setTextAlignment:NSTextAlignmentCenter];
        
        [rosterView addSubview:rosterImageView];
        [rosterView addSubview:rosterLabel];
        
        UIImageView *chatGroupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, imageWidth, imageWidth)];
        [chatGroupImageView setImage:[UIImage imageNamed:@"search_chatgroup"]];
        UILabel *chatGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageWidth, itemWidth, 20)];
        [chatGroupLabel setText:@"群组"];
        [chatGroupLabel setFont:[UIFont systemFontOfSize:12]];
        [chatGroupLabel setTextColor:UIColorFromRGB(0xdddddd)];
        [chatGroupLabel setTextAlignment:NSTextAlignmentCenter];
        
        [chatGroupView addSubview:chatGroupImageView];
        [chatGroupView addSubview:chatGroupLabel];
        
        UIImageView *messageImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, imageWidth, imageWidth)];
        [messageImageView setImage:[UIImage imageNamed:@"search_message"]];
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageWidth, itemWidth, 20)];
        [messageLabel setText:@"消息"];
        [messageLabel setFont:[UIFont systemFontOfSize:12]];
        [messageLabel setTextColor:UIColorFromRGB(0xdddddd)];
        [messageLabel setTextAlignment:NSTextAlignmentCenter];
        
        [messageView addSubview:messageImageView];
        [messageView addSubview:messageLabel];
    }
}

@end
