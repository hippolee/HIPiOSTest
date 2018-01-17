//
//  YYIMLoginManagerProtocol.h
//  YonyouIM
//
//  Created by litfb on 14/12/29.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMBaseProtocol.h"
#import "YYIMTokenDelegate.h"

typedef void(^YYIMLoginCompleteBlock)(BOOL result, NSDictionary* userInfo, YYIMError* loginError);

@protocol YYIMLoginProtocol <YYIMBaseProtocol>

@required

- (BOOL)isAutoLogin;

- (YYIMError *)login:(NSString *)account;

- (YYIMError *)loginAnonymous;

- (void)login:(NSString *)account completion:(YYIMLoginCompleteBlock) completeBlock;

- (void)loginAnonymousWithCompletion:(YYIMLoginCompleteBlock) completeBlock;

- (YYIMError *)logoff;

- (BOOL)isConnected;

- (YYIMConnectState)connectState;

- (void)goOnline;

- (void)goOffline;

- (void)modifiPassword:(NSString *)newPassword;

- (void)doAutoLogin;

@end
