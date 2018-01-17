//
//  YYIMEmojiKeyboard.h
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMEmojiKeyboardKeyGroup.h"
#import "YYIMEmojiKeyboardCollectionFlowLayout.h"
#import "YYIMEmojiKeyboardCell.h"
#import "YYIMEmojiItem.h"

@protocol YYIMEmojiKeyboardDelegate;

@interface YYIMEmojiKeyboard : UIView

@property (nonatomic, copy) NSArray *keyItemGroups;

@property (nonatomic, copy) void (^keyItemGroupPressedKeyCellChangedBlock)(YYIMEmojiKeyboardKeyGroup *keyItemGroup, YYIMEmojiKeyboardCell *fromKeyCell, YYIMEmojiKeyboardCell *toKeyCell);

@property (nonatomic, weak, readonly) UITextView *textInput;

+ (instancetype)keyboard;

- (void)attachToTextInput:(UITextView *)textInput;

@end