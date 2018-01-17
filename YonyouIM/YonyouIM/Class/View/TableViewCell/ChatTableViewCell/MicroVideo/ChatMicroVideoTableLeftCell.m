//
//  ChatMicroVideoTableLeftCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/7.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatMicroVideoTableLeftCell.h"

@implementation ChatMicroVideoTableLeftCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.messageView setDirection:kYMViewLayerBubbleDirectionLeft];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
