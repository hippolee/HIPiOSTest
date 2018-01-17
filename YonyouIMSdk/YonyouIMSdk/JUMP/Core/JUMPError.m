//
//  JUMPError.m
//  YonyouIMSdk
//
//  Created by litfb on 15/6/1.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <objc/runtime.h>
#import "JUMPError.h"

@implementation JUMPError

+ (JUMPError *)errorFromPacket:(JUMPPacket *)packet {
    object_setClass(packet, [JUMPError class]);
    
    return (JUMPError *)packet;
}

- (id)copyWithZone:(NSZone *)zone {
    JUMPPacket *packet = [super copyWithZone:zone];
    return [JUMPError errorFromPacket:packet];
}

- (NSInteger)code {
    return [[self objectForKey:@"code"] integerValue];
}

- (NSString *)message {
    return [self objectForKey:@"message"];
}

@end
