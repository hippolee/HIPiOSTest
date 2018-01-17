//
//  YYIMLoginManager.m
//  YonyouIM
//
//  Created by litfb on 15/1/21.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "YYIMLoginManager.h"

#import "YYIMDefs.h"
#import "YYIMConfig.h"
#import "YYIMJUMPHelper.h"
#import "YYIMDBHelper.h"
#import "YYIMChatGroupMemberDBHelper.h"
#import "YYIMStringUtility.h"
#import "JUMPFramework.h"
#import "YYIMHttpUtility.h"
#import "YMAFHTTPSessionManager.h"
#import "YYIMLogger.h"
#import "YYIMPanDBHelper.h"
#import <Security/SecureTransport.h>

@interface YYIMLoginManager ()<JUMPStreamDelegate>

@property (nonatomic) NSString *_user;

@property (nonatomic) BOOL _anonymous;

@property (copy, nonatomic) YYIMLoginCompleteBlock loginCompleteBlock;

@end

@implementation YYIMLoginManager

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

#pragma mark login protocol

- (BOOL)isAutoLogin {
    if ([[YYIMConfig sharedInstance] isAutoLogin]) {
        NSString *user = [[YYIMConfig sharedInstance] getUser];
        if (![YYIMStringUtility isEmpty:user] && ![[YYIMConfig sharedInstance] isAnonymous]) {
            return YES;
        }
    }
    return NO;
}

- (YYIMError *)login:(NSString *)account {
    return [self doLogin:account];
}

- (void)login:(NSString *)account completion:(YYIMLoginCompleteBlock)completeBlock {
    self.loginCompleteBlock = [completeBlock copy];
    [self doLogin:account];
}

- (YYIMError *)loginAnonymous {
    return [self doLoginAnonymous];
}

- (void)loginAnonymousWithCompletion:(YYIMLoginCompleteBlock)completeBlock {
    self.loginCompleteBlock = [completeBlock copy];
    [self doLoginAnonymous];
}

- (YYIMError *)doLogin:(NSString *)user {
    YYIMError *ymError = nil;
    
    self._anonymous = NO;
    self._user = user;
    
    NSError *error = nil;
    NSString *jid = [YYIMJUMPHelper genFullJidString:user];
    
    BOOL result = [self connect:jid error:&error];
    if (!result) {
        ymError = [YYIMError errorWithNSError:error];
    }
    
    if (ymError) {
        [[self activeDelegate] didConnectFailure:ymError];
        [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:user forKey:@"account"] error:ymError];
    }
    return ymError;
}

- (YYIMError *)doLoginAnonymous {
    YYIMError *ymError = nil;
    
    self._anonymous = YES;
    self._user = nil;
    
    NSError *error = nil;
    NSString *jid = [YYIMJUMPHelper anonymousJidString];
    
    
    BOOL result = [self connect:jid error:&error];
    if (!result) {
        ymError = [YYIMError errorWithNSError:error];
    }
    
    if (ymError) {
        [[self activeDelegate] didConnectFailure:ymError];
        [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:@"anonymous" forKey:@"account"] error:ymError];
    }
    return ymError;
}

- (YYIMError *)logoff {
    [self goOffline];
    [self.activeStream disconnect];
    [[YYIMChatGroupMemberDBHelper sharedInstance] resetDatabase];
    [[YYIMDBHelper sharedInstance] resetDatabase];
    [[YYIMPanDBHelper sharedInstance] resetDatabase];
    return nil;
}

- (BOOL)isConnected {
    return [[self activeStream] isConnected];
}

- (YYIMConnectState)connectState {
    if ([[self activeStream] isConnected]) {
        return kYYIMConnectStateConnected;
    } else if ([[self activeStream] isDisconnected]) {
        return kYYIMConnectStateDisconnect;
    } else {
        return kYYIMConnectStateConnecting;
    }
}

- (void)goOnline {
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresencePacketOpCode)];
    [presence setPriority:10];
    [[self activeStream] sendPacket:presence];
}

- (void)goOffline {
    JUMPPresence *presence = [JUMPPresence presenceWithOpData:JUMP_OPDATA(JUMPPresencePacketOpCode) type:@"unavailable"];
    [[self activeStream] sendPacket:presence];
    
    [[self activeStream] disconnect];
}

- (void)modifiPassword:(NSString *)newPassword {
    NSString *regex = @"\\S{6,32}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isValidPassword = [predicate evaluateWithObject:newPassword];
    if (!isValidPassword) {
        YYIMError *error = [YYIMError errorWithCode:YMERROR_CODE_ILLEGAL_ARGUMENT errorMessage:@"password not valid"];
        [[self activeDelegate] didNotModifyPassword:error];
        return;
    }
    
    [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
        if (result) {
            YMAFHTTPSessionManager *manager = [YMAFHTTPSessionManager manager];
            [manager setCompletionQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
            NSString *urlString = [[YYIMConfig sharedInstance] getPasswordServlet];
            if ([YYIMStringUtility isEmpty:urlString]) {
                [[self activeDelegate] didNotModifyPassword:[YYIMError errorWithCode:YMERROR_CODE_UNEXPECT_STATE errorMessage:@"empty user or empty password url"]];
                return;
            }
            
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setObject:[token tokenStr] forKey:@"token"];
            [params setObject:newPassword forKey:@"password"];
            
            [manager PUT:urlString parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [[self activeDelegate] didModifyPasswordSuccess];
            } failure:^(NSURLSessionDataTask * _Nullable task, id responseObject, NSError * _Nonnull error) {
                NSHTTPURLResponse *response = [error.userInfo objectForKey:YMAFNetworkingOperationFailingURLResponseErrorKey];
                NSInteger statusCode = [response statusCode];
                [[self activeDelegate] didNotModifyPassword:[YYIMError errorWithCode:statusCode errorMessage:[error localizedDescription]]];
            }];
        } else {
            [[self activeDelegate] didNotModifyPassword:tokenError];
        }
    }];
}

- (void)doAutoLogin {
    if ([[self activeStream] isDisconnected]) {
        if ([[YYIMConfig sharedInstance] isAutoLogin]) {
            NSString *user = [[YYIMConfig sharedInstance] getUser];
            if (![[YYIMConfig sharedInstance] isAnonymous] && ![YYIMStringUtility isEmpty:user]) {
                YYIMLogInfo(@"%@", @"doAutoLogin");
                [self login:user];
            }
        }
    }
}

#pragma mark jumpstream delegate

- (void)jumpStreamWillConnect:(JUMPStream *)sender {
    YYIMLogError(@"jumpStreamWillConnect");
    [[self activeDelegate] willConnect];
}

- (void)jumpStreamDidConnect:(JUMPStream *)sender {
    YYIMLogError(@"jumpStreamDidConnect");
    __block NSError *error = nil;
    [[self activeDelegate] didConnect];
    if (self._anonymous) {
        [[YYIMConfig sharedInstance] setAnonymous:YES];
        [[YYIMConfig sharedInstance] setUser:[[[self activeStream] myJID] user]];
    } else {
        [[YYIMConfig sharedInstance] setAnonymous:NO];
        [[YYIMConfig sharedInstance] setUser:self._user];
    }
    if (self._anonymous) {
        [self authenticateAnonymous:&error];
    } else {
        [YYIMJUMPHelper genAvailableTokenWithComplete:^(BOOL result, YYToken *token, YYIMError *tokenError) {
            if (result) {
                [self authenticate:[token tokenStr] error:&error];
            } else {
                if ([tokenError errorCode] == 401) {
                    [[YYIMConfig sharedInstance] setAutoLogin:NO flag:NO];
                }
                [[self activeStream] disconnect];
                [[self activeDelegate] didAuthenticateFailure:tokenError];
                [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:self._user forKey:@"account"] error:tokenError];
            }
        } forceLoad:YES];
    }
}

- (void)jumpStreamDidNotConnect:(JUMPStream *)sender error:(NSError *)error {
    YYIMLogError(@"jumpStreamDidNotConnect");
    YYIMError *ymError = [YYIMError errorWithNSError:error];
    [[self activeDelegate] didConnectFailure:ymError];
    [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:self._user forKey:@"account"] error:ymError];
}

- (void)jumpStreamDidAuthenticate:(JUMPStream *)sender {
    [[YYIMConfig sharedInstance] setAutoLogin:YES];
    [self loginComplete:YES userInfo:[NSDictionary dictionaryWithObject:self._user forKey:@"account"] error:nil];
}

- (void)jumpStream:(JUMPStream *)sender didNotAuthenticate:(JUMPPacket *)packet error:(NSError *)error {
    YYIMError *ymError;
    if (packet) {
        NSInteger errorCode = [[packet objectForKey:@"code"] integerValue];
        NSString *errorMessage = [packet objectForKey:@"message"];
        ymError = [YYIMError errorWithCode:errorCode errorMessage:errorMessage];
    } else if (error) {
        ymError = [YYIMError errorWithNSError:error];
    } else {
        ymError = [YYIMError errorWithCode:YMERROR_CODE_UNKNOWN_ERROR errorMessage:@"Authenticate faild with unknown error"];
    }
    
    [[self activeDelegate] didAuthenticateFailure:ymError];
    [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:self._user forKey:@"account"] error:ymError];
}

- (void)jumpStreamDidDisconnect:(JUMPStream *)sender withError:(NSError *)error {
    if ([[error domain] isEqualToString:@"kCFStreamErrorDomainSSL"]) {
        YYIMLogError(@"jumpStreamDidDisconnect:SSL");
        [[YYIMConfig sharedInstance] setIMServerEnableSSL:NO];
        if (self._anonymous) {
            [self doLoginAnonymous];
        } else {
            [self doLogin:self._user];
        }
    } else {
        YYIMLogError(@"jumpStreamDidDisconnect");
        [[self activeDelegate] didDisconnect];
        [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:self._user forKey:@"account"] error:[YYIMError errorWithNSError:error]];
    }
}

- (void)jumpStream:(JUMPStream *)sender willSecureWithSettings:(NSMutableDictionary *)settings {
    [settings setObject:@(YES) forKey:YMGCDAsyncSocketManuallyEvaluateTrust];
    [settings setObject:@"im.yyuap.com" forKey:(NSString *)kCFStreamSSLPeerName];
}

- (void)jumpStream:(JUMPStream *)sender didReceiveTrust:(SecTrustRef)trust completionHandler:(void (^)(BOOL))completionHandler {
    completionHandler(YES);
}

- (void)jumpStreamDidSecure:(JUMPStream *)sender {
    YYIMLogDebug(@"jumpStreamDidSecure");
}

#pragma private func

- (BOOL)connect:(NSString *)jid error:(NSError **)errPtr {
    if ([[self activeStream] isConnected] || [[self activeStream] isConnectedNoAuth]) {
        [[self activeStream] disconnect];
    }
    
    JUMPJID *jumpJid = [JUMPJID jidWithString:jid resource:[NSString stringWithFormat:@"%@-%@", YM_CLIENT_IOS, YM_CLIENT_CURRENT_VERSION]];
    [[self activeStream] setMyJID:jumpJid];
    [[self activeStream] setHostName:[[YYIMConfig sharedInstance] getIMServer]];
    // 是否使用ssl
    if ([[YYIMConfig sharedInstance] isIMServerEnableSSL]) {
        [[self activeStream] setHostPort:[[YYIMConfig sharedInstance] getIMServerSSLPort]];
        [[self activeStream] setIsSecure:YES];
    } else {
        [[self activeStream] setHostPort:[[YYIMConfig sharedInstance] getIMServerPort]];
        [[self activeStream] setIsSecure:NO];
    }
    [[self activeStream] setEnableBackgroundingOnSocket:YES];
    
    NSTimeInterval timeInteval = 30;
    
    BOOL result = [[self activeStream] connectWithTimeout:timeInteval error:errPtr];
    if (!result) {
        [[self activeDelegate] didConnectFailure:[YYIMError errorWithNSError:*errPtr]];
        [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:self._user forKey:@"account"] error:[YYIMError errorWithNSError:*errPtr]];
    }
    return result;
}

- (BOOL)authenticate:(NSString *)password error:(NSError **)errPtr {
    if ([[self activeStream] isAuthenticated]) {
        return YES;
    }
    
    BOOL result = [[self activeStream] authenticateWithPassword:password error:errPtr];
    if (!result) {
        [[self activeDelegate] didAuthenticateFailure:[YYIMError errorWithNSError:*errPtr]];
        [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:self._user forKey:@"account"] error:[YYIMError errorWithNSError:*errPtr]];
    }
    return result;
}

- (BOOL)authenticateAnonymous:(NSError **)errPtr {
    if ([[self activeStream] isAuthenticated]) {
        return YES;
    }
    
    BOOL result = [[self activeStream] authenticateAnonymously:errPtr];
    if (!result) {
        [[self activeDelegate] didAuthenticateFailure:[YYIMError errorWithNSError:*errPtr]];
        [self loginComplete:NO userInfo:[NSDictionary dictionaryWithObject:@"anonymous" forKey:@"account"] error:[YYIMError errorWithNSError:*errPtr]];
    }
    return result;
}

- (void)loginComplete:(BOOL)result userInfo:(NSDictionary *)userInfo error:(YYIMError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.loginCompleteBlock) {
            self.loginCompleteBlock(result, userInfo, error);
            self.loginCompleteBlock = nil;
        }
    });
}

@end
