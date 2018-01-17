//
//  InviteFormChatGroupViewController.m
//  YonyouIM
//
//  Created by yanghao on 15/11/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "InviteFormChatGroupViewController.h"
#import "UINavigationController+YMInvite.h"
#import "YYIMUtility.h"
#import "SingleLineCell.h"
#import "ChatGroupMemberInviteViewController.h"
#import "UIViewController+HUDCategory.h"

@interface InviteFormChatGroupViewController ()<YYIMChatDelegate, YMInviteDelegate>

@property (weak, nonatomic) IBOutlet UITableView *groupTableView;

@property (retain, nonatomic) NSArray *groupArray;

@property (retain, nonatomic) UIBarButtonItem *confirmBtn;

@end

@implementation InviteFormChatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title =self.actionName;
    
    self.confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
    UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [self.confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.confirmBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.confirmBtn;
    
    // 注册Cell nib
    [self.groupTableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.groupTableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 加载数据
    [self reloadData];
    
    [[self navigationController] setInviteDelegate:self];
    
    NSInteger selectedCount = [self.navigationController selectedUserArray].count;
    [self refreshConfirmStatus:selectedCount];
    
    [self.navigationController generateToolbar];
}

#pragma mark table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.groupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell";
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    // 取数据
    YYChatGroup *group = [self.groupArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell setGroupIcon:[group groupId]];
    [cell setName:[group groupName]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYChatGroup *groupSelected = [self.groupArray objectAtIndex:indexPath.row];
    
    ChatGroupMemberInviteViewController *chatGroupMemberInviteViewController = [[ChatGroupMemberInviteViewController alloc] initWithNibName:@"ChatGroupMemberInviteViewController" bundle:nil];
    
    chatGroupMemberInviteViewController.inviteDelegate = self.inviteDelegate;
    chatGroupMemberInviteViewController.groupId = [groupSelected groupId];
    chatGroupMemberInviteViewController.actionName = self.actionName;
    
    [self.navigationController pushViewController:chatGroupMemberInviteViewController animated:YES];
    // 取消行选中状态
    [self.groupTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark yminvite delegate

- (void)didSelectChangeWithCount:(NSInteger)count {
    [self refreshConfirmStatus:count];
}

#pragma mark private func

- (void)reloadData {
    self.groupArray = [[YYIMChat sharedInstance].chatManager getAllChatGroups];
    [self.groupTableView reloadData];
}

- (void)confirmAction {
    if (self.inviteDelegate && [self.inviteDelegate respondsToSelector:@selector(didConfirmInviteActionViewController:)]) {
        [self.inviteDelegate didConfirmInviteActionViewController:self];
    }
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
