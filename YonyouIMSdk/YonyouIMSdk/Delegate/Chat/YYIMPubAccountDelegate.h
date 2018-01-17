//
//  YYIMPubAccountDelegate.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/14.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYPubAccount.h"

@protocol YYIMPubAccountDelegate <NSObject>

@optional

/**
 *  公共号数据变化
 */
- (void)didPubAccountChange;

/**
 *  搜索公共号结果
 *
 *  @param pubAccountArray NSArray<YYPubAccount>
 */
- (void)didReceivePubAccountSearchResult:(NSArray *)pubAccountArray;

/**
 *  搜索公共号失败
 *
 *  @param error 错误
 */
- (void)didNotReceivePubAccountSearchResult:(YYIMError *)error;

/**
 *  加载公共号信息失败
 *
 *  @param error 错误
 */
- (void)didNotLoadPubAccountWithError:(YYIMError *)error;

/**
 * 公共号菜单发生变化
 */

/**
 * 公共号菜单发生变化
 *
 *  @param accountId公共号id
 */
- (void)didPubAccountMenuChange:(NSString *)accountId;

/**
 *  发送公共号命令失败
 *
 *  @param accountId公共号id
 *  @param error     错误信息
 */
- (void)didNotSendPubAccountCommandFailed:(NSString *)accountId error:(YYIMError *)error;

/**
 *  发送公共号命令成功
 *
 *  @param accountId公共号id
 */
- (void)didSendPubAccountxCommandSuccess:(NSString *)accountId;

@end
