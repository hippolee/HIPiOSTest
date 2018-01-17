//
//  JUMPPresence.h
//  YonyouIMSdk
//
//  Created by litfb on 15/4/27.
//  Copyright (c) 2015年 yonyou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JUMPPacket.h"

@interface JUMPPresence : JUMPPacket

// Converts an JUMPPacket to an JUMPPresence element in place (no memory allocations or copying)
+ (JUMPPresence *)presenceFromPacket:(JUMPPacket *)packet;

+ (JUMPPresence *)presenceWithOpData:(NSData *)opData;
+ (JUMPPresence *)presenceWithOpData:(NSData *)opData type:(NSString *)type;
+ (JUMPPresence *)presenceWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)to;

- (instancetype)initWithOpData:(NSData *)opData type:(NSString *)type;
- (instancetype)initWithOpData:(NSData *)opData type:(NSString *)type to:(JUMPJID *)to;

- (void)setType:(NSString *)type;

- (void)setShow:(NSString *)show;
- (void)setStatus:(NSString *)status;
- (void)setPriority:(NSInteger)priority;

- (void)setJid:(JUMPJID *)jid;
- (void)setRole:(NSString *)role;
- (void)setAffiliation:(NSString *)affiliation;

- (NSString *)type;

- (NSString *)show;
- (NSString *)status;
- (NSInteger)priority;

- (JUMPJID *)jid;
- (NSString *)role;
- (NSString *)affiliation;

- (int)intShow;

@end
