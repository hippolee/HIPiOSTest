//
//  RosterInviteViewController.m
//  YonyouIM
//
//  Created by litfb on 15/1/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "RosterInviteViewController.h"

#import "NormalTableViewCell.h"
#import "UIViewController+HUDCategory.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "TableBackgroundView.h"
#import "AddRosterViewController.h"

@interface RosterInviteViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@property (retain, nonatomic) NSArray *inviteArray;

@end

@implementation RosterInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"好友邀请";
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"NormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalTableViewCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark tableview

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.inviteArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"NormalTableViewCell";
    NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    // 取数据
    YYRoster *invite = [self.inviteArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell setHeadImageWithUrl:[invite.user getUserPhoto] placeholderName:[invite.user userName]];
    [cell setName:[invite.user userName]];
    [cell setDetail:[NSString stringWithFormat:@"%@请求添加您为好友", invite.user ? [invite.user userName] : @""]];
    [cell setOptionWidth:100];
    [cell setOption:@"拒绝"];
    [cell.optionButton addTarget:self action:@selector(refuseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell setOption2:@"同意"];
    [cell.optionButton2 addTarget:self action:@selector(acceptBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YYRoster *roster = [self.inviteArray objectAtIndex:[indexPath row]];
        [[YYIMChat sharedInstance].chatManager refuseRosterInvite:[roster rosterId]];
        [self reloadData];
    }
}

#pragma mark yyimchat delegate

- (void)didUserInfoUpdate {
    [self reloadData];
}

- (void)didRosterChange {
    [self reloadData];
}

#pragma mark private func

- (void)acceptBtnClick:(UIButton *)sender {
    // 点击cell
    NormalTableViewCell *cell =(NormalTableViewCell *)[YYIMUtility superCellForView:sender];
    // indexPath
    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
    if ([self.inviteArray count] <= indexPath.row) {
        return;
    }
    // 取数据
    YYRoster *invite = [self.inviteArray objectAtIndex:indexPath.row];
    // 发送好友请求
    [[YYIMChat sharedInstance].chatManager acceptRosterInvite:[invite rosterId]];
}

- (void)refuseBtnClick:(UIButton *)sender {
    // 点击cell
    NormalTableViewCell *cell =(NormalTableViewCell *)[YYIMUtility superCellForView:sender];
    // indexPath
    NSIndexPath *indexPath =[self.tableView indexPathForCell:cell];
    if ([self.inviteArray count] <= indexPath.row) {
        return;
    }
    // 取数据
    YYRoster *invite = [self.inviteArray objectAtIndex:indexPath.row];
    // 发送好友请求
    [[YYIMChat sharedInstance].chatManager refuseRosterInvite:[invite rosterId]];
}

- (void)addRosterAction:(id)sender {
    AddRosterViewController *addRosterViewController = [[AddRosterViewController alloc] initWithNibName:@"AddRosterViewController" bundle:nil];
    [self.navigationController pushViewController:addRosterViewController animated:YES];
}

- (void)reloadData {
    self.inviteArray = [[YYIMChat sharedInstance].chatManager getAllRosterInvite];
    [self.tableView reloadData];
    
    if (self.inviteArray.count > 0) {
        if (self.emptyBgView) {
            [self.emptyBgView removeFromSuperview];
        }
    } else {
        if (!self.emptyBgView) {
            TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"还没有好友邀请哦" type:kYYIMTableBackgroundTypeNormal];
            [self.view insertSubview:emptyBgView aboveSubview:self.tableView];
            
            [emptyBgView addBtnTarget:self action:@selector(addRosterAction:) forControlEvents:UIControlEventTouchUpInside];
            self.emptyBgView = emptyBgView;
        }
    }
}

@end
