//
//  YYIMEmojiKeyboardBuilder.m
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiKeyboardBuilder.h"
#import "YYIMEmojiKeyboardCellPopupView.h"
#import "YYIMEmojiHelper.h"
#import "UIColor+YYIMTheme.h"

@implementation YYIMEmojiKeyboardBuilder

+ (YYIMEmojiKeyboard *)sharedEmojiKeyboard {
    static YYIMEmojiKeyboard *_sharedEmoticonsKeyboard;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // create a keyboard of default size
        YYIMEmojiKeyboard *keyboard = [YYIMEmojiKeyboard keyboard];
        
        // emoji group
        YYIMEmojiKeyboardKeyGroup *emojiGroup = [[YYIMEmojiKeyboardKeyGroup alloc] init];
        emojiGroup.keyItems = [[YYIMEmojiHelper sharedInstance] arrayOfEmoji];
        emojiGroup.image = [UIImage imageNamed:@"icon_emoji"];
        emojiGroup.selectedImage = [UIImage imageNamed:@"icon_emoji_hl"];
//        // history emoji group
//        YYIMEmojiKeyboardKeyGroup *hisEmojiGroup = [[YYIMEmojiKeyboardKeyGroup alloc] init];
//        hisEmojiGroup.keyItems = [[YYIMEmojiHelper sharedInstance] arrayOfEmojiHistory];
//        hisEmojiGroup.image = [UIImage imageNamed:@"icon_history"];
//        hisEmojiGroup.selectedImage = [UIImage imageNamed:@"icon_history_hl"];
        
        // emoji groups
        keyboard.keyItemGroups = @[emojiGroup];// , hisEmojiGroupZ
        
        // cell popup view
        [keyboard setKeyItemGroupPressedKeyCellChangedBlock:^(YYIMEmojiKeyboardKeyGroup *keyItemGroup, YYIMEmojiKeyboardCell *fromCell, YYIMEmojiKeyboardCell *toCell) {
            [YYIMEmojiKeyboardBuilder sharedEmotionsKeyboardKeyItemGroup:keyItemGroup pressedKeyCellChangedFromCell:fromCell toCell:toCell];
        }];
        
        [keyboard setBackgroundColor:[UIColor f9GrayColor]];
        
        _sharedEmoticonsKeyboard = keyboard;
    });
    return _sharedEmoticonsKeyboard;
}

+ (void)sharedEmotionsKeyboardKeyItemGroup:(YYIMEmojiKeyboardKeyGroup *)keyItemGroup
             pressedKeyCellChangedFromCell:(YYIMEmojiKeyboardCell *)fromCell
                                    toCell:(YYIMEmojiKeyboardCell *)toCell {
    static YYIMEmojiKeyboardCellPopupView *pressedKeyCellPopupView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pressedKeyCellPopupView = [[YYIMEmojiKeyboardCellPopupView alloc] initWithFrame:CGRectMake(0, 0, 48, 85)];
        pressedKeyCellPopupView.hidden = YES;
        [[self sharedEmojiKeyboard] addSubview:pressedKeyCellPopupView];
    });
    
    if ([[self sharedEmojiKeyboard].keyItemGroups indexOfObject:keyItemGroup] == 0) {
        [[self sharedEmojiKeyboard] bringSubviewToFront:pressedKeyCellPopupView];
        if (toCell && ![toCell isSend] && ![toCell isBack] && [toCell keyItem]) {
            pressedKeyCellPopupView.keyItem = toCell.keyItem;
            pressedKeyCellPopupView.hidden = NO;
            CGRect frame = [[self sharedEmojiKeyboard] convertRect:toCell.bounds fromView:toCell];
            pressedKeyCellPopupView.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMaxY(frame)-CGRectGetHeight(pressedKeyCellPopupView.frame)/2);
        } else {
            pressedKeyCellPopupView.hidden = YES;
        }
    }
}

@end
