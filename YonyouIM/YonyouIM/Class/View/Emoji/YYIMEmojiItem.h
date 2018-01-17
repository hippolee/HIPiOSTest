//
//  YYIMEmojiItem.h
//  YonyouIM
//
//  Created by litfb on 15/3/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface YYIMEmojiItem : NSObject

@property (nonatomic,retain) NSString *emojiText;

@property (nonatomic,retain) NSString *emojiImageName;

@property (nonatomic,retain) UIImage *emojiImage;

+ (instancetype) emojiItemWithText:(NSString *) emojiText imageName:(NSString *) imageName;

@end
