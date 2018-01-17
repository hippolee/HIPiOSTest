//
//  FollowPubAccountController.m
//  YonyouIM
//
//  Created by litfb on 15/1/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "FollowPubAccountController.h"

#import "NormalTableViewCell.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "YYIMColorHelper.h"
#import "TableBackgroundView.h"
#import "UIColor+YYIMTheme.h"
#import "UIImage+YYIMCategory.h"

@interface FollowPubAccountController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@property (retain, nonatomic) NSArray *pubAccountArray;

@property (retain, nonatomic) NSDictionary *accountDic;

@end

@implementation FollowPubAccountController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查找公共号";
    
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
    [self loadPubAccountData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)searchAction:(id)sender {
    [self.searchBar becomeFirstResponder];
}

#pragma mark emptyView

- (void)initEmptyView {
    TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.searchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"输入公共号名称开始搜索" type:kYYIMTableBackgroundTypeSearch];
    [self.view insertSubview:emptyBgView aboveSubview:self.tableView];
    
    [emptyBgView addBtnTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    self.emptyBgView = emptyBgView;
}

#pragma mark tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pubAccountArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"NormalTableViewCell";
    NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setOptionWidth:46];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    // 取数据
    YYPubAccount *account = [self.pubAccountArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell.headImage setImage:[UIImage imageWithDispName:[account accountName] coreIcon:@"icon_pubaccount_core"]];
    [cell setName2WithAttrString:[YYIMUtility attributeStringWithString:[account accountName] keyword:self.searchBar.text hilightColor:[UIColor themeBlueColor]]];
    if ([self.accountDic objectForKey:[account accountId]]) {
        [cell setState:@"已关注"];
    } else {
        [cell setOption2:@"关注"];
        [cell.optionButton2 addTarget:self action:@selector(optionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void) optionBtnClick:(UIButton *)sender {
    // 点击cell
    NormalTableViewCell *cell =(NormalTableViewCell *)[YYIMUtility superCellForView:sender];
    if (!cell) {
        return;
    }
    // indexPath
    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
    // 取数据
    YYPubAccount *account = [self.pubAccountArray objectAtIndex:indexPath.row];
    // 发送好友请求
    [[YYIMChat sharedInstance].chatManager followPubAccount:[account accountId]];
    // hint
    [self showHint:@"已关注"];
}

#pragma mark searchbar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *keyword = [searchBar text];
    if (!keyword || [keyword length] <= 0) {
        [self showHint:@"请输入关键字"];
    }
    [self showThemeHudInView:self.view];
    // search
    [[YYIMChat sharedInstance].chatManager searchPubAccountWithKeyword:keyword];
    [self.searchBar resignFirstResponder];
}

#pragma mark yyimchatdelegate

- (void)didReceivePubAccountSearchResult:(NSArray *)pubAccountArray {
    self.pubAccountArray = pubAccountArray;
    [self.tableView reloadData];
    [self hideHud];
    
    if (self.pubAccountArray.count > 0) {
        [self.emptyBgView setHidden:YES];
    } else {
        [self.emptyBgView setHidden:NO];
        [self.emptyBgView setTitleText:@"没有搜到结果哦"];
    }
}

- (void)didNotReceivePubAccountSearchResult:(YYIMError *)error {
    [self hideHud];
    
    [self.emptyBgView setHidden:NO];
    [self.emptyBgView setTitleText:@"搜索出错了，请重试"];
}

- (void)didPubAccountChange {
    [self loadPubAccountData];
}

#pragma mark private

- (void)loadPubAccountData {
    // 取关注列表
    NSArray *accountArray = [[YYIMChat sharedInstance].chatManager getAllPubAccount];
    NSMutableDictionary *accountDic = [[NSMutableDictionary alloc] initWithCapacity:[accountArray count]];
    for (YYPubAccount *account in accountArray) {
        [accountDic setObject:account forKey:[account accountId]];
    }
    self.accountDic = accountDic;
    [self.tableView reloadData];
}

@end
