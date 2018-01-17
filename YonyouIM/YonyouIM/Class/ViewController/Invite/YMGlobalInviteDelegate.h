//
//  InviteDelegate.h
//  YonyouIM
//
//  Created by yanghao on 15/11/12.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYChatGroup.h"

@protocol YMGlobalInviteDelegate <NSObject>

@required

- (void)didConfirmInviteActionViewController:(UIViewController *)viewController;

- (NSInteger)getDefaultCount;

@end

@protocol GlobalInviteViewControllerDelegate <NSObject>

@optional

- (void)didGlobalInviteViewController:(UIViewController *)viewController InviteUsers:(NSArray *)userArray;

@end
