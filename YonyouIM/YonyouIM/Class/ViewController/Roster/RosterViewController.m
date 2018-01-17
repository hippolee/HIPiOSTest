//
//  RosterViewController.m
//  YonyouIM
//
//  Created by litfb on 14/12/18.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import "RosterViewController.h"
#import "UIImageView+WebCache.h"
#import "YYIMChatHeader.h"
#import "SingleLineCell.h"
#import "ChatViewController.h"
#import "UserViewController.h"
#import "ChatSelNavController.h"
#import "AddRosterViewController.h"
#import "YYIMUtility.h"
#import "YYIMColorHelper.h"

@interface RosterViewController ()

@end

@implementation RosterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"好友列表";
    
    // searchBar背景色
    [[self searchBar] setBackgroundImage:[YYIMUtility imageWithColor:UIColorFromRGB(0xefeff4)]];
    
    // 注册Cell nib
    UINib *singleCellNib = [UINib nibWithNibName:@"SingleLineCell" bundle:nil];
    [self.rosterTableView registerNib:singleCellNib forCellReuseIdentifier:@"SingleLineCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark tableview delegate

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
    return index + 1;
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
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell"];
    [cell reuse];
    [cell setImageRadius:16];
    
    // 取数据
    YYRoster *roster = [self getDataWithIndexPath:indexPath];
    // 为cell设置数据
    [cell setHeadImageWithUrl:[roster getRosterPhoto] placeholderName:[roster rosterAlias]];
    [cell setName:[roster rosterAlias]];
    [cell showState:[roster isOnline]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YYRoster *rosterSelected = [self getDataWithIndexPath:indexPath];
    if ([self.navigationController isKindOfClass:[ChatSelNavController class]]) {
        [[(ChatSelNavController *)self.navigationController chatSelDelegate] didSelectChatId:[rosterSelected rosterId] chatType:YM_MESSAGE_TYPE_CHAT];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
        userViewController.userId = [rosterSelected rosterId];
        [self.navigationController pushViewController:userViewController animated:YES];
    }
    [self.rosterTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark yyimchat delegate

- (void)didUserInfoUpdate {
    [self loadData];
}

- (void)didRosterChange {
    [self loadData];
}

- (void)didRosterStateChange:(NSString *)rosterId {
    [self loadData];
}

@end
