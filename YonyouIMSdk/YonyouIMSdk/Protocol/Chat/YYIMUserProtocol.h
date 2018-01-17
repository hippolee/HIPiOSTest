//
//  YYIMUserProtocol.h
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseProtocol.h"

@protocol YYIMUserProtocol <YYIMBaseProtocol>

@optional

- (void)activeYYIMDelegate:(id<YYIMChatDelegate>)delegate;

- (void)loadRosterUsers;

- (void)deleteAllUnExistUserMessages;

- (void)deleteUnExistUserMessage:(NSString *)userId;

@required

/**
 *  根据关键字查询用户信息
 *
 *  @param keyword 关键字
 */
- (void)searchUserWithKeyword:(NSString *)keyword;

/**
 *  根据用户ID向Server请求用户信息
 *
 *  @param userId 用户ID
 */
- (void)loadUser:(NSString *)userId;

/**
 *  根据用户ID获取用户对象
 *
 *  @param userId 用户ID
 *
 *  @return YYUser
 */
- (YYUser *)getUserWithId:(NSString *)userId;

/**
 *  更新用户信息
 *
 *  @param user 用户信息YYUser
 */
- (void)updateUser:(YYUser *)user;

/**
 *  给用户增加tag
 *
 *  @param userTags tag数组
 *  @param complete 执行的回调
 */
- (void)AddUserTags:(NSArray *)userTags complete:(void (^)(BOOL, YYIMError *))complete;

/**
 *  删除用户的tag
 *
 *  @param userTags tag数组
 *  @param complete 执行的回调
 */
- (void)deleteUserTags:(NSArray *)userTags complete:(void (^)(BOOL, YYIMError *))complete;

@end
