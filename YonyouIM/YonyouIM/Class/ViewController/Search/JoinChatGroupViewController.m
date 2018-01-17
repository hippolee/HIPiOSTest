//
//  JoinChatGroupViewController.m
//  YonyouIM
//
//  Created by litfb on 15/1/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JoinChatGroupViewController.h"

#import "NormalTableViewCell.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "YYIMColorHelper.h"
#import "TableBackgroundView.h"
#import "UIColor+YYIMTheme.h"

@interface JoinChatGroupViewController ()

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@property (retain, nonatomic) NSArray *chatGroupArray;

@property (retain, nonatomic) NSDictionary *groupDic;

@end

@implementation JoinChatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"查找群";
    
    // searchBar背景色
    [[self searchBar] setBackgroundImage:[YYIMUtility imageWithColor:UIColorFromRGB(0xefeff4)]];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"NormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalTableViewCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
    
    [self initEmptyView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadChatGroupData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)searchAction:(id)sender {
    [self.searchBar becomeFirstResponder];
}

#pragma mark emptyView

- (void)initEmptyView {
    TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.searchBar.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"输入群组名称开始搜索" type:kYYIMTableBackgroundTypeSearch];
    [self.view insertSubview:emptyBgView aboveSubview:self.tableView];
    
    [emptyBgView addBtnTarget:self action:@selector(searchAction:) forControlEvents:UIControlEventTouchUpInside];
    self.emptyBgView = emptyBgView;
}

#pragma mark tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chatGroupArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"NormalTableViewCell";
    NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setOptionWidth:46];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    // 取数据
    YYChatGroup *group = [self.chatGroupArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell setHeadIcon:@"icon_chatgroup"];
    [cell setName2WithAttrString:[YYIMUtility attributeStringWithString:[group groupName] keyword:self.searchBar.text hilightColor:[UIColor themeBlueColor]]];
    if ([self.groupDic objectForKey:[group groupId]]) {
        [cell setState:@"已加入"];
    } else {
        [cell setOption2:@"加入"];
        [cell.optionButton2 addTarget:self action:@selector(optionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (void)optionBtnClick:(UIButton *)sender {
    // 点击cell
    NormalTableViewCell *cell =(NormalTableViewCell *)[YYIMUtility superCellForView:sender];
    if (!cell) {
        return;
    }
    // indexPath
    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
    // 取数据
    YYChatGroup *group = [self.chatGroupArray objectAtIndex:indexPath.row];
    // 发送好友请求
    [[YYIMChat sharedInstance].chatManager joinChatGroup:[group groupId]];
}

#pragma mark searchbar

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSString *keyword = [searchBar text];
    if (!keyword || [keyword length] <= 0) {
        [self showHint:@"请输入关键字"];
    }
    [self showThemeHudInView:self.view];
    // search
    [[YYIMChat sharedInstance].chatManager searchChatGroupWithKeyword:keyword];
    [self.searchBar resignFirstResponder];
}

#pragma mark yyimchatdelegate

- (void)didReceiveChatGroupSearchResult:(NSArray *)groupArray {
    self.chatGroupArray = groupArray;
    [self.tableView reloadData];
    [self hideHud];
    
    if (self.chatGroupArray.count > 0) {
        [self.emptyBgView setHidden:YES];
    } else {
        [self.emptyBgView setHidden:NO];
        [self.emptyBgView setTitleText:@"没有搜到结果哦"];
    }

}

- (void)didNotReceiveChatGroupSearchResult:(YYIMError *)error {
    [self hideHud];
    
    [self.emptyBgView setHidden:NO];
    [self.emptyBgView setTitleText:@"搜索出错了，请重试"];
}

- (void)didChatGroupInfoUpdate {
    [self loadChatGroupData];
}

- (void)didJoinChatGroup:(NSString *)groupId {
    // hint
    [self showHint:@"已加入"];
}

- (void)didNotJoinChatGroup:(NSString *)groupId error:(YYIMError *)error {
    // hint
    NSRange range = [[error errorMsg] rangeOfString:@"limit"];
    
    if (range.location != NSNotFound) {
        [self showHint:@"加入群组失败，群组人数已达到上限"];
    } else {
        [self showHint:@"加入群组失败"];
    }
}

#pragma mark private

- (void)loadChatGroupData {
    // 取已加入
    NSArray *groupArray = [[YYIMChat sharedInstance].chatManager getAllChatGroups];
    NSMutableDictionary *groupDic = [[NSMutableDictionary alloc] initWithCapacity:[groupArray count]];
    for (YYChatGroup *group in groupArray) {
        [groupDic setObject:group forKey:[group groupId]];
    }
    self.groupDic = groupDic;
    [self.tableView reloadData];
}

@end
