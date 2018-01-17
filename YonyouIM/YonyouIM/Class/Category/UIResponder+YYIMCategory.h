//
//  UIResponder+YYIMCategory.h
//  YonyouIM
//
//  Created by litfb on 15/2/10.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (YYIMCategory)

- (void)bubbleEventWithUserInfo:(NSDictionary *)userInfo;

- (void)bubbleLongPressWithUserInfo:(NSDictionary *)userInfo;

@end
