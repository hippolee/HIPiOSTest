//
//  JUMPModule.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPModule.h"
#import "JUMPStream.h"
#import "JUMPLogging.h"

@implementation JUMPModule

/**
 * Standard init method.
 **/
- (id)init {
    return [self initWithDispatchQueue:NULL];
}

/**
 * Designated initializer.
 **/
- (id)initWithDispatchQueue:(dispatch_queue_t)queue {
    if ((self = [super init])) {
        if (queue) {
            moduleQueue = queue;
        } else {
            const char *moduleQueueName = [[self moduleName] UTF8String];
            moduleQueue = dispatch_queue_create(moduleQueueName, NULL);
        }
        
        moduleQueueTag = &moduleQueueTag;
        dispatch_queue_set_specific(moduleQueue, moduleQueueTag, moduleQueueTag, NULL);
        
        multicastDelegate = [[YMGCDMulticastDelegate alloc] init];
    }
    return self;
}

/**
 * The activate method is the point at which the module gets plugged into the jump stream.
 *
 * It is recommended that subclasses override didActivate, instead of this method,
 * to perform any custom actions upon activation.
 **/
- (BOOL)activate:(JUMPStream *)aJumpStream {
    __block BOOL result = YES;
    
    dispatch_block_t block = ^{
        
        if (jumpStream != nil) {
            result = NO;
        } else {
            jumpStream = aJumpStream;
            
            [jumpStream addDelegate:self delegateQueue:moduleQueue];
            [jumpStream registerModule:self];
            
            [self didActivate];
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
    return result;
}

/**
 * It is recommended that subclasses override this method (instead of activate:)
 * to perform tasks after the module has been activated.
 *
 * This method is only invoked if the module is successfully activated.
 * This method is always invoked on the moduleQueue.
 **/
- (void)didActivate {
    // Override me to do custom work after the module is activated
}

/**
 * The deactivate method unplugs a module from the jump stream.
 * When this method returns, no further delegate methods on this module will be dispatched.
 * However, there may be delegate methods that have already been dispatched.
 * If this is the case, the module will be properly retained until the delegate methods have completed.
 * If your custom module requires that delegate methods are not run after the deactivate method has been run,
 * then simply check the jumpStream variable in your delegate methods.
 *
 * It is recommended that subclasses override didDeactivate, instead of this method,
 * to perform any custom actions upon deactivation.
 **/
- (void)deactivate {
    dispatch_block_t block = ^{
        
        if (jumpStream) {
            [self willDeactivate];
            
            [jumpStream removeDelegate:self delegateQueue:moduleQueue];
            [jumpStream unregisterModule:self];
            
            jumpStream = nil;
        }
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_sync(moduleQueue, block);
    }
}

/**
 * It is recommended that subclasses override this method (instead of deactivate:)
 * to perform tasks after the module has been deactivated.
 *
 * This method is only invoked if the module is transitioning from activated to deactivated.
 * This method is always invoked on the moduleQueue.
 **/
- (void)willDeactivate {
    // Override me to do custom work after the module is deactivated
}

- (dispatch_queue_t)moduleQueue {
    return moduleQueue;
}

- (void *)moduleQueueTag {
    return moduleQueueTag;
}

- (JUMPStream *)jumpStream {
    if (dispatch_get_specific(moduleQueueTag)) {
        return jumpStream;
    } else {
        __block JUMPStream *result;
        
        dispatch_sync(moduleQueue, ^{
            result = jumpStream;
        });
        
        return result;
    }
}

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    // Asynchronous operation (if outside jumpQueue)
    
    dispatch_block_t block = ^{
        [multicastDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else {
        dispatch_async(moduleQueue, block);
    }
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue synchronously:(BOOL)synchronously {
    dispatch_block_t block = ^{
        [multicastDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(moduleQueueTag)) {
        block();
    } else if (synchronously) {
        dispatch_sync(moduleQueue, block);
    } else {
        dispatch_async(moduleQueue, block);
    }
}
- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    // Synchronous operation (common-case default)
    
    [self removeDelegate:delegate delegateQueue:delegateQueue synchronously:YES];
}

- (void)removeDelegate:(id)delegate {
    // Synchronous operation (common-case default)
    
    [self removeDelegate:delegate delegateQueue:NULL synchronously:YES];
}

- (NSString *)moduleName {
    // Override me (if needed) to provide a customized module name.
    // This name is used as the name of the dispatch_queue which could aid in debugging.
    
    return NSStringFromClass([self class]);
}

@end