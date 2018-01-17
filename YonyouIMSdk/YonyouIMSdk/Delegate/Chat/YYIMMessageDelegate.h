//
//  YYIMMessageDelegate.h
//  YonyouIM
//
//  Created by litfb on 15/1/9.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYMessage.h"

@protocol YYIMMessageDelegate <NSObject>

@optional

/**
 *  消息即将发送
 *
 *  @param message 消息
 */
- (void)willSendMessage:(YYMessage *)message;

/**
 *  消息已经发送
 *
 *  @param message 消息
 */
- (void)didSendMessage:(YYMessage *)message;

/**
 *  消息发送失败
 *
 *  @param message 消息
 *  @param error   错误
 */
- (void)didSendMessageFaild:(YYMessage *)message error:(YYIMError *)error;

/**
 *  收到消息
 *
 *  @param message 消息
 */
- (void)didReceiveMessage:(YYMessage *)message;

/**
 *  lazy delegate
 *  收到离线消息
 */
- (void)didReceiveOfflineMessages;

/**
 *  消息状态变更
 *
 *  @param message 消息
 */
- (void)didMessageStateChange:(YYMessage *)message;

/**
 *  消息状态变化
 *
 *  @param chatId 用户/群组ID
 */
- (void)didMessageStateChangeWithChatId:(NSString *)chatId;

/**
 *  消息资源（语音/图片/文件）状态变化
 *
 *  @param message 消息
 *  @param error   错误
 */
- (void)didMessageResStatusChanged:(YYMessage *)message error:(YYIMError *)error;

/**
 *  消息删除
 *
 *  @param info 删除信息
 */
- (void)didMessageDelete:(NSDictionary *)info;

/**
 *  消息撤回成功
 *
 *  @param pid 消息ID
 */
- (void)didRevokeMessageWithPid:(NSString *)pid;

/**
 *  消息撤回失败
 *
 *  @param pid   消息ID
 *  @param error
 */
- (void)didNotRevokeMessageWithPid:(NSString *)pid error:(YYIMError *)error;

/**
 *  消息撤回通知
 *
 *  @param message 消息
 */
- (void)didMessageRevoked:(YYMessage *)message;

@end
