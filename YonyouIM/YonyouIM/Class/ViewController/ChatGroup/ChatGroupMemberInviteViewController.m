//
//  ChatGroupMemberInviteViewController.m
//  YonyouIM
//
//  Created by yanghao on 15/11/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatGroupMemberInviteViewController.h"
#import "SingleLineSelCell.h"
#import "UINavigationController+YMInvite.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"

@interface ChatGroupMemberInviteViewController ()<YYIMChatDelegate, YMInviteDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSArray *memberArray;

@property (retain, nonatomic) UIBarButtonItem *confirmBtn;

@property (retain, nonatomic) NSArray *memberIdArray;

@end

@implementation ChatGroupMemberInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.actionName;
    self.confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
    UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [self.confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.confirmBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.confirmBtn;
    
    // 注册Cell nib
    UINib *singleCellNib = [UINib nibWithNibName:@"SingleLineSelCell" bundle:nil];
    [self.tableView registerNib:singleCellNib forCellReuseIdentifier:@"SingleLineSelCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setInviteDelegate:self];
    
    // 注册委托
    [[YYIMChat sharedInstance].chatManager addDelegate:self];
    
    NSInteger selectedCount = [self.navigationController selectedUserArray].count;
    [self refreshConfirmStatus:selectedCount];
    
    // 获取群组成员
    [self loadData];
    
    [self.navigationController generateToolbar];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
    
    SingleLineSelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineSelCell"];
    [cell setImageRadius:16];
    
    [cell setHeadImageWithUrl:[member getMemberPhoto] placeholderName:[member memberName]];
    [cell setName:[member memberName]];
    
    if ([self.navigationController isUserDisabled:[member memberId]]) {
        [cell setSelectEnable:NO];
    }
    
    UINavigationController *navController = [self navigationController];
    
    if ([navController isUserSelected:[member memberId]]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
    
    if ([self.navigationController isUserDisabled:[member memberId]]) {
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
    
    [[self navigationController] setUserSelectState:[member memberId] info:member isSelect:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYChatGroupMember *member = [self.memberArray objectAtIndex:indexPath.row];
    
    [[self navigationController] setUserSelectState:[member memberId] info:member isSelect:NO];
}

#pragma mark yminvite delegate

- (void)didSelectChangeWithCount:(NSInteger)count {
    [self refreshConfirmStatus:count];
}

- (void)didUserUnSelect:(NSString *)userId withObject:(id)userObj {
    [self.tableView reloadData];
}

#pragma mark private

/**
 *  点击确认按钮
 */
- (void)confirmAction {
    if (self.inviteDelegate && [self.inviteDelegate respondsToSelector:@selector(didConfirmInviteActionViewController:)]) {
        [self.inviteDelegate didConfirmInviteActionViewController:self];
    }
}

/**
 *  加载成员列表
 */
- (void)loadData {
    NSMutableArray *memberArray = (NSMutableArray *)[[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:self.groupId];
    YYChatGroupMember *member;
    for (YYChatGroupMember *groupMember in memberArray) {
        if ([[groupMember memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            member = groupMember;
            break;
        }
    }
    if (member) {
        [memberArray removeObject:member];
    }
    self.memberArray = memberArray;
    [self.tableView reloadData];
}

/**
 *  根据选择数量设置确认按钮的状态
 *
 *  @param count 选择数量
 */
- (void)refreshConfirmStatus:(NSInteger)count{
    if (self.inviteDelegate && [self.inviteDelegate respondsToSelector:@selector(getDefaultCount)]) {
        NSInteger defaultCount = [self.inviteDelegate getDefaultCount];
        
        if (defaultCount > 0) {
            count = count + defaultCount;
        }
    }
    
    if (count > 0) {
        [self.confirmBtn setTitle:[NSString stringWithFormat:@"确定(%ld)", (long)count]];
        [self.confirmBtn setEnabled:YES];
    } else {
        [self.confirmBtn setTitle:@"确定"];
        [self.confirmBtn setEnabled:NO];
    }
}

@end
