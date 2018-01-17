//
//  ChatTableRightCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatTableRightCell.h"

@implementation ChatTableRightCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self.messageView setDirection:kYMChatBubbleDirectionRight];
    
    self.audioImage.animationImages = [NSArray arrayWithObjects:
                                       [UIImage imageNamed:@"icon_audioplay_right1"],
                                       [UIImage imageNamed:@"icon_audioplay_right2"],
                                       [UIImage imageNamed:@"icon_audioplay_right3"], nil];
    self.audioImage.animationDuration = 0.8; //浏览整个图片一次所用的时间
    self.audioImage.animationRepeatCount = 0; // 0 = loops forever 动画重复次数
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
