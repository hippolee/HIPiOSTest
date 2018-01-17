//
//  JUMPParser.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPPacket.h"

@interface JUMPParser : NSObject

- (id)initWithDelegate:(id)delegate delegateQueue:(dispatch_queue_t)dq;
- (id)initWithDelegate:(id)delegate delegateQueue:(dispatch_queue_t)dq parserQueue:(dispatch_queue_t)pq;

- (void)setDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

/**
 * Asynchronously parses the given data.
 * The delegate methods will be dispatch_async'd as events occur.
 **/
- (void)parseData:(NSData *)data header:(JUMPHeader *)header;

@end

#pragma mark -

@protocol JUMPParserDelegate
@optional

- (void)jumpParser:(JUMPParser *)sender didReadPacket:(JUMPPacket *)element;

- (void)jumpParser:(JUMPParser *)sender didFail:(NSError *)error;

- (void)jumpParserDidParseData:(JUMPParser *)sender;

@end
