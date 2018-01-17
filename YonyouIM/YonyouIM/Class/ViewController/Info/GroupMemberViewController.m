//
//  GroupMemberViewController.m
//  YonyouIM
//
//  Created by litfb on 16/7/9.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "GroupMemberViewController.h"
#import "YYIMChatHeader.h"
#import "YYIMColorHelper.h"
#import "YYIMUtility.h"
#import "UIColor+YYIMTheme.h"
#import "SingleLineCell.h"
#import "GlobalInviteViewController.h"
#import "UIViewController+HUDCategory.h"
#import "UINavigationController+YMInvite.h"
#import "UserViewController.h"

@interface GroupMemberViewController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate, GlobalInviteViewControllerDelegate>

@property (strong, nonatomic) NSArray *memberArray;

@property (strong, nonatomic) NSArray *dataArray;

@property (strong, nonatomic) YYChatGroup *group;

@property (assign, nonatomic) BOOL isOwner;

@property (weak, nonatomic) UISearchBar *searchBar;

@property (weak, nonatomic) UITableView *tableView;

@property (retain, nonatomic) UISearchDisplayController *searchDisplayController;

@end

@implementation GroupMemberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.searchDisplayController isActive]) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initData {
    // 群组
    self.group = [[YYIMChat sharedInstance].chatManager getChatGroupWithGroupId:self.groupId];
    // 是否管理员
    self.isOwner = [[YYIMChat sharedInstance].chatManager isGroupOwner:self.groupId];
    // 成员列表
    self.memberArray = [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:self.groupId];
}

- (void)reloadData {
    // 成员列表
    self.memberArray = [[YYIMChat sharedInstance].chatManager getGroupMembersWithGroupId:self.groupId];
    if ([self.searchDisplayController isActive]) {
        [self doSearch:[self.searchBar text]];
    }
    [self.tableView reloadData];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

- (void)initView {
    // title
    [self.navigationItem setTitle:[NSString stringWithFormat:@"群成员(%ld)", (long)[self.group memberCount]]];
    // right bar button
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(inviteAction:)]];
    // search bar
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 44.0f)];
    [searchBar setDelegate:self];
    [searchBar setTintColor:[UIColor themeBlueColor]];
    [searchBar setBarTintColor:UIColorFromRGB(0xefeff4)];
    [searchBar setTranslucent:NO];
    [searchBar setBackgroundImage:[YYIMUtility imageWithColor:UIColorFromRGB(0xefeff4)]];
    
    [YYIMUtility searchBar:searchBar setBackgroundColor:UIColorFromRGB(0xefeff4)];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame) - [self baseHeight])];
    [tableView setDelegate:self];
    [tableView setDataSource:self];
    [tableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    [tableView setTableHeaderView:searchBar];
    [tableView setSeparatorColor:UIColorFromRGB(0xf8eeee)];
    [tableView setSeparatorInset:UIEdgeInsetsMake(0, 62.0f, 0, 0)];
    [self.view addSubview:tableView];
    self.searchBar = searchBar;
    self.tableView = tableView;
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    // 初始化uisearchdisplaycontroller
    UISearchDisplayController *searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];
    [searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    [searchDisplayController.searchResultsTableView setBackgroundColor:UIColorFromRGB(0xf0eff5)];
    [searchDisplayController.searchResultsTableView setSeparatorColor:UIColorFromRGB(0xf8eeee)];
    [searchDisplayController.searchResultsTableView setSeparatorInset:UIEdgeInsetsMake(0, 62.0f, 0, 0)];
    [YYIMUtility setExtraCellLineHidden:searchDisplayController.searchResultsTableView];
    self.searchDisplayController = searchDisplayController;
    [YYIMUtility searchBar:searchBar setBackgroundColor:UIColorFromRGB(0xefeff4)];
}

#pragma mark UITableViewDelegate, UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.dataArray count];
    }
    return [self.memberArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 56.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYChatGroupMember *member;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        member = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        member = [self.memberArray objectAtIndex:indexPath.row];
    }
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell"];
    [cell setHeadImageWithUrl:[member memberPhoto] placeholderName:[member memberName]];
    [cell setName:[member memberName]];
    [cell setImageRadius:19.5f];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isOwner) {
        return NO;
    }
    
    YYChatGroupMember *member;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        member = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        member = [self.memberArray objectAtIndex:indexPath.row];
    }
    if ([[member memberId] isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        return NO;
    }
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YYChatGroupMember *member;
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            member = [self.dataArray objectAtIndex:indexPath.row];
        } else {
            member = [self.memberArray objectAtIndex:indexPath.row];
        }
        [self kickAction:[member memberId]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYChatGroupMember *member;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        member = [self.dataArray objectAtIndex:indexPath.row];
    } else {
        member = [self.memberArray objectAtIndex:indexPath.row];
    }
    UserViewController *userVC = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
    [userVC setUserId:[member memberId]];
    [self.navigationController pushViewController:userVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UISearchDisplayDelegate

-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller{
    // 处理statusbar的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    // 处理statusbar的颜色
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self doSearch:searchString];
    return YES;
}

- (void)doSearch:(NSString *)searchString {
    if ([YYIMUtility isEmptyString:searchString]) {
        self.dataArray = nil;
    } else {
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"memberName CONTAINS[cd] %@", searchString];
        self.dataArray = [self.memberArray filteredArrayUsingPredicate:pre];
    }
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"");
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"");
}

#pragma mark private

- (void)inviteAction:(id)sender {
    GlobalInviteViewController *globalInviteViewController = [[GlobalInviteViewController alloc] initWithNibName:@"GlobalInviteViewController" bundle:nil];
    globalInviteViewController.groupId = self.groupId;
    globalInviteViewController.delegate = self;
    globalInviteViewController.actionName = @"发起邀请";
    [self.navigationController pushViewController:globalInviteViewController animated:YES];
}

- (void)kickAction:(NSString *)memberId {
    [[YYIMChat sharedInstance].chatManager kickGroupMemberFromGroup:self.groupId member:memberId];
}

#pragma mark

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

#pragma mark YYIMChatDelegate

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

- (CGFloat)baseHeight {
    CGFloat navigationHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    CGFloat statusHeight = CGRectGetHeight([[UIApplication sharedApplication] statusBarFrame]);
    return navigationHeight + statusHeight;
}

@end
