//
//  JUMPHeader.h
//  YonyouIMSdk
//
//  Created by litfb on 15/5/5.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define JUMP_OPDATA(bytes) [NSData dataWithBytes:bytes length:2]

@interface JUMPHeader : NSObject<NSCopying>

@property (retain, nonatomic) NSData *finData;
@property (retain, nonatomic) NSData *opData;
@property (retain, nonatomic) NSData *lenData;
@property (retain, nonatomic) NSData *verData;
@property (retain, nonatomic) NSData *seqData;

+ (instancetype)header;

+ (instancetype)headerWithData:(NSData *)data;

- (NSData *)headerData;

- (NSData *)headerData:(int)packetLength;

- (void)setPacketLength:(int)packetLength;

- (int)getPacketLength;

#pragma mark judge

- (BOOL)checkHeader;

- (BOOL)isAuthHeader;

- (BOOL)isPingHeader;

- (BOOL)isIqHeader;

- (BOOL)isMessageHeader;

- (BOOL)isPresenceHeader;

- (BOOL)isErrorHeader;

- (BOOL)isStremErrorHeader;

- (BOOL)isPacketErrorHeader;

- (BOOL)checkOpData:(NSData *)opData;

@end
