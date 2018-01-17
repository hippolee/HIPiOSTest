//
//  ConferenceManagerCell.m
//  YonyouIM
//
//  Created by yanghaoc on 16/3/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "ConferenceManagerCell.h"
#import "UIResponder+YYIMCategory.h"
#import "YYIMUIDefs.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"

@interface ConferenceManagerCell ()

@property (nonatomic) YYNetMeetingMember *member;

@end

@implementation ConferenceManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self reuse];
    
    [self.audioButton setImage:[UIImage imageNamed:@"icon_netmeeting_audio_small_normal"] forState:UIControlStateNormal];
    [self.audioButton setImage:[UIImage imageNamed:@"icon_netmeeting_audio_small_disable"] forState:UIControlStateSelected];
    
    [self.audioButton addTarget:self action:@selector(audioPress:) forControlEvents:UIControlEventTouchUpInside];
    [self.moderatorButton addTarget:self action:@selector(moderatorPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)setConferenceMember:(YYNetMeetingMember *)member isModerator:(BOOL)isModerator conferenceType:(YYIMNetMeetingType)conferenceType {
    self.member = member;

    YYIMNetMeetingInviteState inviteState = member.inviteState;
    switch (inviteState) {
        case kYYIMNetMeetingInviteStateJoined: {
            self.stateLabel.hidden = YES;
            
            if (conferenceType == kYYIMNetMeetingTypeLive) {
                self.audioButton.hidden = YES;
                self.moderatorButton.hidden = YES;
            } else {
                self.audioButton.hidden = NO;
                
                if (member.forbidAudio) {
                    self.audioButton.selected = YES;
                } else {
                    self.audioButton.selected = NO;
                }
                
                if (isModerator) {
                    self.moderatorButton.hidden = NO;
                } else {
                    self.moderatorButton.hidden = YES;
                }
            }
            
            break;
        }
        case kYYIMNetMeetingInviteStateInviting: {
            self.stateLabel.text = @"正在等待处理中...";
            self.stateLabel.hidden = NO;
            self.audioButton.hidden = YES;
            self.moderatorButton.hidden = YES;
            
            break;
        }
        case kYYIMNetMeetingInviteStateTimeout: {
            self.stateLabel.text = @"未响应";
            self.stateLabel.hidden = NO;
            self.audioButton.hidden = YES;
            self.moderatorButton.hidden = YES;
            
            break;
        }
        case kYYIMNetMeetingInviteStateBusy: {
            self.stateLabel.text = @"未响应";
            self.stateLabel.hidden = NO;
            self.audioButton.hidden = YES;
            self.moderatorButton.hidden = YES;
            
            break;
        }
        default:
            self.stateLabel.hidden = YES;
            self.audioButton.hidden = YES;
            self.moderatorButton.hidden = YES;
            
            break;
    }
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name {
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:image options:0];
}

- (void)setImageRadius:(NSInteger)radius {
    CALayer *layer = [self.iconImage layer];
    if (radius > 0) {
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:radius];
    } else {
        [layer setMasksToBounds:NO];
        [layer setCornerRadius:0];
    }
}

- (void)reuse {
    self.iconImage.image = nil;
    self.nameLabel.text = nil;
    self.stateLabel.text = nil;
    self.audioButton.selected = NO;
    
    CALayer *layer = [self.iconImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:24];
}

- (void)moderatorPressed:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self bubbleEventWithUserInfo:@{kYMConferenceManagerPressedMember:self.member, kYMConferenceManagerPressedType:@(0)}];
}

- (void)audioPress:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self bubbleEventWithUserInfo:@{kYMConferenceManagerPressedMember:self.member, kYMConferenceManagerPressedType:@(1), kYMConferenceManagerPressedValue:@(self.member.forbidAudio)}];
}

@end
