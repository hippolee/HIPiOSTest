//
//  JUMPAnonymousAuthentication.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPAnonymousAuthentication.h"
#import "JUMPLogging.h"
#import "JUMPInternal.h"

// Log levels: off, error, warn, info, verbose
#if DEBUG
static const int jumpLogLevel = JUMP_LOG_LEVEL_INFO; // | JUMP_LOG_FLAG_TRACE;
#else
static const int jumpLogLevel = JUMP_LOG_LEVEL_WARN;
#endif

/**
 * Seeing a return statements within an inner block
 * can sometimes be mistaken for a return point of the enclosing method.
 * This makes inline blocks a bit easier to read.
 **/
#define return_from_block  return

@implementation JUMPAnonymousAuthentication {
    __weak JUMPStream *jumpStream;
}

+ (NSString *)mechanismName {
    return @"ANONYMOUS";
}

- (id)initWithStream:(JUMPStream *)stream {
    if ((self = [super init])) {
        jumpStream = stream;
    }
    return self;
}

- (id)initWithStream:(JUMPStream *)stream password:(NSString *)password {
    return [self initWithStream:stream];
}

- (BOOL)start:(NSError **)errPtr {
    // <auth xmlns="urn:ietf:params:xml:ns:jump-sasl" mechanism="ANONYMOUS" />
    
//    NSXMLElement *auth = [NSXMLElement elementWithName:@"auth" xmlns:@"urn:ietf:params:xml:ns:jump-sasl"];
//    [auth addAttributeWithName:@"mechanism" stringValue:@"ANONYMOUS"];
//    
//    [jumpStream sendAuthElement:auth];
    
    return YES;
}

- (JUMPHandleAuthResponse)handleAuth:(JUMPPacket *)authResponse {
    // We're expecting a success response.
    // If we get anything else we can safely assume it's the equivalent of a failure response.
    
//    if ([[authResponse name] isEqualToString:@"success"]) {
//        return JUMP_AUTH_SUCCESS;
//    } else {
//        return JUMP_AUTH_FAIL;
//    }
    return JUMP_AUTH_FAIL;
}

@end

#pragma mark -

@implementation JUMPStream (JUMPAnonymousAuthentication)

- (BOOL)supportsAnonymousAuthentication {
    return [self supportsAuthenticationMechanism:[JUMPAnonymousAuthentication mechanismName]];
}

- (BOOL)authenticateAnonymously:(NSError **)errPtr {
    JUMPLogTrace();
    
    __block BOOL result = YES;
    __block NSError *err = nil;
    
    dispatch_block_t block = ^{ @autoreleasepool {
        
        if ([self supportsAnonymousAuthentication]) {
            JUMPAnonymousAuthentication *anonymousAuth = [[JUMPAnonymousAuthentication alloc] initWithStream:self];
            
            result = [self authenticate:anonymousAuth error:&err];
        } else {
            NSString *errMsg = @"The server does not support anonymous authentication.";
            NSDictionary *info = [NSDictionary dictionaryWithObject:errMsg forKey:NSLocalizedDescriptionKey];
            
            err = [NSError errorWithDomain:JUMPStreamErrorDomain code:JUMPStreamUnsupportedAction userInfo:info];
            
            result = NO;
        }
    }};
    
    if (dispatch_get_specific(self.jumpQueueTag)) {
        block();
    } else {
        dispatch_sync(self.jumpQueue, block);
    }
    
    if (errPtr) {
        *errPtr = err;
    }
    return result;
}

@end
