//
//  ChatSingleConferenceTableLeftCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatSingleConferenceTableLeftCell.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "YYIMLabel.h"
#import "ChatBubbleView.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUtility.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"

@implementation ChatSingleConferenceTableLeftCell


- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.messageView setDirection:kYMChatBubbleDirectionLeft];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
