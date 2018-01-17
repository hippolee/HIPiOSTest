//
//  NormalTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/1/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "NormalTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "UIImageView+YYIMCatagory.h"
#import "UIImage+YYIMCategory.h"
#import "YYIMColorHelper.h"
#import "YYIMEmojiHelper.h"

@interface NormalTableViewCell ()<YYIMEmojiLabelDelegate>

@property (retain, nonatomic) NSLayoutConstraint *constraint;

@end

@implementation NormalTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *btnLayer = [self.optionButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5];
    btnLayer = [self.optionButton2 layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5];
    
    CALayer *badgeLayer = [self.badgeLabel layer];
    [badgeLayer setMasksToBounds:YES];
    [badgeLayer setCornerRadius:9];
    
    UIView *view = [[UIView alloc] initWithFrame:self.frame];
    view.backgroundColor = UIColorFromRGBA(0xececec, 0.25f);
    [self setSelectedBackgroundView:view];
    
    [self.optionButton setBackgroundColor:UIColorFromRGB(0xed4d22)];
    [self.optionButton2 setBackgroundColor:UIColorFromRGB(0x69b553)];
    
    CALayer *stateLayer = [self.stateView layer];
    [stateLayer setMasksToBounds:YES];
    [stateLayer setCornerRadius:7.5f];
    [stateLayer setBorderWidth:3.0f];
    [stateLayer setBorderColor:[UIColor whiteColor].CGColor];
    
    [self.detailLabel setEmojiDelegate:self];
    
    [self reuse];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)prepareForReuse {
    [self reuse];
}

- (void)reuse {
    self.headImage.image = nil;
    self.nameLabel.text = nil;
    self.timeLabel.text = nil;
    self.detailLabel.text = nil;
    [self.optionButton setTitle:nil forState:UIControlStateNormal];
    [self.optionButton setHidden:YES];
    [self.optionButton2 setTitle:nil forState:UIControlStateNormal];
    [self.optionButton2 setHidden:YES];
    self.stateLabel.text = nil;
    [self.stateLabel setHidden:YES];
    [self.headMaskView setHidden:YES];
    if (self.constraint) {
        [self.optionView removeConstraint:self.constraint];
    }
    [self.badgeLabel setText:nil];
    [self.badgeLabel setHidden:YES];
    [self.stateImage setHidden:YES];
    
    [self.stateView setStateColor:UIColorFromRGB(0xc2c0c0)];
    [self.stateView setHidden:YES];
    
    CALayer *layer = [self.headImage layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:24];
}

- (void)showHeadMask {
    [self.headMaskView setHidden:NO];
}

- (void) setHeadImageWithUrl:(NSString *) headUrl {
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:[UIImage imageNamed:@"icon_head"] options:0];
}

- (void)setHeadImageWithUrl:(NSString *)headUrl placeholderName:(NSString *)name {
    UIImage *image = [UIImage imageWithDispName:name];
    if (!image) {
        image = [UIImage imageNamed:@"icon_head"];
    }
    [self.headImage sd_setImageWithURL:[NSURL URLWithString:headUrl]
                      placeholderImage:image options:0];
}

- (void) setHeadIcon:(NSString *)iconName {
    [self.headImage setImage:[UIImage imageNamed:iconName]];
}

- (void) setGroupIcon:(NSString *)groupId {
    [self.headImage ym_setImageWithGroupId:groupId placeholderImage:[UIImage imageNamed:@"icon_chatgroup"]];
    [self setImageRadius:0];
}

- (void) setName:(NSString *) name {
    self.nameLabel.text = name;
}

- (void)setNameWithAttrString:(NSAttributedString *)attrName {
    [self.nameLabel setAttributedText:attrName];
}

- (void)setName2:(NSString *)name {
    self.nameLabel2.text = name;
}

- (void)setName2WithAttrString:(NSAttributedString *)attrName {
    [self.nameLabel2 setAttributedText:attrName];
}

- (void) setTime:(NSString *) time {
    self.timeLabel.text = time;
}

- (void) setDetail:(NSString *) detail {
    [self.detailLabel setText:detail];
}

- (void)setDetail:(NSString *)detail isAt:(BOOL)isAt {
    if (!isAt) {
        [self.detailLabel setText:detail];
    } else {
        NSMutableAttributedString *detailAttrString = [[YYIMEmojiHelper sharedInstance] attributeStringWithEmojiText:detail];
        [detailAttrString addAttribute:NSForegroundColorAttributeName value:self.detailLabel.textColor range:NSMakeRange(0, detailAttrString.length)];
        NSMutableAttributedString *atAttrString = [[YYIMEmojiHelper sharedInstance] attributeStringWithEmojiText:@"[有人@我]"];
        [atAttrString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, atAttrString.length)];
        
        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
        [attrString appendAttributedString:atAttrString];
        [attrString appendAttributedString:detailAttrString];
        [attrString addAttribute:NSFontAttributeName value:self.detailLabel.font range:NSMakeRange(0, attrString.length)];
        [self.detailLabel setAttributedText:attrString];
    }
}

- (void)setDetailWithAttrString:(NSAttributedString *)attrDetail {
    [self.detailLabel setAttributedText:attrDetail];
}

- (void)setOption:(NSString *)option {
    [self.optionButton setTitle:option forState:UIControlStateNormal];
    [self.optionButton setHidden:NO];
}

- (void)setOption2:(NSString *)option {
    [self.optionButton2 setTitle:option forState:UIControlStateNormal];
    [self.optionButton2 setHidden:NO];
}

- (void)setState:(NSString *)state {
    self.stateLabel.text = state;
    [self.stateLabel setHidden:NO];
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

- (void)setOptionWidth:(CGFloat)width {
    self.constraint = [NSLayoutConstraint constraintWithItem:self.optionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:width];
    [self.constraint setPriority:UILayoutPriorityRequired];
    [self.optionView addConstraint:self.constraint];
}

- (void)setImageRadius:(NSInteger)radius {
    CALayer *layer = [self.headImage layer];
    if (radius > 0) {
        [layer setMasksToBounds:YES];
        [layer setCornerRadius:radius];
    } else {
        [layer setMasksToBounds:NO];
        [layer setCornerRadius:0];
    }
}

- (void)setStateImageWithImageName:(NSString *)imageName {
    [self.stateImage setImage:[UIImage imageNamed:imageName]];
    [self.stateImage setHidden:NO];
}

- (void)showState:(BOOL)state {
    if (state) {
        [self.stateView setStateColor:UIColorFromRGB(0x85b760)];
    } else {
        [self.stateView setStateColor:UIColorFromRGB(0xc2c0c0)];
    }
    [self.stateView setHidden:NO];
}

#pragma mark YYIMEmojiLabelDelegate

- (NSString *)emojiLabel:(YYIMEmojiLabel *)emojiLabel imageNameOfEmojiText:(NSString *)emojiText {
    return [[YYIMEmojiHelper sharedInstance] imageNameWithEmojiText:emojiText];
}

@end
