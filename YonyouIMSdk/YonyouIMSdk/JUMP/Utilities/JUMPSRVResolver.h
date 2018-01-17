//
//  JUMPSRVResolver.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/29.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//  Based on SRVResolver by Apple, Inc.
//

#import <Foundation/Foundation.h>
#import <dns_sd.h>

extern NSString *const JUMPSRVResolverErrorDomain;

@interface JUMPSRVResolver : NSObject {
    __unsafe_unretained id delegate;
    dispatch_queue_t delegateQueue;
    
    dispatch_queue_t resolverQueue;
    void *resolverQueueTag;
    
    __strong NSString *srvName;
    NSTimeInterval timeout;
    
    BOOL resolveInProgress;
    
    NSMutableArray *results;
    DNSServiceRef sdRef;
    
    int sdFd;
    dispatch_source_t sdReadSource;
    dispatch_source_t timeoutTimer;
}

@property (strong, readonly) NSString *srvName;
@property (readonly) NSTimeInterval timeout;

/**
 * The delegate & delegateQueue are mandatory.
 * The resolverQueue is optional. If NULL, it will automatically create it's own internal queue.
 **/
- (id)initWithdDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq resolverQueue:(dispatch_queue_t)rq;

- (void)startWithSRVName:(NSString *)aSRVName timeout:(NSTimeInterval)aTimeout;
- (void)stop;

+ (NSString *)srvNameFromJUMPDomain:(NSString *)jumpDomain;

@end

#pragma mark -

@protocol JUMPSRVResolverDelegate

- (void)jumpSRVResolver:(JUMPSRVResolver *)sender didResolveRecords:(NSArray *)records;
- (void)jumpSRVResolver:(JUMPSRVResolver *)sender didNotResolveDueToError:(NSError *)error;

@end

#pragma mark -

@interface JUMPSRVRecord : NSObject {
    UInt16 priority;
    UInt16 weight;
    UInt16 port;
    NSString *target;
    
    NSUInteger sum;
    NSUInteger srvResultsIndex;
}

@property (nonatomic, readonly) UInt16 priority;
@property (nonatomic, readonly) UInt16 weight;
@property (nonatomic, readonly) UInt16 port;
@property (nonatomic, readonly) NSString *target;

+ (JUMPSRVRecord *)recordWithPriority:(UInt16)priority weight:(UInt16)weight port:(UInt16)port target:(NSString *)target;

- (id)initWithPriority:(UInt16)priority weight:(UInt16)weight port:(UInt16)port target:(NSString *)target;

@end