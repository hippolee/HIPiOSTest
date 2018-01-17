//
//  YYMessage+YYIMCatagory.m
//  YonyouIM
//
//  Created by litfb on 15/4/8.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYMessage+YYIMCatagory.h"
#import "YYIMUtility.h"
#import "YYIMEmojiHelper.h"
#import "YYIMEmojiLabel.h"
#import "YYIMUIDefs.h"

#define kContentImage @"YYIM_CONTENT_IMAGE"
#define kContentThumbImage @"YYIM_CONTENT_THUMB_IMAGE"
#define kContentOriginalImage @"YYIM_CONTENT_ORIGINAL_IMAGE"
#define kContentMicroVideoUrl @"YYIM_CONTENT_MICROVIDEO_URL"
#define kContentHeight @"YYIM_CONTENT_HEIGHT"
#define kContentAttributeString @"YYIM_CONTENT_ATTRIBUTED_STRING"

const CGFloat kChatTextFontSize = 16.0f;

@implementation YYMessage (YYIMCatagory)

- (NSMutableAttributedString *)getAttributedString {
    NSMutableAttributedString *attributedString = [[self getMessageContent] attributeForKey:kContentAttributeString];
    if (!attributedString) {
        attributedString = [[YYIMEmojiHelper sharedInstance] attributeStringWithEmojiText:[[self getMessageContent] message]];
        [[self getMessageContent] setAttribute:attributedString forKey:kContentAttributeString];
    }
    return attributedString;
}

- (void)setContentHeight:(CGFloat)contentHeight {
    NSNumber *heightNumber = [NSNumber numberWithDouble:contentHeight];
    [[self getMessageContent] setAttribute:heightNumber forKey:kContentHeight];
}

- (void)clearContentHeight {
    [[self getMessageContent] setAttribute:nil forKey:kContentHeight];
}

- (CGFloat)getContentHeight {
    NSNumber *heightNumber = [[self getMessageContent] attributeForKey:kContentHeight];
    if (heightNumber) {
        return [heightNumber doubleValue];
    }
    return -1;
}

- (CGFloat)contentHeight {
    NSNumber *heightNumber = [[self getMessageContent] attributeForKey:kContentHeight];
    if (!heightNumber) {
        CGFloat offsetHeight = 20;
        CGFloat height = 0;
        switch ([self type]) {
            case YM_MESSAGE_CONTENT_TEXT:
            case YM_MESSAGE_CONTENT_CUSTOM:{
                CGSize size = [[YYIMEmojiHelper sharedInstance] preferredSizeWithAttributedString:[self getAttributedString] maxWidth:220 fontSize:kChatTextFontSize];
                height = size.height + offsetHeight + 10;
                height = fmaxf(56, height);
                break;
            }
            case YM_MESSAGE_CONTENT_LOCATION:
            case YM_MESSAGE_CONTENT_IMAGE: {
                UIImage *image = [self getMessageImage];
                CGSize newSize = [YYIMUtility sizeOfImageThumbSize:image.size withMaxSide:160.0f];
                height = newSize.height + offsetHeight;
                height = fmaxf(56, height);
                break;
            }
            case YM_MESSAGE_CONTENT_MICROVIDEO: {
                height = 150 + offsetHeight;
                
                break;
            }
            case YM_MESSAGE_CONTENT_AUDIO: {
                height = 56;
                break;
            }
            case YM_MESSAGE_CONTENT_FILE: {
                height = 82;
                break;
            }
            case YM_MESSAGE_CONTENT_SHARE: {
                height = 106;
                break;
            }
            default:
                height = 56;
                break;
        }
        heightNumber = [NSNumber numberWithDouble:height];
        [[self getMessageContent] setAttribute:heightNumber forKey:kContentHeight];
    }
    return [heightNumber doubleValue];
}

- (UIImage *)getMessageThumbImage {
    UIImage *image = [[self getMessageContent] attributeForKey:kContentThumbImage];
    if (!image) {
        if (![YYIMUtility isEmptyString:[self getResThumbLocal]] ) {
            image = [UIImage imageWithContentsOfFile:[self getResThumbLocal]];
            if (image) {
                [[self getMessageContent] setAttribute:image forKey:kContentThumbImage];
            }
        }
    }
    
    if (!image) {
        image = [UIImage imageNamed:@"icon_image"];
    }
    return image;
}

- (UIImage *)getMessageImage {
    UIImage *image = [[self getMessageContent] attributeForKey:kContentImage];
    if (!image) {
        if (![YYIMUtility isEmptyString:[self getResLocal]]) {
            image = [UIImage imageWithContentsOfFile:[self getResLocal]];
            
            if (image) {
                [[self getMessageContent] setAttribute:image forKey:kContentImage];
            }
        }
    }
    
    if (!image) {
        image = [self getMessageThumbImage];
    }
    return image;
}

- (UIImage *)getMessageMicroVideoThumb {
    UIImage *image = [[self getMessageContent] attributeForKey:kContentThumbImage];
    
    if (!image) {
        if (![YYIMUtility isEmptyString:[self getResThumbLocal]] ) {
            image = [UIImage imageWithContentsOfFile:[self getResThumbLocal]];
            if (image) {
                [[self getMessageContent] setAttribute:image forKey:kContentThumbImage];
            }
        }
    }
    
    return image;
}

- (NSURL *)getMessageMicroVideoFile {
    NSURL *url = [[self getMessageContent] attributeForKey:kContentMicroVideoUrl];
    
    if (!url) {
        if (![YYIMUtility isEmptyString:[self getResLocal]]) {
            url = [NSURL fileURLWithPath:self.getResLocal];
        }
    }
    
    return url;
}

- (UIImage *)getMessageOriginalImage {
    UIImage *image = [[self getMessageContent] attributeForKey:kContentOriginalImage];
    if (!image) {
        if (![YYIMUtility isEmptyString:[self getResOriginalLocal]]) {
            image = [UIImage imageWithContentsOfFile:[self getResOriginalLocal]];
            
            if (image) {
                [[self getMessageContent] setAttribute:image forKey:kContentOriginalImage];
            }
        }
    }
    
    if (!image) {
        image = [self getMessageImage];
    }
    return image;
}

@end
