//
//  ChatMuitiConferenceTableViewCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatMuitiConferenceTableViewCell.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUtility.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"

@interface ChatMuitiConferenceTableViewCell ()

@property (strong, nonatomic) YYNetMeetingInfo *noticeInfo;

@end

@implementation ChatMuitiConferenceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *layer = [self.headImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:24];
    
    CALayer *btnLayer = [self.dealButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5];
    
    [self.dealButton setBackgroundColor:UIColorFromRGB(0x69b553)];
    
    [self reuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.timeLabel.text = nil;
    self.headImage.image = nil;
    self.nameLabel.text = nil;
    self.detailLabel.text = nil;
    [self.dealButton setTitle:@"" forState:UIControlStateNormal];
    self.dealButton.hidden = YES;
    self.tipLabel.hidden = YES;
    self.tipLabel.text = nil;
}

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name {
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:image options:0];
}

- (void)setActiveData:(YYNetMeetingInfo *)noticeInfo {
    self.noticeInfo = noticeInfo;
    
    NSString *moderator = noticeInfo.moderator;
    NSString *creator = noticeInfo.creator;
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:moderator];
    
    [self setHeadImageWithUrl:[user getUserPhoto] placeholderName:[user userName]];
    
    NSString *title;
    
    switch (noticeInfo.state) {
        case kYYIMNetMeetingStateIng:
            title = [creator isEqualToString:[[YYIMConfig sharedInstance] getUser]] ? @"我发起:" : @"会议邀请:";
            title = [NSString stringWithFormat:@"%@%@", title, noticeInfo.topic];
            self.nameLabel.text = title;
            
            self.dealButton.hidden = NO;
            [self.dealButton setTitle:@"加入" forState:UIControlStateNormal];
            [self.dealButton addTarget:self action:@selector(messagePressed:) forControlEvents:UIControlEventTouchUpInside];
            
            self.detailLabel.text = [NSString stringWithFormat:@"%@  开始时间：%@",user.userName, [self getShowTime:noticeInfo.date]];
            break;
        case kYYIMNetMeetingStateEnd:
            title = [creator isEqualToString:[[YYIMConfig sharedInstance] getUser]] ? @"我发起:" : @"会议邀请:";
            title = [NSString stringWithFormat:@"%@%@", title, noticeInfo.topic];
            self.nameLabel.text = title;
            
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"已结束";
            
            self.detailLabel.text = [NSString stringWithFormat:@"%@  开始时间：%@",user.userName, [self getShowTime:noticeInfo.date]];
            break;
        case kYYIMNetMeetingStateNew:
        case kYYIMNetMeetingStateReservationInvite:
            title = [creator isEqualToString:[[YYIMConfig sharedInstance] getUser]] ? @"我预约了:" : @"预约邀请:";
            title = [NSString stringWithFormat:@"%@%@", title, noticeInfo.topic];
            self.nameLabel.text = title;
            
            self.detailLabel.text = [NSString stringWithFormat:@"%@  开始时间：%@",user.userName, [self getShowTime:noticeInfo.date]];
            
            if ([creator isEqualToString:[[YYIMConfig sharedInstance] getUser]] && noticeInfo.waitBegin) {
                self.dealButton.hidden = NO;
                [self.dealButton setTitle:@"开始" forState:UIControlStateNormal];
                [self.dealButton addTarget:self action:@selector(messagePressed:) forControlEvents:UIControlEventTouchUpInside];
            }
            break;
        case kYYIMNetMeetingStateCancelReservation:
            self.nameLabel.text = [NSString stringWithFormat:@"取消预约:%@", noticeInfo.topic];
            self.detailLabel.text = [NSString stringWithFormat:@"%@取消了一个预约会议", user.userName];
            break;
        case kYYIMNetMeetingStateReservationReady:
            self.nameLabel.text = [NSString stringWithFormat:@"会议提醒:%@", noticeInfo.topic];
            self.detailLabel.text = @"距离您的会议开始时间还有5分钟";
            
            if ([creator isEqualToString:[[YYIMConfig sharedInstance] getUser]] && noticeInfo.waitBegin) {
                self.dealButton.hidden = NO;
                [self.dealButton setTitle:@"开始" forState:UIControlStateNormal];
                [self.dealButton addTarget:self action:@selector(messagePressed:) forControlEvents:UIControlEventTouchUpInside];
            }
            break;
        case kYYIMNetMeetingStateReservationKick:
            self.nameLabel.text = @"取消会议提醒";
            self.detailLabel.text = [NSString stringWithFormat:@"您已被移出%@", noticeInfo.topic];
            break;
        default:
            break;
    }
    
    self.timeLabel.text = [YYIMUtility genTimeString:[noticeInfo notifyDate]];
}

- (NSString *)getShowTime:(NSTimeInterval)time {
    //判断是否是同一年
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSCalendarUnit calendarUnit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
    NSDateComponents *dateComponents =  [calendar components:calendarUnit fromDate:date];
    NSDateComponents *nowComponents = [calendar components:calendarUnit fromDate:[NSDate date]];
    
    //同一年不显示年，不同一年显示年
    if (dateComponents.year == nowComponents.year) {
        return [YYIMUtility genTimeString:time dateFormat:@"MM-dd HH:mm"];
    } else {
        return [YYIMUtility genTimeString:time dateFormat:@"yyyy-MM-dd HH:mm"];
    }
    
    return @"";
}

#pragma mark -
#pragma mark tap

- (void)messagePressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.noticeInfo, kYMChatPressedCell:self, kYMChatPressedGestureRecognizer:tapGestureRecognizer}];
}

@end
