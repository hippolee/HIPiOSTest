//
//  YYIMUserDelegate.h
//  YonyouIM
//
//  Created by litfb on 15/1/23.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYUser.h"

@protocol YYIMUserDelegate <NSObject>

@optional

/**
 *  用户搜索结果
 *
 *  @param userArray NSArray<YYUser>
 */
- (void)didReceiveUserSearchResult:(NSArray *)userArray;

/**
 *  用户搜索失败
 *
 *  @param error 错误
 */
- (void)didNotReceiveUserSearchResult:(YYIMError *)error;

/**
 *  用户信息更新
 *
 *  @param user 用户
 */
- (void)didUserInfoUpdate:(YYUser *)user;

// lazy delegate
- (void)didUserInfoUpdate;

/**
 *  加载好友用户信息失败
 *
 *  @param error
 */
- (void)didNotLoadRosterUsersWithError:(YYIMError *)error;

@end
