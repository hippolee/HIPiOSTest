//
//  ChatSingleConferenceTableViewCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/22.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ChatSingleConferenceTableViewCell.h"
#import "YYIMColorHelper.h"
#import "YYIMUIDefs.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUtility.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"

@interface ChatSingleConferenceTableViewCell ()

@property (retain, nonatomic) NSLayoutConstraint *timeConstraint;

@property (retain, nonatomic) NSLayoutConstraint *timeLabelConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint;

@property (retain, nonatomic) NSLayoutConstraint *bottomConstraint2;

@property (strong, nonatomic) YYMessage *message;

@end

@implementation ChatSingleConferenceTableViewCell

+ (CGFloat)heightForCell:(BOOL)isTimeShow isBottomShow:(BOOL)isBottomShow {
    CGFloat height = 56;
    
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
    self.messageLabel.text = nil;
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
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messagePressed:)];
    [tapGestureRecognizer setCancelsTouchesInView:NO];
    [self.messageView addGestureRecognizer:tapGestureRecognizer];
    
    YYMessageContent *content = [message getMessageContent];
    YYNetMeetingContent *conference = content.netMeetingContent;
    
    if (message.direction == YM_MESSAGE_DIRECTION_RECEIVE) {
        if (conference.netMeetingMode == kYYIMNetMeetingModeAudio) {
            self.videoImageView.image = [UIImage imageNamed:@"icon_audio_state_left"];
        } else {
            self.videoImageView.image = [UIImage imageNamed:@"icon_camera_state_left"];
        }
    } else {
        if (conference.netMeetingMode == kYYIMNetMeetingModeAudio) {
            self.videoImageView.image = [UIImage imageNamed:@"icon_audio_state_right"];
        } else {
            self.videoImageView.image = [UIImage imageNamed:@"icon_camera_state_right"];
        }
    }
    
    NSString *showMessage;
    
    if (conference.contentState == kYYIMNetMeetingContentTypeTimeout
        || conference.contentState == kYYIMNetMeetingContentTypeRefuse
        || conference.contentState == kYYIMNetMeetingContentTypeBusy) {
        showMessage = message.direction == YM_MESSAGE_DIRECTION_RECEIVE ? @"已取消" : @"对方已取消";
    } else if (conference.contentState == kYYIMNetMeetingContentTypeCancel) {
        showMessage = message.direction == YM_MESSAGE_DIRECTION_RECEIVE ? @"对方已取消" : @"已取消";
    } else if (conference.contentState == kYYIMNetMeetingContentTypeEnd) {
        NSString *talkTime = [YYIMUtility genTimingStringWithTime:conference.talkTime];;
        showMessage = [NSString stringWithFormat:@"聊天时长: %@",talkTime];
    }
    
    [self.messageLabel setText:showMessage];
    
    if ([message direction] == YM_MESSAGE_DIRECTION_RECEIVE && (![message specificStatus] || [message specificStatus] == YM_MESSAGE_SPECIFIC_INITIAL) && conference.contentState != kYYIMNetMeetingContentTypeEnd) {
        self.unreadImage.image = [UIImage imageNamed:@"icon_unread"];
        self.unreadImage.hidden = NO;
    }
    
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

@end
