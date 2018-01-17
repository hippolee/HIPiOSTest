//
//  ChatShareConferenceTableViewCell.h
//  YonyouIM
//
//  Created by yanghaoc on 16/3/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYMessage.h"
#import "YYIMLabel.h"
#import "ChatBubbleView.h"

@interface ChatShareConferenceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *timeView;
@property (weak, nonatomic) IBOutlet YYIMLabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headImage;

@property (retain, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet ChatBubbleView *messageView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

@property (weak, nonatomic) IBOutlet UIImageView *unreadImage;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

+ (CGFloat)heightForCell:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setName:(NSString *)name;

- (void)setActiveMessage:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow isHeaderShow:(BOOL)isHeaderShow;

@end
