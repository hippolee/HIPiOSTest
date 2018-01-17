//
//  JUMPOPTracker.m
//  YonyouIMSdk
//
//  Created by litfb on 15/6/2.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPOPTracker.h"
#import "JUMPPacket.h"
#import "JUMPLogging.h"
#import "JUMPIQ.h"
#import "JUMPStream.h"

#pragma mark -

@interface JUMPOPTracker () {
    void *queueTag;
}
@end

@implementation JUMPOPTracker

- (id)init {
    // You must use initWithDispatchQueue or initWithStream:dispatchQueue:
    return nil;
}

- (id)initWithDispatchQueue:(dispatch_queue_t)aQueue {
    return [self initWithStream:nil dispatchQueue:aQueue];
}

- (id)initWithStream:(JUMPStream *)stream dispatchQueue:(dispatch_queue_t)aQueue {
    NSParameterAssert(aQueue != NULL);
    
    if ((self = [super init])) {
        jumpStream = stream;
        
        queue = aQueue;
        
        queueTag = &queueTag;
        dispatch_queue_set_specific(queue, queueTag, queueTag, NULL);
        
        dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    // We don't call [self removeAllIDs] because dealloc might not be invoked on queue
    
    for (id <JUMPOPTrackingInfo> info in [dict objectEnumerator]) {
        [info cancelTimer];
    }
    [dict removeAllObjects];
}

- (void)addOPData:(NSData *)opData target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout {
    JUMPBasicOPTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicOPTrackingInfo alloc] initWithTarget:target selector:selector timeout:timeout];
    [self addOPData:opData trackingInfo:trackingInfo];
}

- (void)addPacket:(JUMPPacket *)packet target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout {
    JUMPBasicOPTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicOPTrackingInfo alloc] initWithTarget:target selector:selector timeout:timeout];
    
    [self addPacket:packet trackingInfo:trackingInfo];
}

- (void)addOPData:(NSData *)opData block:(void (^)(id, id<JUMPOPTrackingInfo>))block timeout:(NSTimeInterval)timeout {
    JUMPBasicOPTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicOPTrackingInfo alloc] initWithBlock:block timeout:timeout];
    [self addOPData:opData trackingInfo:trackingInfo];
}

- (void)addPacket:(JUMPPacket *)packet block:(void (^)(id, id<JUMPOPTrackingInfo>))block timeout:(NSTimeInterval)timeout {
    JUMPBasicOPTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicOPTrackingInfo alloc] initWithBlock:block timeout:timeout];
    
    [self addPacket:packet trackingInfo:trackingInfo];
}

- (void)addOPData:(NSData *)opData trackingInfo:(id<JUMPOPTrackingInfo>)trackingInfo {
    [dict setObject:trackingInfo forKey:opData];
    
    [trackingInfo setOpData:opData];
    [trackingInfo createTimerWithDispatchQueue:queue];
}

- (void)addPacket:(JUMPPacket *)packet trackingInfo:(id <JUMPOPTrackingInfo>)trackingInfo {
    [dict setObject:trackingInfo forKey:[packet opData]];
    
    [trackingInfo setOpData:[packet opData]];
    [trackingInfo setPacket:packet];
    [trackingInfo createTimerWithDispatchQueue:queue];
}

- (BOOL)invokeForOPData:(NSData *)opData withObject:(id)obj {
    id <JUMPOPTrackingInfo> info = [dict objectForKey:opData];
    if (info) {
        [info invokeWithObject:obj];
        [info cancelTimer];
        [dict removeObjectForKey:opData];
        return YES;
    }
    return NO;
}

- (BOOL)invokeForPacket:(JUMPPacket *)packet withObject:(id)obj {
    NSData *opData = [packet opData];
    
    id <JUMPOPTrackingInfo> info = [dict objectForKey:opData];
    if (info) {
        [info invokeWithObject:obj];
        [info cancelTimer];
        [dict removeObjectForKey:opData];
    }
    return NO;
}

- (NSUInteger)numberOfOPDatas {
    return [[dict allKeys] count];
}

- (void)removeOPData:(NSData *)opData {
    id <JUMPOPTrackingInfo> info = [dict objectForKey:opData];
    if (info) {
        [info cancelTimer];
        [dict removeObjectForKey:opData];
    }
}

- (void)removeAllOPDatas {
    for (id <JUMPOPTrackingInfo> info in [dict objectEnumerator]) {
        [info cancelTimer];
    }
    [dict removeAllObjects];
}

@end

#pragma mark -

@implementation JUMPBasicOPTrackingInfo

@synthesize timeout;
@synthesize opData;
@synthesize packet;

- (id)init {
    // Use initWithTarget:selector:timeout: or initWithBlock:timeout:
    return nil;
}

- (id)initWithTarget:(id)aTarget selector:(SEL)aSelector timeout:(NSTimeInterval)aTimeout {
    if (target || selector) {
        NSParameterAssert(aTarget);
        NSParameterAssert(aSelector);
    }
    
    if ((self = [super init])) {
        target = aTarget;
        selector = aSelector;
        timeout = aTimeout;
    }
    return self;
}

- (id)initWithBlock:(void (^)(id obj, id <JUMPOPTrackingInfo> info))aBlock timeout:(NSTimeInterval)aTimeout {
    NSParameterAssert(aBlock);
    
    if ((self = [super init])) {
        block = [aBlock copy];
        timeout = aTimeout;
    }
    return self;
}

- (void)dealloc {
    [self cancelTimer];
    
    target = nil;
    selector = NULL;
}

- (void)createTimerWithDispatchQueue:(dispatch_queue_t)queue {
    NSAssert(queue != NULL, @"Method invoked with NULL queue");
    NSAssert(timer == NULL, @"Method invoked multiple times");
    
    if (timeout > 0.0) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        
        dispatch_source_set_event_handler(timer, ^{ @autoreleasepool {
            
            [self invokeWithObject:nil];
            [self cancelTimer];
            
        }});
        
        dispatch_time_t tt = dispatch_time(DISPATCH_TIME_NOW, (timeout * NSEC_PER_SEC));
        
        dispatch_source_set_timer(timer, tt, DISPATCH_TIME_FOREVER, 0);
        dispatch_resume(timer);
    }
}

- (void)cancelTimer {
    if (timer) {
        dispatch_source_cancel(timer);
        timer = NULL;
    }
}

- (void)invokeWithObject:(id)obj {
    if (block) {
        block(obj, self);
    } else if(target && selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [target performSelector:selector withObject:obj withObject:self];
#pragma clang diagnostic pop
    }
}

@end