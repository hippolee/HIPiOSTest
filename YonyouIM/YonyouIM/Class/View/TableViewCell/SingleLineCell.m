//
//  SingleLineCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "SingleLineCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+YYIMCatagory.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMColorHelper.h"

@implementation SingleLineCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *badgeLayer = [self.badgeLabel layer];
    [badgeLayer setMasksToBounds:YES];
    [badgeLayer setCornerRadius:9];
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = UIColorFromRGBA(0xececec, 0.25f);
    [self setSelectedBackgroundView:view];
    
    CALayer *stateLayer = [self.stateView layer];
    [stateLayer setMasksToBounds:YES];
    [stateLayer setCornerRadius:7.5f];
    [stateLayer setBorderWidth:3.0f];
    [stateLayer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self reuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    self.iconImage.image = nil;
    self.nameLabel.text = nil;
    [self.badgeLabel setText:nil];
    [self.badgeLabel setHidden:YES];
    [self.stateView setStateColor:UIColorFromRGB(0xc2c0c0)];
    [self.stateView setHidden:YES];
    CALayer *layer = [self.iconImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:24];
}

- (void)showState:(BOOL)state {
    if (state) {
        [self.stateView setStateColor:UIColorFromRGB(0x85b760)];
    } else {
        [self.stateView setStateColor:UIColorFromRGB(0xc2c0c0)];
    }
    [self.stateView setHidden:NO];
}

- (void) setHeadImageWithUrl:(NSString *) headUrl {
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:[UIImage imageNamed:@"icon_head"] options:0];
}

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name {
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:image options:0];
}

- (void) setHeadIcon:(NSString *)iconName {
    [self.iconImage setImage:[UIImage imageNamed:iconName]];
}

- (void)setIconImageWithName:(NSString *)imageName {
    [self.iconImage setImage:[UIImage imageNamed:imageName]];
}

- (void)setIconImageWithUrl:(NSString *)imageUrl {
    [self.iconImage sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                      placeholderImage:[UIImage imageNamed:@"icon_head"] options:0];
}

- (void) setGroupIcon:(NSString *)groupId {
    [self.iconImage ym_setImageWithGroupId:groupId placeholderImage:[UIImage imageNamed:@"icon_chatgroup"]];
    [self setImageRadius:0];
}

- (void)setName:(NSString *)name {
    self.nameLabel.text = name;
}

- (void)setNameWithAttrString:(NSAttributedString *)attrName {
    self.nameLabel.attributedText = attrName;
}

- (void)setLabelFont:(UIFont *)font {
    [self.nameLabel setFont:font];
}

- (void)setBadge:(NSString *)badge {
    if (!badge) {
        [self.badgeLabel setText:nil];
        [self.badgeLabel setHidden:YES];
    } else {
        [self.badgeLabel setText:badge];
        [self.badgeLabel setHidden:NO];
    }
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

@end
