//
//  JUMPIDTracker.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JUMPTrackingInfo;

@class JUMPPacket;

@class JUMPStream;

extern const NSTimeInterval JUMPIDTrackerTimeoutNone;

/**
 * A common operation in JUMP is to send some kind of request with a unique id,
 * and wait for the response to come back.
 * The most common example is sending an IQ of type='get' with a unique id, and then awaiting the response.
 *
 * In order to properly handle the response, the id must be stored.
 * If there are multiple queries going out and/or different kinds of queries,
 * then information about the appropriate handling of the response must also be stored.
 * This may be accomplished by storing the appropriate selector, or perhaps a block handler.
 * Additionally one may need to setup timeouts and handle those properly as well.
 *
 * This class provides the scaffolding to simplify the tasks associated with this common operation.
 * Essentially, it provides the following:
 * - a dictionary where the unique id is the key, and the needed tracking info is the object
 * - an optional timer to fire upon a timeout
 *
 * The class is designed to be flexible.
 * You can provide a target/selector or a block handler to be invoked.
 * Additionally, you can use the basic tracking info, or you can extend it to suit your needs.
 */
@interface JUMPIDTracker : NSObject {

    JUMPStream *jumpStream;
    dispatch_queue_t queue;
    
    NSMutableDictionary *dict;
    
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (id)initWithStream:(JUMPStream *)stream dispatchQueue:(dispatch_queue_t)queue;

- (void)addID:(NSString *)packetID target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout;

- (void)addPacket:(JUMPPacket *)packet target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout;

- (void)addID:(NSString *)packetID block:(void (^)(id obj, id <JUMPTrackingInfo> info))block timeout:(NSTimeInterval)timeout;

- (void)addPacket:(JUMPPacket *)packet block:(void (^)(id obj, id <JUMPTrackingInfo> info))block timeout:(NSTimeInterval)timeout;

- (void)addID:(NSString *)packetID trackingInfo:(id <JUMPTrackingInfo>)trackingInfo;

- (void)addPacket:(JUMPPacket *)packet trackingInfo:(id <JUMPTrackingInfo>)trackingInfo;

- (BOOL)invokeForID:(NSString *)packetID withObject:(id)obj;

- (BOOL)invokeForPacket:(JUMPPacket *)packet withObject:(id)obj;

- (NSUInteger)numberOfIDs;

- (void)removeID:(NSString *)packetID;

- (void)removeAllIDs;

@end

#pragma mark -

@protocol JUMPTrackingInfo <NSObject>

@property (nonatomic, readonly) NSTimeInterval timeout;

@property (nonatomic, readwrite, copy) NSString *packetID;

@property (nonatomic, readwrite, copy) JUMPPacket *packet;

- (void)createTimerWithDispatchQueue:(dispatch_queue_t)queue;

- (void)cancelTimer;

- (void)invokeWithObject:(id)obj;

@end

#pragma mark -

@interface JUMPBasicTrackingInfo : NSObject <JUMPTrackingInfo> {
    id target;
    SEL selector;
    
    void (^block)(id obj, id <JUMPTrackingInfo> info);
    
    NSTimeInterval timeout;
    
    NSString *packetID;
    JUMPPacket *packet;
    dispatch_source_t timer;
}

- (id)initWithTarget:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout;
- (id)initWithBlock:(void (^)(id obj, id <JUMPTrackingInfo> info))block timeout:(NSTimeInterval)timeout;

@property (nonatomic, readonly) NSTimeInterval timeout;

@property (nonatomic, readwrite, copy) NSString *packetID;

@property (nonatomic, readwrite, copy) JUMPPacket *packet;

- (void)createTimerWithDispatchQueue:(dispatch_queue_t)queue;

- (void)cancelTimer;

- (void)invokeWithObject:(id)obj;

@end
