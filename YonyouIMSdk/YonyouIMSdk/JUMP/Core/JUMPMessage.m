//
//  JUMPMessage.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <objc/runtime.h>
#import "JUMPMessage.h"

@implementation JUMPMessage

+ (JUMPMessage *)messageFromPacket:(JUMPPacket *)packet {
    object_setClass(packet, [JUMPMessage class]);
    
    return (JUMPMessage *)packet;
}

+ (JUMPMessage *)messageWithOpData:(NSData *)opData {
    return [[JUMPMessage alloc] initWithOpData:opData];
}

+ (JUMPMessage *)messageWithOpData:(NSData *)opData packetID:(NSString *)pid {
    return [[JUMPMessage alloc] initWithOpData:opData packetID:pid];
}

+ (JUMPMessage *)messageWithOpData:(NSData *)opData to:(JUMPJID *)to {
    return [[JUMPMessage alloc] initWithOpData:opData to:to];
}

+ (JUMPMessage *)messageWithOpData:(NSData *)opData to:(JUMPJID *)to packetID:(NSString *)pid {
    return [[JUMPMessage alloc] initWithOpData:opData to:to packetID:pid];
}

- (id)initWithOpData:(NSData *)opData to:(JUMPJID *)to {
    return [self initWithOpData:opData to:to packetID:nil];
}

- (id)initWithOpData:(NSData *)opData to:(JUMPJID *)to packetID:(NSString *)pid {
    if ((self = [super initWithOpData:opData])) {
        if (to) {
            [self setObject:[to full] forKey:@"to"];
        }
        if (pid) {
            [self setObject:pid forKey:@"id"];
        }
    }
    return self;
}

- (id)initWithOpData:(NSData *)opData packetID:(NSString *)pid {
    return [self initWithOpData:opData to:nil packetID:pid];
}

- (id)copyWithZone:(NSZone *)zone {
    JUMPPacket *packet = [super copyWithZone:zone];
    return [JUMPMessage messageFromPacket:packet];
}

- (BOOL)isErrorMessage {
    return [[self objectForKey:@"type"] isEqualToString:@"error"];
}

- (BOOL)isMessageWithContent {
    if ([self objectForKey:@"content"]) {
        return YES;
    }
    return NO;
}

- (JUMPMessage *)generateReceiptResponse {
    return [JUMPMessage messageWithOpData:JUMP_OPDATA(JUMPMessageReceiptsPacketOpCode) to:[self from] packetID:self.packetID];
}

@end