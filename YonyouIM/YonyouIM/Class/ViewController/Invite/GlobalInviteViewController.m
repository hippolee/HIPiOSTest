//
//  GlobalInviteViewController.m
//  YonyouIM
//
//  Created by yanghao on 15/11/11.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "GlobalInviteViewController.h"
#import "YYIMUtility.h"
#import "SingleLineSelCell.h"
#import "UINavigationController+YMInvite.h"
#import "YYIMColorHelper.h"
#import "UIViewController+HUDCategory.h"
#import "ChatViewController.h"
#import "SingleLineSelCell.h"
#import "InviteViewController.h"
#import "InviteFormChatGroupViewController.h"
#import "ChatGroupMemberInviteViewController.h"
#import "SearchUserInviteViewController.h"

@interface GlobalInviteViewController ()<YYIMChatDelegate, YMInviteDelegate, YMGlobalInviteDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain, nonatomic) NSArray *rosterArray;

@property (retain, nonatomic) UIBarButtonItem *confirmBtn;

@property (retain, nonatomic) NSArray *memberIdArray;

@end

@implementation GlobalInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.actionName;
    
    [self.navigationController clearData];
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction)]];
    
    // searchBar背景色
    [[self searchBar] setBackgroundImage:[YYIMUtility imageWithColor:UIColorFromRGB(0xefeff4)]];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineSelCell" bundle:nil] forCellReuseIdentifier:@"SingleLineSelCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    self.confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
    UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [self.confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.confirmBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.confirmBtn;
    
    CGFloat tableWith  = CGRectGetWidth([UIScreen mainScreen].bounds);
    
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWith, 100.0f)];
    [headView setBackgroundColor:UIColorFromRGB(0xefeff4)];
    
    UIView *separateView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWith, 0.5f)];
    [separateView1 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    
    UIView *separateView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 32.0f, tableWith, 0.5f)];
    [separateView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    
    UIView *separateView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 100.0f, tableWith, 0.5f)];
    [separateView3 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    
    //title zone
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableWith, 32.0f)];
    [titleView setBackgroundColor:UIColorFromRGB(0xefeff4)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 4.0f, tableWith - 20.0f, 24.0f)];
    [titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [titleLabel setTextColor:UIColorFromRGB(0x858E99)];
    titleLabel.text = @"从以下分组选择";
    
    [titleView addSubview:titleLabel];
    
    //choice zone
    UIView *choiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 32.0f, tableWith, 68.0f)];
    [choiceView setBackgroundColor:UIColorFromRGB(0xffffff)];
    
    CGFloat buttonWith = 60.0f;
    CGFloat buttomMargin = (tableWith - 40 - 3 * buttonWith) / 2;
    
    UIButton *groupButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWith + 20.0f + buttomMargin, 4.0f, buttonWith, 60.0f)];
    [groupButton setBackgroundColor:[UIColor clearColor]];
    [groupButton setImage:[UIImage imageNamed:@"icon_chatgroup"] forState:UIControlStateNormal];
    [groupButton setTitle:@"群组聊天" forState:UIControlStateNormal];
    [groupButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    groupButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [groupButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10.0f, 20.0f, 10.0f)];
    [groupButton setTitleEdgeInsets:UIEdgeInsetsMake(42.0f, -40.f, 0, 0)];
    [groupButton addTarget:self action:@selector(useChatGroupView) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rosterButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonWith * 2 + 20.0f + buttomMargin * 2, 4.0f, buttonWith, 60.0f)];
    [rosterButton setBackgroundColor:[UIColor clearColor]];
    [rosterButton setImage:[UIImage imageNamed:@"icon_roster"] forState:UIControlStateNormal];
    [rosterButton setTitle:@"联系人列表" forState:UIControlStateNormal];
    [rosterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rosterButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [rosterButton setImageEdgeInsets:UIEdgeInsetsMake(0, 10.0f, 20.0f, 10.0f)];
    [rosterButton setTitleEdgeInsets:UIEdgeInsetsMake(42.0f, -40.f, 0, 0)];
    [rosterButton addTarget:self action:@selector(useRosterView) forControlEvents:UIControlEventTouchUpInside];
    
    [choiceView addSubview:groupButton];
    [choiceView addSubview:rosterButton];
    
    //all zone
    [headView addSubview:titleView];
    [headView addSubview:separateView1];
    [headView addSubview:separateView2];
    [headView addSubview:choiceView];
    [headView addSubview:separateView3];
    
    [self.tableView setTableHeaderView:headView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setInviteDelegate:self];    
    // 注册委托
    [[YYIMChat sharedInstance].chatManager addDelegate:self];
    
    // 最近联系人列表
    [self reload];
    
    NSInteger selectedCount = [self.navigationController selectedUserArray].count;
    [self refreshConfirmStatus:selectedCount];
    
    [self.navigationController generateToolbar];
}

#pragma mark searchbar delegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    //弹出新的搜索页面
    SearchUserInviteViewController *searchUserInviteViewController = [[SearchUserInviteViewController alloc] initWithNibName:@"SearchUserInviteViewController" bundle:nil];
    
    searchUserInviteViewController.inviteDelegate = self;
    searchUserInviteViewController.actionName = self.actionName;
    
    [self.navigationController pushViewController:searchUserInviteViewController animated:YES];
    
    return NO;
}

#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"最近联系人";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.rosterArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
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
    static NSString *CellIndentifier = @"SingleLineSelCell";
    SingleLineSelCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell setImageRadius:16.0f];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    // 取数据
    NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
    
    NSString *name;
    YYUser *user;
    NSString *photo;
    
    if ([obj isKindOfClass:[YYRoster class]]) {
        name = [(YYRoster *)obj rosterAlias];
        photo = [(YYRoster *)obj getRosterPhoto];
        user = [(YYRoster *)obj user];
    } else if ([obj isKindOfClass:[YYUser class]]) {
        name = [(YYUser *)obj userName];
        photo = [(YYUser *)obj getUserPhoto];
        user = (YYUser *)obj;
    }
    
    [cell setName:name];
    [cell setHeadImageWithUrl:photo placeholderName:name];
    
    if ([self.navigationController isUserDisabled:[user userId]]) {
        [cell setSelectEnable:NO];
    }
    
    UINavigationController *navController = [self navigationController];
    
    if ([navController isUserSelected:[user userId]]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
    
    NSString *chatId;
    if ([obj isKindOfClass:[YYRoster class]]) {
        chatId = [(YYRoster *)obj rosterId];
    } else if ([obj isKindOfClass:[YYUser class]]) {
        chatId = [(YYUser *)obj userId];
    }
    
    if ([self.navigationController isUserDisabled:chatId]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
    
    NSString *chatId;
    if ([obj isKindOfClass:[YYRoster class]]) {
        chatId = [(YYRoster *)obj rosterId];
    } else if ([obj isKindOfClass:[YYUser class]]) {
        chatId = [(YYUser *)obj userId];
    }
    
    [[self navigationController] setUserSelectState:chatId info:obj isSelect:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
    
    NSString *chatId;
    if ([obj isKindOfClass:[YYRoster class]]) {
        chatId = [(YYRoster *)obj rosterId];
    } else if ([obj isKindOfClass:[YYUser class]]) {
        chatId = [(YYUser *)obj userId];
    }
    
    [[self navigationController] setUserSelectState:chatId info:obj isSelect:NO];
}

#pragma mark yminvite delegate

- (void)didSelectChangeWithCount:(NSInteger)count {
    [self refreshConfirmStatus:count];
}

- (void)didUserUnSelect:(NSString *)userId withObject:(id)userObj {
    [self.tableView reloadData];
}

#pragma mark InviteDelegate

- (void)didConfirmInviteActionViewController:(UIViewController *)viewController{
    [self confirmActionByChild:viewController];
}

- (NSInteger)getDefaultCount {
    return self.defaultCount;
}

#pragma mark private

/**
 *  因为是邀请的根页面所以彻底关闭
 */
- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
    [self.navigationController clearData];
}

- (void)reload {
    if (self.groupId) {
        NSArray *memberArray = [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:self.groupId];
        if (memberArray && memberArray.count > 0) {
            NSMutableArray *ary = [NSMutableArray arrayWithCapacity:memberArray.count];
            
            for (YYChatGroupMember *member in memberArray) {
                [ary addObject:[member memberId]];
            }
            
            self.memberIdArray = ary;
        }
    } else if (self.userId) {
        self.memberIdArray = [NSArray arrayWithObject:self.userId];
    } else if (self.channelId) {
        NSArray *memberArray = [[YYIMChat sharedInstance].chatManager getNetMeetingMembersWithChannelId:self.channelId];
        
        if (memberArray && memberArray.count > 0) {
            NSMutableArray *ary = [[NSMutableArray alloc] initWithCapacity:memberArray.count];
            
            for (YYNetMeetingMember *member in memberArray) {
                switch (member.inviteState) {
                    case kYYIMNetMeetingInviteStateJoined:
                    case kYYIMNetMeetingInviteStateInviting:
                    case kYYIMNetMeetingInviteStateTimeout:
                    case kYYIMNetMeetingInviteStateBusy:
                        [ary addObject:member.memberId];
                        break;
                    default:
                        break;
                }
            }
            
            self.memberIdArray = ary;
        }
    } else if (self.disableUserIds) {
        self.memberIdArray = self.disableUserIds;
    }
    
    //自己也是不可选择的
    NSString *selfUserId = [[YYIMConfig sharedInstance] getUser];
    if (!self.memberIdArray) {
        self.memberIdArray = [[NSArray alloc] initWithObjects:selfUserId, nil];
    } else {
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.memberIdArray];
        [array addObject:selfUserId];
        
        self.memberIdArray = array;
    }
    
    [self.navigationController setDisableUserIdArray:self.memberIdArray];
    
    self.rosterArray = [[YYIMChat sharedInstance].chatManager getRecentRoster];
    [self.tableView reloadData];
}

/**
 *  确定的行为
 */
- (void)confirmAction {    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didGlobalInviteViewController:InviteUsers:)]) {
        [self.delegate didGlobalInviteViewController:self InviteUsers:[self.navigationController selectedUserArray]];
    }
}

- (void)confirmActionByChild:(UIViewController *)viewController {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didGlobalInviteViewController:InviteUsers:)]) {
        [self.delegate didGlobalInviteViewController:viewController InviteUsers:[self.navigationController selectedUserArray]];
    }
}

/**
 *  根据选择数量设置确认按钮的状态
 *
 *  @param count 选择数量
 */
- (void)refreshConfirmStatus:(NSInteger)count{
    if (self.defaultCount > 0) {
        count = count + self.defaultCount;
    }
    
    if (count > 0) {
        [self.confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)", (long)count]];
        [self.confirmBtn setEnabled:YES];
    } else {
        [self.confirmBtn setTitle:@"确定"];
        [self.confirmBtn setEnabled:NO];
    }
}

/**
 *  通过群组选择
 */
- (void)useChatGroupView{
    InviteFormChatGroupViewController *chatGroupViewController = [[InviteFormChatGroupViewController alloc] initWithNibName:@"InviteFormChatGroupViewController" bundle:nil];
    chatGroupViewController.inviteDelegate = self;
    chatGroupViewController.actionName = self.actionName;
    
    [self.navigationController pushViewController:chatGroupViewController animated:YES];
}

/**
 *  通过常用联系人选择
 */
- (void)useRosterView{    
    InviteViewController *inviteViewController = [[InviteViewController alloc] initWithNibName:@"InviteViewController" bundle:nil];
    
    inviteViewController.inviteDelegate = self;
    inviteViewController.actionName = self.actionName;
        
    [self.navigationController pushViewController:inviteViewController animated:YES];
}

@end
