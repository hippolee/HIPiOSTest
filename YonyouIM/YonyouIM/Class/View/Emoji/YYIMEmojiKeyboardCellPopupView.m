//
//  YYIMEmojiKeyboardCellPopupView.m
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiKeyboardCellPopupView.h"

@interface YYIMEmojiKeyboardCellPopupView ()

@property (nonatomic,weak) UIImageView *imageView;

@end

@implementation YYIMEmojiKeyboardCellPopupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImage *popupBackground = [UIImage imageNamed:@"bg_emojipop"];
        UIImageView *popupBackgroundView = [[UIImageView alloc] initWithImage:popupBackground];
        [self addSubview:popupBackgroundView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        self.imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = CGRectMake(8, 8, 32, 32);
}

- (void)setKeyItem:(YYIMEmojiItem *)keyItem {
    _keyItem = keyItem;
    self.imageView.image = keyItem.emojiImage;
}

@end
