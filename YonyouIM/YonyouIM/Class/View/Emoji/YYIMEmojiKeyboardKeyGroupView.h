//
//  YYIMEmojiKeyboardKeyGroupView.h
//  YonyouIM
//
//  Created by litfb on 15/1/15.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMEmojiKeyboardKeyGroup.h"
#import "YYIMEmojiItem.h"
#import "YYIMEmojiKeyboardCell.h"

@interface YYIMEmojiKeyboardKeyGroupView : UIView

@property (nonatomic,strong) YYIMEmojiKeyboardKeyGroup *keyItemGroup;

@property (nonatomic,copy) void (^keyItemTappedBlock)(YYIMEmojiItem *keyItem);
@property (nonatomic,copy) void (^backspaceButtonTappedBlock)(void);

@property (nonatomic,copy) void (^pressedKeyItemCellChangedBlock)(YYIMEmojiKeyboardCell *fromKeyCell, YYIMEmojiKeyboardCell *toKeyCell);
@property (nonatomic, copy) void (^keyboardWillReturnBlock)(void);

@property (nonatomic,weak,readonly) UIImageView *backgroundImageView;

- (void) reloadEmojiData;

@end
