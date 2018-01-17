//
//  JUMPPresence.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <objc/runtime.h>
#import "JUMPPresence.h"

@implementation JUMPPresence

+ (JUMPPresence *)presenceFromPacket:(JUMPPacket *)packet {
    object_setClass(packet, [JUMPPresence class]);
    
    return (JUMPPresence *)packet;
}

+ (JUMPPresence *)presenceWithOpData:(NSData *)opData {
    return [[JUMPPresence alloc] initWithOpData:opData];
}

+ (JUMPPresence *)presenceWithOpData:(NSData *)opData type:(NSString *)type {
    return [[JUMPPresence alloc] initWithOpData:opData type:type to:nil];
}

+ (JUMPPresence *)presenceWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)to {
    return [[JUMPPresence alloc] initWithOpData:opData type:type to:to];
}

- (id)initWithOpData:(NSData *)opData type:(NSString *)type {
    return [self initWithOpData:opData type:type to:nil];
}

- (id)initWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)to {
    if ((self = [super initWithOpData:opData])) {
        if (type) {
            [self setObject:type forKey:@"type"];
        }
        if (to) {
            [self setObject:[to full] forKey:@"to"];
        }
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    JUMPPacket *packet = [super copyWithZone:zone];
    return [JUMPPresence presenceFromPacket:packet];
}

- (void)setType:(NSString *)type {
    if (type) {
        [self setObject:type forKey:@"type"];
    }
}

- (void)setShow:(NSString *)show {
    if (show) {
        [self setObject:show forKey:@"show"];
    }
}

- (void)setStatus:(NSString *)status {
    if (status) {
        [self setObject:status forKey:@"status"];
    }
}

- (void)setPriority:(NSInteger)priority {
    [self setObject:[NSString stringWithFormat:@"%ld", (long)priority] forKey:@"priority"];
}

- (void)setJid:(JUMPJID *)jid {
    [self setObject:[jid full] forKey:@"jid"];
}

- (void)setRole:(NSString *)role {
    if (role) {
        [self setObject:role forKey:@"role"];
    }
}

- (void)setAffiliation:(NSString *)affiliation {
    if (affiliation) {
        [self setObject:affiliation forKey:@"affiliation"];
    }
}

- (NSString *)type {
    NSString *type = [self objectForKey:@"type"];
    if (type) {
        return [type lowercaseString];
    } else {
        return @"available";
    }
}

- (NSString *)show {
    return [self objectForKey:@"show"];
}

- (NSString *)status {
    return [self objectForKey:@"status"];
}

- (NSInteger)priority {
    return [[[self objectForKey:@"priority"] stringValue] integerValue];
}

- (JUMPJID *)jid {
    return [JUMPJID jidWithString:[self objectForKey:@"jid"]];
}

- (NSString *)role {
    return [self objectForKey:@"role"];
}

- (NSString *)affiliation {
    return [self objectForKey:@"affiliation"];
}

- (int)intShow {
    NSString *show = [self show];
    
    if([show isEqualToString:@"dnd"]) {
        return 0;
    }
    if([show isEqualToString:@"xa"]) {
        return 1;
    }
    if([show isEqualToString:@"away"]) {
        return 2;
    }
    if([show isEqualToString:@"chat"]) {
        return 4;
    }
    return 3;
}

@end