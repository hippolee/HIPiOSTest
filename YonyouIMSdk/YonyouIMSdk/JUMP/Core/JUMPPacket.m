//
//  JUMPPacket.m
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <objc/runtime.h>
#import "JUMPPacket.h"
#import "YYIMGZipUtility.h"

#define kInnerErrorCode1    10001
#define kInnerErrorCode2    10002
#define kInnerErrorMessage1 @"packet length mismatching"
#define kInnerErrorMessage2 @"packetdata can not be resolved"

static const Byte JUMPGZipHeaderBytes[] = {0x1f, 0x8b};

@interface JUMPPacket ()

@property (retain, nonatomic) JUMPHeader *header;

@property (retain, nonatomic) NSMutableDictionary *packetDic;

@end

@implementation JUMPPacket

- (instancetype)init {
    if (self = [super init]) {
        _header = [JUMPHeader header];
        _packetDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithOpData:(NSData *)opData {
    if (self = [self init]) {
        [self.header setOpData:opData];
    }
    return self;
}

- (instancetype)initWithHeader:(JUMPHeader *)header {
    if (self = [super init]) {
        if (header) {
            _header = header;
        } else {
            _header = [JUMPHeader header];
        }
        _packetDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)initWithBodyData:(NSData *)data header:(JUMPHeader *)header error:(NSError *__autoreleasing *)error {
    if (self = [self initWithHeader:header]) {
        int dataLength = data ? (int)data.length : 0;
        int packetLength = [header getPacketLength];
        if (dataLength != packetLength) {
            if (error) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                if (data) {
                    [userInfo setObject:data forKey:@"data"];
                }
                if (header) {
                    [userInfo setObject:header forKey:@"header"];
                }
                [userInfo setObject:kInnerErrorMessage1 forKey:@"message"];
                *error = [NSError errorWithDomain:@"JUMPPacket" code:kInnerErrorCode1 userInfo:userInfo];
            }
            return nil;
        }
        if (dataLength > 0) {
            NSData *tempData = [data subdataWithRange:NSMakeRange(0, 2)];
            
            NSData *bodyData;
            if ([tempData isEqualToData:[NSData dataWithBytes:JUMPGZipHeaderBytes length:2]]) {
                bodyData = [YYIMGZipUtility unGzipData:data];
            } else {
                bodyData = data;
            }
            
            if (!bodyData) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                if (data) {
                    [userInfo setObject:data forKey:@"data"];
                }
                if (header) {
                    [userInfo setObject:header forKey:@"header"];
                }
                [userInfo setObject:kInnerErrorMessage2 forKey:@"message"];
                *error = [NSError errorWithDomain:@"JUMPPacket" code:kInnerErrorCode2 userInfo:userInfo];
                return nil;
            }
            
            NSDictionary *contentDic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingMutableLeaves error:error];
            [_packetDic setDictionary:contentDic];
        }
    }
    return self;
}

- (instancetype)initWithPacketData:(NSData *)packetData error:(NSError *__autoreleasing *)error {
    NSData *headerData = [packetData subdataWithRange:NSMakeRange(0, 13)];
    JUMPHeader *header = [JUMPHeader headerWithData:headerData];
    NSData *bodyData;
    if (packetData.length > 13) {
        bodyData = [packetData subdataWithRange:NSMakeRange(13, packetData.length - 13)];
    }
    return [self initWithBodyData:bodyData header:header error:error];
}

- (NSData *)opData {
    return [self.header opData];
}

- (NSData *)packetData {
    NSData *jsonData = [self jsonData];
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self.header headerData:(int)jsonData.length]];
    [data appendData:jsonData];
    return data;
}

- (NSData *)gzipPacketData {
    NSData *gzipBodyData = [self gzipBodyData];
    NSMutableData *data = [NSMutableData data];
    [data appendData:[self.header headerData:(int)gzipBodyData.length]];
    [data appendData:gzipBodyData];
    return data;
}

- (NSData *)headerData {
    return [[self header] headerData];
}

- (NSData *)jsonData {
    if (self.packetDic.count > 0) {
        return [NSJSONSerialization dataWithJSONObject:self.packetDic options:NSJSONWritingPrettyPrinted error:nil];
    }
    return [NSData data];
}

- (NSData *)gzipBodyData {
    return [YYIMGZipUtility gzipData:[self jsonData]];
}

- (NSString *)jsonString {
    return [[NSString alloc] initWithData:[self jsonData] encoding:NSUTF8StringEncoding];
}

- (void)setObject:(id)anObject forKey:(id<NSCopying>)aKey {
    if (anObject) {
        [_packetDic setObject:anObject forKey:aKey];
    } else {
        [_packetDic removeObjectForKey:aKey];
    }
}

- (id)objectForKey:(id)aKey {
    return [_packetDic objectForKey:aKey];
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    [_packetDic setDictionary:otherDictionary];
}

#pragma mark Encoding, Decoding

- (id)initWithCoder:(NSCoder *)coder {
    NSData *packetData;
    if ([coder allowsKeyedCoding]) {
        packetData = [coder decodeObjectForKey:@"packetData"];
    } else {
        packetData = [coder decodeObject];
    }
    
    Class selfClass = [self class];
    if ((self = [self initWithPacketData:packetData error:nil])) {
        object_setClass(self, selfClass);
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    NSData *data = [self packetData];
    if([coder allowsKeyedCoding]) {
        [coder encodeObject:data forKey:@"packetData"];
    } else {
        [coder encodeObject:data];
    }
}

#pragma mark Copying

- (id)copyWithZone:(NSZone *)zone {
    JUMPPacket *packetCopy = [[JUMPPacket alloc] init];
    packetCopy->_header = [_header copy];
    packetCopy->_packetDic = [_packetDic copy];
    return packetCopy;
}

#pragma mark Common Methods

- (NSString *)packetID {
    return [self.packetDic objectForKey:@"id"];
}

- (NSString *)toStr {
    return [self.packetDic objectForKey:@"to"];
}

- (NSString *)fromStr {
    return [self.packetDic objectForKey:@"from"];
}

- (JUMPJID *)to {
    return [JUMPJID jidWithString:[self toStr]];
}

- (JUMPJID *)from {
    return [JUMPJID jidWithString:[self fromStr]];
}

- (void)setPacketID:(NSString *)packetID {
    [self.packetDic setObject:packetID forKey:@"id"];
}

- (void)setTo:(JUMPJID *)toJid {
    [self.packetDic setObject:[toJid full] forKey:@"to"];
}

- (void)setFrom:(JUMPJID *)fromJid {
    [self.packetDic setObject:[fromJid full] forKey:@"from"];
}

#pragma mark To and From Methods

- (BOOL)isTo:(JUMPJID *)to {
    return [self.to isEqualToJID:to];
}

- (BOOL)isTo:(JUMPJID *)to options:(JUMPJIDCompareOptions)mask {
    return [self.to isEqualToJID:to options:mask];
}

- (BOOL)isFrom:(JUMPJID *)from {
    return [self.from isEqualToJID:from];
}

- (BOOL)isFrom:(JUMPJID *)from options:(JUMPJIDCompareOptions)mask {
    return [self.from isEqualToJID:from options:mask];
}

- (BOOL)isToOrFrom:(JUMPJID *)toOrFrom {
    if([self isTo:toOrFrom] || [self isFrom:toOrFrom]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isToOrFrom:(JUMPJID *)toOrFrom options:(JUMPJIDCompareOptions)mask {
    if([self isTo:toOrFrom options:mask] || [self isFrom:toOrFrom options:mask]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isTo:(JUMPJID *)to from:(JUMPJID *)from {
    if([self isTo:to] && [self isFrom:from]) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isTo:(JUMPJID *)to from:(JUMPJID *)from options:(JUMPJIDCompareOptions)mask {
    if([self isTo:to options:mask] && [self isFrom:from options:mask]) {
        return YES;
    } else {
        return NO;
    }
}

#pragma mark judge

- (BOOL)isAuthPacket {
    return [self.header isAuthHeader];
}

- (BOOL)isPingPacket {
    return [self.header isPingHeader];
}

- (BOOL)isIqPacket {
    return [self.header isIqHeader];
}

- (BOOL)isMessagePacket {
    return [self.header isMessageHeader];
}

- (BOOL)isPresencePacket {
    return [self.header isPresenceHeader];
}

- (BOOL)isErrorPacket {
    return [self.header isErrorHeader];
}

- (BOOL)isStreamError {
    return [self.header isStremErrorHeader];
}

- (BOOL)isPacketError {
    return [self.header isPacketErrorHeader];
}

- (BOOL)checkOpData:(NSData *)opData {
    return [self.header checkOpData:opData];
}

@end