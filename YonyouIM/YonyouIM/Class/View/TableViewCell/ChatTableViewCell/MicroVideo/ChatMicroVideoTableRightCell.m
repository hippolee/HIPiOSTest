//
//  ChatMicroVideoTableRightCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/6/7.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatMicroVideoTableRightCell.h"

@implementation ChatMicroVideoTableRightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.messageView setDirection:kYMViewLayerBubbleDirectionRight];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
