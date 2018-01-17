//
//  JUMPMessage.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/28.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPPacket.h"

@interface JUMPMessage : JUMPPacket

// Converts an JUMPPacket to an JUMPMessage element in place (no memory allocations or copying)
+ (JUMPMessage *)messageFromPacket:(JUMPPacket *)packet;

+ (JUMPMessage *)messageWithOpData:(NSData *)opData;
+ (JUMPMessage *)messageWithOpData:(NSData *)opData packetID:(NSString *)pid;
+ (JUMPMessage *)messageWithOpData:(NSData *)opData to:(JUMPJID *)to;
+ (JUMPMessage *)messageWithOpData:(NSData *)opData to:(JUMPJID *)to packetID:(NSString *)pid;

- (id)initWithOpData:(NSData *)opData to:(JUMPJID *)to;
- (id)initWithOpData:(NSData *)opData to:(JUMPJID *)to packetID:(NSString *)pid;
- (id)initWithOpData:(NSData *)opData packetID:(NSString *)pid;

- (BOOL)isMessageWithContent;

- (JUMPMessage *)generateReceiptResponse;

@end