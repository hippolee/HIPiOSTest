//
//  JUMPIQ.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPPacket.h"

@interface JUMPIQ : JUMPPacket

/**
 * Converts an JUMPPacket to an JUMPIQ element in place (no memory allocations or copying)
 **/
+ (JUMPIQ *)iqFromPacket:(JUMPPacket *)packet;

+ (JUMPIQ *)iqWithOpData:(NSData *)opData;
+ (JUMPIQ *)iqWithOpData:(NSData *)opData packetID:(NSString *)pid;
+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type;
+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid;
+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid packetID:(NSString *)pid;
+ (JUMPIQ *)iqWithOpData:(NSData *)opData type:(NSString *)type packetID:(NSString *)pid;

- (id)initWithOpData:(NSData *)opData type:(NSString *)type;
- (id)initWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid;
- (id)initWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)jid packetID:(NSString *)pid;
- (id)initWithOpData:(NSData *)opData type:(NSString *)type packetID:(NSString *)pid;

/**
 * Returns the type attribute of the IQ.
 * According to the JUMP protocol, the type should be one of 'get', 'set', 'result' or 'error'.
 *
 * This method converts the attribute to lowercase so
 * case-sensitive string comparisons are safe (regardless of server treatment).
 **/
- (NSString *)type;

/**
 * Convenience methods for determining the IQ type.
 **/
- (BOOL)isGetIQ;
- (BOOL)isSetIQ;
- (BOOL)isResultIQ;
- (BOOL)isErrorIQ;

/**
 * Convenience method for determining if the IQ is of type 'get' or 'set'.
 **/
- (BOOL)requiresResponse;

@end