//
//  SingleLineCell2.m
//  YonyouIM
//
//  Created by litfb on 15/3/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "SingleLineCell2.h"
#import "UIImageView+WebCache.h"
#import "YYIMColorHelper.h"
#import "UIImage+YYIMCategory.h"

@implementation SingleLineCell2

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = UIColorFromRGBA(0xececec, 0.25f);
    [self setSelectedBackgroundView:view];
    
    [self reuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        if (!self.switchControl.hidden) {
            [self.switchControl setOn:![self.switchControl isOn] animated:YES];
            [self.switchControl sendActionsForControlEvents:UIControlEventValueChanged];
        }
    }
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    self.nameLabel.text = nil;
    self.detailLabel.text = nil;
    self.detailLabel.hidden = YES;
    self.switchControl.on = NO;
    self.switchControl.hidden = YES;
    self.detailImage.image = nil;
    self.detailImage.hidden = YES;
    self.timerView.hidden = YES;
    self.timerLabel.text = nil;
    self.timerImage.image = nil;
    
    CALayer *layer = [self.detailImage layer];
    [layer setMasksToBounds:NO];
    [layer setCornerRadius:0];
    [self.switchControl setTag:0];
}

- (void)setNameLabelWidth:(CGFloat)nameWidth {
    [self.nameLabel removeConstraints:[self.nameLabel constraints]];
    [self.nameLabel addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:nameWidth]];
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setAttributeName:(NSMutableAttributedString *)name {
    self.nameLabel.attributedText = name;
}

- (void)setDetail:(NSString *)detail {
    self.detailLabel.text = detail;
    self.detailLabel.hidden = NO;
}

- (void)setImageWithName:(NSString *)name {
    [self.detailImage setImage:[UIImage imageNamed:name]];
    [self.detailImage setHidden:NO];
}

- (void)setImageWithUrl:(NSString *)url {
    [self.detailImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"icon_head"] options:0];
    [self.detailImage setHidden:NO];
}

- (void)setImageWithUrl:(NSString *)url placeholderName:(NSString *)name {
    UIImage *placeholder = [UIImage imageWithDispName:name];
    if (!placeholder) {
        placeholder = [UIImage imageNamed:@"icon_head"];
    }
    [self.detailImage sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:nil options:0 completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (!image) {
            [self.detailImage setImage:placeholder];
        }
    }];
    [self.detailImage setHidden:NO];
}

- (void)setImageRadius:(CGFloat)radius {
    CALayer *layer = [self.detailImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
}

- (void)setSwitchState:(BOOL)switchState {
    [self setSwitchState:switchState enable:YES];
}

- (void)setSwitchState:(BOOL)switchState enable:(BOOL)enable {
    self.switchControl.on = switchState;
    self.switchControl.enabled = enable;
    self.switchControl.hidden = NO;
}

- (void)setTimer:(NSString *)timer enbleEidt:(BOOL)enbleEidt {
    self.timerLabel.text = timer;
    
    if (enbleEidt) {
        [self.timerLabel setTextColor:UIColorFromRGB(0x6ac66f)];
        self.timerImage.image = [UIImage imageNamed:@"icon_neetmeeting_time_edit"];
    } else {
        [self.timerLabel setTextColor:UIColorFromRGB(0x686868)];
        self.timerImage.image = [UIImage imageNamed:@"icon_neetmeeting_time_normal"];
    }
    
    self.timerView.hidden = NO;
}

@end
