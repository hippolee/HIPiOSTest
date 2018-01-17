//
//  ChatBatchMixedSubDetailCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatBatchMixedSubDetailCell.h"
#import "ChatMixedTableViewCell.h"

@implementation ChatBatchMixedSubDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.titleLabel setFont:[UIFont systemFontOfSize:kChatMixedSubTitleFontSize]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
