//
//  JUMPSASLAuthentication.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JUMPStream;
@class JUMPPacket;

typedef NS_ENUM(NSInteger, JUMPHandleAuthResponse) {
    
    JUMP_AUTH_FAIL,     // Authentication failed.
    // The delegate will be informed via jumpStream:didNotAuthenticate:
    
    JUMP_AUTH_SUCCESS,  // Authentication succeeded.
    // The delegate will be informed via jumpStreamDidAuthenticate:
    
    JUMP_AUTH_CONTINUE, // The authentication process is still ongoing.
};

@protocol JUMPSASLAuthentication <NSObject>

@required

/**
 * Returns the associated mechanism name.
 *
 * An jump server sends a list of supported authentication mechanisms during the jump handshake.
 * The list looks something like this:
 *
 * <stream:features>
 *    <mechanisms xmlns="urn:ietf:params:xml:ns:jump-sasl">
 *       <mechanism>DIGEST-MD5</mechanism>
 *       <mechanism>X-FACEBOOK-PLATFORM</mechanism>
 *       <mechanism>X-YOUR-CUSTOM-AUTH-SCHEME</mechanism>
 *    </mechanisms>
 * </stream:features>
 *
 * The mechanismName returned should match the value inside the <mechanism>HERE</mechanism>.
 **/
+ (NSString *)mechanismName;

/**
 * Standard init method.
 *
 * The JUMPStream class natively supports the standard authentication scheme (auth with password).
 * If that method is used, then jumpStream will automatically create an authentication instance via this method.
 * Which authentication class it chooses is based on the configured authentication priorities,
 * and the auth mechanisms supported by the server.
 *
 * Not all authentication mechanisms will use this init method.
 * For example:
 *  - they require an appId and authToken
 *  - they require a userName (not related to JID), privilegeLevel, and password
 *  - they require an eyeScan and voiceFingerprint
 *
 * In this case, the authentication mechanism class should provide it's own custom init method.
 * However it should still implement this method, and then use the start method to notify of errors.
 **/
- (id)initWithStream:(JUMPStream *)stream password:(NSString *)password;

/**
 * Attempts to start the authentication process.
 * The auth mechanism should send whatever stanzas are needed to begin the authentication process.
 *
 * If it isn't possible to start the authentication process (perhaps due to missing information),
 * this method should return NO and set an appropriate error message.
 * For example: "X-Custom-Platform authentication requires authToken"
 * Otherwise this method should return YES.
 *
 * This method is called by automatically JUMPStream (via the authenticate: method).
 * You should NOT invoke this method manually.
 **/
- (BOOL)start:(NSError **)errPtr;

/**
 * After the authentication process has started, all incoming jump stanzas are routed to this method.
 * The authentication mechanism should process the stanza as appropriate, and return the coresponding result.
 * If the authentication is not yet complete, it should return JUMP_AUTH_CONTINUE,
 * meaning the jump stream will continue to forward all incoming jump stanzas to this method.
 *
 * This method is called automatically by JUMPStream (via the authenticate: method).
 * You should NOT invoke this method manually.
 **/
- (JUMPHandleAuthResponse)handleAuth:(JUMPPacket *)auth;

@end
