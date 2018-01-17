//
//  JUMPPlainAuthentication.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPPlainAuthentication.h"
#import "JUMPLogging.h"
#import "JUMPInternal.h"
#import "JUMPStream.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int jumpLogLevel = JUMP_LOG_LEVEL_INFO; // | JUMP_LOG_FLAG_TRACE;
#else
static const int jumpLogLevel = JUMP_LOG_LEVEL_WARN;
#endif

@implementation JUMPPlainAuthentication {
    __weak JUMPStream *jumpStream;
    
    NSString *password;
}

+ (NSString *)mechanismName {
    return @"PLAIN";
}

- (id)initWithStream:(JUMPStream *)stream password:(NSString *)inPassword {
    if ((self = [super init])) {
        jumpStream = stream;
        password = inPassword;
    }
    return self;
}

//opcode 0x0001
//{
//    "usr": "liuhaoi",
//    "atk": "3a637a38-d035-4897-aa75-ea0acee2327f",
//    "br": "web",
//    "cm": "zlib"
//}
- (BOOL)start:(NSError **)errPtr {
    JUMPLogTrace();
    NSString *username = [jumpStream.myJID user];
    NSString *resource = [jumpStream.myJID resource];
    
    JUMPPacket *packet = [[JUMPPacket alloc] initWithOpData:JUMP_OPDATA(JUMPAuthPacketOpCode)];
    [packet setObject:username forKey:@"usr"];
    [packet setObject:password forKey:@"atk"];
    [packet setObject:resource forKey:@"br"];
    [packet setObject:@"gzip" forKey:@"cm"];
    
    [jumpStream sendAuthPacket:packet];
    return YES;
}

- (JUMPHandleAuthResponse)handleAuth:(JUMPPacket *)authResponse {
    JUMPLogTrace();
    
    // We're expecting a success response.
    // If we get anything else we can safely assume it's the equivalent of a failure response.
    
    if ([[authResponse objectForKey:@"code"] intValue] == 200) {
        return JUMP_AUTH_SUCCESS;
    } else {
        return JUMP_AUTH_FAIL;
    }
}

@end

#pragma mark -

@implementation JUMPStream (JUMPPlainAuthentication)

- (BOOL)supportsPlainAuthentication {
    return [self supportsAuthenticationMechanism:[JUMPPlainAuthentication mechanismName]];
}

@end
