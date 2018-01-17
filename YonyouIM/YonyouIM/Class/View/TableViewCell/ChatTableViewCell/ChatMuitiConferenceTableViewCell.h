//
//  ChatMuitiConferenceTableViewCell.h
//  YonyouIM
//
//  Created by yanghaoc on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYNetMeetingInfo.h"

@interface ChatMuitiConferenceTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *headImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UILabel *detailLabel;
@property (retain, nonatomic) IBOutlet UIButton *dealButton;
@property (retain, nonatomic) IBOutlet UILabel *tipLabel;

- (void)setActiveData:(YYNetMeetingInfo *)noticeInfo;

@end
