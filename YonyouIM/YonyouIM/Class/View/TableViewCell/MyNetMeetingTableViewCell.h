//
//  MyNetMeetingTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

@interface MyNetMeetingTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImage;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *stateLabel;
@property (weak, nonatomic) IBOutlet UILabel *moderatorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;

- (void)activeData:(YYNetMeetingHistory *)history;

@end
