//
//  YYIMPubAccountProtocol.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/13.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YYIMBaseProtocol.h"
#import "YYPubAccountMenu.h"

@protocol YYIMPubAccountProtocol <YYIMBaseProtocol>

@required

/**
 *  从服务器加载所有PubAccount
 */
- (void)loadPubAccount;

/**
 *  获得已关注的所有公共号
 *
 *  @return NSArray<YYPubAccount>
 */
- (NSArray *)getAllPubAccount;

/**
 *  根据公共号ID获得公共号对象
 *
 *  @param accountId 公共号ID
 *
 *  @return YYPubAccount
 */
- (YYPubAccount *)getPubAccountWithAccountId:(NSString *)accountId;

/**
 *  根据关键字搜索公共号
 *
 *  @param keyword 关键字
 */
- (void)searchPubAccountWithKeyword:(NSString *)keyword;

/**
 *  关注公共号
 *
 *  @param accountId 公共号ID
 */
- (void)followPubAccount:(NSString *)accountId;

/**
 *  取消关注公共号
 *
 *  @param accountId 公共号ID
 */
- (void)unFollowPubAccount:(NSString *)accountId;

/**
 *  获取公共号的菜单
 *
 *  @param accountId公共号id
 
 */
- (YYPubAccountMenu *)getPubAccountMenu:(NSString *)accountId;

/**
 *  向Server请求公共号菜单
 *
 *  @param accountId公共号id
 */
- (void)LoadPubAccountMenu:(NSString *)accountId;

/**
 *  发送公共号的菜单命令
 *
 *  @param accountId公共号id
 *  @param item     公共号菜单选项
 *  @param complete  执行的回调
 */
- (void)sendPubAccountMenuCommand:(NSString *)accountId item:(YYPubAccountMenuItem *)item;

/**
 *  通过tag获取公共号集合
 *
 *  @param tag tag
 *
 *  @return公共号集合
 */
- (NSArray *)getPubAccountsWithTag:(NSString *)tag;

@end
