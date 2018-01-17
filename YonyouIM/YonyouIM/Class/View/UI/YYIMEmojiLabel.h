//
//  YYIMEmojiLabel.h
//  YonyouIM
//
//  Created by litfb on 16/6/23.
//  Copyright © 2016年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTTAttributedLabel.h"

typedef NS_OPTIONS(NSUInteger, YYIMEmojiLabelLinkType) {
    // 超链接
    YYIMEmojiLabelLinkTypeURL = 0,
    // 电话
    YYIMEmojiLabelLinkTypeMobile,
    // 邮箱
    YYIMEmojiLabelLinkTypeEmail,
    // @
    YYIMEmojiLabelLinkTypeAt,
    // #topic#
    YYIMEmojiLabelLinkTypeTopic
};

@protocol YYIMEmojiLabelDelegate;

@interface YYIMEmojiLabel : TTTAttributedLabel

// 禁用表情, default NO
@property (nonatomic, assign) BOOL disableEmoji;
// 禁用电话, default YES
@property (nonatomic, assign) BOOL disableMobile;
// 禁用邮箱, default YES
@property (nonatomic, assign) BOOL disableEmail;
// 禁用超链接, default YES
@property (nonatomic, assign) BOOL disableURL;
// 禁用@和话题, default YES
@property (nonatomic, assign) BOOL disableAtAndTopic;
// 代理
@property (nonatomic, weak) id<YYIMEmojiLabelDelegate> emojiDelegate;

// emojiText
@property (nonatomic, copy, readonly) id emojiText;

- (NSMutableAttributedString*)mutableAttributeStringWithEmojiText:(NSAttributedString *)emojiText;
// 计算preferredSize
- (CGSize)preferredSizeWithMaxWidth:(CGFloat)maxWidth;

@end

@protocol YYIMEmojiLabelDelegate <NSObject>

@optional

- (void)emojiLabel:(YYIMEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(YYIMEmojiLabelLinkType)type;

@required

- (NSString *)emojiLabel:(YYIMEmojiLabel *)emojiLabel imageNameOfEmojiText:(NSString *)emojiText;

@end