//
//  ChatShareConferenceTableLeftCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatShareConferenceTableLeftCell.h"

@implementation ChatShareConferenceTableLeftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.messageView setDirection:kYMChatBubbleDirectionLeft];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
