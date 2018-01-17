//
//  YYIMEmojiHelper.h
//  YonyouIM
//
//  Created by litfb on 15/1/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "YYIMEmojiItem.h"

@interface YYIMEmojiHelper : NSObject

+ (YYIMEmojiHelper *)sharedInstance;

- (NSArray *)arrayOfEmoji;

- (NSArray *)arrayOfEmojiHistory;

- (NSString *)imageNameWithEmojiText:(NSString *)emojiText;

- (void)didEmojiUsed:(YYIMEmojiItem *)emojiItem;

- (NSMutableAttributedString *)attributeStringWithEmojiText:(NSString *)emojiText;

- (CGSize)preferredSizeWithAttributedString:(NSAttributedString *)attrString maxWidth:(CGFloat)maxWidth fontSize:(CGFloat)fontSize;

@end
