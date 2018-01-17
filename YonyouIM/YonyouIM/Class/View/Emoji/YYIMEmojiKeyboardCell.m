//
//  YYIMEmojiKeyboardCell.m
//  YonyouIM
//
//  Created by litfb on 15/6/17.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiKeyboardCell.h"

#define kYYIMEmojiPadding 2

@implementation YYIMEmojiKeyboardCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)prepareForReuse {
    self.keyItem = nil;
    self.isBack = NO;
    self.isSend = NO;
    [self.emojiLabel setText:nil];
    [self.emojiImage setImage:nil];
}

- (void)setKeyItem:(YYIMEmojiItem *)keyItem {
    _keyItem = keyItem;
    if (self.keyItem.emojiImage) {
        [self.emojiLabel setText:nil];
        [self.emojiImage setImage:self.keyItem.emojiImage];
    } else {
        [self.emojiImage setImage:nil];
        [self.emojiLabel setText:self.keyItem.emojiText];
    }
}

- (void)setIsBack:(BOOL)isBack {
    _isBack = isBack;
    if (isBack) {
        [self.emojiImage setImage:[UIImage imageNamed:@"icon_emojiback"]];
    }
}

- (void)setIsSend:(BOOL)isSend {
    _isSend = isSend;
    if (isSend) {
        UIImage *image = [[UIImage imageNamed:@"bg_bluebtn"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
        [self.emojiImage setImage:image];
        [self.emojiLabel setText:@"发送"];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj respondsToSelector:@selector(setSelected:)]) {
            [obj setSelected:selected];
        }
    }];
}

@end
