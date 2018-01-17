//
//  ChatSelViewController.m
//  YonyouIM
//
//  Created by litfb on 15/6/18.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatSelViewController.h"
#import "ChatSelNavController.h"
#import "YYIMChatHeader.h"
#import "YYIMUtility.h"
#import "SingleLineCell.h"
#import "ChatViewController.h"
#import "ChatGroupViewController.h"
#import "RosterViewController.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMColorHelper.h"

@interface ChatSelViewController ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSArray *rosterArray;

@end

@implementation ChatSelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"分享";
    
    [self.navigationItem setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction:)]];
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 最近联系人列表
    [self reload];
}

- (void)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return nil;
    }
    return @"最近联系人";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return [self.rosterArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 32;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (sectionTitle == nil) {
        return nil;
    }
    
    UIView * sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 32)];
    [sectionView setBackgroundColor:UIColorFromRGB(0xf6f6f6)];
    
    UILabel * label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, 0, 320, 32);
    label.font = [UIFont systemFontOfSize:14];
    [label setTextColor:UIColorFromRGB(0xa3a3a3)];
    label.text = sectionTitle;
    [sectionView addSubview:label];
    
    UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 0.5)];
    [sepView setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView];
    
    UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 32, tableView.bounds.size.width, 0.5)];
    [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
    [sectionView addSubview:sepView2];
    return sectionView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 取cell
    static NSString *CellIndentifier = @"SingleLineCell";
    SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIndentifier];
    [cell reuse];
    [cell setImageRadius:16];
    if ([indexPath section] == 0) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        switch (indexPath.row) {
            case 0:
                [cell setHeadIcon:@"icon_chatgroup"];
                [cell setName:@"群组聊天"];
                break;
            case 1:
                [cell setHeadIcon:@"icon_roster"];
                [cell setName:@"好友列表"];
                break;
        }
        return cell;
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        // 取数据
        NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
        
        NSString *name;
        NSString *photo;
        if ([obj isKindOfClass:[YYRoster class]]) {
            name = [(YYRoster *)obj rosterAlias];
            photo = [(YYRoster *)obj getRosterPhoto];
        } else if ([obj isKindOfClass:[YYUser class]]) {
            name = [(YYUser *)obj userName];
            photo = [(YYUser *)obj getUserPhoto];
        }
        [cell setName:name];
        [cell setHeadImageWithUrl:photo placeholderName:name];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([indexPath section] == 0) {
        switch (indexPath.row) {
            case 0: {
                ChatGroupViewController *chatGroupViewController = [[ChatGroupViewController alloc] initWithNibName:@"ChatGroupViewController" bundle:nil];
                [self.navigationController pushViewController:chatGroupViewController animated:YES];
                break;
            }
            case 1:{
                RosterViewController *rosterViewController = [[RosterViewController alloc] initWithNibName:@"RosterViewController" bundle:nil];
                [self.navigationController pushViewController:rosterViewController animated:YES];
                break;
            }
        }
    } else {
        // 取数据
        NSObject *obj = [self.rosterArray objectAtIndex:indexPath.row];
        
        NSString *chatId;
        if ([obj isKindOfClass:[YYRoster class]]) {
            chatId = [(YYRoster *)obj rosterId];
        } else if ([obj isKindOfClass:[YYUser class]]) {
            chatId = [(YYUser *)obj userId];
        }
        
        [[(ChatSelNavController *)self.navigationController chatSelDelegate] didSelectChatId:chatId chatType:YM_MESSAGE_TYPE_CHAT];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    // 取消行选中状态
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -
#pragma mark private

- (void)reload {
    self.rosterArray = [[YYIMChat sharedInstance].chatManager getRecentRoster];
    [self.tableView reloadData];
}

@end
