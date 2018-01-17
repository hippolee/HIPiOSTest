//
//  ChatPromptTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/7/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMLabel.h"
#import "YYIMChatHeader.h"

@interface ChatPromptTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet YYIMLabel *timeLabel;

@property (weak, nonatomic) IBOutlet YYIMLabel *promptLabel;

@property (retain, nonatomic) YYMessage *message;

+ (CGFloat)heightForCellWithData:(YYMessage *)message isTimeShow:(BOOL)isTimeShow;

- (void)setTimeText:(NSString *)time;

- (void)setActiveMessage:(YYMessage *)message;

@end
