//
//  YYIMEmojiTabViewCell.m
//  YonyouIM
//
//  Created by litfb on 15/4/20.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiTabViewCell.h"
#import "UIColor+YYIMTheme.h"

@implementation YYIMEmojiTabViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor edGrayColor]];
    [self setSelectedBackgroundView:view];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        self.iconImage.image = _highlightedImage;
    } else {
        self.iconImage.image = _image;
    }
}

- (void)prepareForReuse {
    [self.iconImage setImage:nil];
    [self.titleLabel setText:nil];
    [self.titleLabel setHidden:YES];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if (![self isSelected]) {
        self.iconImage.image = _image;
    }
}

- (void)setHighlightedImage:(UIImage *)image {
    _highlightedImage = image;
    if ([self isSelected]) {
        self.iconImage.image = _highlightedImage;
    }
}

- (void)setTitle:(NSString *)title {
    [self.titleLabel setText:title];
    [self.titleLabel setHidden:NO];
}

@end
