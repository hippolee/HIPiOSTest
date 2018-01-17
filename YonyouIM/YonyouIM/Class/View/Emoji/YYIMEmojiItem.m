//
//  YYIMEmojiItem.m
//  YonyouIM
//
//  Created by litfb on 15/3/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiItem.h"

@implementation YYIMEmojiItem

+ (instancetype)emojiItemWithText:(NSString *)emojiText imageName:(NSString *)imageName {
    YYIMEmojiItem *emojiItem = [[YYIMEmojiItem alloc] init];
    emojiItem.emojiText = emojiText;
    emojiItem.emojiImageName = imageName;
    return emojiItem;
}

- (UIImage *)emojiImage {
    if (_emojiImage == nil) {
        _emojiImage = [UIImage imageNamed:self.emojiImageName];
    }
    return _emojiImage;
}

@end
