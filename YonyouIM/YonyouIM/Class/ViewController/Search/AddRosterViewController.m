//
//  AddRosterViewController.m
//  YonyouIM
//
//  Created by litfb on 15/1/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "AddRosterViewController.h"

#import "NormalTableViewCell.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "YYIMColorHelper.h"
#import "TableBackgroundView.h"
#import "UserViewController.h"
#import "UIColor+YYIMTheme.h"

@interface AddRosterViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@property (retain, nonatomic) NSArray *userArray;

@property (retain, nonatomic) NSDictionary *rosterDic;

@end

@implementation AddRosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"添加好友";
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"NormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalTableViewCell"];
    
    // searchBar背景色
    [[self searchBar] setBackgroundImage:[YYIMUtility imageWithColor:UIColorFromRGB(0xefeff4)]];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    [self initEmptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadRosterData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)searchAction:(id)sender {
    [self.searchBar becomeFirstResponder];
}

#pragma mark emptyView

- (void)initEmptyView {
    TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.searchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"输入好友昵称开始搜索" type:kYYIMTableBackgroundTypeSearch];
    [self.view insertSubview:emptyBgView aboveSubview:self.tableView];
    
    [emptyBgView addBtnTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    self.emptyBgView = emptyBgView;
}

#pragma mark tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.userArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"NormalTableViewCell";
    NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setOptionWidth:46];
    // 取数据
    YYUser *user = [self.userArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell setHeadImageWithUrl:[user getUserPhoto] placeholderName:[user userName]];
    if ([user userName]) {
        [cell setNameWithAttrString:[YYIMUtility attributeStringWithString:[user userName] keyword:self.searchBar.text hilightColor:[UIColor themeBlueColor]]];
    }
    if ([user userEmail]) {
        [cell setDetailWithAttrString:[YYIMUtility getHighlightContent:[user userEmail] keyword:self.searchBar.text defaultFont:cell.detailLabel.font textColor:cell.detailLabel.textColor]];
    }
    if ([self.rosterDic objectForKey:[user userId]]) {
        [cell setState:@"已添加"];
    } else {
        [cell setOption2:@"添加"];
        [cell.optionButton2 addTarget:self action:@selector(optionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取数据
    YYUser *user = [self.userArray objectAtIndex:indexPath.row];
    
    UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
    userViewController.userId = [user userId];
    [self.navigationController pushViewController:userViewController animated:YES];
    
//    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
//    chatViewController.chatId = [user userId];
//    chatViewController.chatType = YM_MESSAGE_TYPE_CHAT;
//    [self.navigationController pushViewController:chatViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)optionBtnClick:(UIButton *)sender {
    // 点击cell
    NormalTableViewCell *cell =(NormalTableViewCell *)[YYIMUtility superCellForView:sender];
    // indexPath
    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
    // 取数据
    YYUser *user = [self.userArray objectAtIndex:indexPath.row];
    // 发送好友请求
    [[YYIMChat sharedInstance].chatManager addRoster:[user userId]];
    // hint
    [self showHint:@"好友请求已发出"];
}

#pragma mark searchbar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *keyword = [searchBar text];
    if (!keyword || [keyword length] <= 0) {
        [self showHint:@"请输入关键字"];
    }
    [self showThemeHudInView:self.view];
    // search
    [[YYIMChat sharedInstance].chatManager searchUserWithKeyword:keyword];
    [self.searchBar resignFirstResponder];
}

#pragma mark yyimchatdelegate

- (void)didReceiveUserSearchResult:(NSArray *)userArray {
    self.userArray = userArray;
    [self.tableView reloadData];
    [self hideHud];
    
    if (self.userArray.count > 0) {
        [self.emptyBgView setHidden:YES];
    } else {
        [self.emptyBgView setHidden:NO];
        [self.emptyBgView setTitleText:@"没有搜到结果哦"];
    }
}

- (void)didNotReceiveUserSearchResult:(YYIMError *)error {
    [self hideHud];
    [self.emptyBgView setHidden:NO];
    [self.emptyBgView setTitleText:@"搜索出错了，请重试"];
}

- (void)didRosterChange {
    [self loadRosterData];
}

- (void)didRosterDelete:(NSString *)rosterId {
    [self loadRosterData];
}

#pragma mark private

- (void)loadRosterData {
    // 取好友
    NSArray *rosterArray = [[YYIMChat sharedInstance].chatManager getAllRosterWithAsk];
    NSMutableDictionary *rosterDic = [[NSMutableDictionary alloc] initWithCapacity:[rosterArray count]];
    for (YYRoster *roster in rosterArray) {
        [rosterDic setObject:roster forKey:[roster rosterId]];
    }
    self.rosterDic = rosterDic;
    [self.tableView reloadData];
}

@end
