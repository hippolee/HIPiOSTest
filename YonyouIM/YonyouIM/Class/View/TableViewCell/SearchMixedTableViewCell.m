//
//  SearchMixedTableViewCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/1/11.
//  Copyright (c) 2016年 yonyou. All rights reserved.
//

#import "SearchMixedTableViewCell.h"
#import "SingleLineCell.h"
#import "SingleLineCell3.h"
#import "UIResponder+YYIMCategory.h"
#import "NormalTableViewCell.h"
#import "YYSearchMessage.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMEmojiHelper.h"
#import "UIColor+YYIMTheme.h"
#import "YYIMColorHelper.h"
#import "YYIMUtility.h"

@interface SearchMixedTableViewCell ()

@property (weak, nonatomic) IBOutlet UITableView *contentTable;

@property (retain, nonatomic) UIView *headerView;

@property (retain, nonatomic) UIView *footView;

@property (retain, nonatomic) UILabel *titleLabel;

@property (retain, nonatomic) NSArray *resultArray;

@property (retain, nonatomic) NSString *searchKey;

@property YMSearchType type;

@property NSInteger limitCount;

@end

@implementation SearchMixedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentTable.dataSource = self;
    self.contentTable.delegate = self;
    [self.contentTable setScrollEnabled:NO];
    self.contentTable.allowsSelection = YES;
    
    // cell nib
    [self.contentTable registerNib:[UINib nibWithNibName:@"SingleLineCell" bundle:nil] forCellReuseIdentifier:@"SingleLineCell"];
    [self.contentTable registerNib:[UINib nibWithNibName:@"SingleLineCell3" bundle:nil] forCellReuseIdentifier:@"SingleLineCell3"];
    [self.contentTable registerNib:[UINib nibWithNibName:@"NormalTableViewCell" bundle:nil] forCellReuseIdentifier:@"NormalTableViewCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    self.resultArray = nil;
    self.contentTable.tableHeaderView = nil;
    self.contentTable.tableFooterView = nil;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = self.resultArray.count > self.limitCount ? self.limitCount + 1 : self.resultArray.count;
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row >= self.limitCount) {
        return 40;
    }
    
    return 68;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 如果是第四条表示是展示全部数据
    if (indexPath.row >= self.limitCount) {
        SingleLineCell3 *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell3"];
        [cell.iconImage setImage:[UIImage imageNamed:@"icon_search2"]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        switch (self.type) {
            case kYMSearchTypeRoster:
                [cell setName:@"查看更多好友"];
                break;
            case kYMSearchTypeChatGroup:
                [cell setName:@"查看更多群组"];
                break;
            case kYMSearchTypeMessage:
                [cell setName:@"查看更多聊天记录"];
                break;
                
            default:
                break;
        }
        
        return cell;
    }
    
    switch (self.type) {
        case kYMSearchTypeRoster: {
            SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell"];
            
            YYRoster *roster = [self.resultArray objectAtIndex:indexPath.row];
            [cell setNameWithAttrString:[YYIMUtility getHighlightContent:[roster rosterAlias] keyword:self.searchKey defaultFont:cell.nameLabel.font textColor:cell.nameLabel.textColor]];
            [cell setImageRadius:16];
            // 为cell设置数据
            [cell setHeadImageWithUrl:roster.user.userPhoto placeholderName:[roster rosterAlias]];
            return cell;
        }
        case kYMSearchTypeChatGroup: {
            SingleLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SingleLineCell"];
            YYChatGroup *group = [self.resultArray objectAtIndex:indexPath.row];
            [cell setNameWithAttrString:[YYIMUtility getHighlightContent:[group groupName] keyword:self.searchKey defaultFont:cell.nameLabel.font textColor:cell.nameLabel.textColor]];
            [cell setGroupIcon:[group groupId]];
            return cell;
        }
        case kYMSearchTypeMessage: {
            NormalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NormalTableViewCell"];
            
            YYSearchMessage *message = [self.resultArray objectAtIndex:indexPath.row];
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

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self messagePressed:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark tap

- (void)messagePressed:(NSInteger)index {
    [self bubbleEventWithUserInfo:@{kYMSearchPressedType:[NSNumber numberWithInteger:self.type], kYMSearchPressedIndex:[NSNumber numberWithInteger:index]}];
}

#pragma mark lazy load

- (UIView *)headerView {
    if (!_headerView) {
        CGFloat width = CGRectGetWidth(self.frame);
        UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
        [headerView setBackgroundColor:[UIColor redColor]];
        [headerView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, width - 32, 24)];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.titleLabel setTextColor:UIColorFromRGB(0x858E99)];
        [self.titleLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
        [titleView setBackgroundColor:[UIColor whiteColor]];
        [titleView addSubview:self.titleLabel];
        [titleView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [headerView addSubview:titleView];
        
        UIView *sepView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0.5f)];
        [sepView1 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        [sepView1 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [headerView addSubview:sepView1];
        
        UIView *sepView2 = [[UIView alloc] initWithFrame:CGRectMake(16, 40, width - 16, 0.5f)];
        [sepView2 setBackgroundColor:UIColorFromRGB(0xe6e6e6)];
        [sepView2 setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [headerView addSubview:sepView2];
        
        _headerView = headerView;
    }
    
    return _headerView;
}

- (UIView *)footView {
    if (!_footView) {
        CGFloat width = CGRectGetWidth(self.frame);
        UIView * footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 4)];
        [footView setBackgroundColor:UIColorFromRGB(0xdcd7d5)];
        
        _footView = footView;
    }
    
    return _footView;
}

#pragma mark public method

- (void)setActiveType:(YMSearchType)type array:(NSArray *)array limit:(NSInteger)limit searchKey:(NSString *)searchKey{
    //赋值
    self.resultArray = array;
    self.type = type;
    self.limitCount = limit;
    self.searchKey = searchKey;
    
    self.contentTable.tableHeaderView = self.headerView;
    self.contentTable.tableFooterView = self.footView;
    [self.contentTable reloadData];
    
    switch (self.type) {
        case kYMSearchTypeRoster:
            self.titleLabel.text = @"好友";
            break;
        case kYMSearchTypeChatGroup:
            self.titleLabel.text = @"群组";
            break;
        case kYMSearchTypeMessage:
            self.titleLabel.text = @"聊天记录";
            break;
        default:
            break;
    }
    
    [self.contentTable reloadData];
}

+ (NSInteger)getHeightOfCell:(NSArray *)array limit:(NSInteger)limit {
    NSInteger height = 0;
    
    if (array.count > limit) {
        height = limit * 68 + 40 + 44;
    } else {
        height =  68 * array.count + 44;
    }
    
    return height;
}

@end
