//
//  MyNetMeetingTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "MyNetMeetingTableViewCell.h"
#import "YYIMColorHelper.h"
#import "YYIMUtility.h"
#import "YYIMChatHeader.h"

@implementation MyNetMeetingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *layer = [self.joinButton layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:2.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self.iconImage setImage:nil];
    [self.topicLabel setText:nil];
    [self.stateLabel setText:nil];
    [self.stateLabel setTextColor:UIColorFromRGB(0x8a8a8a)];
    [self.stateLabel setFont:[UIFont systemFontOfSize:14.0f]];
//    [self.stateLabel setFont:[UIFont systemFontOfSize:14.0f]];
    [self.moderatorLabel setText:nil];
    [self.timeLabel setText:nil];
    [self.joinButton setTitle:nil forState:UIControlStateNormal];
    [self.joinButton setHidden:YES];
}

- (void)activeData:(YYNetMeetingHistory *)history {
    switch ([history type]) {
        case kYYIMNetMeetingTypeLive:
            [self.iconImage setImage:[UIImage imageNamed:@"icon_netmeeting_live"]];
            break;
        default:
            [self.iconImage setImage:[UIImage imageNamed:@"icon_netmeeting_conference"]];
            break;
    }
    
    switch ([history state]) {
        case kYYIMNetMeetingStateEnd:
            [self.stateLabel setText:@"已结束"];
            break;
        case kYYIMNetMeetingStateIng:
            [self.stateLabel setText:@"进行中…"];
            [self.stateLabel setTextColor:UIColorFromRGB(0x6ac66f)];
            [self.stateLabel setFont:[UIFont boldSystemFontOfSize:14.0f]];
            [self.joinButton setTitle:@"加入" forState:UIControlStateNormal];
            [self.joinButton setHidden:NO];
            break;
        case kYYIMNetMeetingStateNew:
            if ([history.moderator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
                [self.joinButton setTitle:@"开始" forState:UIControlStateNormal];
                [self.joinButton setHidden:NO];
            }
            
            [self.stateLabel setText:@"未开始"];
            break;
        default:
            break;
    }
    [self.moderatorLabel setText:[NSString stringWithFormat:@"主持人:%@", [history moderatorName]]];
    
    if ([history topic]) {
        [self.topicLabel setText:[history topic]];
    } else if ([history moderatorName]) {
        switch ([history type]) {
            case kYYIMNetMeetingTypeLive:
                [self.topicLabel setText:[NSString stringWithFormat:@"%@的直播", [history moderatorName]]];
                break;
            default:
                [self.topicLabel setText:[NSString stringWithFormat:@"%@的会议", [history moderatorName]]];
                break;
        }
    }
    
    NSString *timeString = [YYIMUtility genTimeString:[history date] dateFormat:@"yyyy-MM-dd HH:mm"];
    [self.timeLabel setText:[NSString stringWithFormat:@"时间:%@", timeString]];
}

@end
