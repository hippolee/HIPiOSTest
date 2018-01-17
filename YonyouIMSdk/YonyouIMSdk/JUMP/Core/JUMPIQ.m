//
//  JUMPIQ.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <objc/runtime.h>
#import "JUMPIQ.h"

@implementation JUMPIQ

+ (JUMPIQ *)iqFromPacket:(JUMPPacket *)packet {
    object_setClass(packet, [JUMPIQ class]);
    
    return (JUMPIQ *)packet;
}

+ (JUMPIQ *)iqWithOpData:(NSData *)opData {
    return [[JUMPIQ alloc] initWithOpData:opData type:nil to:nil packetID:nil];
}

+ (JUMPIQ *)iqWithOpData:(NSData *)opData packetID:(NSString *)pid {
    return [[JUMPIQ alloc] initWithOpData:opData type:nil to:nil packetID:pid];
}

+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type {
    return [[JUMPIQ alloc] initWithOpData:opData type:type to:nil packetID:nil];
}

+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid {
    return [[JUMPIQ alloc] initWithOpData:opData type:type to:jid packetID:nil];
}

+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid packetID:(NSString *)pid {
    return [[JUMPIQ alloc] initWithOpData:opData type:type to:jid packetID:pid];
}

+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type packetID:(NSString *)pid {
    return [[JUMPIQ alloc] initWithOpData:opData type:type to:nil packetID:pid];
}

- (id)initWithOpData:(NSData *)opData type:(NSString *)type {
    return [self initWithOpData:opData type:type to:nil packetID:nil];
}

- (id)initWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid {
    return [self initWithOpData:opData type:type to:jid packetID:nil];
}

- (id)initWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid packetID:(NSString *)pid {
    if ((self = [super initWithOpData:opData])) {
        if (type) {
            [self setObject:type forKey:@"type"];
        }
        if (jid) {
            [self setObject:[jid full] forKey:@"to"];
        }
        if (pid) {
            [self setObject:pid forKey:@"id"];
        }
    }
    return self;
}

- (id)initWithOpData:(NSData *)opData type:(NSString *)type packetID:(NSString *)pid {
    return [self initWithOpData:opData type:type to:nil packetID:pid];
}

- (id)copyWithZone:(NSZone *)zone {
    JUMPPacket *packet = [super copyWithZone:zone];
    return [JUMPIQ iqFromPacket:packet];
}

- (NSString *)type {
    return [[self objectForKey:@"type"] lowercaseString];
}

- (BOOL)isGetIQ {
    return [[self type] isEqualToString:@"get"];
}

- (BOOL)isSetIQ {
    return [[self type] isEqualToString:@"set"];
}

- (BOOL)isResultIQ {
    return [[self type] isEqualToString:@"result"];
}

- (BOOL)isErrorIQ {
    return [[self type] isEqualToString:@"error"];
}

- (BOOL)requiresResponse {
    // An entity that receives an IQ request of type "get" or "set" MUST reply with an IQ response
    // of type "result" or "error" (the response MUST preserve the 'id' attribute of the request).
    
    return [self isGetIQ] || [self isSetIQ];
}

@end