//
//  YYIMUIDefs.h
//  YonyouIM
//
//  Created by litfb on 14/12/26.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#ifndef YonyouIM_YYIMUIDefs_h
#define YonyouIM_YYIMUIDefs_h

#define YYIM_NOTIFICATION_LOGINCHANGE @"YYIM_NOTIFICATION_LOGINCHANGE"

#define YYIM_LASTLOGIN_ACCOUNT @"YYIM_LASTLOGIN_ACCOUNT"

#define YYIM_NOTIFICATION_HEADPHONE_CHANGE @"YYIM_NOTIFICATION_HEADPHONE_CHANGE"

#define YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE @"YYIM_NOTIFICATION_NETMEETING_STATE_CHANGE"

#define YYIM_ACCOUNT @"YYIM_ACCOUNT"

#define YYIM_PASSWORD @"YYIM_PASSWORD"

#define YYIM_APPKEY @"YYIM_APPKEY"

#define YYIM_ETPKEY @"YYIM_ETPKEY"

#define YYIM_DEFAULT_APPKEY @"udn"

#define YYIM_DEFAULT_ETPKEY @"yonyou"

#define YYIM_iOS9 [[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0

#define YYIM_iOS8 [[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0

#define YYIM_iOS7 [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define YM_MULTILINE_TEXTSIZE(text, font, maxSize) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define YM_MULTILINE_TEXTSIZE(text, font, maxSize) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:0] : CGSizeZero;
#endif

#define kYMChatPressedMessage               @"YM_CHAT_PRESSED_MESSAGE"
#define kYMChatPressedCell                  @"YM_CHAT_PRESSED_CELL"
#define kYMChatPressedGestureRecognizer     @"YM_CHAT_PRESSED_GESTURE_RECOGNIZER"
#define kYMChatPressedIndex                 @"YM_CHAT_PRESSED_INDEX"
#define kYMChatPressedHead                  @"YM_CHAT_PRESSED_HEAD"
#define kYMChatPressedURL                   @"YM_CHAT_PRESSED_URL"

#define kYMSearchPressedType                @"YM_Search_PRESSED_TYPE"
#define kYMSearchPressedIndex               @"YM_Search_PRESSED_INDEX"

#define kYMConferenceManagerPressedMember                @"YM_CONFERENCE_MANAGER_PRESSED_MEMBER"
#define kYMConferenceManagerPressedType                @"YM_CONFERENCE_MANAGER_PRESSED_TYPE"
#define kYMConferenceManagerPressedValue               @"YM_CONFERENCE_MANAGER_PRESSED_VALUE"

typedef NS_ENUM(NSInteger, YMSearchType) {
    kYMSearchTypeRoster      = 0,
    kYMSearchTypeChatGroup   = 1,
    kYMSearchTypeMessage     = 2
};

#endif
