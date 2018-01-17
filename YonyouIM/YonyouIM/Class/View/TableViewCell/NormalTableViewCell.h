//
//  NormalTableViewCell.h
//  YonyouIM
//
//  Created by litfb on 15/1/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMEmojiLabel.h"
#import "YYIMChatHeader.h"
#import "RosterStateView.h"

@interface NormalTableViewCell : UITableViewCell

@property (retain, nonatomic) IBOutlet UIView *headMaskView;
@property (retain, nonatomic) IBOutlet UIImageView *headImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel2;
@property (retain, nonatomic) IBOutlet UILabel *timeLabel;
@property (retain, nonatomic) IBOutlet UIView *optionView;
@property (retain, nonatomic) IBOutlet YYIMEmojiLabel *detailLabel;
@property (retain, nonatomic) IBOutlet UIButton *optionButton;
@property (retain, nonatomic) IBOutlet UIButton *optionButton2;
@property (retain, nonatomic) IBOutlet UILabel *stateLabel;
@property (retain, nonatomic) IBOutlet UILabel *badgeLabel;
@property (retain, nonatomic) IBOutlet UIImageView *stateImage;
@property (retain, nonatomic) IBOutlet RosterStateView *stateView;

- (void)reuse;

- (void)showHeadMask;

- (void)setHeadImageWithUrl:(NSString *)headUrl;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setHeadIcon:(NSString *)iconName;

- (void)setGroupIcon:(NSString *)groupId;

- (void)setName:(NSString *)name;

- (void)setNameWithAttrString:(NSAttributedString *)attrName;

- (void)setName2:(NSString *)name;

- (void)setName2WithAttrString:(NSAttributedString *)attrName;

- (void)setTime:(NSString *)time;

- (void)setDetail:(NSString *)detail;

- (void)setDetail:(NSString *)detail isAt:(BOOL)isAt;

- (void)setDetailWithAttrString:(NSAttributedString *)attrDetail;

- (void)setOption:(NSString *)option;

- (void)setOption2:(NSString *)option;

- (void)setState:(NSString *)state;

- (void)setBadge:(NSString *)badge;

- (void)setOptionWidth:(CGFloat)width;

- (void)setImageRadius:(NSInteger)radius;

- (void)setStateImageWithImageName:(NSString *)imageName;

- (void)showState:(BOOL)state;

@end
