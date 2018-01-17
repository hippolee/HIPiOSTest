//
//  YYIMEmojiKeyboardKeyGroup.m
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMEmojiKeyboardKeyGroup.h"
#import "YYIMEmojiKeyboardCell.h"
#import "YYIMEmojiKeyboardCollectionFlowLayout.h"
#import "YYIMEmojiKeyboardKeyGroupView.h"
#import "YYIMEmojiKeyboard.h"

@interface YYIMEmojiKeyboardKeyGroup ()

@property (nonatomic,strong) UICollectionViewLayout *keyItemsLayout;

@end

@implementation YYIMEmojiKeyboardKeyGroup
@synthesize keyItemCellClass = _keyItemCellClass;

- (Class)keyItemCellClass {
    if (!_keyItemCellClass) {
        _keyItemCellClass = [YYIMEmojiKeyboardCell class];
    }
    return _keyItemCellClass;
}

- (void)setKeyItemCellClass:(Class)keyItemCellClass {
    if ([keyItemCellClass isSubclassOfClass:[YYIMEmojiKeyboardCell class]]) {
        _keyItemCellClass = keyItemCellClass;
    } else {
        NSAssert(NO, @"YYIMEmojiKeyboardKeyItemGroup: Setting keyItemCellClass - keyItemCellClass must be a subclass of YYIMEmojiKeyboardKeyCell.class");
    }
}

@end
