//
//  JUMPOPTracker.h
//  YonyouIMSdk
//
//  Created by litfb on 15/6/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JUMPOPTrackingInfo;

@class JUMPPacket;

@class JUMPStream;

@interface JUMPOPTracker : NSObject {
    
    JUMPStream *jumpStream;
    dispatch_queue_t queue;
    
    NSMutableDictionary *dict;
}

- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (id)initWithStream:(JUMPStream *)stream dispatchQueue:(dispatch_queue_t)queue;

- (void)addOPData:(NSData *)opData target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout;

- (void)addPacket:(JUMPPacket *)packet target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout;

- (void)addOPData:(NSData *)opData block:(void (^)(id obj, id <JUMPOPTrackingInfo> info))block timeout:(NSTimeInterval)timeout;

- (void)addPacket:(JUMPPacket *)packet block:(void (^)(id obj, id <JUMPOPTrackingInfo> info))block timeout:(NSTimeInterval)timeout;

- (void)addOPData:(NSData *)opData trackingInfo:(id <JUMPOPTrackingInfo>)trackingInfo;

- (void)addPacket:(JUMPPacket *)packet trackingInfo:(id <JUMPOPTrackingInfo>)trackingInfo;

- (BOOL)invokeForOPData:(NSData *)opData withObject:(id)obj;

- (BOOL)invokeForPacket:(JUMPPacket *)packet withObject:(id)obj;

- (NSUInteger)numberOfOPDatas;

- (void)removeOPData:(NSData *)opData;

- (void)removeAllOPDatas;

@end

#pragma mark -

@protocol JUMPOPTrackingInfo <NSObject>

@property (nonatomic, readonly) NSTimeInterval timeout;

@property (nonatomic, readwrite, copy) NSData *opData;

@property (nonatomic, readwrite, copy) JUMPPacket *packet;

- (void)createTimerWithDispatchQueue:(dispatch_queue_t)queue;

- (void)cancelTimer;

- (void)invokeWithObject:(id)obj;

@end

#pragma mark -

@interface JUMPBasicOPTrackingInfo : NSObject <JUMPOPTrackingInfo> {
    id target;
    SEL selector;
    
    void (^block)(id obj, id <JUMPOPTrackingInfo> info);
    
    NSTimeInterval timeout;
    
    NSData *opData;
    JUMPPacket *packet;
    dispatch_source_t timer;
}

- (id)initWithTarget:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout;
- (id)initWithBlock:(void (^)(id obj, id <JUMPOPTrackingInfo> info))block timeout:(NSTimeInterval)timeout;

@property (nonatomic, readonly) NSTimeInterval timeout;

@property (nonatomic, readwrite, copy) NSData *opData;

@property (nonatomic, readwrite, copy) JUMPPacket *packet;

- (void)createTimerWithDispatchQueue:(dispatch_queue_t)queue;

- (void)cancelTimer;

- (void)invokeWithObject:(id)obj;

@end
