//
//  SearchDetailViewController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/1/6.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import "SearchDetailViewController.h"
#import "YYIMUtility.h"
#import "NormalTableViewCell.h"
#import "YYSearchMessage.h"
#import "UIImage+YYIMCategory.h"
#import "ChatViewController.h"
#import "YYIMEmojiHelper.h"
#import "UIColor+YYIMTheme.h"

@interface SearchDetailViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSMutableArray *searchArray;

@end

@implementation SearchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.searchArray = [[NSMutableArray alloc] initWithCapacity:10];
    
    self.navigationItem.title = @"消息";
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"NormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalTableViewCell"];
    
    // 设置多余分割线隐藏
    [YYIMUtility setExtraCellLineHidden:self.tableView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self reloadData];
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.searchArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalTableViewCell"];
    
    YYSearchMessage *message = [self.searchArray objectAtIndex:indexPath.row];
    
    // 为cell设置数据
    if ([YM_MESSAGE_TYPE_CHAT isEqualToString:[message chatType]]) {
        if ([message isSystemMessage]) {
            [cell setName:@"系统消息"];
            [cell setHeadIcon:@"icon_system"];
        } else {
            NSString *name;
            if ([message roster]) {
                name = [[message roster] rosterAlias];
            } else {
                name = [[message user] userName];
            }
            [cell setName:name];
            [cell setHeadImageWithUrl:[[message user] getUserPhoto] placeholderName:name];
        }
    } else if ([YM_MESSAGE_TYPE_GROUPCHAT isEqualToString:[message chatType]]) {
        YYChatGroup *group = [message group];
        [cell setName:[group groupName]];
        [cell setGroupIcon:[group groupId]];
    } else if ([YM_MESSAGE_TYPE_PUBACCOUNT isEqualToString:[message chatType]]) {
        YYPubAccount *account = [message account];
        [cell setName:[account accountName]];
        [cell.headImage setImage:[UIImage imageWithDispName:[account accountName] coreIcon:@"icon_pubaccount_core"]];
    }
    
    NSString *text;
    YYMessageContent *content = [message getMessageContent];
    
    switch ([message type]) {
        case YM_MESSAGE_CONTENT_TEXT:
            if (content.message) {
                text = content.message;
            } else {
                text = @"";
            }
            break;
        case YM_MESSAGE_CONTENT_FILE:
            text = content.fileName;
            break;
        case YM_MESSAGE_CONTENT_LOCATION:
            if ([content address]) {
                text = [content address];
            } else {
                text = @"";
            }
            break;
        case YM_MESSAGE_CONTENT_SINGLE_MIXED:
            text = content.paContent.title;
            break;
        case YM_MESSAGE_CONTENT_BATCH_MIXED:
            if ([[content.paArray objectAtIndex:0] showCoverPic]) {
                text = [[content.paArray objectAtIndex:0] title];
                break;
            }
            break;
        case YM_MESSAGE_CONTENT_SHARE:
            text = [NSString stringWithFormat:@"%@|%@", content.shareTitle, content.shareDesc];
            break;
        default:
            text = @"";
            break;
    }
    
    [cell setDetailWithAttrString:[YYIMUtility getHighlightContent:text keyword:self.searchKey defaultFont:cell.detailLabel.font textColor:cell.detailLabel.textColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 消息
    YYMessage *messageSelected = [self.searchArray objectAtIndex:[indexPath row]];
    NSString *chatId;
    // 传参到聊天controller
    if ([messageSelected direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
        chatId = [messageSelected fromId];
    } else {
        chatId = [messageSelected toId];
    }
    NSString *chatType = [messageSelected chatType];
    
    ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    [chatViewController setValue:chatId forKey:@"chatId"];
    [chatViewController setValue:chatType forKey:@"chatType"];
    chatViewController.pid = messageSelected.pid;
    [self.navigationController pushViewController:chatViewController animated:YES];
    
    // 取消行选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark private method

- (void)reloadData {
    //query message
    NSArray *messageArray = [[[YYIMChat sharedInstance] chatManager] getMessageWithKey:self.searchKey chatId:self.chatId];
    [self.searchArray removeAllObjects];
    [self.searchArray addObjectsFromArray:messageArray];
    
    [self.tableView reloadData];
}

@end
