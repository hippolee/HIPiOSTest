//
//  JUMPIntenal.h
//  YonyouIMSdk
//  This file is for JUMPStream and various internal components.
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPStream.h"
#import "JUMPModule.h"

// Define the various states we'll use to track our progress
typedef NS_ENUM(NSInteger, JUMPStreamState) {
    STATE_JUMP_DISCONNECTED,
    STATE_JUMP_RESOLVING_SRV,
    STATE_JUMP_CONNECTING,
    STATE_JUMP_CONNECTED_NOAUTH,
    STATE_JUMP_TLS,
    STATE_JUMP_AUTH,
    STATE_JUMP_CONNECTED
};

/**
 * It is recommended that storage classes cache a stream's myJID.
 * This prevents them from constantly querying the property from the jumpStream instance,
 * as doing so goes through jumpStream's dispatch queue.
 * Caching the stream's myJID frees the dispatch queue to handle jump processing tasks.
 *
 * The object of the notification will be the JUMPStream instance.
 *
 * Note: We're not using the typical MulticastDelegate paradigm for this task as
 * storage classes are not typically added as a delegate of the jumpStream.
 **/
extern NSString *const JUMPStreamDidChangeMyJIDNotification;

@interface JUMPStream (/* Internal */)

/**
 * JUMPStream maintains thread safety by dispatching  through the internal serial jumpQueue.
 * Subclasses of JUMPStream MUST follow the same technique:
 *
 * dispatch_block_t block = ^{
 *     // Code goes here
 * };
 *
 * if (dispatch_get_specific(jumpQueueTag))
 *   block();
 * else
 *   dispatch_sync(jumpQueue, block);
 *
 * Category methods may or may not need to dispatch through the jumpQueue.
 * It depends entirely on what properties of jumpStream the category method needs to access.
 * For example, if a category only accesses a single property, such as the rootPacket,
 * then it can simply fetch the atomic property, inspect it, and complete its job.
 * However, if the category needs to fetch multiple properties, then it likely needs to fetch all such
 * properties in an atomic fashion. In this case, the category should likely go through the jumpQueue,
 * to ensure that it gets an atomic state of the jumpStream in order to complete its job.
 **/
@property (nonatomic, readonly) dispatch_queue_t jumpQueue;
@property (nonatomic, readonly) void *jumpQueueTag;

/**
 * Returns the current state of the jumpStream.
 **/
@property (atomic, readonly) JUMPStreamState state;

/**
 * This method is for use by jump authentication mechanism classes.
 * They should send packets using this method instead of the public sendPacket methods,
 * as those methods don't send the packets while authentication is in progress.
 *
 * @see JUMPSASLAuthentication
 **/
- (void)sendAuthPacket:(JUMPPacket *)packet;

/**
 * This method allows you to inject an packet into the stream as if it was received on the socket.
 * This is an advanced technique, but makes for some interesting possibilities.
 **/
- (void)injectPacket:(JUMPPacket *)packet;

@end

@interface JUMPModule (/* Internal */)

/**
 * Used internally by methods like JUMPStream's unregisterModule:.
 * Normally removing a delegate is a synchronous operation, but due to multiple dispatch_sync operations,
 * it must occasionally be done asynchronously to avoid deadlock.
 **/
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously;

@end
