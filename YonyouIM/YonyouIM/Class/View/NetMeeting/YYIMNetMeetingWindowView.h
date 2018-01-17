//
//  YYIMNetMeetingWindowView.h
//  YonyouIM
//
//  Created by yanghaoc on 16/4/12.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMChatHeader.h"

@interface YYIMNetMeetingWindowView : UIView


@property (nonatomic, weak) IBOutlet UIView *nameView;

@property (nonatomic, weak) IBOutlet UIImageView *nameAvatar;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UIView *videoView;

+ (YYIMNetMeetingWindowView *)initNetMeetingWindowView;

- (void)setNetMeetingMember:(YYNetMeetingMember *)member;

@end
