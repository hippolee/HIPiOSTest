//
//  ChatGroupViewController.m
//  YonyouIM
//
//  Created by litfb on 15/1/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatGroupViewController.h"
#import "ChatViewController.h"
#import "ChatSelNavController.h"
#import "SingleLineCell.h"
#import "YYIMUtility.h"
#import "YYIMUIDefs.h"
#import "UIColor+YYIMTheme.h"
#import "TableBackgroundView.h"
#import "JoinChatGroupViewController.h"

@interface ChatGroupViewController ()

@property (weak, nonatomic) IBOutlet UITableView *groupTableView;

@property (retain, nonatomic) TableBackgroundView *emptyBgView;

@property (retain, nonatomic) NSArray *groupArray;

@end

@implementation ChatGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"群组";
    
    // 注册Cell nib
    [self.groupTableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.groupTableView];    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 加载数据
    [self reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    if ([self.navigationController isKindOfClass:[ChatSelNavController class]]) {
        [[(ChatSelNavController *)self.navigationController chatSelDelegate] didSelectChatId:[groupSelected groupId] chatType:YM_MESSAGE_TYPE_GROUPCHAT];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
        [chatViewController setValue:[groupSelected groupId] forKey:@"chatId"];
        [chatViewController setValue:YM_MESSAGE_TYPE_GROUPCHAT forKey:@"chatType"];
        
        [self.navigationController pushViewController:chatViewController animated:YES];
    }
    // 取消行选中状态
    [self.groupTableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark chat delegate

- (void)didChatGroupCreateWithSeriId:(NSString *)seriId group:(YYChatGroup *)group {
    [self reloadData];
}

- (void)didChatGroupInfoUpdate {
    [self reloadData];
}

- (void)didLeaveChatGroup:(NSString *)groupId {
    [self reloadData];
}

#pragma mark private func

- (void)joinGroupAction:(id)sender {
    JoinChatGroupViewController *joinChatGroupViewController = [[JoinChatGroupViewController alloc] initWithNibName:@"JoinChatGroupViewController" bundle:nil];
    [self.navigationController pushViewController:joinChatGroupViewController animated:YES];
}

- (void)reloadData {
    self.groupArray = [[YYIMChat sharedInstance].chatManager getAllChatGroups];
    [self.groupTableView reloadData];
    
    if (self.groupArray.count > 0) {
        if (self.emptyBgView) {
            [self.emptyBgView removeFromSuperview];
        }
    } else {
        if (!self.emptyBgView) {
            TableBackgroundView *emptyBgView = [[TableBackgroundView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)) title:@"还没有加入群组哦" type:kYYIMTableBackgroundTypeNormal];
            [self.view insertSubview:emptyBgView aboveSubview:self.groupTableView];
            
            [emptyBgView addBtnTarget:self action:@selector(joinGroupAction:) forControlEvents:UIControlEventTouchUpInside];
            self.emptyBgView = emptyBgView;
        }
    }
}

@end
