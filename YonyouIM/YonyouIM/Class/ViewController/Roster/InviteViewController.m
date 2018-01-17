//
//  InviteViewController.m
//  YonyouIM
//
//  Created by litfb on 15/4/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "InviteViewController.h"
#import "YYIMUtility.h"
#import "UIViewController+HUDCategory.h"
#import "SingleLineSelCell.h"
#import "ChatViewController.h"
#import "UINavigationController+YMInvite.h"
#import "YYIMColorHelper.h"

@interface InviteViewController ()<YMInviteDelegate>

@property (retain, nonatomic) NSArray *memberIdArray;

@property (retain, nonatomic) UIBarButtonItem *confirmBtn;

@property NSString *seriId;

@end

@implementation InviteViewController

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
    [self.rosterTableView registerNib:singleCellNib forCellReuseIdentifier:@"SingleLineSelCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setInviteDelegate:self];
    
    NSInteger selectedCount = [self.navigationController selectedUserArray].count;
    [self refreshConfirmStatus:selectedCount];
    
    [self.navigationController generateToolbar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setToolbarHidden:YES];
}

- (void)confirmAction {
    if (self.inviteDelegate && [self.inviteDelegate respondsToSelector:@selector(didConfirmInviteActionViewController:)]) {
        [self.inviteDelegate didConfirmInviteActionViewController:self];
    }
}
#pragma mark table delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.letterArray count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return self.letterArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index {
    NSString *key = [self.letterArray objectAtIndex:index];
    if (key == UITableViewIndexSearch) {
        [self.rosterTableView setContentOffset:CGPointZero animated:NO];
        return NSNotFound;
    }
    return index;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return [self.letterArray objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 24;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 320, 24);
    label.font = [UIFont systemFontOfSize:14];
    [label setTextColor:UIColorFromRGB(0x4e4e4e)];
    label.text = sectionTitle;
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 24, tableView.bounds.size.width, 0.5)];
    [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 24)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    [sectionView addSubview:label];
    [sectionView addSubview:sepView];
    [sectionView addSubview:sepView2];
    return sectionView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)[self.dataDic objectForKey:[self.letterArray objectAtIndex:section]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    SingleLineSelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineSelCell"];
    [cell reuse];
    [cell setImageRadius:16];
    // 取数据
    YYRoster *roster = [self getDataWithIndexPath:indexPath];
    // 为cell设置数据
    [cell setHeadImageWithUrl:[roster getRosterPhoto] placeholderName:[roster rosterAlias]];
    [cell setName:[roster rosterAlias]];
    [cell showState:[roster isOnline]];
    
    UINavigationController *navController = [self navigationController];
    
    if ([navController isUserDisabled:[roster rosterId]]) {
        [cell setSelectEnable:NO];
    }
    
    if ([navController isUserSelected:[roster rosterId]]) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYRoster *roster = [self getDataWithIndexPath:indexPath];
    if ([self.navigationController isUserDisabled:[roster rosterId]]) {
        return nil;
    }
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYRoster *roster = [self getDataWithIndexPath:indexPath];
    [[self navigationController] setUserSelectState:[roster rosterId] info:roster isSelect:YES];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYRoster *roster = [self getDataWithIndexPath:indexPath];
    [[self navigationController] setUserSelectState:[roster rosterId] info:roster isSelect:NO];
}

#pragma mark yminvite delegate

- (void)didSelectChangeWithCount:(NSInteger)count {
    [self refreshConfirmStatus:count];
}

- (void)didUserUnSelect:(NSString *)userId withObject:(id)userObj {
    [self.rosterTableView reloadData];
}

#pragma mark private func

- (void)loadData {
    [super loadData];
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
