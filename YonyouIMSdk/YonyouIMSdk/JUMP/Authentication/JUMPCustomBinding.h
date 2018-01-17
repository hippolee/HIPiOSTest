//
//  JUMPCustomBinding.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPPacket.h"

typedef NS_ENUM(NSInteger, JUMPBindResult) {
    
    JUMP_BIND_CONTINUE,      // The custom binding process is still ongoing.
    
    JUMP_BIND_SUCCESS,       // Custom binding succeeded.
    // The stream should continue normal post-binding operation.
    
    JUMP_BIND_FAIL_FALLBACK, // Custom binding failed.
    // The stream should fallback to the standard binding protocol.
    
    JUMP_BIND_FAIL_ABORT     // Custom binding failed.
    // The stream must abort the binding process.
    // Further, because the stream is in a bad state (authenticated, but
    // unable to complete the full handshake) it must immediately disconnect.
    // The given NSError will be reported via jumpStreamDidDisconnect:withError:
};

/**
 * Binding a JID resource is a standard part of the authentication process,
 * and occurs after SASL authentication completes (which generally authenticates the JID username).
 *
 * This protocol may be used if there is a need to customize the binding process.
 * For example:
 *
 * - Custom SASL authentication scheme required both username & resource
 * - Custom SASL authentication scheme provided required resource in server response
 * - Stream Management (XEP-0198) replaces binding with resumption from previously bound session
 *
 * A custom binding procedure may be plugged into an JUMPStream instance via the delegate method:
 * - (id <JUMPCustomBinding>)jumpStreamWillBind;
 **/
@protocol JUMPCustomBinding <NSObject>

/**
 * Attempts to start the custom binding process.
 *
 * If it isn't possible to start the process (perhaps due to missing information),
 * this method should return JUMP_BIND_FAIL_FALLBACK or JUMP_BIND_FAIL_ABORT.
 *
 * (The error message is only used by jumpStream if this method returns JUMP_BIND_FAIL_ABORT.)
 *
 * If binding isn't needed (for example, because custom SASL authentication already handled it),
 * this method should return JUMP_BIND_SUCCESS.
 * In this case, jumpStream will immediately move to its post-binding operations.
 *
 * Otherwise this method should send whatever stanzas are needed to begin the binding process.
 * And then return JUMP_BIND_CONTINUE.
 *
 * This method is called by automatically JUMPStream.
 * You MUST NOT invoke this method manually.
 **/
- (JUMPBindResult)start:(NSError **)errPtr;

/**
 * After the custom binding process has started, all incoming jump stanzas are routed to this method.
 * The method should process the stanza as appropriate, and return the coresponding result.
 * If the process is not yet complete, it should return JUMP_BIND_CONTINUE,
 * meaning the jump stream will continue to forward all incoming jump stanzas to this method.
 *
 * This method is called automatically by JUMPStream.
 * You MUST NOT invoke this method manually.
 **/
- (JUMPBindResult)handleBind:(JUMPPacket *)auth withError:(NSError **)errPtr;

@optional

/**
 * Optionally implement this method to override the default behavior.
 * By default behavior, we mean the behavior normally taken by jumpStream, which is:
 *
 * - IF the server includes <session xmlns='urn:ietf:params:xml:ns:jump-session'/> in its stream:features
 * - AND jumpStream.skipStartSession property is NOT set
 * - THEN jumpStream will send the session start request, and await the response before transitioning to authenticated
 *
 * Thus if you implement this method and return YES, then jumpStream will skip starting a session,
 * regardless of the stream:features and the current jumpStream.skipStartSession property value.
 *
 * If you implement this method and return NO, then jumpStream will follow the default behavior detailed above.
 * This means that, even if this method returns NO, the jumpStream may still skip starting a session if
 * the server doesn't require it via its stream:features,
 * or if the user has explicitly forbidden it via the jumpStream.skipStartSession property.
 *
 * The default value is NO.
 **/
- (BOOL)shouldSkipStartSessionAfterSuccessfulBinding;

@end