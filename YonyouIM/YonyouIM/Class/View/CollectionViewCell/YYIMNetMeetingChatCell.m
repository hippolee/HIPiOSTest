//
//  YYIMNetMeetingChatCell.m
//
//  Created by yanghao on 21/12/15.
//  Copyright (c) 2015 yonyou. All rights reserved.
//

#import "YYIMNetMeetingChatCell.h"
#import "UIImage+YYIMCategory.h"
#import "UIImageView+WebCache.h"

@interface YYIMNetMeetingChatCell ()

@end

@implementation YYIMNetMeetingChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.loadingImage.animationImages = [NSArray arrayWithObjects:
                                         [UIImage imageNamed:@"icon_netmeeting_inviting_loading0"],
                                         [UIImage imageNamed:@"icon_netmeeting_inviting_loading1"],
                                         [UIImage imageNamed:@"icon_netmeeting_inviting_loading2"],
                                         [UIImage imageNamed:@"icon_netmeeting_inviting_loading3"], nil];
    self.loadingImage.animationDuration = 0.8; //浏览整个图片一次所用的时间
    self.loadingImage.animationRepeatCount = 0; // 0 = loops forever 动画重复次数
    
    [self reuse];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)setChannelMember:(YYNetMeetingMember *)member {
    self.labelSmallName.text = member.memberName;
    
    self.avatar.image = nil;
        
    UIImage *image = [UIImage imageWithDispName:member.memberName];
    
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:member.getMemberPhoto] placeholderImage:image options:SDWebImageDelayPlaceholder];
    
    switch (member.inviteState) {
        case kYYIMNetMeetingInviteStateJoined: {
            if (member.isModerator) {
                if (member.enableAudio) {
                    self.audioImage.hidden = YES;
                } else {
                    self.audioImage.hidden = NO;
                }
            } else {
                if (member.forbidAudio || !member.enableAudio) {
                    self.audioImage.hidden = NO;
                } else {
                    self.audioImage.hidden = YES;
                }
            }
            
            if (member.enableVideo) {
                self.videoView.hidden = NO;
            } else {
                self.videoView.hidden = YES;
            }
            
            self.avatarMaskView.hidden = YES;
            [self.loadingImage stopAnimating];
            
            break;
        }
        case kYYIMNetMeetingInviteStateInviting: {
            self.avatarMaskView.hidden = NO;
            [self.loadingImage startAnimating];
            self.videoView.hidden = YES;
            self.audioImage.hidden = YES;
            
            break;
        }
        default:
            break;
    }
}

- (void)setImageRadius:(NSInteger)radius {
    CALayer *layer = [self.avatar layer];
    CALayer *maskLayer = [self.avatarMaskView layer];
    
    if (radius > 0) {
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:radius];
        [maskLayer setMasksToBounds:YES];
        [maskLayer setCornerRadius:radius];
    } else {
        [layer setMasksToBounds:NO];
        [layer setCornerRadius:0];
        [maskLayer setMasksToBounds:NO];
        [maskLayer setCornerRadius:0];
    }
}

- (void)reuse {
    [self.avatarMaskView setHidden:YES];
    self.videoView.hidden = YES;
    self.audioImage.hidden = YES;
    [self.loadingImage stopAnimating];
}

@end
