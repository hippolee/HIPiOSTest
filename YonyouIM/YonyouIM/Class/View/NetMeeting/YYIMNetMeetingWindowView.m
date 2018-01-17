//
//  YYIMNetMeetingWindowView.m
//  YonyouIM
//
//  Created by yanghaoc on 16/4/12.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import "YYIMNetMeetingWindowView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+YYIMCategory.h"

@implementation YYIMNetMeetingWindowView

+ (YYIMNetMeetingWindowView *)initNetMeetingWindowView {
    NSArray* nibView = [[NSBundle mainBundle] loadNibNamed:@"YYIMNetMeetingWindowView" owner:nil options:nil];
    return [nibView objectAtIndex:0];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.nameView.hidden = YES;
    self.videoView.hidden = YES;
    
    CALayer *layer = [self.nameAvatar layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:30.0f];
}

- (void)setNetMeetingMember:(YYNetMeetingMember *)member {
    self.nameLabel.text = member.memberName;
    
    self.nameAvatar.image = nil;
    
    UIImage *image = [UIImage imageWithDispName:member.memberName];
    
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    
    [self.nameAvatar sd_setImageWithURL:[NSURL URLWithString:member.getMemberPhoto] placeholderImage:image options:SDWebImageDelayPlaceholder];
    
    if (member.enableVideo) {
        self.nameView.hidden = YES;
        self.videoView.hidden = NO;
        
        if ([member.memberId isEqualToString:[[YYIMConfig sharedInstance] getUser]]) {
            [[YYIMChat sharedInstance].chatManager setupNetMeetingLocalVideo:self.videoView userId:member.memberId];
        } else {
            [[YYIMChat sharedInstance].chatManager setupNetMeetingRemoteVideo:self.videoView userId:member.memberId];
        }
    } else {
        self.nameView.hidden = NO;
        self.videoView.hidden = YES;
    }
}


@end
