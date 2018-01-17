//
//  YYIMNetMeetingChatCell.h
//
//  Created by yanghao on 21/12/15.
//  Copyright (c) 2015 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMDefs.h"
#import "YYNetMeetingMember.h"

@interface YYIMNetMeetingChatCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (weak, nonatomic) IBOutlet UIImageView *audioImage;

@property (weak, nonatomic) IBOutlet UILabel *labelSmallName;

@property (weak, nonatomic) IBOutlet UIImageView *avatar;

@property (weak, nonatomic) IBOutlet UIView *avatarMaskView;

@property (weak, nonatomic) IBOutlet UIImageView *loadingImage;

- (void)setChannelMember:(YYNetMeetingMember *)member;

- (void)setImageRadius:(NSInteger)radius;

@end
