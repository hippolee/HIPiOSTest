//
//  ChatBatchMixedTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatBatchMixedTableViewCell.h"
#import "YYIMColorHelper.h"
#import "ChatBatchMixedSubCell.h"
#import "YYIMUtility.h"
#import "YYMessage+YYIMCatagory.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUIDefs.h"

@interface ChatBatchMixedTableViewCell ()

@property (weak, nonatomic) IBOutlet UITableView *contentTable;

@end

@implementation ChatBatchMixedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentTable.dataSource = self;
    self.contentTable.delegate = self;
    [self.contentTable setScrollEnabled:NO];
    self.contentTable.allowsSelection = YES;
    
    // cell nib
    [self.contentTable registerNib:[UINib nibWithNibName:@"ChatBatchMixedSubImageCell" bundle:nil] forCellReuseIdentifier:@"ChatBatchMixedSubImageCell"];
    [self.contentTable registerNib:[UINib nibWithNibName:@"ChatBatchMixedSubDetailCell" bundle:nil] forCellReuseIdentifier:@"ChatBatchMixedSubDetailCell"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.contentTable reloadData];
}

- (void)setActiveMessage:(YYMessage *)message {
    [super setActiveMessage:message];
    
    [self.contentTable reloadData];
}

+ (CGFloat)heightForCellWithData:(YYMessage *)message {
    CGFloat height = [message getContentHeight];
    if (height > 0) {
        return height;
    }
    
    height = [self baseHeight];
    NSArray *paArray = [[message getMessageContent] paArray];
    for (YYPubAccountContent *paContent in paArray) {
        height += [self heightForPaContent:paContent];
    }
    
    [message setContentHeight:height];
    return height;
    
    
    return height;
}

#pragma mark UITableViewDataSource, UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.message getMessageContent] paArray].count;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    YYPubAccountContent *paContent = [[[self.message getMessageContent] paArray] objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatBatchMixedTableViewCell heightForPaContent:paContent];
    return cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *paArray = [[self.message getMessageContent] paArray];
    YYPubAccountContent *paContent = [paArray objectAtIndex:indexPath.row];
    ChatBatchMixedSubCell *cell;
    if ([paContent showCoverPic]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChatBatchMixedSubImageCell"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"ChatBatchMixedSubDetailCell"];
    }
    [cell setActivePaContent:paContent];
    if (indexPath.row == (paArray.count - 1)) {
        cell.sepView.hidden = YES;
    } else {
        cell.sepView.hidden = NO;
    }
    return cell;
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
    [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedIndex:[NSNumber numberWithInteger:index]}];
}

#pragma mark private func

+ (CGFloat)baseHeight {
    return 40 + 6 + 18;
}

+ (CGFloat)heightForPaContent:(YYPubAccountContent *)paContent {
    if ([paContent showCoverPic]) {
        // image
        CGFloat imageHeight = [self baseWidth] / 16 * 9;
        return imageHeight + 12;
    } else {
        CGFloat height = [self subTitleHeight:paContent];
        height += 12;
        return fmax(62, height);
    }
}

@end