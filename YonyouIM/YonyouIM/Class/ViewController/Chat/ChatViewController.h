//
//  ChatViewController.h
//  YonyouIM
//
//  Created by litfb on 15/5/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YYIMBaseViewController.h"

typedef NS_ENUM(NSInteger,YMMessageViewState) {
    YMMessageViewStateShowEmoji,   //显示表情
    YMMessageViewStateShowExtend,  //显示扩展功能
    YMMessageViewStateShowNone     //没有显示
};

@interface ChatViewController : YYIMBaseViewController<UITableViewDataSource, UITableViewDelegate>

@property NSString *chatId;

@property NSString *chatType;

@property NSString *pid;

@property BOOL backToMain;

@end
