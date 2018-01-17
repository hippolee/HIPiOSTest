//
//  ChatSelNavController.h
//  YonyouIM
//
//  Created by litfb on 15/7/14.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMChatSelDelegate;

@interface ChatSelNavController : UINavigationController

@property (retain, nonatomic) id<YMChatSelDelegate> chatSelDelegate;

@end

@protocol YMChatSelDelegate <NSObject>

- (void)didSelectChatId:(NSString *)chatId chatType:(NSString *)chatType;

@end