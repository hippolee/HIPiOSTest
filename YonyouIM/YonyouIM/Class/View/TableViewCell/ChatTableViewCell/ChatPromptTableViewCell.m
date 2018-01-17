//
//  ChatPromptTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/7/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatPromptTableViewCell.h"
#import "YYMessage+YYIMCatagory.h"
#import "YYIMUIDefs.h"
#import "YYIMUtility.h"

@interface ChatPromptTableViewCell ()

@property (retain, nonatomic) NSLayoutConstraint *timeConstraint;

@property (retain, nonatomic) NSLayoutConstraint *timeLabelConstraint;

@end

@implementation ChatPromptTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *timeLayer = [self.timeLabel layer];
    [timeLayer setMasksToBounds:YES];
    [timeLayer setCornerRadius:3.0f];
    [self.timeLabel setEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 8)];
    
    CALayer *labelLayer = [self.promptLabel layer];
    [labelLayer setMasksToBounds:YES];
    [labelLayer setCornerRadius:4.0f];
    [self.promptLabel setEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 8)];
    
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.message = nil;
    self.promptLabel.text = nil;
    self.timeLabel.text = nil;
    self.timeLabel.hidden = YES;
    
    if (_timeConstraint) {
        [self.timeView removeConstraint:_timeConstraint];
    }
    if (_timeLabelConstraint) {
        [self.timeLabel removeConstraint:_timeLabelConstraint];
    }
}

- (void)setTimeText:(NSString *)time {
    if (time != nil && time.length > 0) {
        self.timeLabel.text = time;
        self.timeLabel.hidden = NO;
        [self.timeView addConstraint:[self timeConstraint]];
        [self.timeLabel addConstraint:[self timeLabelConstraint]];
    }
}

- (void)setActiveMessage:(YYMessage *)message {
    self.message = message;
    self.promptLabel.text = [YYIMUtility getSimpleMessage:message];
}

- (NSLayoutConstraint *)timeConstraint {
    if (!_timeConstraint) {
        _timeConstraint = [NSLayoutConstraint constraintWithItem:self.timeView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:30.0f];
        _timeConstraint.priority = 751;
    }
    return _timeConstraint;
}

- (NSLayoutConstraint *)timeLabelConstraint {
    if (!_timeLabelConstraint) {
        _timeLabelConstraint = [NSLayoutConstraint constraintWithItem:self.timeLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:22.0f];
        _timeLabelConstraint.priority = 751;
    }
    return _timeLabelConstraint;
}

+ (CGFloat)heightForCellWithData:(YYMessage *)message isTimeShow:(BOOL)isTimeShow {
    CGFloat height = [message getContentHeight];
    if (height <= 0) {
        NSString *prompt = [YYIMUtility getSimpleMessage:message];
        height = [self baseHeight];
        // title
        height += [self promptHeight:prompt];
        // set
        [message setContentHeight:height];
    }
    
    if (isTimeShow) {
        height += 30.0f;
    }
    return height;
}

#pragma mark private func

+ (CGFloat)baseHeight {
    return 20;
}

+ (CGFloat)baseWidth {
    return CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * 32 - 2 * 8;
}

+ (CGFloat)promptHeight:(NSString *)prompt {
    if (prompt) {
        CGSize titleSize = YM_MULTILINE_TEXTSIZE(prompt, [UIFont systemFontOfSize:12.0f], CGSizeMake([self baseWidth], CGFLOAT_MAX));
        return ceil(titleSize.height);
    }
    return 0;
}

@end
