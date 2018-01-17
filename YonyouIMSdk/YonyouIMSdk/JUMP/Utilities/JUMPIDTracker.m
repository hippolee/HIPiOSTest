//
//  JUMPIDTracker.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPIDTracker.h"
#import "JUMPPacket.h"
#import "JUMPLogging.h"
#import "JUMPIQ.h"
#import "JUMPStream.h"

//#define AssertProperQueue() NSAssert(YES)(dispatch_get_specific(queueTag), @"Invoked on incorrect queue")

const NSTimeInterval JUMPIDTrackerTimeoutNone = -1;

#pragma mark -

@interface JUMPIDTracker () {
    void *queueTag;
}
@end

@implementation JUMPIDTracker

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
    @synchronized(self) {
        for (id <JUMPTrackingInfo> info in [dict objectEnumerator])
        {
            [info cancelTimer];
        }
        [dict removeAllObjects];
    }
}

- (void)addID:(NSString *)packetID target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout {
    //AssertProperQueue();
    
    JUMPBasicTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicTrackingInfo alloc] initWithTarget:target selector:selector timeout:timeout];
    
    [self addID:packetID trackingInfo:trackingInfo];
}

- (void)addPacket:(JUMPPacket *)packet target:(id)target selector:(SEL)selector timeout:(NSTimeInterval)timeout {
    //AssertProperQueue();
    
    JUMPBasicTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicTrackingInfo alloc] initWithTarget:target selector:selector timeout:timeout];
    
    [self addPacket:packet trackingInfo:trackingInfo];
}

- (void)addID:(NSString *)packetID block:(void (^)(id obj, id <JUMPTrackingInfo> info))block timeout:(NSTimeInterval)timeout {
    //AssertProperQueue();
    
    JUMPBasicTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicTrackingInfo alloc] initWithBlock:block timeout:timeout];
    
    [self addID:packetID trackingInfo:trackingInfo];
}

- (void)addPacket:(JUMPPacket *)packet
            block:(void (^)(id obj, id <JUMPTrackingInfo> info))block
          timeout:(NSTimeInterval)timeout {
    //AssertProperQueue();
    
    JUMPBasicTrackingInfo *trackingInfo;
    trackingInfo = [[JUMPBasicTrackingInfo alloc] initWithBlock:block timeout:timeout];
    
    [self addPacket:packet trackingInfo:trackingInfo];
}

- (void)addID:(NSString *)packetID trackingInfo:(id <JUMPTrackingInfo>)trackingInfo {
    //AssertProperQueue();
    @synchronized(self) {
        [dict setObject:trackingInfo forKey:packetID];
    }
    [trackingInfo setPacketID:packetID];
    [trackingInfo createTimerWithDispatchQueue:queue];
}

- (void)addPacket:(JUMPPacket *)packet trackingInfo:(id <JUMPTrackingInfo>)trackingInfo {
    //AssertProperQueue();
    
    if([[packet packetID] length] == 0) {
        return;
    }
    @synchronized(self) {
        [dict setObject:trackingInfo forKey:[packet packetID]];
    }
    [trackingInfo setPacketID:[packet packetID]];
    [trackingInfo setPacket:packet];
    [trackingInfo createTimerWithDispatchQueue:queue];
}

- (BOOL)invokeForID:(NSString *)packetID withObject:(id)obj {
    //AssertProperQueue();
    
    if([packetID length] == 0) return NO;
    
    id <JUMPTrackingInfo> info = [dict objectForKey:packetID];
    
    if (info) {
        [info invokeWithObject:obj];
        [info cancelTimer];
        @synchronized(self) {
            [dict removeObjectForKey:packetID];
        }
        
        return YES;
    }
    
    return NO;
}

- (BOOL)invokeForPacket:(JUMPPacket *)packet withObject:(id)obj {
    //AssertProperQueue();
    
    NSString *packetID = [packet packetID];
    
    if ([packetID length] == 0) return NO;
    
    id <JUMPTrackingInfo> info = [dict objectForKey:packetID];
    if (info) {
        [info invokeWithObject:obj];
        [info cancelTimer];
        @synchronized(self) {
            [dict removeObjectForKey:[packet packetID]];
        }
        return YES;
    }
    return NO;
}

- (NSUInteger)numberOfIDs {
    //AssertProperQueue();
    
    return [[dict allKeys] count];
}

- (void)removeID:(NSString *)packetID {
    //AssertProperQueue();
    
    id <JUMPTrackingInfo> info = [dict objectForKey:packetID];
    if (info) {
        [info cancelTimer];
        @synchronized(self) {
            [dict removeObjectForKey:packetID];
        }
    }
}

- (void)removeAllIDs {
    //AssertProperQueue();
    @synchronized(self) {
        for (id <JUMPTrackingInfo> info in [dict objectEnumerator]) {
            [info cancelTimer];
        }
        [dict removeAllObjects];
    }
}

@end

#pragma mark -

@implementation JUMPBasicTrackingInfo

@synthesize timeout;
@synthesize packetID;
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

- (id)initWithBlock:(void (^)(id obj, id <JUMPTrackingInfo> info))aBlock timeout:(NSTimeInterval)aTimeout {
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