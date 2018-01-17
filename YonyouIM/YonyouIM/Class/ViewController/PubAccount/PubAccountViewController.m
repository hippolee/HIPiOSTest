//
//  PubAccountViewController.m
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "PubAccountViewController.h"
#import "ChatViewController.h"
#import "SingleLineCell.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "UIColor+YYIMTheme.h"
#import "TableBackgroundView.h"
#import "FollowPubAccountController.h"
#import "UIImage+YYIMCategory.h"

@interface PubAccountViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@property (retain, nonatomic) NSArray *pubAccountArray;

@end

@implementation PubAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"公共号";
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 加载数据
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.pubAccountArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell";
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setImageRadius:16];
    // 取数据
    YYPubAccount *account = [self.pubAccountArray objectAtIndex:indexPath.row];
    // 为cell设置数据
    [cell.iconImage setImage:[UIImage imageWithDispName:[account accountName] coreIcon:@"icon_pubaccount_core"]];
    [cell setName:[account accountName]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    YYPubAccount *account = [self.pubAccountArray objectAtIndex:indexPath.row];
    [chatViewController setValue:[account accountId] forKey:@"chatId"];
    [chatViewController setValue:YM_MESSAGE_TYPE_PUBACCOUNT forKey:@"chatType"];
    
    [self.navigationController pushViewController:chatViewController animated:YES];
    // 取消行选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    YYPubAccount *account = [self.pubAccountArray objectAtIndex:indexPath.row];
    if ([account accountType] == YYIM_ACCOUNT_TYPE_SUBSCRIBE) {
        return YES;
    }
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"取消关注";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        YYPubAccount *account = [self.pubAccountArray objectAtIndex:indexPath.row];
        [[YYIMChat sharedInstance].chatManager unFollowPubAccount:[account accountId]];
    }
}

#pragma mark chat delegate

- (void)didPubAccountChange {
    [self reloadData];
}

#pragma mark private func

- (void)followPubAccountAction:(id)sender {
    FollowPubAccountController *followPubAccountController = [[FollowPubAccountController alloc] initWithNibName:@"FollowPubAccountController" bundle:nil];
    [self.navigationController pushViewController:followPubAccountController animated:YES];
}

- (void)reloadData {
    self.pubAccountArray = [[YYIMChat sharedInstance].chatManager getAllPubAccount];
    [self.tableView reloadData];
    
    if (self.pubAccountArray.count > 0) {
        if (self.emptyBgView) {
            [self.emptyBgView removeFromSuperview];
        }
    } else {
        if (!self.emptyBgView) {
            TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"还没有关注公共号哦" type:kYYIMTableBackgroundTypeNormal];
            [self.view insertSubview:emptyBgView aboveSubview:self.tableView];
            
            [emptyBgView addBtnTarget:self action:@selector(followPubAccountAction:) forControlEvents:UIControlEventTouchUpInside];
            self.emptyBgView = emptyBgView;
        }
    }
}

@end
