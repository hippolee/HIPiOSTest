//
//  YYIMEmojiDefs.h
//  YonyouIM
//
//  Created by litfb on 15/1/30.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#ifndef YonyouIM_YYIMEmojiDefs_h
#define YonyouIM_YYIMEmojiDefs_h

#define kYYIMEmojiKeyboardDefaultHeight 216
#define kYYIMEmojiKeyboardDefaultWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kYYIMEmojiKeyboardKeyItemGroupViewPageControlHeight 24
#define kYYIMEmojiKeyboardItemSpacing 1.0f
#define kYYIMEmojiKeyboardLineSpacing 1.0f
#define kYYIMEmojiKeyboardItemSide 44.0f

#define kYYIMEmojiKeyboardKeyItemGroupHeight (kYYIMEmojiKeyboardDefaultHeight - kYYIMEmojiKeyboardKeyItemGroupViewPageControlHeight)
#define kYYIMEmojiKeyboardColNumber (NSInteger)floorf(kYYIMEmojiKeyboardDefaultWidth / (kYYIMEmojiKeyboardItemSide + kYYIMEmojiKeyboardItemSpacing))
#define kYYIMEmojiKeyboardRowNumber (NSInteger)floorf(kYYIMEmojiKeyboardKeyItemGroupHeight / (kYYIMEmojiKeyboardItemSide + kYYIMEmojiKeyboardLineSpacing))
#define kYYIMEmojiKeyboardItemsPerPage ((NSInteger)(kYYIMEmojiKeyboardColNumber * kYYIMEmojiKeyboardRowNumber))

#endif
