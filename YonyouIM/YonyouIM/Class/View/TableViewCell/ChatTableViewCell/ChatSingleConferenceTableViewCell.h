//
//  ChatSingleConferenceTableViewCell.h
//  YonyouIM
//
//  Created by yanghaoc on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYMessage.h"
#import "YYIMLabel.h"
#import "ChatBubbleView.h"

@interface ChatSingleConferenceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet YYIMLabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet ChatBubbleView *messageView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *unreadImage;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

+ (CGFloat)heightForCell:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setActiveMessage:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow isHeaderShow:(BOOL)isHeaderShow;

@end
