//
//  YYMessage.h
//  YonyouIM
//
//  Created by litfb on 15/1/4.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYRoster.h"
#import "YYUser.h"
#import "YYChatGroup.h"
#import "YYPubAccount.h"
#import "YYMessageContent.h"
#import "YYIMDefs.h"

#define YM_MESSAGE_DIRECTION_RECEIVE        0
#define YM_MESSAGE_DIRECTION_SEND           1

#define YM_MESSAGE_TYPE_CHAT                @"chat"
#define YM_MESSAGE_TYPE_GROUPCHAT           @"groupchat"
#define YM_MESSAGE_TYPE_PUBACCOUNT          @"pubaccount"

#define YM_MESSAGE_STATE_NEW                0
#define YM_MESSAGE_STATE_FAILD              1
#define YM_MESSAGE_STATE_SENT_OR_READ       2
#define YM_MESSAGE_STATE_ACKED              3
#define YM_MESSAGE_STATE_DELIVERED          4

#define YM_MESSAGE_DOWNLOADSTATE_INI        0
#define YM_MESSAGE_DOWNLOADSTATE_ING        1
#define YM_MESSAGE_DOWNLOADSTATE_FAILD      2
#define YM_MESSAGE_DOWNLOADSTATE_SUCCESS    3

#define YM_MESSAGE_UPLOADSTATE_INI          0
#define YM_MESSAGE_UPLOADSTATE_ING          1
#define YM_MESSAGE_UPLOADSTATE_FAILD        2
#define YM_MESSAGE_UPLOADSTATE_SUCCESS      3

#define YM_MESSAGE_SPECIFIC_INITIAL         0
#define YM_MESSAGE_SPECIFIC_AUDIO_READ      10
#define YM_MESSAGE_SPECIFIC_INVITE_ACCEPT   20
#define YM_MESSAGE_SPECIFIC_INVITE_REFUSE   21

// 文本
#define YM_MESSAGE_CONTENT_TEXT             2
// 文件
#define YM_MESSAGE_CONTENT_FILE             4
// 图片
#define YM_MESSAGE_CONTENT_IMAGE            8
// 小视频
#define YM_MESSAGE_CONTENT_MICROVIDEO       10
// 撤回！！
#define YM_MESSAGE_CONTENT_REVOKE           13
// 单图文
#define YM_MESSAGE_CONTENT_SINGLE_MIXED     16
// 多图文
#define YM_MESSAGE_CONTENT_BATCH_MIXED      32
// 语音
#define YM_MESSAGE_CONTENT_AUDIO            64
// 位置
#define YM_MESSAGE_CONTENT_LOCATION         128
// 共享
#define YM_MESSAGE_CONTENT_SHARE            256
// 自定义
#define YM_MESSAGE_CONTENT_CUSTOM           512
// 视频会议
#define YM_MESSAGE_CONTENT_NETMEETING       2048
// 提示
#define YM_MESSAGE_CONTENT_PROMPT           1001

@interface YYMessage : NSObject

@property NSInteger pkid;

@property NSString *pid;

@property NSString *fromId;

@property NSString *rosterId;

@property NSString *toId;

@property NSInteger direction;

@property NSString *message;

@property NSInteger status;

@property NSInteger downloadStatus;

@property NSInteger uploadStatus;

@property NSInteger specificStatus;

@property NSInteger type;

@property NSString *chatType;

@property NSString *resLocal;

@property NSString *resThumbLocal;

@property NSString *resOriginalLocal;

@property NSTimeInterval date;

@property NSInteger version;

@property NSInteger mucVersion;

@property YYIMClientType clientType;

@property NSInteger customType;

@property NSString *keyInfo;

@property (retain, nonatomic) YYRoster *roster;

@property (retain, nonatomic) YYUser *user;

@property (retain, nonatomic) YYChatGroup *group;

@property (retain, nonatomic) YYPubAccount *account;

@property (retain, nonatomic) YYMessageContent *content;

- (YYMessageContent *)getMessageContent;

- (NSString *)getResLocal;

- (NSString *)getResThumbLocal;

- (NSString *)getResOriginalLocal;

- (void)updateReadState;

- (BOOL)isSystemMessage;

- (BOOL)isAtMe;

@end
