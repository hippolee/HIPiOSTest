//
//  ChatMixedTableViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/24.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "ChatMixedTableViewCell.h"
#import "YYIMUIDefs.h"
#import "YYIMColorHelper.h"
#import "YYIMUtility.h"

const CGFloat kChatMixedTitleFontSize = 20.0f;
const CGFloat kChatMixedSubTitleFontSize = 20.0f;
const CGFloat kChatMixedDetailFontSize = 14.0f;

@implementation ChatMixedTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CALayer *mixedLayer = [self.mixedView layer];
    [mixedLayer setMasksToBounds:YES];
    [mixedLayer setCornerRadius:8.0f];
    [mixedLayer setBorderColor:UIColorFromRGB(0xededed).CGColor];
    [mixedLayer setBorderWidth:1.0f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse {
    self.message = nil;
    self.timeLabel.text = nil;
}

- (void)setActiveMessage:(YYMessage *)message {
    self.message = message;
    self.timeLabel.text = [YYIMUtility genTimeString:[message date]];
}

+ (CGFloat)heightForCellWithData:(YYMessage *)message {
    return 0;
}

#pragma mark private func

+ (CGFloat)baseHeight {
    return 0;
}

+ (CGFloat)baseWidth {
    return CGRectGetWidth([UIScreen mainScreen].bounds) - 2 * 18 - 2 * 10;
}

+ (CGFloat)titleHeight:(YYPubAccountContent *)paContent {
    if ([paContent title]) {
        CGSize titleSize = YM_MULTILINE_TEXTSIZE([paContent title], [UIFont systemFontOfSize:kChatMixedTitleFontSize], CGSizeMake([ChatMixedTableViewCell baseWidth], CGFLOAT_MAX));
        return ceil(titleSize.height) + 0;
        
    }
    return 0;
}

+ (CGFloat)subTitleHeight:(YYPubAccountContent *)paContent {
    if ([paContent title]) {
        CGFloat baseWidth = [ChatMixedTableViewCell baseWidth];
        CGSize titleSize = YM_MULTILINE_TEXTSIZE([paContent title], [UIFont systemFontOfSize:kChatMixedTitleFontSize], CGSizeMake(baseWidth - 56, CGFLOAT_MAX));
        return ceil(titleSize.height) + 0;
        
    }
    return 0;
}

+ (CGFloat)detailHeight:(YYPubAccountContent *)paContent {
    if ([paContent digest]) {
        CGSize digestSize = YM_MULTILINE_TEXTSIZE([paContent digest], [UIFont systemFontOfSize:kChatMixedDetailFontSize], CGSizeMake([ChatMixedTableViewCell baseWidth], CGFLOAT_MAX));
        return ceil(digestSize.height) + 0;
    }
    return 0;
}

@end
