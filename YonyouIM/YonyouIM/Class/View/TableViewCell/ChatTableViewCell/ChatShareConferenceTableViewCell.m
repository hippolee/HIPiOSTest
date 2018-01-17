//
//  ChatShareConferenceTableViewCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/25.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatShareConferenceTableViewCell.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUtility.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"

@interface ChatShareConferenceTableViewCell ()

@property (retain, nonatomic) NSLayoutConstraint *timeConstraint;

@property (retain, nonatomic) NSLayoutConstraint *timeLabelConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint2;

@property (retain, nonatomic) NSLayoutConstraint *nameConstraint;

@property (strong, nonatomic) YYMessage *message;

@end

@implementation ChatShareConferenceTableViewCell

+ (CGFloat)heightForCell:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow {
    CGFloat height = 88;
    
    if (isTimeShow) {
        height += 30;
    }
    if (!isBottomShow) {
        height -= 8;
    }
    return height;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *layer = [self.headImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:20];
    
    [self.timeLabel setEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 8)];
    
    CALayer *btnLayer = [self.joinButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5];
    
    [self.joinButton setBackgroundColor:UIColorFromRGB(0x69b553)];
    
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
    self.timeLabel.hidden = YES;
    self.headImage.image = nil;
    self.headImage.hidden = NO;
    self.messageView.showArrow = YES;
    self.titleLabel.text = nil;
    self.topicLabel.text = nil;
    self.createTimeLabel.text = nil;
    self.unreadImage.image = nil;
    self.unreadImage.hidden = YES;
    
    if (_timeConstraint) {
        [self.timeView removeConstraint:_timeConstraint];
    }
    if (_timeLabelConstraint) {
        [self.timeLabel removeConstraint:_timeLabelConstraint];
    }
    if (_bottomConstraint) {
        [self.bottomView removeConstraint:_bottomConstraint];
    }
    if (_bottomConstraint2) {
        [self.bottomView removeConstraint:_bottomConstraint2];
    }
}

- (void)setName:(NSString *)name {
    [self.nameLabel setText:name];
    [self.nameLabel addConstraint:[self nameConstraint]];
}

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name {
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:image options:0];
}

- (void)setActiveMessage:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow isHeaderShow:(BOOL)isHeaderShow {
    self.message = message;
    
    if (self.headImage) {
        [self.headImage setUserInteractionEnabled:YES];
        UITapGestureRecognizer *headTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headPressed:)];
        [self.headImage addGestureRecognizer:headTapGestureRecognizer];
    }
    
    YYMessageContent *content = [message getMessageContent];
    YYNetMeetingContent *conference = [content netMeetingContent];
    
    NSString *moderator = [conference moderator];
    
    YYUser *user = [[YYIMChat sharedInstance].chatManager getUserWithId:moderator];
    
    NSString *name;
    if ([moderator isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
        name = @"我";
    } else {
        name = user.userName;
    }
    
    [self setHeadImageWithUrl:[user getUserPhoto] placeholderName:[user userName]];
    if (!name) {
        name = @"主持人";
    }
    
    switch (conference.contentState) {
        case kYYIMNetMeetingContentTypeCreate:
            name = [NSString stringWithFormat:@"%@发起了", name];
            
            self.joinButton.hidden = NO;
            [self.joinButton setTitle:@"加入" forState:UIControlStateNormal];
            [self.joinButton addTarget:self action:@selector(messagePressed:) forControlEvents:UIControlEventTouchUpInside];
            break;
        case kYYIMNetMeetingContentTypeEnd:
            name = [NSString stringWithFormat:@"%@结束了", name];
            break;
        default:
            break;
    }
    
    switch (conference.netMeetingType) {
        case kYYIMNetMeetingTypeMeeting:
            name = [NSString stringWithFormat:@"%@视频会议", name];
            break;
        case kYYIMNetMeetingTypeGroupChat:
            name = [NSString stringWithFormat:@"%@视频聊天", name];
            break;
        case kYYIMNetMeetingTypeLive:
            name = [NSString stringWithFormat:@"%@视频直播", name];
            break;
        default:
            
            break;
    }
    
    self.titleLabel.text = name;
    
    self.timeLabel.text = [YYIMUtility genTimeString:[message date]];
    self.topicLabel.text = [NSString stringWithFormat:@"主题：%@", conference.topic];
    
    self.createTimeLabel.text = [NSString stringWithFormat:@"会议时间：%@", [YYIMUtility genTimeString:[conference createTime]dateFormat:@"yyyy-MM-dd HH:mm"]];
    
    [self layoutByMessage:message isTimeShow:isTimeShow isBottomShow:isBottomShow isHeaderShow:isHeaderShow];
}

- (void)layoutByMessage:(YYMessage *)message isTimeShow:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow isHeaderShow:(BOOL)isHeaderShow {
    NSString *timeStr = [YYIMUtility genTimeString:[message date]];
    
    if (isTimeShow && timeStr != nil && timeStr.length > 0) {
        self.timeLabel.text = timeStr;
        self.timeLabel.hidden = NO;
        [self.timeView addConstraint:[self timeConstraint]];
        [self.timeLabel addConstraint:[self timeLabelConstraint]];
    }
    
    if (isBottomShow) {
        [self.bottomView addConstraint:self.bottomConstraint2];
    } else {
        [self.bottomView addConstraint:self.bottomConstraint];
    }
    
    if (isHeaderShow) {
        self.headImage.hidden = NO;
        self.messageView.showArrow = YES;
    } else {
        self.headImage.hidden = YES;
        self.messageView.showArrow = NO;
    }
}

#pragma mark tap

- (void)messagePressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    if ([self.message direction] == YM_MESSAGE_DIRECTION_RECEIVE && (![self.message specificStatus] || [self.message specificStatus] == YM_MESSAGE_SPECIFIC_INITIAL)) {
        [self.message setSpecificStatus:YM_MESSAGE_SPECIFIC_AUDIO_READ];
        self.unreadImage.hidden = YES;
        [[YYIMChat sharedInstance].chatManager updateAudioReaded:[self.message pid]];
    }
    
    [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedGestureRecognizer:tapGestureRecognizer}];
}

- (void)headPressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self bubbleEventWithUserInfo:@{kYMChatPressedMessage:self.message, kYMChatPressedCell:self, kYMChatPressedGestureRecognizer:tapGestureRecognizer, kYMChatPressedHead:[NSNumber numberWithBool:YES]}];
}

- (NSLayoutConstraint *)timeConstraint {
    if (!_timeConstraint) {
        _timeConstraint = [NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
        _timeConstraint.priority = 751;
    }
    return _timeConstraint;
}

- (NSLayoutConstraint *)timeLabelConstraint {
    if (!_timeLabelConstraint) {
        _timeLabelConstraint = [NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:22.0f];
        _timeLabelConstraint.priority = 751;
    }
    return _timeLabelConstraint;
}

- (NSLayoutConstraint *)bottomConstraint {
    if (!_bottomConstraint) {
        _bottomConstraint = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0.0];
        _bottomConstraint.priority = 751;
    }
    return _bottomConstraint;
}

- (NSLayoutConstraint *)bottomConstraint2 {
    if (!_bottomConstraint2) {
        _bottomConstraint2 = [NSLayoutConstraint constraintWithItem:self.bottomView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:8.0];
        _bottomConstraint2.priority = 751;
    }
    return _bottomConstraint2;
}

- (NSLayoutConstraint *)nameConstraint {
    if (!_nameConstraint) {
        _nameConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:16.0f];
        _nameConstraint.priority = 751;
    }
    return _nameConstraint;
}

@end
