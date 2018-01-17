//
//  JUMPHeader.m
//  YonyouIMSdk
//
//  Created by litfb on 15/5/5.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import "JUMPHeader.h"

static const Byte kHeaderFin[] = {0x00};
static const Byte kHeaderVer[] = {0x01, 0x00};

@implementation JUMPHeader

+ (instancetype)header {
    return [[JUMPHeader alloc] init];
}

+ (instancetype)headerWithData:(NSData *)data {
    return [[JUMPHeader alloc] initWithData:data];
}

- (instancetype)init {
    if (self = [super init]) {
        _finData = [NSData dataWithBytes:kHeaderFin length:1];
        _verData = [NSData dataWithBytes:kHeaderVer length:2];
        Byte seq[] = {0x00, 0x00, 0x00, 0x00};
        _seqData = [NSData dataWithBytes:seq length:4];
    }
    return self;
}

- (instancetype)initWithData:(NSData *)data {
    if (self = [super init]) {
        [self setFinData:[data subdataWithRange:NSMakeRange(0, 1)]];
        [self setOpData:[data subdataWithRange:NSMakeRange(1, 2)]];
        [self setLenData:[data subdataWithRange:NSMakeRange(3, 4)]];
        [self setVerData:[data subdataWithRange:NSMakeRange(7, 2)]];
        [self setSeqData:[data subdataWithRange:NSMakeRange(9, 4)]];
    }
    return self;
}

- (NSData *)headerData {
    NSMutableData *data = [NSMutableData data];
    [data appendData:_finData];
    [data appendData:_opData];
    [data appendData:_lenData];
    [data appendData:_verData];
    [data appendData:_seqData];
    return data;
}

- (NSData *)headerData:(int)packetLength {
    [self setPacketLength:packetLength];
    return [self headerData];
}

- (void)setPacketLength:(int)packetLength {
    NSData *data = [[self class] intToData:packetLength];
    [self setLenData:data];
}

- (int)getPacketLength {
    Byte bytes[4];
    [_lenData getBytes:bytes length:4];
    return [[self class] byteToInt:bytes];
}

#pragma mark judge

- (BOOL)checkHeader {
    BOOL finEqual = [self.finData isEqualToData:[NSData dataWithBytes:kHeaderFin length:1]];
    return finEqual;
}

- (BOOL)isAuthHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] == 0x00 && bytes[1] == 0x01) {
        return YES;
    }
    return NO;
}

- (BOOL)isPingHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] == 0x00 && bytes[1] == 0x02) {
        return YES;
    }
    return NO;
}

- (BOOL)isIqHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] >= 0x20 && bytes[0] <= 0x2f) {
        return YES;
    }
    return NO;
}

- (BOOL)isMessageHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] >= 0x10 && bytes[0] <= 0x1f) {
        return YES;
    }
    return NO;
}

- (BOOL)isPresenceHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] >= 0x30 && bytes[0] <= 0x3f) {
        return YES;
    }
    return NO;
}

- (BOOL)isErrorHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] >= 0x40 && bytes[0] <= 0x4f) {
        return YES;
    }
    return NO;
}

- (BOOL)isStremErrorHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] == 0x41) {
        return YES;
    }
    return NO;
}

- (BOOL)isPacketErrorHeader {
    Byte bytes[2];
    [_opData getBytes:bytes length:2];
    if (bytes[0] == 0x40) {
        return YES;
    }
    return NO;
}

- (BOOL)checkOpData:(NSData *)opData {
    return [_opData isEqualToData:opData];
}

#pragma mark copying

- (id)copyWithZone:(NSZone *)zone {
    JUMPHeader *headerCopy = [[JUMPHeader alloc] init];
    headerCopy->_finData = [_finData copy];
    headerCopy->_opData = [_opData copy];
    headerCopy->_lenData = [_lenData copy];
    headerCopy->_verData = [_verData copy];
    headerCopy->_seqData = [_seqData copy];
    return headerCopy;
}

#pragma mark private func

+ (NSData *)intToData:(int)intVal {
    NSMutableData *data = [NSMutableData dataWithCapacity:4];
    char byte3 = intVal & 0x000000ff;
    intVal = intVal >> 8;
    char byte2 = intVal & 0x000000ff;
    intVal = intVal >> 8;
    char byte1 = intVal & 0x000000ff;
    intVal = intVal >> 8;
    char byte0 = intVal & 0x000000ff;
    
    [data appendBytes:&byte0 length:1];
    [data appendBytes:&byte1 length:1];
    [data appendBytes:&byte2 length:1];
    [data appendBytes:&byte3 length:1];
    return data;
}

+ (int)byteToInt:(Byte[4])bytes {
    int n = (int)bytes[0] << 24;
    n |= (int)bytes[1] << 16;
    n |= (int)bytes[2] << 8;
    n |= (int)bytes[3];
    return n;
}

@end
