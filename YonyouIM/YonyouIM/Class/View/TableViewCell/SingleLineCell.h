//
//  SingleLineCell.h
//  ；
//
//  Created by litfb on 15/1/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RosterStateView.h"

@interface SingleLineCell : UITableViewCell

@property (retain, nonatomic) IBOutlet RosterStateView *stateView;
@property (retain, nonatomic) IBOutlet UIImageView *iconImage;
@property (retain, nonatomic) IBOutlet UILabel *nameLabel;
@property (retain, nonatomic) IBOutlet UILabel *badgeLabel;

- (void)reuse;

- (void)showState:(BOOL)state;

- (void)setHeadImageWithUrl:(NSString *)headUrl;

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name;

- (void)setHeadIcon:(NSString *)iconName;

- (void)setGroupIcon:(NSString *)groupId;

- (void)setName:(NSString *)name;

- (void)setNameWithAttrString:(NSAttributedString *)attrName;

- (void)setLabelFont:(UIFont *)font;

- (void)setBadge:(NSString *)badge;

- (void)setImageRadius:(NSInteger)radius;

@end
