//
//  SearchUserInviteViewController.m
//  YonyouIM
//
//  Created by yanghao on 15/11/16.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "SearchUserInviteViewController.h"
#import "YYIMUtility.h"
#import "UINavigationController+YMInvite.h"
#import "SingleLineSelCell.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMColorHelper.h"
#import "TableBackgroundView.h"

@interface SearchUserInviteViewController ()<YYIMChatDelegate, YMInviteDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (retain, nonatomic) UIBarButtonItem *confirmBtn;

@property (retain, nonatomic) NSArray *searchUserArray;

@end

@implementation SearchUserInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.actionName;
    
    self.confirmBtn = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction)];
    UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
    [self.confirmBtn setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.confirmBtn.tintColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = self.confirmBtn;
    
    // searchBar背景色
    [[self searchBar] setBackgroundImage:[YYIMUtility imageWithColor:UIColorFromRGB(0xefeff4)]];
    
    // 注册Cell nib
    UINib *singleCellNib = [UINib nibWithNibName:@"SingleLineSelCell" bundle:nil];
    [self.tableView registerNib:singleCellNib forCellReuseIdentifier:@"SingleLineSelCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    [self initEmptyView];
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
    
    [self.navigationController generateToolbar];
    
    [self.searchBar becomeFirstResponder];
}

- (void)searchAction:(id)sender {
    [self.searchBar becomeFirstResponder];
}

#pragma mark emptyView

- (void)initEmptyView {
    TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.searchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"输入关键字开始搜索" type:kYYIMTableBackgroundTypeSearch];
    [self.view insertSubview:emptyBgView aboveSubview:self.tableView];
    
    [emptyBgView addBtnTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    self.emptyBgView = emptyBgView;
}

#pragma mark table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchUserArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    SingleLineSelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineSelCell"];
    [cell reuse];
    [cell setImageRadius:16];
    
    // 取数据
    YYUser *user = [self.searchUserArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell setHeadImageWithUrl:[user userPhoto] placeholderName:[user userName]];
    [cell setName:[user userName]];
    
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
    YYUser *user = [self.searchUserArray objectAtIndex:indexPath.row];
    
    if ([self.navigationController isUserDisabled:[user userId]]) {
        return nil;
    }
    
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYUser *user = [self.searchUserArray objectAtIndex:indexPath.row];
    
    [[self navigationController] setUserSelectState:[user userId] info:user isSelect:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYUser *user = [self.searchUserArray objectAtIndex:indexPath.row];
    
    [[self navigationController] setUserSelectState:[user userId] info:user isSelect:NO];
}

#pragma mark searchbar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *text =  searchBar.text;
    
    if (!text || [text length] <= 0) {
        [self showHint:@"请输入关键字"];
        return;
    }
    
    [searchBar resignFirstResponder];
    
    [[[YYIMChat sharedInstance] chatManager] searchUserWithKeyword:text];
    
    [self showThemeHudInView:self.view];
}

#pragma mark chat delegate

- (void)didReceiveUserSearchResult:(NSArray *)userArray {
    [self hideHud];
    
    self.searchUserArray = userArray;
    
    [self.tableView reloadData];
    
    if (self.searchUserArray.count > 0) {
        [self.emptyBgView setHidden:YES];
    } else {
        [self.emptyBgView setHidden:NO];
        [self.emptyBgView setTitleText:@"没有搜到结果哦"];
    }
}

-(void)didNotReceiveUserSearchResult:(YYIMError *)error {
    [self hideHud];
    
    NSLog(@"not found user");
    self.searchUserArray = [NSArray array];
    [self.tableView reloadData];
    
    [self.emptyBgView setHidden:NO];
    [self.emptyBgView setTitleText:@"搜索出错了，请重试"];
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
