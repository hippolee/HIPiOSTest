//
//  ConferenceManagerCell.h
//  YonyouIM
//
//  Created by yanghaoc on 16/3/1.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYNetMeetingMember.h"
#import "YYNetMeeting.h"

@interface ConferenceManagerCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIImageView *iconImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UIButton *audioButton;
@property (retain, nonatomic) IBOutlet UIButton *moderatorButton;
@property (retain, nonatomic) IBOutlet UILabel *stateLabel;

- (void)setName:(NSString *)name;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setImageRadius:(NSInteger)radius;

- (void)setConferenceMember:(YYNetMeetingMember *)member isModerator:(BOOL)isModerator conferenceType:(YYIMNetMeetingType)conferenceType;

@end
