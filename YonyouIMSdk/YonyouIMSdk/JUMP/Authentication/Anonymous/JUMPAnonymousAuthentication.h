//
//  JUMPAnonymousAuthentication.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPSASLAuthentication.h"
#import "JUMPStream.h"

@interface JUMPAnonymousAuthentication : NSObject<JUMPSASLAuthentication>

- (id)initWithStream:(JUMPStream *)stream;

// This class implements the JUMPSASLAuthentication protocol.
//
// See JUMPSASLAuthentication.h for more information.

@end

#pragma mark -

@interface JUMPStream (JUMPAnonymousAuthentication)

/**
 * Returns whether or not the server support anonymous authentication.
 *
 * This information is available after the stream is connected.
 * In other words, after the delegate has received jumpStreamDidConnect: notification.
 **/
- (BOOL)supportsAnonymousAuthentication;

/**
 * This method attempts to start the anonymous authentication process.
 *
 * This method is asynchronous.
 *
 * If there is something immediately wrong,
 * such as the stream is not connected or doesn't support anonymous authentication,
 * the method will return NO and set the error.
 * Otherwise the delegate callbacks are used to communicate auth success or failure.
 *
 * @see jumpStreamDidAuthenticate:
 * @see jumpStream:didNotAuthenticate:
 **/
- (BOOL)authenticateAnonymously:(NSError **)errPtr;

@end