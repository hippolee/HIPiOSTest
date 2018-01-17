//
//  ChatShareConferenceTableRightCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatShareConferenceTableRightCell.h"

@implementation ChatShareConferenceTableRightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.messageView setDirection:kYMChatBubbleDirectionRight];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
