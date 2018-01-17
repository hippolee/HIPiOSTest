//
//  SearchViewCompleteController.m
//  YonyouIM
//
//  Created by yanghaoc on 16/1/6.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import "SearchViewCompleteController.h"
#import "YYIMUtility.h"
#import "SingleLineCell.h"
#import "NormalTableViewCell.h"
#import "YYSearchMessage.h"
#import "UIImage+YYIMCategory.h"
#import "ChatViewController.h"
#import "UserViewController.h"
#import "YYIMEmojiHelper.h"
#import "UIColor+YYIMTheme.h"
#import "SearchDetailViewController.h"

@interface SearchViewCompleteController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (retain, nonatomic) NSArray *dataArray;

@end

@implementation SearchViewCompleteController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.searchType) {
        case kYMSearchTypeRoster:
            self.navigationItem.title = @"好友列表";
            break;
        case kYMSearchTypeChatGroup:
            self.navigationItem.title = @"群组";
            break;
        case kYMSearchTypeMessage:
            self.navigationItem.title = @"消息";
            break;
        default:
            break;
    }
    
    // 注册Cell nib
    [self.tableView registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
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

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.searchType) {
            // 用户
        case kYMSearchTypeRoster: {
            SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell"];
            
            YYRoster *roster = [self.dataArray objectAtIndex:indexPath.row];
            [cell setNameWithAttrString:[YYIMUtility getHighlightContent:[roster rosterAlias] keyword:self.searchKey defaultFont:cell.nameLabel.font textColor:cell.nameLabel.textColor]];
            [cell setImageRadius:16];
            // 为cell设置数据
            [cell setHeadImageWithUrl:roster.user.userPhoto placeholderName:[roster rosterAlias]];
            return cell;
        }
            // 群组
        case kYMSearchTypeChatGroup: {
            SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell"];
            YYChatGroup *group = [self.dataArray objectAtIndex:indexPath.row];
            [cell setNameWithAttrString:[YYIMUtility getHighlightContent:[group groupName] keyword:self.searchKey defaultFont:cell.nameLabel.font textColor:cell.nameLabel.textColor]];
            [cell setGroupIcon:[group groupId]];
            return cell;
        }
            // 消息
        case kYMSearchTypeMessage: {
            NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalTableViewCell"];
            
            YYSearchMessage *message = [self.dataArray objectAtIndex:indexPath.row];
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
            
            if (message.mergeCount > 1) {
                [cell setDetail:[NSString stringWithFormat:@"%ld条相关的聊天记录", (long)message.mergeCount]];
            } else {
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
            }
            
            return cell;
        }
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (self.searchType) {
        case kYMSearchTypeRoster: {
            // 取数据
            YYRoster *roster = [self.dataArray objectAtIndex:indexPath.row];
            
            UserViewController *userViewController = [[UserViewController alloc] initWithNibName:@"UserViewController" bundle:nil];
            userViewController.userId = roster.rosterId;
            [self.navigationController pushViewController:userViewController animated:YES];
            break;
        }
        case kYMSearchTypeChatGroup: {
            YYChatGroup *groupSelected = [self.dataArray objectAtIndex:indexPath.row];
            
            ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
            [chatViewController setChatId:[groupSelected groupId]];
            [chatViewController setChatType:YM_MESSAGE_TYPE_GROUPCHAT];
            
            [self.navigationController pushViewController:chatViewController animated:YES];
            break;
        }
        case kYMSearchTypeMessage: {
            // 消息
            YYSearchMessage *messageSelected = [self.dataArray objectAtIndex:[indexPath row]];
            
            // 如果是合并信息需要跳转到详细条目页面，如果不是直接打开对话
            if (messageSelected.mergeCount > 1) {
                SearchDetailViewController *searchDetailViewController = [[SearchDetailViewController alloc] initWithNibName:@"SearchDetailViewController" bundle:nil];
                
                searchDetailViewController.searchKey = self.searchKey;
                
                if ([messageSelected direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                    searchDetailViewController.chatId = [messageSelected fromId];
                } else {
                    searchDetailViewController.chatId = [messageSelected toId];
                }
                
                [self.navigationController pushViewController:searchDetailViewController animated:YES];
            } else {
                NSString *chatId;
                // 传参到聊天controller
                if ([messageSelected direction] == YM_MESSAGE_DIRECTION_RECEIVE) {
                    chatId = [messageSelected fromId];
                } else {
                    chatId = [messageSelected toId];
                }
                NSString *chatType = [messageSelected chatType];
                
                ChatViewController *chatViewController = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
                [chatViewController setChatId:chatId];
                [chatViewController setChatType:chatType];
                chatViewController.pid = messageSelected.pid;
                [self.navigationController pushViewController:chatViewController animated:YES];
            }
            break;
        }
        default:
            break;
    }
    // 取消行选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark private method

- (void)reloadData {
    switch (self.searchType) {
        case kYMSearchTypeRoster: {
            //query roster
            NSArray *rosterArray = [[YYIMChat sharedInstance].chatManager getAllRosterWithAsk];
            
            NSPredicate *preRoster = [NSPredicate predicateWithFormat:@"rosterAlias CONTAINS[cd] %@", self.searchKey];
            self.dataArray = [rosterArray filteredArrayUsingPredicate:preRoster];
            break;
        }
        case kYMSearchTypeChatGroup: {
            //query chagroup
            NSArray *groupArray = [[YYIMChat sharedInstance].chatManager getAllChatGroups];
            
            NSPredicate *preGroup = [NSPredicate predicateWithFormat:@"groupName CONTAINS[cd] %@", self.searchKey];
            self.dataArray = [groupArray filteredArrayUsingPredicate:preGroup];
            break;
        }
        case kYMSearchTypeMessage: {
            //query message
            self.dataArray = [[YYIMChat sharedInstance].chatManager getMessageWithKey:self.searchKey];
        }
        default:
            break;
    }
    [self.tableView reloadData];
}

@end
