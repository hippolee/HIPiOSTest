//
//  JUMPParser.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPParser.h"
#import "JUMPLogging.h"
#import "YYIMLogger.h"

@implementation JUMPParser {
    __weak id delegate;
    dispatch_queue_t delegateQueue;
    
    dispatch_queue_t parserQueue;
    void *jumpParserQueueTag;
}

- (id)initWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq {
    return [self initWithDelegate:aDelegate delegateQueue:dq parserQueue:NULL];
}

- (id)initWithDelegate:(id)aDelegate delegateQueue:(dispatch_queue_t)dq parserQueue:(dispatch_queue_t)pq {
    if ((self = [super init])) {
        delegate = aDelegate;
        delegateQueue = dq;
        
        if (pq) {
            parserQueue = pq;
        } else {
            parserQueue = dispatch_queue_create("jump.parser", NULL);
        }
        
        jumpParserQueueTag = &jumpParserQueueTag;
        dispatch_queue_set_specific(parserQueue, jumpParserQueueTag, jumpParserQueueTag, NULL);
    }
    return self;
}

- (void)setDelegate:(id)newDelegate delegateQueue:(dispatch_queue_t)newDelegateQueue {
    dispatch_block_t block = ^{
        delegate = newDelegate;
        delegateQueue = newDelegateQueue;
    };
    
    if (dispatch_get_specific(jumpParserQueueTag)) {
        block();
    } else {
        dispatch_async(parserQueue, block);
    }
}

- (void)parseData:(NSData *)data header:(JUMPHeader *)header {
    dispatch_block_t block = ^{ @autoreleasepool {
        
        NSError *error;
        
        JUMPPacket *packet = [[JUMPPacket alloc] initWithBodyData:data header:header error:&error];
        
        if (delegateQueue && [delegate respondsToSelector:@selector(jumpParserDidParseData:)]) {
            __strong id theDelegate = delegate;
            
            dispatch_async(delegateQueue, ^{ @autoreleasepool {
                
                [theDelegate jumpParserDidParseData:self];
            }});
        }
        
        if (error) {
            if (delegateQueue && [delegate respondsToSelector:@selector(jumpParser:didFail:)]) {
                __strong id theDelegate = delegate;
                
                dispatch_async(delegateQueue, ^{ @autoreleasepool {
                    
                    [theDelegate jumpParser:self didFail:error];
                }});
            }
        } else {
            if (delegateQueue && [delegate respondsToSelector:@selector(jumpParser:didReadPacket:)]) {
                __strong id theDelegate = delegate;
                
                dispatch_async(delegateQueue, ^{ @autoreleasepool {
                    [theDelegate jumpParser:self didReadPacket:packet];
                }});
            }
        }
    }};
    
    if (dispatch_get_specific(jumpParserQueueTag)) {
        block();
    } else {
        dispatch_async(parserQueue, block);
    }
}

@end
