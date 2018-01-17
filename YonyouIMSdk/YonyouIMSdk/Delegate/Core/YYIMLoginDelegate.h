//
//  YYIMLoginDelegate.h
//  YonyouIM
//
//  Created by litfb on 14/12/31.
//  Copyright (c) 2014年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YYIMError.h"

@protocol YYIMLoginDelegate <NSObject>

@optional

- (void)willConnect;

- (void)didConnect;

- (void)didConnectFailure:(YYIMError *) error;

- (void)didAuthenticate;

- (void)didAuthenticateFailure:(YYIMError *) error;

- (void)didDisconnect;

- (void)didLoginConflictOccurred;

- (void)didModifyPasswordSuccess;

- (void)didNotModifyPassword:(YYIMError *)error;

- (void)didPresenceOnline;

@end
