//
//  JUMPModule.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "YMGCDMulticastDelegate.h"

@class JUMPStream;

/**
 * JUMPModule is the base class that all extensions/modules inherit.
 * They automatically get:
 *
 * - A dispatch queue.
 * - A multicast delegate that automatically invokes added delegates.
 *
 * The module also automatically registers/unregisters itself with the
 * jump stream during the activate/deactive methods.
 **/
@interface JUMPModule : NSObject {
    
    JUMPStream *jumpStream;
    
    dispatch_queue_t moduleQueue;
    void *moduleQueueTag;
    
    id multicastDelegate;
    
}

@property (readonly) dispatch_queue_t moduleQueue;
@property (readonly) void *moduleQueueTag;

@property (strong, readonly) JUMPStream *jumpStream;

- (id)init;
- (id)initWithDispatchQueue:(dispatch_queue_t)queue;

- (BOOL)activate:(JUMPStream *)aJumpStream;
- (void)deactivate;

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;
- (void)removeDelegate:(id)delegate;

- (NSString *)moduleName;

@end