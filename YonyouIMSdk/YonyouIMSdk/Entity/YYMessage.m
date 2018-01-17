//
// YYMessage.m
// YonyouIM
//
// Created by litfb on 15/1/4.
// Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYMessage.h"
#import "YYIMResourceUtility.h"
#import "YYIMDefs.h"
#import "YYIMChat.h"
#import "YYIMStringUtility.h"
#import "YYIMConfig.h"

@implementation YYMessage

- (YYMessageContent *)getMessageContent {
    if (![self content]) {
        [self setContent:[YYMessageContent contentWithMessage:self]];
    }
    return [self content];
}

- (NSString *)getResLocal {
    if ([YYIMStringUtility isEmpty:self.resLocal]) {
        return nil;
    }
    return [YYIMResourceUtility fullPathWithResourceRelaPath:self.resLocal];
}

- (NSString *)getResThumbLocal {
    if ([YYIMStringUtility isEmpty:self.resThumbLocal]) {
        return nil;
    }
    return [YYIMResourceUtility fullPathWithResourceRelaPath:self.resThumbLocal];
}

- (NSString *)getResOriginalLocal {
    if ([YYIMStringUtility isEmpty:self.resOriginalLocal]) {
        return nil;
    }
    return [YYIMResourceUtility fullPathWithResourceRelaPath:self.resOriginalLocal];
}

- (void)updateReadState {
    if ([self direction] != YM_MESSAGE_DIRECTION_RECEIVE) {
        return;
    }
    if (YM_MESSAGE_STATE_SENT_OR_READ == [self status]) {
        return;
    }
    [[YYIMChat sharedInstance].chatManager updateMessageReadedWithPid:[self pid]];
}

- (BOOL)isSystemMessage {
    if ([YM_ADMIN_USER isEqual:[self fromId]]) {
        return YES;
    }
    
    if ([[self chatType] isEqualToString:YM_MESSAGE_TYPE_GROUPCHAT] && [YM_ADMIN_USER isEqual:[self rosterId]]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isAtMe {
    return [[[self getMessageContent] atUserArray] containsObject:[[YYIMConfig sharedInstance] getUser]];
}

@end
